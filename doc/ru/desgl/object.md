### object.d

#### `class GLVBO`

Класс-обёртка для OpenGL Vertex Buffer Object

* отвязать буфер определённого типа

    ```d
    static nothrow void unbind( GLenum tp );
    ```

* конструктор принимает массив данных, тип буфера и тип памяти для нового буфера

    ```d
    this(E)( in E[] data_arr=null, GLenum Type=GL_ARRAY_BUFFER, GLenum mem=GL_DYNAMIC_DRAW );
    ```

* финальные методы связывания, отвязывания

    ```d
    final nothrow void bind();
    final nothrow void unbind();
    ```

* возвращение номера буфера
    
    ```d
    final nothrow @property uint id() const;
    ```
    
* выставление данных
    
    ```d
    final void setData(E)( in E[] data_arr, GLenum mem=GL_DYNAMIC_DRAW );
    ```

#### `final class GLVAO`

Класс-обёртка для OpenGL Vertex Array Object

* отвязать буфер
    
    ```d
    static nothrow void unbind();
    ```

* конструктор не принимает аргументов

* связать буфер
    
    ```d
    nothrow void bind();
    ```

* выставить определённый атрибут активным
    
    ```d
    nothrow void enable( int n );
    ```
* выставить определённый атрибут пассивным

    ```d
    nothrow void disable( int n );
    ```

#### `class GLObj(Args...)`

Класс объеденяет концепции VBO и VAO

##### Protected поля и методы

* `GLVAO vao;`

* выставить указатель атрибута
    
    ```d
    final nothrow void setAttribPointer( GLVBO buffer, int index, uint size, GLenum attype, bool norm=false );

    final nothrow void setAttribPointer( GLVBO buffer, int index, uint size, 
            GLenum attype, size_t stride, size_t offset, bool norm=false );
    ```

##### Public поля и методы

* сигнал отрисовки `SignalBox!Args draw;`

* конструктор без параметров

