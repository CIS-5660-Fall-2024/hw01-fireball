import {vec3} from 'gl-matrix';
const Stats = require('stats-js');
import * as DAT from 'dat.gui';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import Cube from './geometry/Cube';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';
import TesCube from './geometry/TesTest';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 8, // start at higher resolution :)
  speed: 8.0,
  mode: 0,
  swirl: 8.0,
  rad: 1.0,
  'Load Scene': loadScene, // A function pointer, essentially
  'Reset': reset,
  Color: [0, 210, 255],
};

let icosphere: Icosphere;
let square: Square;
let square2: Square;
let square3: Square;
let cube: Cube;
let cube2: Cube;
let tesCube: TesCube;
let prevTesselations: number = 8;
let prevColor: number[] = [255, 0, 255];
let time = 0;
let prevSpeed = 8.0;
let prevMode = 0.0;
let prevSwirl = 8.0;
let prevRad = 1.0;

let resetBool = 0.0;

function reset() {
  resetBool = 1.0;
  }

function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  icosphere.create();

  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();
  square2 = new Square(vec3.fromValues(0, 0, 0.4));
  square2.create();
  square3 = new Square(vec3.fromValues(0, 0, 0.8));
  square3.create();

  cube = new Cube(vec3.fromValues(0,0,0), 30); // adjust side length as needed
  cube.create();
  cube2 = new Cube(vec3.fromValues(0,0,0), 2); // adjust side length as needed
  cube2.create();

  tesCube = new TesCube(vec3.fromValues(0,0,0), 1);
  tesCube.create();
}


function main() {
  // Initial display for framerate
  // hello I am a test comment
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // Add controls to the gui
  const gui = new DAT.GUI();
  gui.add(controls, 'tesselations', 0, 8).step(1);
  gui.add(controls, 'speed', 0, 20.0).step(0.1);
  gui.add(controls, 'mode', 0, 1).step(1);
  gui.add(controls, 'swirl', 0, 20.0).step(0.1);
  gui.add(controls, 'rad', 0, 3.0).step(0.1);
  gui.add(controls, 'Load Scene');
  gui.addColor(controls, 'Color');
  gui.add(controls, 'Reset');

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
  reset();

  const camera = new Camera(vec3.fromValues(0, 0, 5), vec3.fromValues(0, 0, 0));
  const renderer = new OpenGLRenderer(canvas);
  renderer.setObjColor(controls.Color[0] / 255, controls.Color[1] / 255, controls.Color[2] / 255, 1);
  renderer.setClearColor(0, 0, 0, 1);
  
  gl.enable(gl.DEPTH_TEST);

  const lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/lambert-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/lambert-frag.glsl')),
  ]);

  const custom = new ShaderProgram([
      new Shader(gl.VERTEX_SHADER, require('./shaders/custom-vert.glsl')), 
      new Shader(gl.FRAGMENT_SHADER, require('./shaders/custom-frag.glsl')),
  ]);

  const fireBall = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/fireBall-vert.glsl')), 
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/fireBall-frag.glsl')),
  ]);

  const bgBox = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/bgBox-vert.glsl')), 
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/bgBox-frag.glsl')),
  ]);

  // set initial values
  renderer.setCamPos(vec3.fromValues(0.0,0.0,5.0), fireBall);
  renderer.setSpinSpeed(8.0, fireBall);
  renderer.setSwirl(8.0, fireBall);
  renderer.setRad(1.0, fireBall);

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

    if(controls.Color != prevColor) {  // update cube color base on control
      prevColor = controls.Color;
      renderer.setObjColor(controls.Color[0] / 255, controls.Color[1] / 255, controls.Color[2] / 255, 1);

    }

    if(controls.speed != prevSpeed) {
      prevSpeed = controls.speed;
      renderer.setSpinSpeed(controls.speed, fireBall);
    }

    if(controls.mode != prevMode){
      prevMode = controls.mode;
      renderer.setCross(controls.mode, fireBall);
    }

    if(controls.swirl != prevSwirl){
      prevSwirl = controls.swirl;
      renderer.setSwirl(controls.swirl, fireBall);
    }

    if (controls.rad != prevRad) {
      prevRad = controls.rad;
      renderer.setRad(controls.rad, fireBall);
    }
    
    // CHANGE WHAT IS RENDERED HERE
    renderer.render(camera, fireBall, [ // Change shaders
      icosphere,
      //square,
      // square2, square3
      
      //tesCube
    ]);

    // CREATE NEW SHADER FOR A BG HERE
    renderer.render(camera, bgBox, [
      cube,
    ]);
    
    stats.end();
    renderer.setTime(time, fireBall);
    renderer.setTime(time, bgBox);
    renderer.setCamPos(camera.controls.eye, fireBall);
    time++;
    
    if (resetBool == 1.0) {
      controls.swirl = 8.0;
      controls.speed = 8.0;
      controls.mode = 0.0;
      controls.rad = 1.0;
      
      renderer.setCamPos(vec3.fromValues(0.0,0.0,5.0), fireBall);
      renderer.setSpinSpeed(8.0, fireBall);
      renderer.setSwirl(8.0, fireBall);
      renderer.setRad(1.0, fireBall);
      resetBool = 0.0;
    }

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
