module desgl.object;

import derelict.opengl3.gl3;

import desutil.signal;

public import desgl.shader;

class GLObjException : Exception { this( string msg ){ super( msg ); } }

class GLObj(Args...)
{
private:
    static uint currentUseID = 0;
    static void set_to_use( uint nvao )
    {
        glBindVertexArray( nvao );
        _inUse = nvao;
    }
    uint vaoID = 0; // OpenGL VAO ID

protected:

    struct buffer
    {
    private:
        uint id; // OpenGL VBO ID
        GLenum type;
        uint[] attribs;

        void addThis( string name )
        {
            if( name in outher.vbo )
                throw new GLObjException( "name '" ~ name "' is exist" );

            outher.vbo[name] = this;
        }

    public:

        this( string name, GLenum t )
        {
            outher.bind();
            addThis( name );
            type = t;
            glGenBuffers( 1, &id );
        }

        this(E)( string name, in E[] data, GLenum tp=GL_ARRAY_BUFFER,
                              GLenum mem=GL_DYNAMIC_DRAW )
        {
            outher.bind();
            this( tp );
            data( data, mem );
        }

        void bind()
        {
            outher.bind();
            glBindBuffer( type, id );
        }

        void unbind()
        {
            outher.bind();
            glBindBuffer( type, 0 );
        }

        void data(E)( in E[] data, GLenum mem=GL_DYNAMIC_DRAW )
        {
            outher.bind();
            auto size = E.sizeof * data.length;
            if( !size ) throw new GLObjException( "buffer data size is 0" );

            glBindBuffer( type, id );
            glBufferData( type, size, data.ptr, mem );
            glBindBuffer( type, 0 );
        }

        void enable()
        {
            bind();
            foreach( attr; attribs )
                glEnableVertexAttribArray( attr );
        }

        void disable()
        {
            bind();
            foreach( attr; attribs )
                glDisableVertexAttribArray( attr );
        }

        void setAttribPointer( string attrname, uint size,
                GLenum type, bool norm=false )
        { setAttribPointer( attrname, size, type, 0, 0, norm ); }

        void setAttribPointer( string attrname, uint size, 
                GLenum type, size_t stride, size_t offset, bool norm=false )
        {
            if( outher.shader is null ) 
                throw new GLObjException( "shader is null" );

            int atLoc = outher.shader.getAttribLocation( attrname );
            if( atLoc < 0 ) 
                throw new GLObjException( "bad attribute name '" ~ attrname ~ "'" );

            outher.bind();

            glBindBuffer( type, id );
            scope(exit) 
                glBindBuffer( type, 0 );

            bool find = 0;
            foreach( attr; attribs )
                if( atLoc == attr ){ find = 1; break; }
            if( !find )
                attribs ~= atLoc;

            glEnableVertexAttribArray( atLoc );
            glVertexAttribPointer( atLoc, cast(int)size, type, norm, 
                    cast(int)stride, cast(void*)offset );
        }

        ~this()
        {
            unbind();
            glDeleteBuffers( 1, &id );
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
    }

    final void postDraw()
    {
        foreach( name, buf; vbo )
            buf.disable();
        glBindBuffer( GL_ARRAY_BUFFER, 0 );
        unbind();
    }

public:

    SignalBox!Args draw;

    this( ShaderProgram sh )
    {
        if( sh is null )
            throw new GLObjException( "shader is null" );

        shader = sh;

        glGenVertexArrays( 1, &vaoID ); 

        draw.addPair( (args){ preDraw(); },
                      (args){ postDraw(); } )
    }

    ~this()
    {
        auto vboNames = vbo.keys.dup;
        foreach( name; vboNames )
            vbo.remove( name );

        unbind();
        glDeleteVertexArrays( 1, &vaoID );
    }
}
