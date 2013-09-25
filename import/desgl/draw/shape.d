module desgl.draw.shape;

import derelict.opengl3.gl3;

import desmath.types.vector;
import desmath.types.rect;

import desgl.object;
import desgl.texture;

alias vrect!int irect;

import desutil.signal;

class UIDrawObj: GLObj!()
{
protected:
    GLTexture2D tex;
    int use_tex = 0;

public:
    this( ShaderProgram sp )
    {
        super( sp );
        tex = new GLTexture2D;
        draw.addBegin( ()
        { 
            shader.setUniform!int( "use_texture", use_tex );
            shader.setUniform!int( "ttu", GL_TEXTURE0 );
            if( use_tex ) tex.bind();
        });
    }

    abstract void setColor( in col4 );
    abstract void reshape( in irect );

    final void notUseTexture(){ use_tex = 0; }

    final void alphaImg(T,E)( in T sz, in E[] data )
        if( isCompVector!(2,int,T) && ( is( E == ubyte ) || is( E == float ) ) )
    {
        static if( is( E == ubyte ) ) enum type = GL_UNSIGNED_BYTE;
        else
        static if( is( E == float ) ) enum type = GL_FLOAT;

        tex.image( sz, GL_RED, GL_RED, type, data.ptr ); 
        use_tex = 1;
    }

    final void colorImg(T,size_t N,E,string as)( in T sz, in vec!(N,E,as)[] data )
        if( isCompVector!(2,int,T) && ( N == 3 || N == 4 ) && 
                ( is( E == ubyte ) || is( E == float ) )  )
    {
        static if( is( E == ubyte ) ) enum type = GL_UNSIGNED_BYTE;
        else static if( is( E == float ) ) enum type = GL_FLOAT;

        static if( N == 3 ) enum fmt = GL_RGB;
        else static if( N == 4 ) enum fmt = GL_RGBA;

        tex.image( sz, fmt, fmt, type, data.ptr ); 
        use_tex = 2;
    }

    final void rawImg(T,E)( in T sz, int texfmt, GLenum datafmt, GLenum datatype, in E* data )
        if( isCompVector!(2,int,T) )
    {
        tex.image( sz, texfmt, datafmt, datatype, data );
        use_tex = 2;
    }
}

class Shape
{
protected:

    abstract void prepare( ShaderProgram );

public:

    UIDrawObj fill, cont;

    this( ShaderProgram sp )
    {
        prepare( sp );

        draw.connect( () 
        {
            fill.draw();
            cont.draw();
        });
    }

    final void reshape( in irect r ) 
    { 
        fill.reshape( r );
        cont.reshape( r );
    }

    SignalBoxNoArgs draw;
}
