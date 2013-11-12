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

module desgl.draw.vfield;

import derelict.opengl3.gl3;

import desmath.types.vector;
public import desmath.types.special : posvec;

import desgl.object;

class VField: GLObj!()
{
    protected size_t vcnt=0;
    protected GLVBO pos;

    this( int posloc )
    {
        pos = new GLVBO( [ 0.0f, 0.0f ], GL_ARRAY_BUFFER, GL_DYNAMIC_DRAW );
        setAttribPointer( pos, posloc, 2, GL_FLOAT );
        draw.connect( (){ glDrawArrays( GL_LINES, 0, cast(int)vcnt ); } );
    }

    struct ArrowInfo
    {
        bool use = false;
        bool absoluteSize = true;
        float size = 10;
        float angle = 0.3;
    }

    ArrowInfo arrow;

    void setCoords( in posvec!2[] data... ) 
    { 
        void setSimpleCoords( in posvec!2[] info )
        {
            vec2[] ndt;
            foreach( pv; info )
            {
                ndt ~= pv.pos;
                ndt ~= pv.pos + pv.val;
            }
            pos.setData( ndt ); 
            vcnt = ndt.length;
        }

        if( !arrow.use ) setSimpleCoords( data );
        else
        {
            posvec!2[] ndt;
            import std.math;
            foreach( pv; data )
            {
                ndt ~= pv;
                auto npos = pv.pos + pv.val;
                auto cosa = cos(arrow.angle);
                auto sina = sin(arrow.angle);

                vec2 apv;
                if( arrow.absoluteSize )
                    apv = -pv.val.e * arrow.size;
                else
                    apv = -pv.val * arrow.size;

                auto cospvx = cosa * apv.x;
                auto sinpvx = sina * apv.x;

                auto cospvy = cosa * apv.y;
                auto sinpvy = sina * apv.y;

                ndt ~= posvec!2( npos, vec2( cospvx - sinpvy,  sinpvx + cospvy ) );
                ndt ~= posvec!2( npos, vec2( cospvx + sinpvy, -sinpvx + cospvy ) );
            }
            setSimpleCoords( ndt );
        }
    }
}
