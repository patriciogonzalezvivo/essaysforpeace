precision highp float;

// glsl-pipeline provides these automatically (matching glslViewer)
uniform vec3  u_camera;
uniform mat4  u_viewMatrix;
uniform mat4  u_projectionMatrix;

uniform sampler2D u_tex0;
uniform vec2      u_tex0Resolution;

// Three.js BufferGeometry attribute
// attribute vec3 position;  // [0..1] x [0..1] plane (pcl_plane equiv)

varying vec4  v_position;
varying vec4  v_color;
varying vec2  v_texcoord;
varying float v_cam;

float luma(vec3 c)  { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }
float luma(vec4 c)  { return luma(c.rgb); }

float random(vec2 st) {
    return fract(sin(dot(st, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main(void) {
    // No mesh transform — object space == world space
    v_position = vec4(position, 1.0);

    float rx = random(position.xy);
    float ry = random(position.yx);
    v_position.x += (rx - 0.5) * 0.01;
    v_position.y += (ry - 0.5) * 0.005;

    v_texcoord = position.xy;

    float aspectRatio = u_tex0Resolution.x / (u_tex0Resolution.y * 2.0);
    v_position.xy -= 0.5;
    v_position.x  *= aspectRatio;

    vec2 uv = v_texcoord * vec2(0.5, 1.0);
    vec4 tex    = texture2D(u_tex0, uv);
    float depth = texture2D(u_tex0, vec2(0.5, 0.0) + uv).r;

    v_position.z += depth;

    v_cam = clamp(length(u_camera - v_position.xyz), 0.0, 1.0);

    v_position.z += mix((ry * rx - 0.5) * 0.5, 0.0, v_cam);

    float lumaV = luma(tex);
    gl_PointSize = 1.0 + mix(
        2.0,
        (10.0 * pow(1.0 - v_cam, 3.0) + 10.0 * pow(lumaV, 3.0)) * (1.0 + 5.0 * pow(ry, 2.0)),
        1.0 - v_cam
    ) * 5.0;

    v_color = tex;
    gl_Position = u_projectionMatrix * u_viewMatrix * v_position;
}
