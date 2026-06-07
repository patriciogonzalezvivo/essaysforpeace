precision highp float;

// glsl-pipeline provides u_resolution automatically
uniform vec2      u_resolution;

uniform sampler2D u_tex0;
uniform vec2      u_tex0Resolution;
uniform sampler2D u_tex1;
uniform vec2      u_tex1Resolution;

varying vec4  v_color;
varying vec2  v_texcoord;
varying float v_cam;

float luma(vec3 c) { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }
float luma(vec4 c) { return luma(c.rgb); }

vec2 scale(vec2 st, float s) {
    return (st - 0.5) / max(s, 0.001) + 0.5;
}

vec2 sprite(vec2 st, vec2 grid, int index) {
    vec2 size = 1.0 / grid;
    float col  = mod(float(index), grid.x);
    float row  = floor(float(index) / grid.x);
    return st * size + vec2(col, row) * size;
}

void main(void) {
    vec4 color = v_color;
    vec2 st    = gl_PointCoord.xy;

    st = scale(st, 1.0 - (0.1 + v_cam * 0.9));

    int  i   = int(v_texcoord.x * 10.0);
    vec2 st1 = sprite(st, vec2(9.0, 1.0), i);
    st1.y    = 1.0 - st1.y;

    vec4 tex = texture2D(u_tex1, st1);
    tex.a    = luma(tex.rgb);

    color.rgb = mix(color.rgb, tex.rgb, pow(1.0 - v_cam, 0.9));
    //color.a   = step(0.5, pow(tex.a, 3.0));

    gl_FragColor = color;
}
