### shader.d ###

### ShaderSource

Простая структура для хранения исходных кодов шейдера.

Содержит 3 поля типа `string` : `vert`, `geom`, `frag` ( вершинный, геометрии,
фрагментный соответственно ).


### ShaderProgram

Класс для работы с шейдером OpenGL.

###### методы

* конструктор принимает исходники шейдера
    
    ```d
    this( in ShaderSource src );
    ```

* использовать
    
    ```d
    final void use();
    ```

* получить адресс атрибута

    ```d
    int getAttribLocation( string name );
    ```

* получить адресс uniform поля

    ```d
    int getUniformLocation( string name );
    ```

* выставить значение uniform поля

    ```d
    void setUniform(S,T...)( int loc, T vals );
    void setUniform(S,T...)( string name, T vals );

    void setUniformArr(size_t sz,T)( int loc, in T[] vals );
    void setUniformArr(size_t sz,T)( string name, in T[] vals );

    void setUniformVec(size_t N,T,string AS)( int loc, vec!(N,T,AS)[] vals... );
    void setUniformVec(size_t N,T,string AS)( string name, vec!(N,T,AS)[] vals... );

    void setUniformMat(size_t h, size_t w)( int loc, in mat!(h,w,float)[] mtr... );
    void setUniformMat(size_t h, size_t w)( string name, in mat!(h,w,float)[] mtr... );
    ```

    Каждая пара функций принимает либо имя атрибута, либо сразу его адрес.

    Первые 2 функции принимаю от 1 до 4 аргументов `vals`, тип данных `S` должен
    быть одним из 3 допустимых типов: `float`, `int`, `uint`.

    Вторые 2 функции принимают массив типа `T`. Тип `T` тоже должен быть одним
    из 3 доступных типов: `float`, `int`, `uint`.

    Последние 2е пары функций работают с
    [векторами](https://github.com/dexset/desmath/blob/master/doc/ru/desmath/types/vector.md) 
    и 
    [матрицами](https://github.com/dexset/desmath/blob/master/doc/ru/desmath/types/matrix.md) 
    из набора [desmath](https://github.com/dexset/desmath). При этом принимаются
    массивы этих типов. Вектора могут содедержать 1 из 3х допустимых типов
    данных, и должны быть размерностью от 2х до 4х. Матрцы могут быть только `float`, 
    размерностью также от 2х до 4х по каждому измерению. 
    
