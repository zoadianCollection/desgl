module desgl.draw.vfield;

import derelict.opengl3.gl3;

import desmath.types.vector;

import desgl.object;
import desgl.ssready;

struct posvec { vec2 pos, val; }

class VField: GLObj!()
{
private:
    int vcnt=0;
    col4 clr = col4(1,1,1,1);
    vec2 winsize = vec2(1,1);
public:
    this( ShaderProgram sh=null )
    {
        if( sh is null )
            sh = new ShaderProgram( SS_WINCRD_UNIFORMCOLOR );
        super( sh );
        auto pos = new buffer( "pos", GL_ARRAY_BUFFER, [ 0.0f, 0 ], GL_DYNAMIC_DRAW );
        pos.setAttribPointer( "vertex", 2, GL_FLOAT );
        draw.addBegin( (){ 
                shader.setUniformVec( "color", clr ); 
                shader.setUniformVec( "winsize", winsize ); 
                } );
        draw.connect( (){ glDrawArrays( GL_LINES, 0, vcnt ); } );
    }

    void setColor( in col4 c ) { clr = c; }

    struct ArrowInfo
    {
        bool use = false;
        bool absoluteSize = true;
        float size = 10;
        float angle = 0.3;
    }

    ArrowInfo arrow;

    void setWinSize( in vec2 w ) { winsize = w; }

    void setCoords( in posvec[] data... ) 
    { 
        void setSimpleCoords( in posvec[] info )
        {
            vec2[] ndt;
            foreach( pv; info )
            {
                ndt ~= pv.pos;
                ndt ~= pv.pos + pv.val;
            }
            vbo["pos"].setData( ndt ); 
            vcnt = cast(int)ndt.length;
        }

        if( !arrow.use )
            setSimpleCoords( data );
        else
        {
            posvec[] ndt;
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

                ndt ~= posvec( npos, vec2( cospvx - sinpvy,  sinpvx + cospvy ) );
                ndt ~= posvec( npos, vec2( cospvx + sinpvy, -sinpvx + cospvy ) );
            }
            setSimpleCoords( ndt );
        }
    }
}
