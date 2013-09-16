## rectshape.d

#### RectShape

Класс-наследник от `GLObj!()`.

Просто рисует прямоугольник.

##### методы

* конструктор принимает шейдер
    
    ```d
    this( ShaderProgram sp );
    ```

* выставить цвет прямоугольника

    ```d
    void setColor( in col4 c );
    ```

    `col4` - псевдоним для 
    [`vec!(4,float,"rgba")`](https://github.com/dexset/desmath/blob/master/doc/ru/desmath/types/vector.md)

* не использовать текстуру

    ```d
    void notUseTexture();
    ```

* заполнить текстуру альфа канала

    ```d
    void fillAlphaTexture(T,E)( in T sz, E[] data );
    ```

    `in T sz` - 
    [вектор](https://github.com/dexset/desmath/blob/master/doc/ru/desmath/types/vector.md),
    хранящий размер нового изображения, должен быть двумерным и целочисленым

    `E[] data` - массив, содержащий изображение.
    К сожалению на данный момент поддерживается только тип `ubyte`.

* заполнить текстуру RGB(A)
    
    ```d
    void fillColorTexture(T,size_t N,E,string as)( in T sz, vec!(N,E,as)[] data );
    ```

    Всё тоже самое, только поддерживаются типы `ubyte` и `float` для вектора
    данных (`data`).

* изменение размера
    
    ```d
    void reshape( in irect r );
    ```

При вызове функций заполнения текстур флаг использования текстуры выставляется и
значение цвета уже не влияет на отображение прямоугольника.
