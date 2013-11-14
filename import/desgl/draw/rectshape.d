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

module desgl.draw.rectshape;

import derelict.opengl3.gl3;

import desmath.types.vector,
       desmath.types.rect;

import desgl.object;
import desgl.helpers;

import desutil.signal;

alias vrect!int irect;
alias const ref irect in_irect;

import desutil.logger;
mixin( PrivateLoggerMixin );

class SimpleRect(Args...): GLObj!Args
{
    protected GLVBO pos;
    protected irect last_rect;

    Signal!in_irect reshape;

    nothrow @property irect rect() const { return last_rect; }

    this( int posloc )
    {
        pos = new GLVBO( [ 0.0f, 0, 1, 0, 0, 1, 1, 1 ] );
        setAttribPointer( pos, posloc, 2, GL_FLOAT );

        reshape.connect( (r) 
        { 
            last_rect = r; 
            pos.setData( r.points!float ); 
        });

        draw.connect( ( Args args ) { glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 ); } );
    }
}

class TexturedRect(Args...): SimpleRect!Args
{
    protected GLVBO uv;
    this( int posloc, int uvloc ) 
    { 
        super( posloc );
        uv = new GLVBO( [ 0.0f, 0, 1, 0, 0, 1, 1, 1 ], 
                        GL_ARRAY_BUFFER, GL_STATIC_DRAW );
        setAttribPointer( uv, uvloc, 2, GL_FLOAT );
    }
}

class ColorRect(Args...): SimpleRect!Args
{
    protected GLVBO col;
    this( int posloc, int colloc )
    {
        super( posloc );
        col = new GLVBO( dataArray( 4, col4(1,1,1,1) ) );
        setAttribPointer( col, colloc, 4, GL_FLOAT );
    }

    void setColor( in col4 v )
    { col.setData( dataArray( 4, v) ); }

    void setColor( in col4[4] v )
    { col.setData( dataArray(v) ); }
}

class ColorTexRect(Args...): ColorRect!Args
{
    protected GLVBO col, uv;
    this( int posloc, int colloc, int uvloc )
    {
        super( posloc, colloc );
        uv = new GLVBO( [ 0.0f, 0, 1, 0, 0, 1, 1, 1 ], 
                        GL_ARRAY_BUFFER, GL_STATIC_DRAW );
        setAttribPointer( uv, uvloc, 2, GL_FLOAT );
    }
}
