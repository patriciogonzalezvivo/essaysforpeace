# essays for peace

Point-cloud depth video rendered as a WebGL scene.

## glslViewer (native)

```bash
make 000
```

Requires [glslViewer](https://github.com/patriciogonzalezvivo/glslViewer) installed.

---

## Web (Three.js)

### Install

```bash
make install
# or: npm install
```

### Dev server

```bash
make web
# or: npm run dev
```

Opens `http://localhost:5173`. Click the canvas to start video playback.

### Production build

```bash
npm run build   # output → dist/
npm run preview # preview the build locally
```

---

## How it works

| glslViewer flag | Web equivalent |
|---|---|
| `pcl_plane,256` | 256×256 `THREE.Points` BufferGeometry, positions in [0,1] |
| `assets/000.mp4` → `u_tex0` | `THREE.VideoTexture` — left half color, right half depth |
| `assets/grid.mp4` → `u_tex1` | `THREE.VideoTexture` — 9-sprite sheet |
| `-e blend,add` | `THREE.AdditiveBlending` |

Shaders live in `src/shaders/`. They are the same logic as `shaders/` but with:
- lygia functions inlined (`luma`, `random`, `sprite`, `scale`)
- `a_position` / `u_modelMatrix` etc. replaced with Three.js built-in uniforms
  (`position`, `modelMatrix`, `viewMatrix`, `projectionMatrix`, `cameraPosition`)

### glsl-pipeline

If you want the uniform naming to stay 1:1 with glslViewer (`u_time`, `u_mouse`, etc.), drop in [glsl-pipeline](https://github.com/patriciogonzalezvivo/glsl-pipeline):

```bash
npm install glsl-pipeline
```

```js
import { GlslPipeline } from 'glsl-pipeline';
const glsl = new GlslPipeline(renderer);
glsl.addTexture('u_tex0', tex0);
glsl.addTexture('u_tex1', tex1);
const material = glsl.material(fragmentShader, vertexShader);
// glsl.render() drives u_time, u_resolution, u_texNResolution automatically
```
