/+
The MIT License (MIT)

    Copyright (c) <2013> <Oleg Butko (deviator), Anton Akzhigitov (Akzwar)>

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
+/

module desgl.fbo;

import derelict.opengl3.gl3;

import desmath.types.vector;
import desmath.types.rect;
import desutil.signal;

public import desgl.shader;
import desgl.object;
import desgl.helpers;

import desutil.logger;
mixin( PrivateLoggerMixin );

class GLFBOException : Exception 
{ @safe pure nothrow this( string msg ){ super( msg ); } }

class GLFBO
{
private:
    uint texID;
    uint rboID;
    uint fboID;

    static uint[] fboStack;

    static this()
    {
        fboStack ~= 0;
    }

    vec!(2,int,"wh") sz;

public:

    alias const ref ivec2 in_ivec2;
    Signal!in_ivec2 resize;
    SignalBoxNoArgs draw;

    this()
    {
        sz = ivec2( 1, 1 );

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
        glGenerateMipmap(GL_TEXTURE_2D);
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

        debug log( "create FBO [fbo:%d], [rbo:%d], [tex:%d]", fboID, rboID, texID );

        resize.connect( (nsz)
        {
            sz = nsz;

            debug log( "reshape FBO: [ %d x %d ]", sz.w, sz.h );

            glBindTexture( GL_TEXTURE_2D, texID );
            glTexImage2D( GL_TEXTURE_2D, 0, 4, sz.w, sz.h, 0, GL_RGBA, 
                          GL_UNSIGNED_BYTE, null );
            glGenerateMipmap(GL_TEXTURE_2D);
            glBindTexture( GL_TEXTURE_2D, 0 );

            glBindRenderbuffer( GL_RENDERBUFFER, rboID );
            glRenderbufferStorage( GL_RENDERBUFFER, GL_DEPTH_COMPONENT, sz.w, sz.h );
            glBindRenderbuffer( GL_RENDERBUFFER, 0 );
        });

        resize( ivec2(1,1) );
    }

    final nothrow void bind() 
    { 
        glBindFramebuffer( GL_FRAMEBUFFER, fboID ); 
        fboStack ~= fboID;
    }
    final nothrow void unbind() 
    { 
        if( fboStack.length > 1 )
        {
            glBindFramebuffer( GL_FRAMEBUFFER, fboStack[$-2] ); 
            fboStack = fboStack[ 0 .. $-1 ];
        }

        //glBindFramebuffer( GL_FRAMEBUFFER, 0 ); 
    }

    final nothrow void bindTexture() { glBindTexture( GL_TEXTURE_2D, texID ); }
    final nothrow void unbindTexture() { glBindTexture( GL_TEXTURE_2D, 0 ); }

    struct ImageData
    {
        ivec2 size;
        ubyte[] data;
    }

    final ImageData getImage( uint level=0, GLenum fmt=GL_RGB, GLenum rtype=GL_UNSIGNED_BYTE )
    {
        bindTexture();
        if( level ) glGenerateMipmap(GL_TEXTURE_2D);
        debug checkGL;
        ImageData img;
        int w, h;
        glGetTexLevelParameteriv( GL_TEXTURE_2D, level, GL_TEXTURE_WIDTH, &(w));
        debug checkGL;
        glGetTexLevelParameteriv( GL_TEXTURE_2D, level, GL_TEXTURE_HEIGHT, &(h));
        img.size = ivec2( w, h );
        debug checkGL;

        import std.string;
        size_t elemSize = 1;
        switch(fmt)
        {
            case GL_RED:
            case GL_GREEN: 
            case GL_BLUE: 
                break;
            case GL_RG: 
                elemSize *= 2;
                break;
            case GL_RGB: 
            case GL_BGR: 
                elemSize *= 3;
                break;
            case GL_RGBA: 
            case GL_BGRA:
                elemSize *= 4;
                break;
            default:
                throw new GLFBOException( format( "FBO.getImage not support format %s", fmt ) );
        }

        switch(rtype)
        {
            case GL_UNSIGNED_BYTE: 
            case GL_BYTE: 
                break;
            case GL_UNSIGNED_SHORT: 
            case GL_SHORT: 
                elemSize *= short.sizeof;
                break;
            case GL_UNSIGNED_INT:
            case GL_INT: 
                elemSize *= int.sizeof;
                break;
            case GL_FLOAT:
                elemSize *= float.sizeof;
                break;
            default:
                throw new GLFBOException( format( "FBO.getImage not support type %s", rtype ) );
        }

        img.data.length = img.size.x * img.size.y * elemSize;

        glGetTexImage( GL_TEXTURE_2D, level, fmt, rtype, img.data.ptr );
        debug checkGL;
        unbindTexture();
        debug checkGL;

        return img;
    }

    nothrow @property auto size() const { return sz; }

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
    GLFBO fbo;
    TexturedRect!() obj;

    SignalBox!Args render, draw;

    this( int posloc, int uvloc )
    {
        fbo = new GLFBO;

        obj = new TexturedRect!()( posloc, uvloc );

        render.addBegin( (Args a) { fbo.bind(); } );
        render.addEnd( (Args a) { fbo.unbind(); } );

        draw.addBegin( (Args a) { fbo.bindTexture(); });
        draw.connect( (Args a) { obj.draw(); } );
    }
}
