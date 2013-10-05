module desgl.fbo;

import derelict.opengl3.gl3;

import desmath.types.vector;
import desmath.types.rect;
import desutil.signal;

public import desgl.shader;
import desgl.object;

import desutil.logger;
debug mixin( LoggerPrivateMixin( "glfbo", __MODULE__ ) );

class GLFBOException : Exception { this( string msg ){ super( msg ); } }

class GLFBO
{
private:

    static int currentUseTexID = -1;
    static void set_tex_to_use( uint ntex )
    {
        currentUseTexID = ntex;
    }

    uint texID;
    uint rboID;
    uint fboID;

    vec!(2,int,"wh") sz;

public:

    Signal!ivec2 resize;
    SignalBoxNoArgs draw;

    this()
    {
        sz = ivec2( 256, 256 );

        // Texture 
        glGenTextures( 1, &texID );
        glBindTexture( GL_TEXTURE_2D, texID );
        glTexParameterf( GL_TEXTURE_2D, 
                         GL_TEXTURE_MAG_FILTER, GL_LINEAR );
        glTexParameterf( GL_TEXTURE_2D, 
                         GL_TEXTURE_MIN_FILTER, GL_LINEAR );
        glTexParameterf( GL_TEXTURE_2D, 
                         GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
        glTexParameterf( GL_TEXTURE_2D, 
                         GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
        glTexImage2D( GL_TEXTURE_2D, 0, 4, sz.w, sz.h, 0, GL_RGBA, 
                      GL_UNSIGNED_BYTE, null );
        glBindTexture( GL_TEXTURE_2D, 0 );

        // Render buffer
        glGenRenderbuffers( 1, &rboID );
        glBindRenderbuffer( GL_RENDERBUFFER, rboID );
        glRenderbufferStorage( GL_RENDERBUFFER, GL_DEPTH_COMPONENT24, sz.w, sz.h );
        glBindRenderbuffer( GL_RENDERBUFFER, 0 );

        // Frame buffer
        glGenFramebuffers( 1, &fboID );
        glBindFramebuffer( GL_FRAMEBUFFER, fboID );
        glFramebufferTexture2D( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                                GL_TEXTURE_2D, texID, 0 );
        glFramebufferRenderbuffer( GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, 
                                   GL_RENDERBUFFER, rboID );

        GLenum status = glCheckFramebufferStatus( GL_FRAMEBUFFER );
        if( status != GL_FRAMEBUFFER_COMPLETE )
            throw new GLFBOException( "status isn't GL_FRAMEBUFFER_COMPLETE" );

        glBindFramebuffer( GL_FRAMEBUFFER, 0 );

        debug import std.string;
        debug log( format("create FBO [fbo:%d], [rbo:%d], [tex:%d]", fboID, rboID, texID ) );

        resize.connect( (nsz)
        {
            sz = nsz;

            debug log( "reshape FBO: [", sz.w, " ", sz.h, "]" );

            glBindTexture( GL_TEXTURE_2D, texID );
            glTexImage2D( GL_TEXTURE_2D, 0, 4, sz.w, sz.h, 0, GL_RGBA, 
                          GL_UNSIGNED_BYTE, null );
            glBindTexture( GL_TEXTURE_2D, 0 );

            glBindRenderbuffer( GL_RENDERBUFFER, rboID );
            glRenderbufferStorage( GL_RENDERBUFFER, GL_DEPTH_COMPONENT, sz.w, sz.h );
            glBindRenderbuffer( GL_RENDERBUFFER, 0 );
        });

        resize( ivec2(1,1) );
    }

    final nothrow void bind() { glBindFramebuffer( GL_FRAMEBUFFER, fboID ); }
    final nothrow void unbind() { glBindFramebuffer( GL_FRAMEBUFFER, 0 ); }

    final nothrow void bindTexture() { glBindTexture( GL_TEXTURE_2D, texID ); }
    final nothrow void unbindTexture() { glBindTexture( GL_TEXTURE_2D, 0 ); }

    @property nothrow auto size() const { return sz; }

    ~this()
    {
        unbind();
        unbindTexture();
        glDeleteFramebuffers( 1, &fboID );
        glDeleteRenderbuffers( 1, &rboID );
        glDeleteTextures( 1, &texID );
    }
}

import desgl.draw.rectshape;

class GLFBODraw(Args...)
{
protected:
    GLFBO fbo;

    TexturedRect obj;

    ShaderProgram fx;
public:

    Signal!in_irect reshape;
    SignalBoxNoArgs render, draw;

    this( ShaderProgram shader, int posloc, int uvloc, 
                            int wszloc, int ttuloc )
    {
        glActiveTexture( GL_TEXTURE0 );
        fbo = new GLFBO;
        fx = shader;

        obj = new TexturedRect( posloc, uvloc );

        render.addBegin( (Args a) { fbo.bind(); } );
        render.addEnd( (Args args) { fbo.unbind(); } );

        draw.connect( () 
        {
            fx.use();
            fx.setUniform!int( ttuloc, GL_TEXTURE0 );
            fbo.bindTexture();
            obj.draw();
        });

        reshape.connect( (r)
        { 
            fbo.resize( r.size ); 
            obj.reshape( r );
            fx.setUniformVec( wszloc, vec2( fbo.size ) );
        } );
    }
}
