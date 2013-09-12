module desgl.object;

import derelict.opengl3.gl3;

import desutil.signal;

public import desgl.shader;

import desutil.logger;
debug mixin( LoggerPrivateMixin( "globj", __MODULE__ ) );

class GLObjException : Exception { this( string msg ){ super( msg ); } }

void checkGL( int ln=__LINE__ )
{
    import std.string : format;
    auto err = glGetError();
    if( err != GL_NO_ERROR )
        log.trace( format( " ## GL ERROR ## at line: #%s: 0x%04x", ln, err ) );
}

class GLObj(Args...)
{
private:
    static uint currentUseID = 0;
    static void set_to_use( uint nvao )
    {
        glBindVertexArray( nvao );
        currentUseID = nvao;
        debug checkGL();
    }
    uint vaoID = 0; // OpenGL VAO ID

protected:

    final class buffer
    {
    private:
        uint id; // OpenGL VBO ID
        GLenum type;
        uint[] attribs;

        void addThis( string name )
        {
            if( name in this.outer.vbo )
                throw new GLObjException( "name '" ~ name ~ "' is exist" );

            this.outer.vbo[name] = this;
            debug log.trace( "add vbo with name: ", name );
        }

    public:

        this(E)( string name, GLenum tp=GL_ARRAY_BUFFER, in E[] data_arr=null,
                              GLenum mem=GL_DYNAMIC_DRAW )
        {
            debug log.trace( "vbo ctor: ", name, " data: ", data_arr );
            this.outer.bind();
            addThis( name );
            type = tp;
            glGenBuffers( 1, &id );
            debug checkGL();
            if( data_arr ) data( data_arr, mem );
            debug checkGL();
            debug log.info( "vbo ctor finish" );
        }

        void bind()
        {
            this.outer.bind();
            glBindBuffer( type, id );

            debug checkGL();
            debug log.trace( "bind vbo [id: ", id, "]" );
        }

        void unbind()
        {
            this.outer.bind();
            glBindBuffer( type, 0 );

            debug checkGL();
            debug log.trace( "unbind vbo [id: ", id, "] [type:", type, "] to 0" );
        }

        void data(E)( in E[] data_arr, GLenum mem=GL_DYNAMIC_DRAW )
        {
            this.outer.bind();
            auto size = E.sizeof * data_arr.length;
            if( !size ) throw new GLObjException( "buffer data size is 0" );

            glBindBuffer( type, id );
            glBufferData( type, size, data_arr.ptr, mem );
            glBindBuffer( type, 0 );

            debug checkGL();
            debug log.trace( "vbo data: ", data_arr );
        }

        void enable()
        {
            bind();
            foreach( attr; attribs )
                glEnableVertexAttribArray( attr );

            debug checkGL();
            debug log.trace( "vbo [id:", id, "] enable attrs" );
        }

        void disable()
        {
            bind();
            foreach( attr; attribs )
                glDisableVertexAttribArray( attr );

            debug checkGL();
            debug log.trace( "vbo [id:", id, "] disable attrs" );
        }

        void setAttribPointer( string attrname, uint size,
                GLenum type, bool norm=false )
        { setAttribPointer( attrname, size, type, 0, 0, norm ); }

        void setAttribPointer( string attrname, uint size, 
                GLenum attype, size_t stride, size_t offset, bool norm=false )
        {
            if( this.outer.shader is null ) 
                throw new GLObjException( "shader is null" );

            int atLoc = this.outer.shader.getAttribLocation( attrname );
            if( atLoc < 0 ) 
                throw new GLObjException( "bad attribute name '" ~ attrname ~ "'" );

            this.outer.bind();

            glBindBuffer( type, id );
            scope(exit) 
                glBindBuffer( type, 0 );

            debug checkGL();

            bool find = 0;
            foreach( attr; attribs )
                if( atLoc == attr ){ find = 1; break; }
            if( !find )
                attribs ~= atLoc;

            glEnableVertexAttribArray( atLoc );
            glVertexAttribPointer( atLoc, cast(int)size, attype, norm, 
                    cast(int)stride, cast(void*)offset );

            debug checkGL();
            debug log.trace( "vbo [id:", id, "] set attrib pointer" );
        }

        ~this()
        {
            unbind();
            glDeleteBuffers( 1, &id );
            
            debug checkGL();
        }
    }

    buffer[string] vbo;

    final void bind()   { if( currentUseID != vaoID ) set_to_use( vaoID ); }
    final void unbind() { if( currentUseID == vaoID ) set_to_use( 0 ); }

    ShaderProgram shader;

    final void preDraw()
    {
        bind();
        shader.use();
        foreach( name, buf; vbo )
            buf.enable();
        glBindBuffer( GL_ARRAY_BUFFER, 0 );

        debug checkGL();
    }

    final void postDraw()
    {
        foreach( name, buf; vbo )
            buf.disable();
        glBindBuffer( GL_ARRAY_BUFFER, 0 );
        unbind();

        debug checkGL();
    }

public:

    SignalBox!Args draw;

    this( ShaderProgram sh )
    {
        if( sh is null )
            throw new GLObjException( "shader is null" );

        shader = sh;

        glGenVertexArrays( 1, &vaoID ); 

        debug checkGL();

        draw.addPair( (Args args){ preDraw(); },
                      (Args args){ postDraw(); } );
    }

    ~this()
    {
        auto vboNames = vbo.keys.dup;
        foreach( name; vboNames )
            vbo.remove( name );

        unbind();
        glDeleteVertexArrays( 1, &vaoID );

        debug checkGL();
    }
}
