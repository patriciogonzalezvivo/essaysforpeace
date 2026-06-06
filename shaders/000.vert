#version 120 

#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D   u_tex0;
uniform vec2        u_tex0Resolution;

uniform mat4        u_modelViewProjectionMatrix;
uniform mat4        u_projectionMatrix;
uniform mat4        u_modelMatrix;
uniform mat4        u_viewMatrix;
uniform mat3        u_normalMatrix;
uniform vec3        u_camera;
uniform vec2        u_resolution;

#ifdef MODEL_PRIMITIVE_GSPLATS
uniform sampler2D   u_GsplatData;
uniform vec2        u_GsplatDataResolution; // Must be passed: vec2(4096.0, height)

uniform vec2        u_focal;

attribute vec2      a_position;
attribute float     a_index;
#else 

attribute vec4      a_position;
#endif

varying vec4        v_position;

varying vec4        v_color;

#ifdef MODEL_VERTEX_NORMAL
attribute vec3      a_normal;
varying vec3        v_normal;
#endif

#ifdef MODEL_VERTEX_TEXCOORD
attribute vec2      a_texcoord;
#endif
varying vec2        v_texcoord;

#ifdef MODEL_VERTEX_TANGENT
attribute vec4      a_tangent;
varying vec4        v_tangent;
varying mat3        v_tangentToWorld;
#endif

#ifdef LIGHT_SHADOWMAP
uniform mat4        u_lightMatrix;
varying vec4        v_lightCoord;
#endif

varying float       v_cam;

#include "lygia/color/luma.glsl"
#include "lygia/generative/random.glsl"

void main(void) {
    v_position = u_modelMatrix * a_position;

    float randomValue = random(a_position.xy);
    v_position.x += (randomValue- 0.5 ) * 0.01; 
    float randomValueY = random(a_position.yx);
    v_position.y += (randomValueY- 0.5 ) * 0.005;
    v_texcoord = a_position.xy;

    float aspectRatio = u_tex0Resolution.x / (u_tex0Resolution.y * 2.);
    v_position.xy -= 0.5;
    v_position.x *= aspectRatio;

    vec2 uv = v_texcoord;
    uv.x *= 0.5;
    vec4 tex = texture2D(u_tex0, uv);
    float depth = texture2D(u_tex0, vec2(0.5 ,0.0) + uv).r;
    float lumaValue = luma(tex);
    v_position.z += depth;

    v_cam = clamp(length(u_camera - v_position.xyz)/1., 0.0, 1.0);

    v_position.z += mix((randomValueY * randomValue - 0.5 ) * 0.5, 0.0, v_cam);

    gl_PointSize = 1.0 + mix(2.0, (10.0 * pow(1.0 - v_cam, 3.) + 10.0 * pow(lumaValue, 3.0))  * (1.0 + 5.0 * pow(randomValueY,2.0)), (1.0 - v_cam));
    v_color = tex;
    
    gl_Position = u_projectionMatrix * u_viewMatrix * v_position;
}
