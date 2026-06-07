import * as THREE from 'three';
import { GlslPipeline } from 'glsl-pipeline';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import vertexShader   from './shaders/000.vert?raw';
import fragmentShader from './shaders/000.frag?raw';

// ── Renderer ──────────────────────────────────────────────────────────────────
const renderer = new THREE.WebGLRenderer({ antialias: false });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.setClearColor(0x000000, 0); // transparent black for additive blend
renderer.setSize(window.innerWidth, window.innerHeight); // must happen before GlslPipeline init
document.body.appendChild(renderer.domElement);

// ── Camera / Controls ─────────────────────────────────────────────────────────
const camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 0.001, 100);
camera.position.set(0, 0, 1);

const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;

// ── Video textures ─────────────────────────────────────────────────────────────
function makeVideo(src) {
    const v = document.createElement('video');
    v.src         = src;
    v.loop        = true;
    v.muted       = true;
    v.playsInline = true;
    return v;
}

const video0 = makeVideo('assets/000.mp4');
const video1 = makeVideo('assets/grid.mp4');

const tex0 = new THREE.VideoTexture(video0);
const tex1 = new THREE.VideoTexture(video1);
tex0.minFilter = tex1.minFilter = THREE.LinearFilter;
tex0.magFilter = tex1.magFilter = THREE.LinearFilter;

// ── GlslPipeline — handles u_resolution, u_camera, u_viewMatrix,
//                  u_projectionMatrix, u_time, u_delta, etc. ─────────────────
const glsl = new GlslPipeline(renderer, {
    u_tex0:           { value: tex0 },
    u_tex0Resolution: { value: new THREE.Vector2(3840, 1080) },
    u_tex1:           { value: tex1 },
    u_tex1Resolution: { value: new THREE.Vector2(1600, 200) },
}, {
    blending:    THREE.AdditiveBlending,
    depthWrite:  false,
    transparent: true,
});

glsl.load(fragmentShader, vertexShader);

// ── Point-cloud geometry  (matches glslViewer's pcl_plane,256) ────────────────
const N     = 256;
const count = N * N;
const verts = new Float32Array(count * 3);
for (let row = 0; row < N; row++) {
    for (let col = 0; col < N; col++) {
        const i = (row * N + col) * 3;
        verts[i]     = col / (N - 1); // x  [0..1]
        verts[i + 1] = row / (N - 1); // y  [0..1]
        verts[i + 2] = 0;
    }
}
const geometry = new THREE.BufferGeometry();
geometry.setAttribute('position', new THREE.BufferAttribute(verts, 3));

// ── Scene ─────────────────────────────────────────────────────────────────────
const scene  = new THREE.Scene();
scene.add(new THREE.Points(geometry, glsl.material));

// ── Click-to-play overlay ─────────────────────────────────────────────────────
const overlay = document.getElementById('overlay');
overlay.addEventListener('click', () => {
    video0.play();
    video1.play();
    overlay.style.display = 'none';
}, { once: true });

// ── Resize ────────────────────────────────────────────────────────────────────
function onResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight); // resizes the canvas element
    glsl.setSize(window.innerWidth, window.innerHeight);      // updates u_resolution
}
window.addEventListener('resize', onResize);
onResize();

// ── Render loop ───────────────────────────────────────────────────────────────
function animate() {
    requestAnimationFrame(animate);
    controls.update();
    glsl.renderScene(scene, camera);
}
animate();
