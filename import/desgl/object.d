module desgl.object;

import derelict.opengl3.gl3;

import desutil.signal;

import desgl.helpers;

import desutil.logger;
mixin PrivateLogger;

class GLObjException : Exception { this( string msg ){ super( msg ); } }

class GLVBO
{
protected:
    uint vboID;
    GLenum type;
public:
    static nothrow void unbind( GLenum tp ){ glBindBuffer( tp, 0 ); }

    this(E)( in E[] data_arr=null, GLenum Type=GL_ARRAY_BUFFER, GLenum mem=GL_DYNAMIC_DRAW )
    {
        glGenBuffers( 1, &vboID );
        type = Type;
        if( data_arr !is null && data_arr.length ) setData( data_arr, mem );

        debug checkGL;
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

            debug checkGL;
            debug log( "vbo data: %s", data_arr );
        }
    }

    ~this() { glDeleteBuffers( 1, &vboID ); }
}

final class GLVAO
{
protected:
    uint vaoID;

public:
    static nothrow void unbind(){ glBindVertexArray(0); }

    this() { glGenVertexArrays( 1, &vaoID ); }

    nothrow 
    {
        void bind() 
        { 
            glBindVertexArray( vaoID ); 
            debug log( "bind:  %d", vaoID );
            debug checkGL;
        }

        void enable( int n )
        { 
            bind();
            glEnableVertexAttribArray( n ); 
            debug log_info( "enable attrib %d for vao %d", n, vaoID );
            debug checkGL;
        }

        void disable( int n )
        { 
            bind();
            glDisableVertexAttribArray( n ); 
            debug log_info( "disable attrib %d for vao %d", n, vaoID );
            debug checkGL;
        }
    }

    ~this() { glDeleteVertexArrays( 1, &vaoID ); }
}

class GLObj(Args...)
{
protected:
    GLVAO vao;

    final nothrow
    {
        void setAttribPointer( GLVBO buffer, int index, uint size, GLenum attype, bool norm=false )
        { setAttribPointer( buffer, index, size, attype, 0, 0, norm ); }

        void setAttribPointer( GLVBO buffer, int index, uint size, 
                GLenum attype, size_t stride, size_t offset, bool norm=false )
        {
            vao.bind();
            vao.enable( index );

            buffer.bind();
            glVertexAttribPointer( index, cast(int)size, attype, norm, 
                    cast(int)stride, cast(void*)offset );
            buffer.unbind();
        }
    }

public:
    SignalBox!Args draw;

    this()
    {
        vao = new GLVAO;
        draw.addBegin( (Args args){ vao.bind(); } );

        debug draw.addBegin( (Args args){ checkGL; } ); 
        debug checkGL;
    }
}
