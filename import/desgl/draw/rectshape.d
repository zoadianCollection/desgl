/++
прямоугольник, удобен для наложения текстур
+/
module desgl.draw.rectshape;

import derelict.opengl3.gl3;

import desmath.types.vector,
       desmath.types.rect;

import desgl.object;
import desgl.texture;

alias vrect!int irect;

import desutil.logger;
debug mixin( LoggerPrivateMixin( "rshape", __MODULE__ ) );

import desgl.draw.shape;

class RectShape: UIDrawObj
{
protected:
    static float[] colArray( in col4 c )
    { return c.data ~ c.data ~ c.data ~ c.data; }

    static float[] colArray( in col4[4] c )
    { return c[0].data ~ c[1].data ~ c[2].data ~ c[3].data; }

    GLTexture2D tex;
    int use_tex = 0;

public:

    this( ShaderProgram sp )
    {
        debug log.trace( "rhape ctor start" );

        super( sp );

        debug log.trace( "rhape base class ctor" );

        auto pos = new buffer( "pos", GL_ARRAY_BUFFER, 
                [ 0.0f, 0, 1, 0, 0, 1, 1, 1 ], GL_STATIC_DRAW );
        pos.setAttribPointer( "vertex", 2, GL_FLOAT );

        debug log.trace( "pos vbo" );

        auto uv = this.new buffer( "uv", GL_ARRAY_BUFFER, 
                [ 0.0f, 0, 1, 0, 0, 1, 1, 1 ], GL_STATIC_DRAW );
        uv.setAttribPointer( "uv", 2, GL_FLOAT );

        debug log.trace( "uv vbo" );

        auto col = this.new buffer( "col", GL_ARRAY_BUFFER, 
                colArray( col4( 1,1,1,1 ) ) ); 
        col.setAttribPointer( "color", 4, GL_FLOAT );

        debug log.trace( "col vbo: ", colArray( col4(1,1,1,1) ) );

        debug log.trace( "tex ctor" );

        draw.connect( (){ glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 ); } );

        debug log.info( "rhape ctor finish" );
    }

    override void setColor( in col4 c ){ vbo["col"].setData( colArray( c ) ); }
    override void reshape( in irect r ) { vbo["pos"].setData( r.points!float ); }
}
