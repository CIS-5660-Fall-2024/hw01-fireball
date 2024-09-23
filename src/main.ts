import { vec3, vec4 } from 'gl-matrix';
const Stats = require('stats-js');
import * as DAT from 'dat.gui';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import { setGL } from './globals';
import ShaderProgram, { Shader } from './rendering/gl/ShaderProgram';
import Cube from './geometry/Cube';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 5,
  'Load Scene': loadScene, // A function pointer, essentially
  'Reset Scene': resetScene, // A function pointer, essentially
  fireball_colour: [255, 0, 0],
  ground_colour: [255, 0, 0],
  sky_colour: [255, 0, 0],
  fireball_scale: 1.
};

let icosphere: Icosphere;
let square: Square;
let cube: Cube;
let prevTesselations: number = 5;
let gui: DAT.GUI;

function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  icosphere.create();
  square = new Square(vec3.fromValues(0, -10, 0));
  square.create();
  cube = new Cube(vec3.fromValues(0, 0, 0), 100);
  cube.create();
}

function resetScene() {
  controls.fireball_colour = [255,0,0];
  controls.ground_colour = [255,0,0];
  controls.sky_colour = [255,0,0];
  controls.fireball_scale = 1.;
  gui.destroy();
  gui = new DAT.GUI();
  addGuiElements();
}

function addGuiElements(){
  gui.add(controls, 'tesselations', 0, 8).step(1);
  gui.add(controls, 'Load Scene');
  gui.add(controls, 'Reset Scene');
  gui.add(controls, 'fireball_scale', 0.5, 3).step(0.1);
  gui.addColor(controls, 'fireball_colour');
  gui.addColor(controls, 'ground_colour');
  gui.addColor(controls, 'sky_colour');
}

function main() {
  // Initial display for framerate
  const stats = Stats();
  let u_tick: GLfloat = 0;
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // Add controls to the gui
  gui = new DAT.GUI();
  addGuiElements();

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement>document.getElementById('canvas');
  const gl = <WebGL2RenderingContext>canvas.getContext('webgl2');
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
  const skybox = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/skybox-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/skybox-frag.glsl')),
  ]);
  const flame = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/fireball-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/fireball-frag.glsl')),
  ]);
  const ground = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/ground-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/ground-frag.glsl')),
  ]);

  // This function will be called every frame
  function tick() {
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();
    if (controls.tesselations != prevTesselations) {
      prevTesselations = controls.tesselations;
      icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, prevTesselations);
      icosphere.create();
    }
    flame.setGeometryColor(vec4.fromValues(controls.fireball_colour[0] / 255, controls.fireball_colour[1] / 255, controls.fireball_colour[2] / 255, 1));
    flame.setScale(controls.fireball_scale);
    flame.setSecondaryColor(vec4.fromValues(controls.ground_colour[0] / 255, controls.ground_colour[1] / 255, controls.ground_colour[2] / 255, 1));
    flame.setTertiaryColor(vec4.fromValues(controls.sky_colour[0] / 255, controls.sky_colour[1] / 255, controls.sky_colour[2] / 255, 1));
    ground.setGeometryColor(vec4.fromValues(controls.ground_colour[0] / 255, controls.ground_colour[1] / 255, controls.ground_colour[2] / 255, 1));
    skybox.setGeometryColor(vec4.fromValues(controls.sky_colour[0] / 255, controls.sky_colour[1] / 255, controls.sky_colour[2] / 255, 1));
    skybox.setSecondaryColor(vec4.fromValues(controls.ground_colour[0] / 255, controls.ground_colour[1] / 255, controls.ground_colour[2] / 255, 1));

    renderer.render(camera, flame, u_tick, [icosphere]);
    renderer.render(camera, ground, u_tick, [square]);
    renderer.render(camera, skybox, u_tick, [cube]);
    u_tick += 1;
    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function () {
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
