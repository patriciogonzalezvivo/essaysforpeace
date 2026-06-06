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

#include "lygia/color/luma.glsl"

void main(void) {
    v_position = u_modelMatrix * a_position;
    v_texcoord = a_position.xy;

    float aspectRatio = u_tex0Resolution.x / u_tex0Resolution.y;
    v_position.xy -= 0.5;
    v_position.x *= aspectRatio;

    vec4 tex = texture2D(u_tex0, v_texcoord);
    float lumaValue = luma(tex);
    v_position.z += lumaValue;

    gl_PointSize = 10.0 + 20.0 * lumaValue;
    v_color = tex;
    
    gl_Position = u_projectionMatrix * u_viewMatrix * v_position;
}
