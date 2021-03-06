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

module desgl.helpers;

import derelict.opengl3.gl3;

import desutil.logger;
import desutil.helpers;
mixin( PrivateLoggerMixin );

nothrow void checkGL( bool except=false, string md=__FILE__, int ln=__LINE__ )
{
    import std.string : format;
    import std.stdio : stderr;
    auto err = glGetError();
    try 
    {
        if( err != GL_NO_ERROR )
        {
            auto errstr = format( " ## GL ERROR ## %s at line: %s: 0x%04x", md, ln, err );
            if( except ) throw new Exception( errstr );
            else stderr.writefln( errstr );
        }
        else{ log( "GL OK %s at line: %s", md, ln ); }
    } 
    catch( Exception e )
    {
        try stderr.writeln( e );
        catch( Exception ee ) {}
    }
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

    irect sub( in irect vp )
    {
        auto cvp = current.viewport;
        auto csc = current.scissor;

        irect nvp;
        nvp.x = cvp.x + vp.x;
        nvp.y = cvp.y + cvp.h - ( vp.y + vp.h );
        nvp.w = vp.w;
        nvp.h = vp.h;

        irect nsc = csc.overlap( nvp );

        irect locsc;
        locsc.x = nsc.x - nvp.x;
        locsc.y = nvp.y + nvp.h - nsc.y - nsc.h;
        locsc.w = nsc.w;
        locsc.h = nsc.h;

        current.viewport = nvp;
        current.scissor = nsc;
        update();

        return locsc;
    }

    void set( in irect vp )
    {
        current.viewport = vp;
        current.scissor = vp;
        update();
    }

    void setClear( in irect vp )
    {
        states.length = 0;
        set( vp );
    }
}
