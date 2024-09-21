import {vec3, vec4, mat4} from 'gl-matrix';
const Stats = require('stats-js');
import * as DAT from 'dat.gui';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';
import Cube from './geometry/Cube';

enum shape {
  Cube = "Cube",
  Icosphere = "Icosphere"
}
// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 1,
  color: [252,214,0],
  shape: shape.Icosphere,
  scale: 10,
  speed: 1,
  size: 0.4,
  'Load Scene': loadScene, // A function pointer, essentially
};

let icosphere: Icosphere;
let skyBox: Icosphere;
let fireball_center: Icosphere;
let square: Square;
let cube : Cube;
let prevTesselations: number = 5;
let time: GLfloat = 0.0;
let scale: GLfloat = 10;
let speed: number = 1;
let size: GLfloat = 0.4;


function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  icosphere.create();
  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();
  cube = new Cube(vec3.fromValues(0,0,0));
  cube.create();
  skyBox = new Icosphere(vec3.fromValues(0, 0, 0), 100, 3);
  skyBox.create();
  fireball_center = new Icosphere(vec3.fromValues(0, 0, 0), 0.85, 5);
  fireball_center.create();
}

function main() {
  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // Add controls to the gui
  const gui = new DAT.GUI();
  var palette = {
    color: [252,214,0]
  };
  gui.addColor(palette, 'color');
  gui.add(controls, 'tesselations', 0, 5).step(1);
  gui.add(controls, 'shape', {Icosphere: shape.Icosphere, Cube: shape.Cube}).name('Shape');
  //gui.add(controls, 'scale', 0.1, 10).step(0.1);
  gui.add(controls, 'speed', 1, 10).step(1);
  gui.add(controls, 'size', 0.3, 0.6).step(0.1);
  gui.add(controls, 'Load Scene');
  
  // get canvas and webgl context
  const canvas = <HTMLCanvasElement> document.getElementById('canvas');
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  const camera = new Camera(vec3.fromValues(0, 0, 5), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(0.2, 0.2, 0.2, 1);
  gl.enable(gl.DEPTH_TEST);

  const sky = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/skyboxS-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/skyboxS-frag.glsl')),
  ]);

  const lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/lambert-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/lambert-frag.glsl')),
  ]);

  const noise = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/FBM-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/FBM-frag.glsl')),
  ]);

  const fireball = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/Fireball-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/Fireball-frag.glsl')),
  ]);

  const fireball_center_shader = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/Fireball_center-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/Fireball_center-frag.glsl')),
  ]);

  // This function will be called every frame
  function tick() {
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();
    if(controls.tesselations != prevTesselations)
    {
      prevTesselations = controls.tesselations;
      icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, prevTesselations);
      icosphere.create();
    }
    const color = vec4.fromValues(
      palette.color[0] / 255.0,
      palette.color[1] / 255.0,
      palette.color[2] / 255.0,
      1.0
    );
    
    noise.setTime(time);
    noise.setScale(controls.scale);
    fireball.setTime(time);
    fireball.setSize(controls.size);
    fireball_center_shader.setTime(time);
    fireball_center_shader.setScale(4.0);
    fireball_center_shader.setSize(controls.size * 2.5);
    sky.setTime(time * 0.1);
    // render objects
    renderer.render(
      camera, sky, [skyBox], color
    );
    // switch rendering shapes
    if (controls.shape === shape.Icosphere) {
      renderer.render(
        camera, fireball, [icosphere], color
      );
    }
    else if (controls.shape === shape.Cube) {
      renderer.render(
        camera, noise, [cube], color
      );
    }
    renderer.render(
      camera, fireball_center_shader, [fireball_center], color
    );
    stats.end();
    time += (controls.speed / 100);
    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  // Start the render loop
  tick();
}

main();
