### object.d ###


### GLObj

Обёртка для работы с vertex array object и vertex buffer object.

`GLObj` параметризуется списком типов `Args...`. 
От списка типов зависит только сигнатура делегатов, соединяемых с сигналом `draw`.

Для использования нужно наследовать от `GLObj` свой класс.

##### `final class buffer`

Вложенный в `GLObj` класс, является обёрткой для vertex buffer object.

###### методы

* конструктор 

    ```d
    this(E)( string name, GLenum tp, in E[] data_arr, GLenum mem );
    ```

    `name` - имя буфера, используется для заполнения ассоциативного массива в `GLObj`

    `tp` - тип буфера, по умолчанию `GL_ARRAY_BUFFER`

    `data_arr` - массив данных, записываемый в буфер, по умолчанию `null`

    `mem` - тип памяти под данные буфера, по умолчанию `GL_DYNAMIC_DRAW`

    В случае, если `data_arr != null` происходит заполнение буфера данными

* установить как текущий (привязать)
    
    ```d
    void bind();
    ```

* отвязать

    ```d
    void unbind();
    ```

* заполнить буфер данными

    ```d
    void data(E)( in E[] data_arr, GLenum mem );
    ```

    `data_arr` - массив данных

    `mem` - тип памяти, по умолчанию `GL_DYNAMIC_DRAW`

* задействовать атрибуты (`glEnableVertexAttribArray`)

    ```d
    void enable();
    ```

* дезактивация атрибутов (`glDisableVertexAttribArray`)

    ```d
    void disable();
    ```

* выставление атрибутов 

    ```d
    void setAttribPointer( string attrname, uint size, GLenum attype, bool norm );
    void setAttribPointer( string attrname, uint size, GLenum attype, size_t stride, size_t offset, bool norm );
    ```

    `attrname` - имя атрибута в шейдере

    `size` - количество данных в одном элементе (количество компонент вектора например)

    `attype` - тип данных компонент элемента ( `GL_FLOAT`, `GL_UNSIGNED_BYTE`, etc )

    `norm` - нормализация данных, по умолчанию `false`

    `stride` - размер блока данных в байтах

    `offset` - смещение начала данных элемента от начала блока данных

    В случае вызова первой функции `stride` и `offset` становятся равными нулю и
    такие данные интерпретируются как непрерывные, тоесть блоки имеют размер 
    элементов и идут в данных буфера без разрыва

##### Protected поля и методы `GLObj` #####

* `buffer[string] vbo` - ассоциативный массив буферов

* `ShaderProgram shader` - шейдер, используемый при рисовании

* привязка и отвязка VAO
    ```d
    void bind();
    void unbind();
    ```

##### Public поля и методы `GLObj` #####
    
* `SignalBox!Args draw` - сигнал, вызываемый при отрисовке,
    в наследуемых классах должен быть заполнен делегатом отрисовки

* конструктор
    
    ```d
    this( ShaderProgram sh );
    ```

    передаётся шейдер, используемый для отрисовки объекта


### Пример использования ###

**см. файл desgl/draw/rectshape.d**














