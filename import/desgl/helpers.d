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
    } 
    catch( Exception e ){}
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

import desmath.types.rect;
import std.array;

class ViewportStateCtrl
{
private:
    struct PRect { irect viewport, scissor; }

    PRect[] states;
    PRect current;

    void update()
    {
        auto vp = current.viewport;
        auto sc = current.scissor;
        glViewport( vp.x,vp.y,vp.w,vp.h );
        glScissor( sc.x,sc.y,sc.w,sc.h );
    }

    nothrow static void setFromGL( ref PRect rr )
    {
        glGetIntegerv( GL_VIEWPORT, rr.viewport.vec_rect.data.ptr );
        glGetIntegerv( GL_SCISSOR_BOX, rr.scissor.vec_rect.data.ptr );
    }

public:

    this( in irect init ) { set( init ); }
    this(){ setFromGL( current ); }

    void push() { states ~= current; }

    void pull()
    {
        if( !states.empty )
        {
            current = states.back();
            states.popBack();
        }
        update();
    }

    uint sub( in irect vp )
    {
        auto cvp = current.viewport;
        auto csc = current.scissor;

        irect nvp;
        nvp.x = cvp.x + vp.x;
        nvp.y = cvp.y + cvp.h - ( vp.y + vp.h );
        nvp.w = vp.w;
        nvp.h = vp.h;

        current.viewport = nvp;
        current.scissor = csc.overlap( nvp );

        update();

        return current.scissor.area;
    }

    void set( in irect vp )
    {
        current.viewport = vp;
        current.scissor = vp;
        update();
    }
}