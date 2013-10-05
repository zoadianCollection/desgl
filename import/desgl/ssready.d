module desgl.ssready;

public import desgl.shader;

enum ShaderSource SS_SIMPLE = 
{
`#version 120
attribute vec3 vertex;
attribute vec4 color;
varying vec4 v_color;
void main(void) 
{ 
    gl_Position = vec4( vertex, 1 ); 
    v_color = color;
}`, 
`#version 120
varying vec4 v_color;
void main(void) { gl_FragColor = v_color; } `
};

enum ShaderSource SS_WINCRD_UNIFORMCOLOR = 
{
`#version 120
uniform vec2 winsize;
attribute vec2 vertex;
void main(void)
{
    gl_Position = vec4( 2.0 * vec2(vertex.x, -vertex.y) / winsize + vec2(-1.0,1.0), -0.05, 1 );
}`, 
`#version 120
uniform vec4 color;
void main(void) { gl_FragColor = color; } `
};

/++
 стандартный шейдер для всех widget"ов

    uniform vec2 winsize - размер окна

    attribute vec2 vertex - позиция в системе координат окна
    attribute vec4 color - цвет вершины
    attribute vec2 uv - текстурная координата

    uniform sampler2D ttu - текстурный сэмплер
    uniform int use_texture - флаг использования текстуры: 
                                0 - не использовать,
                                1 - использовать только альфу
                                2 - использовать все 4 канала текстуры

 +/
enum ShaderSource SS_WINCRD_FULLCOLOR_TEXTURE = 
{
`#version 120
uniform vec2 winsize;

attribute vec2 vertex;
attribute vec4 color;
attribute vec2 uv;

varying vec2 ex_uv;
varying vec4 ex_color;

void main(void)
{
    gl_Position = vec4( 2.0 * vec2(vertex.x, -vertex.y) / winsize + vec2(-1.0,1.0), -0.05, 1 );
    ex_uv = uv;
    ex_color = color;
}
`,

`#version 120
uniform sampler2D ttu;
uniform int use_texture;

varying vec2 ex_uv;
varying vec4 ex_color;

void main(void) 
{ 
    if( use_texture == 0 )
        gl_FragColor = ex_color; 
    else if( use_texture == 1 )
        gl_FragColor = vec4( 1, 1, 1, texture2D( ttu, ex_uv ).r ) * ex_color;
    else if( use_texture == 2 )
        gl_FragColor = texture2D( ttu, ex_uv );
}`
};

enum ShaderSource SS_WINSZ_SIMPLE_FBO_FX = 
{
`#version 120
uniform vec2 winsize;
attribute vec2 vertex;
attribute vec2 uv;
varying vec2 ex_uv;
void main(void)
{
    gl_Position = vec4( 2.0 * vec2(vertex.x, vertex.y) / winsize + vec2(-1.0,-1.0), 0, 1 );
    ex_uv = uv;
}`,
`#version 120
uniform vec2 winsize;
uniform sampler2D ttu;
varying vec2 ex_uv;
void main(void)
{
    vec4 sum = vec4(0);

    int dw = 4;
    int dh = 4;

    float c = 0.5f;

    float xs = 1.0f / winsize.x;
    float ys = 1.0f / winsize.y;

    for( int i = -dw+1; i < dw; i++ )
    {
        for( int j = -dh+1; j < dh; j++ )
        {
            float k = c / ( i*i + j*j + c );
            vec4 clr = texture2D( ttu, ex_uv + vec2( i*xs, j*ys ) );
            sum +=  clr * k;
        }
    }

    float accum = 0;
    if( sum.x > 1 ) { accum += sum.x - 1; sum.x = 1; }
    if( sum.y > 1 ) { accum += sum.y - 1; sum.y = 1; }
    if( sum.z > 1 ) { accum += sum.z - 1; sum.z = 1; }

    vec4 res = ( sum / ( accum + 2.0f ) + vec4(1,1,1,0) * accum );
    gl_FragColor = res;
    //gl_FragColor = vec4( res.xyz, res.w * length(res.xyz) );
}`
};

enum ShaderSource SS_WINSZ_SIMPLE_FBO = 
{
`#version 120
uniform vec2 winsize;
attribute vec2 vertex;
attribute vec2 uv;
varying vec2 ex_uv;
void main(void)
{
    gl_Position = vec4( 2.0 * vec2(vertex.x, vertex.y) / winsize + vec2(-1.0,-1.0), 0, 1 );
    ex_uv = uv;
}`,
`#version 120
uniform sampler2D ttu;
uniform float alpha;
varying vec2 ex_uv;
void main(void)
{
    vec4 res = texture2D( ttu, ex_uv );
    res *= alpha;
    gl_FragColor = res;
}`
};
