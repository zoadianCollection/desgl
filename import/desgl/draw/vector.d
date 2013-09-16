module desgl.draw.vector;

import derelict.opengl3.gl3;

import desmath.types.vector;

import desgl.object;

class Vector : GLObj!()
{
protected:
    static float[] colArray( in col4 c )
    { return c.data ~ c.data; }
public:
    this( ShaderProgram sh )
    {
        super( sh );
        auto pos = new buffer( "pos", GL_ARRAY_BUFFER,
                [ 0.0f, 0, 1, 1 ], GL_STATIC_DRAW );
        auto col = this.new buffer( "col", GL_ARRAY_BUFFER,
                colArray( col4( 1, 1, 1, 1 ) ));
        pos.setAttribPointer( "vertex", 2, GL_FLOAT );
        col.setAttribPointer( "color", 4, GL_FLOAT );
        draw.connect( (){ glDrawArrays( GL_LINES, 0, 2 ); } );
    }

    void setColor( in col4 c ){ vbo["col"].data( colArray(c) ); };

    void setCoords( in vec2[2] v ) { vbo["pos"].data( [ v[0].x, v[0].y, v[1].x, v[1].y ] ); }
}
