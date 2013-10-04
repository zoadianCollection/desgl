module desgl.object;

import derelict.opengl3.gl3;

import desutil.signal;

import desutil.logger;
debug mixin( LoggerPrivateMixin( "globj", __MODULE__ ) );

class GLObjException : Exception { this( string msg ){ super( msg ); } }

debug
{
    void checkGL( int ln=__LINE__ )
    {
        import std.string : format;
        auto err = glGetError();
        if( err != GL_NO_ERROR )
            log.trace( format( " ## GL ERROR ## at line: #%s: 0x%04x", ln, err ) );
    }
}

class GLVBO
{
protected:
    uint vboID;
    GLenum type;
public:
    static nothrow void unbind( GLenum tp ){ glBindBuffer( tp, 0 ); }

    this(E)( GLenum Type=GL_ARRAY_BUFFER, in E[] data_arr=null, GLenum mem=GL_DYNAMIC_DRAW )
    {
        glGenBuffers( 1, &vboID );
        type = Type;
        if( data_arr !is null ) setData( data_arr, mem );
    }

    final
    {
        nothrow
        {
            void bind() { glBindBuffer( type, vboID ); }
            void unbind(){ glBindBuffer( type, 0 ); }
            @property uint id() const { return vboID; }
        }
        
        void setData(E)( in E[] data_arr, GLenum mem=GL_DYNAMIC_DRAW )
        {
            auto size = E.sizeof * data_arr.length;
            if( !size ) throw new GLObjException( "buffer data size is 0" );

            glBindBuffer( type, vboID );
            glBufferData( type, size, data_arr.ptr, mem );
            glBindBuffer( type, 0 );

            debug checkGL();
            debug log.trace( "vbo data: ", data_arr );
        }
    }

    ~this() { glDeleteBuffers( 1, &vboID ); }
}

final class GLVAO
{
protected:
    uint vaoID;
    bool[int] attr;

public:
    static nothrow void unbind(){ glBindVertexArray(0); }

    this() { glGenVertexArrays( 1, &vaoID ); }

    nothrow void bind() { glBindVertexArray( vaoID ); }

    void enable( int n )
    { 
        bind();
        glEnableVertexAttribArray( n ); 
        attr[n] = true;
    }

    void disable( int n )
    { 
        bind();
        glDisableVertexAttribArray( n ); 
        attr[n] = false;
    }

    bool checkEnable( int[] locs )
    {
        foreach( n; locs )
            if( n !in attr || !attr[n] ) 
                return false;
        return true;
    }

    ~this() { glDeleteVertexArrays( 1, &vaoID ); }
}

class GLObj(Args...)
{
protected:
    GLVAO vao;

    void setAttribPointer( GLVBO buffer, int index, uint size, GLenum attype, bool norm=false )
    { setAttribPointer( index, size, attype, 0, 0, norm ); }

    void setAttribPointer( GLVBO buffer, int index, uint size, 
            GLenum attype, size_t stride, size_t offset, bool norm=false )
    {
        vao.bind();
        buffer.bind();
        vao.enable( index );
        glVertexAttribPointer( index, cast(int)size, attype, norm, 
                cast(int)stride, cast(void*)offset );
        buffer.unbind();
    }

public:
    SignalBox!Args draw;

    this()
    {
        vao = new GLVAO;
        draw.addBegin( (Args args){ vao.bind(); } );
    }
}
