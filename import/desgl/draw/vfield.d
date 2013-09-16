module desgl.draw.vector;

import derelict.opengl3.gl3;

import desmath.types.vector;

import desgl.object;

struct posvec { vec2 pos, val; }

enum ShaderSource SS_WINCRD_UNIFORMCOLOR = 
{
r"
#version 120
uniform vec2 winsize;
attribute vec2 vertex;
void main(void)
{
    gl_Position = vec4( 2.0 * vec2(vertex.x, -vertex.y) / winsize + vec2(-1.0,1.0), -0.05, 1 );
}
", 

r"
#version 120
uniform vec4 color;
void main(void) { gl_FragColor = color; }
"
};

class VField: GLObj!()
{
private:
    int vcnt=0;
    col4 clr = col4(1,1,1,1);
public:
    this( ShaderProgram sh=null )
    {
        if( sh is null )
            sh = new ShaderProgram( SS_WINCRD_UNIFORMCOLOR );
        super( sh );
        auto pos = new buffer( "pos", GL_ARRAY_BUFFER, [ 0.0f, 0 ], GL_DYNAMIC_DRAW );
        pos.setAttribPointer( "vertex", 2, GL_FLOAT );
        draw.addBegin( (){ shader.setUniformVec( "color", clr ); } );
        draw.connect( (){ glDrawArrays( GL_LINES, 0, vcnt ); } );
    }

    void setColor( in col4 c ) { clr = c; }

    void setCoords( in posvec[] data... ) 
    { 
        vbo["pos"].setData( data ); 
        vcnt = data.length * 2;
    }
}
