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
    vec2 winsize = vec(1,1);
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
    void setWinSize( in vec2 w ) { winsize = w; }

    void setCoords( in posvec[] data... ) 
    { 
        vbo["pos"].setData( data ); 
        vcnt = data.length * 2;
    }
}
