module desgl.object;

import derelict.opengl3.gl3;

import desutil.signal;

public import desgl.shader;

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

    class buffer
    {
    protected:
        uint _id; // OpenGL VBO ID
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
            glGenBuffers( 1, &_id );
            debug checkGL();
            if( data_arr ) setData( data_arr, mem );
            debug checkGL();
            debug log.info( "vbo ctor finish" );
        }

        void bind()
        {
            this.outer.bind();
            glBindBuffer( type, _id );

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

        void setData(E)( in E[] data_arr, GLenum mem=GL_DYNAMIC_DRAW )
        {
            this.outer.bind();
            auto size = E.sizeof * data_arr.length;
            if( !size ) throw new GLObjException( "buffer data size is 0" );

            glBindBuffer( type, _id );
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
            debug log.trace( "vbo [id:", _id, "] enable attrs" );
        }

        void disable()
        {
            this.outer.bind();
            bind();
            foreach( attr; attribs )
                glDisableVertexAttribArray( attr );

            debug checkGL();
            debug log.trace( "vbo [id:", _id, "] disable attrs" );
        }

        void setAttribPointer( string attrname, uint size,
                GLenum attype, bool norm=false )
        { setAttribPointer( attrname, size, attype, 0, 0, norm ); }

        void setAttribPointer( string attrname, uint size, 
                GLenum attype, size_t stride, size_t offset, bool norm=false )
        {
            if( this.outer.shader is null ) 
                throw new GLObjException( "shader is null" );

            int atLoc = this.outer.shader.getAttribLocation( attrname );
            if( atLoc < 0 ) 
                throw new GLObjException( "bad attribute name '" ~ attrname ~ "'" );


            glBindBuffer( type, _id );
            scope(exit) 
                glBindBuffer( type, 0 );

            debug checkGL();

            bool find = 0;
            foreach( attr; attribs )
                if( atLoc == attr ){ find = 1; break; }
            if( !find )
                attribs ~= atLoc;

            this.outer.bind();
            glEnableVertexAttribArray( atLoc );
            glVertexAttribPointer( atLoc, cast(int)size, attype, norm, 
                    cast(int)stride, cast(void*)offset );

            debug checkGL();
            debug log.trace( "vbo [id:", id, "] set attrib pointer" );
        }

        @property nothrow uint id() const { return _id; }

        ~this()
        {
            unbind();
            glDeleteBuffers( 1, &_id );
            
            debug checkGL();
        }
    }

    buffer[string] vbo;

    final void bind()   { if( currentUseID != vaoID ) set_to_use( vaoID ); }
    final void unbind() { if( currentUseID == vaoID ) set_to_use( 0 ); }

    ShaderProgram shader;

public:

    SignalBox!Args draw;

    this( ShaderProgram sh )
    {
        if( sh is null )
            throw new GLObjException( "shader is null" );

        shader = sh;

        glGenVertexArrays( 1, &vaoID ); 

        debug checkGL();

        draw.addPair( (Args args) { bind(); shader.use(); },
                      (Args args) { unbind(); } );
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
