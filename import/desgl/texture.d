module desgl.texture;

public import derelict.opengl3.gl3;

import desgl.helpers;

import desmath.types.vector;

class TextureException: Exception { this( string msg ){ super( msg ); } }

private @property string accessVecFields(T,string name)()
    if( isVector!T )
{
    import std.string : format;
    string ret;
    foreach( i; 0 .. T.length )
        ret ~= format( "%s[%d],", name, i );
    return ret[0 .. $-1];
}

class GLTexture(ubyte DIM)
    if( DIM == 1 || DIM == 2 || DIM == 3 )
{
    import std.string : format;

    private uint texID;
    protected texsize sz;

    mixin( format( "enum GLenum type = GL_TEXTURE_%1dD;", DIM ) );
    alias vec!(DIM,int,"whd"[0 .. DIM]) texsize; 

    this()
    {
        glGenTextures( 1, &texID );
        debug checkGL;
        bind(); scope(exit) unbind();
        debug checkGL;

        parameteri( GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
        parameteri( GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
        parameteri( GL_TEXTURE_MAG_FILTER, GL_LINEAR );
        parameteri( GL_TEXTURE_MIN_FILTER, GL_LINEAR );

        debug checkGL;
    }

    /+ TODO
        разных функций ярких и много!
     +/
    final void parameteri( GLenum param, int val )
    { 
        bind(); scope(exit) unbind();
        glTexParameteri( type, param, val ); 
    }

    final nothrow void bind()   { glBindTexture( type, texID ); }
    static nothrow void unbind() { glBindTexture( type, 0 ); }

    final @property texsize size() const { return sz; }

    final void image(T,E)( in T nsz, int texfmt, GLenum datafmt, GLenum datatype, in E* data )
        if( isCompVector!(DIM,int,T) )
    {
        sz = nsz;
        bind();
        mixin( format( "glTexImage%1dD( type, 0, texfmt, %s, 0, datafmt, datatype, cast(void*)data );",
                    DIM, accessVecFields!(T,"sz") ) );
        debug checkGL;
    }

    ~this()
    {
        unbind();
        glDeleteTextures( 1, &texID );

        debug checkGL;
    }
}

alias GLTexture!2 GLTexture2D;
