module desgl.helpers;

import derelict.opengl3.gl3;

import desutil.logger;
debug mixin( LoggerPrivateMixin( "glhelper", __MODULE__ ) );

nothrow @property void checkGL( string md=__FILE__, int ln=__LINE__ )
{
    auto err = glGetError();
    try 
    {
    if( err != GL_NO_ERROR )
    {
        import std.stdio : stderr;
        stderr.writefln( " ## GL ERROR ## %s at line: %s: 0x%04x", md, ln, err );
    }
    else
    {
        import std.string : format;
        debug log.trace( format( "GL OK %s at line: %s", md, ln ) );
    }
    } catch( Exception e ){}
}

pure nothrow string toDString( const(char*) c_str )
{
    string buf;
    char *ch = cast(char*)c_str;
    while( *ch != '\0' ) buf ~= *(ch++);
    return buf;
}

pure nothrow string toDStringFix(size_t S)( const(char[S]) c_buf )
{
    string buf;
    foreach( c; c_buf ) buf ~= c;
    return buf;
}

import desmath.types.vector;

pure nothrow T[] dataArray(size_t N, T, string AS)( size_t cnt, in vec!(N,T,AS) v )
{ 
    T[] ret;
    foreach( i; 0 .. cnt ) ret ~= v.data;
    return ret;
}

pure nothrow T[] dataArray(size_t N, T, string AS)( in vec!(N,T,AS)[] arr... )
{ 
    T[] ret;
    foreach( v; arr ) ret ~= v.data;
    return ret;
}

