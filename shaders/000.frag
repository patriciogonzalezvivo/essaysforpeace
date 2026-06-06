#version 120 

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2        u_resolution;

uniform sampler2D   u_tex0;
uniform vec2        u_tex0Resolution;

uniform sampler2D   u_tex1;
uniform vec2        u_tex1Resolution;

varying vec4        v_color;
varying vec2        v_texcoord;

#include "lygia/space/sprite.glsl"
#include "lygia/color/luma.glsl"

void main (void) {
    vec4 color = v_color;
    vec2 pixel = 1.0/u_resolution.xy;
    vec2 st = gl_PointCoord.xy;
    vec2 uv = v_texcoord;

    int i = int(uv.x * 10.0);
    vec2 st1 = sprite(st, vec2(9.0, 1.0), i);
    st1.y = 1.0 - st1.y;
    vec4 tex = texture2D(u_tex1, st1);
    color.rgb *= tex.rgb;
    color.a = step(0.5, pow(luma(tex.rgb), 3.0));
    // color = vec4(st, 0.0, 1.0);

    gl_FragColor = color;
}
