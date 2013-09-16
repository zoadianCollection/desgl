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
alias GLTexture!2 GLTexture2D;

import desutil.logger;
debug mixin( LoggerPrivateMixin( "rshape", __MODULE__ ) );

class RectShape: GLObj!()
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

        tex = new GLTexture2D; 

        debug log.trace( "tex ctor" );

        draw.connect( (){ glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 ); } );
        draw.addPair( (){ 
                    shader.setUniform!int( "use_texture", use_tex );
                    shader.setUniform!int( "ttu", GL_TEXTURE0 );
                    if( use_tex ) tex.bind(); 
                },
                (){ if( use_tex ) tex.unbind(); } );

        debug log.info( "rhape ctor finish" );
    }

    void setColor( in col4 c ){ vbo["col"].data( colArray( c ) ); }

    void notUseTexture(){ use_tex = 0; }

    void fillAlphaTexture(T,E)( in T sz, E[] data )
        if( isCompVector!(2,int,T) && ( is( E == ubyte ) ) )
    { 
        static if( is( E == ubyte ) ) enum type = GL_UNSIGNED_BYTE;
        tex.image( sz, GL_RED, GL_RED, type, data.ptr ); 
        use_tex = 1;
    }

    void fillColorTexture(T,size_t N,E,string as)( in T sz, vec!(N,E,as)[] data )
        if( isCompVector!(2,int,T) && ( N==3 || N==4 ) && 
                ( is( E == ubyte ) || is( E == float ) ) )
    {
        static if( is( E == ubyte ) ) 
            enum type = GL_UNSIGNED_BYTE;
        else static if( is( E == float ) ) 
            enum type = GL_FLOAT;

        static if( N == 3 ) 
            enum fmt = GL_RGB;
        else static if( N == 4 )
            enum fmt = GL_RGBA;

        tex.image( sz, fmt, fmt, type, data.ptr ); 
        use_tex = 2;
    }

    void reshape( in irect r ) { vbo["pos"].data( r.points!float ); }
}
