## texture.d

### GLTexture

Класс для работы с текстурами.

Минимально необходимый функционал для desgui. 
Pull Request с доработками приветствуются (не забывайте вносить изменения и в
документацию).

Класс параметризуется числом измерений текстуры: 1, 2 или 3.

##### методы

* Конструктор: 
    создаётся текстура нужного типа и 
    применяются базовые настройки текстуры.

    ```d
    this();
    ```

* выставление целочисленных параметров

    ```d
    final void parameteri( GLenum param, int val );
    ```

* привязка/отвязка
    
    ```d
    final void bind();
    final void unbind();
    ```

* получение размера текстуры
    
    ```d
    final @property texsize size() const;
    ```

    `texsize` - alias для типа
    [вектора](https://github.com/dexset/desmath/blob/master/doc/ru/desmath/types/vector.md). 
    Этот тип вектора имеет размерность, совпадающую с размерностью текстуры и
    имеет строку доступа "w", "wh" либо "whd", в зависимости от размерности.

* заполнить текстуру
    
    ```d
    final void image(T,E)( in T nsz, int texfmt, GLenum datafmt, GLenum datatype, in E* data );
    ```

    `T` - тип
    [вектора](https://github.com/dexset/desmath/blob/master/doc/ru/desmath/types/vector.md), 
    совместимый с `texsize`,

    `nsz` - размер нового изображения,

    `texfmt` - формат текстуры (internalFormat),

    `datafmt` - формат данных (format),

    `datatype` - тип данных (type),

    `data` - указатель на сами данные

    Для каждого типа текстур вызывается своя функция, например для 2D текстуры 
    [glTexImage2D](http://www.opengl.org/sdk/docs/man/xhtml/glTexImage2D.xml).
    

    

    




