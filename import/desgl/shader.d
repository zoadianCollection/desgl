module gesgl.shader;

import gesmath.types.vector,
       gesmath.types.matrix;

import std.conv : to;
import std.string : format;

import derelict.opengl3.gl3;

private pure string castArgsString(S,string data,T...)()
{
    string ret = "";
    foreach( i, type; T )
    {
        if( is( T == S ) ) ret ~= format( "%s[%d]", data, i );
        else ret ~= format( "cast(%s)%s[%d]", S.stringof, data, i );
        ret ~= ",";
    }

    return ret[0 .. $-1];
}

private pure string glPostfix(S)()
{
         static if( is( S == float ) ) return "f";
    else static if( is( S == int ) )   return "i";
    else static if( is( S == uint ) )  return "ui";
    else return "";
}

private pure bool checkUnifrom(S,T...)()
{
    if( glPostfix!S == "" ) return false;
    if( T.length < 1 || T.length > 4 ) return false;
    foreach( t; T ) if( !is( T : S ) ) return false;
    return true;
}

unittest
{
    string getFloats(string data,T...)( in T vals )
    { return castArgsString!(float,data,vals)(); }

    assert( getFloats!"v"( 1.0f, 2u, -3 ) == "v[0],cast(float)v[1],cast(float)v[2]" );
}

struct ShaderSource { string vert, frag, geom; }

class ShaderException: Exception { this( string msg ) { super( msg ); } }

class ShaderProgram
{
private:
    static GLint inUse = -1;

    GLuint vert_sh = 0,
           geom_sh = 0,
           frag_sh = 0;

    GLuint program = 0;

    static GLuint makeShader( GLenum type, string src )
    {
        GLuint shader = glCreateShader( type );
        glShaderSource( shader, 1, &(src.ptr), null );
        glCompileShader( shader );

        int res;
        glGetShaderiv( shader, GL_COMPILE_STATUS, &res );
        if( res == GL_FALSE )
        {
            int logLen;
            glGetShaderiv( shader, GL_INFO_LOG_LENGTH, &logLen );
            if( logLen > 0 )
            {
                auto chlog = new char[logLen];
                glGetShaderInfoLog( shader, logLen, &logLen, chlog.ptr );
                throw new ShaderException( "shader compile error: \n" ~ chlog.idup );
            }
        }

        return shader;
    }

    static void checkProgram( GLuint prog )
    {
        int res;
        glGetProgramiv( prog, GL_LINK_STATUS, &res );
        if( res == GL_FALSE )
        {
            int logLen;
            glGetProgramiv( prog, GL_INFO_LOG_LENGTH, &logLen );
            if( logLen > 0 )
            {
                auto chlog = new char[logLen];
                glGetProgramInfoLog( prog, logLen, &logLen, chlog.ptr );
                throw new ShaderException( "program link error: \n" ~ chlog.idup );
            }
        }
    }

    void destruct()
    {
        if( inUse == program ) glUseProgram(0);
        glDetachShader( program, frag_sh );
        if( geom_sh ) glDetachShader( program, geom_sh );
        glDetachShader( program, vert_sh );

        glDeleteProgram( program );

        glDeleteShader( frag_sh );
        if( geom_sh ) glDeleteShader( geom_sh );
        glDeleteShader( vert_sh );
    }

    void construct( in ShaderSource src )
    {
        if( src.vert.length == 0 ) 
            throw new ShaderException( "vertex shader source is empty" );
        if( src.frag.length == 0 ) 
            throw new ShaderException( "fragment shader source is empty" );

        program = glCreateProgram();

        vert_sh = makeShader( GL_VERTEX_SHADER, src.vert );
        if( src.geom.length )
            geom_sh = makeShader( GL_GEOMETRY_SHADER, src.frag );
        frag_sh = makeShader( GL_FRAGMENT_SHADER, src.frag );

        glAttachShader( program, vert_sh );
        if( geom_sh )
            glAttachShader( program, geom_sh );
        glAttachShader( program, frag_sh );

        glLinkProgram( program );
        checkProgram( program );
    }

    void checkLocation( int loc )
    { 
        if( loc < 0 ) 
            throw new ShaderException( "bad location: " ~ to!string(loc) ); 
    }

public:
    this( in ShaderSource src ) { construct( src ); }
    ~this() { destroy(); }

    final void use()
    {
        if( inUse == program ) return;
        glUseProgram( program );
        inUse = program;
    }

    int getAttribLocation( string name )
    { return glGetAttribLocation( program, name.ptr ); }

    int getUniformLocation( string name )
    { return glGetUniformLocation( program, name.ptr ); }

    void setUniform(S,T...)( int loc, T vals ) 
        if( checkUnifrom!(S,T) )
    {
        checkLocation( loc ); use();
        mixin( "glUniform" ~ to!string(T.length) ~ glPostfix!S ~ "( loc, " ~ 
                castArgsString!(S,"vals",T) ~ " );" );
    }

    void setUniform(S,T...)( string name, T vals ) 
        if( checkUnifrom!(S,T) )
    { setUniform!S( getUniformLocation( name ), vals ); }

    void setUniformArr(size_t sz,T)( int loc, in T[] vals )
        if( sz > 0 && sz < 5 && (glPostfix!T).length != 0 )
    {
        checkLocation( loc );
        auto cnt = vals.length / sz;
        use();
        mixin( "glUniform" ~ to!string(sz) ~ glPostfix!T ~ 
                "v( loc, cast(int)cnt, vlas.ptr );" );
    }

    void setUniformArr(size_t sz,T)( string name, in T[] vals )
        if( sz > 0 && sz < 5 && (glPostfix!T).length != 0 )
    { setUniformArr!sz( getUniformLocation( name ), vals ); }

    void setUniformVec(size_t N,T,string AS)( int loc, vec!(N,T,AS)[] vals... )
        if( N > 0 && N < 5 && (glPostfix!T).length != 0 )
    {
        checkLoc( loc ); 
        auto cnt = vals.length;
        use();
        mixin( "glUniform" ~ to!string(sz) ~ glPostfix!T ~ 
                "v( loc, cast(int)cnt, cast(" ~ T.stringof ~ "*)vals.ptr );" );
    }

    void setUniformVec(size_t N,T,string AS)( string name, vec!(N,T,AS)[] vals... )
        if( N > 0 && N < 5 && (glPostfix!T).length != 0 )
    { setUniformVec( getUniformLocation( name ), vals ); }
    
    void setUniformMat(size_t h, size_t w)( int loc, in mat!(h,w,float)[] mtr... )
        if( h <= 4 && w <= 4 )
    {
        checkLoc( loc );
        use();
        static if( w == h )
            mixin( "glUniformMatrix" ~ to!string(w) ~ 
                    "fv( loc, cast(int)mtr.length, GL_TRUE, cast(float*)mtr.ptr ); " );
        else
            mixin( "glUniformMatrix" ~ to!string(h) ~ "x" ~ to!string(w) ~
                    "fv( loc, cast(int)mtr.length GL_TRUE, cast(float*)mtr.ptr ); " );
    }

    void setUniformMat(size_t h, size_t w)( string name, in mat!(h,w,float)[] mtr... )
        if( h <= 4 && w <= 4 )
    { setUniformMat( getUniformLocation( name ), mtr ); }
}
