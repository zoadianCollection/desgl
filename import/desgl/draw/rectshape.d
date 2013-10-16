/++
прямоугольник, удобен для наложения текстур
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
mixin PrivateLogger;

class SimpleRect: GLObj!()
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

        draw.connect( () { glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 ); } );
    }
}

class TexturedRect: SimpleRect
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

class ColorRect: SimpleRect
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

class ColorTexRect: ColorRect
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
