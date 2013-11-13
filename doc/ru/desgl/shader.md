### shader.d ###

#### `struct ShaderSource`

структура содержит 3 поля
```d
string vert, frag, geom;
```
отвечающие соответственно за хранение исходников для вершинного, фрагментного и геометрического
шейдеров.

#### `class ShaderProgram`
Класс-обёртка для OpenGL шейдеров

* Конструктор принимает структуру `ShaderSource`

    ```d
    this( in ShaderSource src );
    ```

* использовать шейдер ( аналог `glUseProgram` )

    ```d
    final nothrow void use();
    ```
* получить адрес атрибута в шейдере по имени

    ```d
    int getAttribLocation( string name );
    ```
* получить адрес однородной переменной в шейдере по имени

    ```d
    int getUniformLocation( string name );
    ```

* выставить значение однородной переменной по адресу и по имени соответственно

    ```d
    void setUniform(S,T...)( int loc, T vals );
    void setUniform(S,T...)( string name, T vals ); 
    ```

* выставить значение однородного массива по адресу и имени соответственно

    ```d
    void setUniformArr(size_t sz,T)( int loc, in T[] vals );
    void setUniformArr(size_t sz,T)( string name, in T[] vals );
    ```

* выставить значение однородного массива по адресу и имени соответственно,
    используя тип данных `vec`

    ```d
    void setUniformVec(size_t N,T,string AS)( int loc, vec!(N,T,AS)[] vals... );
    void setUniformVec(size_t N,T,string AS)( string name, vec!(N,T,AS)[] vals... );
    ```
    
* выставить значение однородного массива по адресу и имени соответственно,
    используя тип данных `mat`

    ```d
    void setUniformMat(size_t h, size_t w)( int loc, in mat!(h,w,float)[] mtr... );
    void setUniformMat(size_t h, size_t w)( string name, in mat!(h,w,float)[] mtr... );
    ```
