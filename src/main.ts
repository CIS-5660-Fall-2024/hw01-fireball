import {vec3} from 'gl-matrix';
const Stats = require('stats-js');
import * as DAT from 'dat.gui';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';
import Cube from './geometry/Cube';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  'Load Scene': loadScene, // A function pointer, essentially
  Frequence: 1.0,
  Amplitude: 3.0,
  Wave_Length: 1.0,
  Inner_Color: [255, 255, 0],
  Outer_Color1: [255, 50, 50],
  Outer_Color2: [130, 0, 225],
  Outer_Color3: [30, 80, 220],
  Background: [255, 205, 220]
};

let icosphere: Icosphere;
let square: Square;
let prevTesselations: number = 5;
let cube: Cube;
let time: number = 0;

function loadScene() {
  // icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  // icosphere.create();
  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();
  //cube = new Cube(vec3.fromValues(0, 0, 0));
  //cube.create();
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
  gui.add(controls, 'Load Scene');
  gui.add(controls, 'Frequence', 1, 5).step(0.5);
  gui.add(controls, 'Amplitude', 2, 3).step(0.2);
  gui.add(controls, 'Wave_Length', 0.5, 5.0).step(0.5);
  gui.addColor(controls, 'Inner_Color');
  gui.addColor(controls, 'Outer_Color1');
  gui.addColor(controls, 'Outer_Color2');
  gui.addColor(controls, 'Outer_Color3');
  gui.addColor(controls, 'Background');

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

  const camera = new Camera(vec3.fromValues(0, 1, 3), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(0.2, 0.2, 0.2, 1);
  gl.enable(gl.DEPTH_TEST);

  const lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/custom-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/custom-frag.glsl')),
  ]);

  // This function will be called every frame
  function tick() {
    time++;
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();

    lambert.setC0([
      controls.Inner_Color[0] / 255.0 *2.5,
      controls.Inner_Color[1] / 255.0 *2.5,
      controls.Inner_Color[2] / 255.0 *2.5,
      2.5
    ])
    lambert.setC1([
      controls.Outer_Color1[0] / 255.0 * 1.5,
      controls.Outer_Color1[1] / 255.0 * 1.5,
      controls.Outer_Color1[2] / 255.0 * 1.5,
      1.5
    ])
    lambert.setC2([
      controls.Outer_Color2[0] / 255.0,
      controls.Outer_Color2[1] / 255.0,
      controls.Outer_Color2[2] / 255.0,
      1
    ])
    lambert.setC3([
      controls.Outer_Color3[0] / 255.0,
      controls.Outer_Color3[1] / 255.0,
      controls.Outer_Color3[2] / 255.0,
      1
    ])
    lambert.setC4([
      controls.Background[0] / 255.0,
      controls.Background[1] / 255.0,
      controls.Background[2] / 255.0,
      1
    ])

    lambert.setFrequence(controls.Frequence);
    lambert.setAmplitude(controls.Amplitude);
    lambert.setWaveLength(controls.Wave_Length);

    lambert.setTime(time);

    renderer.render(camera, lambert, [
      //icosphere,
      //cube
      square,
    ]);
    stats.end();

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
