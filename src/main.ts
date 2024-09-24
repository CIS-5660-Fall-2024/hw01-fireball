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

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 5,
  'Load Scene': loadScene, // A function pointer, essentially
  Color: [100.0, 1.0, 1.0, 1.0],
  CoreColor: [223.0, 239.0, 150.0, 1.0],
  degreeOfEruption : 0.3,
  ColorBias:0.4,
};

let icosphere: Icosphere;
let square: Square;
let cube:Cube;
let prevTesselations: number = 5;
let time: number = 0;
let center: vec3 = vec3.fromValues(0.0, 0.0, 0.0);
let degreeOfEruption: number = 0.3;
let ColorBias:number = 0.4;


function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  icosphere.create();
  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();
  cube = new Cube(vec3.fromValues(0, 0, 0));
  cube.create();
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
  gui.add(controls, 'tesselations', 0, 8).step(1);
  gui.add(controls, 'Load Scene');
  gui.addColor(controls, 'Color');
  gui.addColor(controls, 'CoreColor');
  gui.add(controls, 'degreeOfEruption', 0.1, 1.0).step(0.1)
  gui.add(controls, 'ColorBias', 0.0, 1.0).step(0.1)
  

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

  const fireball = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/fireball-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/fireball-frag.glsl')),
  ]);
  
  // This function will be called every frame
  function tick() {
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();

    const colorLocation= gl.getUniformLocation(fireball.prog, 'u_Color');
    gl.uniform4f(colorLocation, controls.Color[0]/255.0, controls.Color[1]/255.0, controls.Color[2]/255.0, controls.Color[3]);

    const CoreColorLocation= gl.getUniformLocation(fireball.prog, 'u_CoreColor');
    gl.uniform4f(CoreColorLocation, controls.CoreColor[0]/255.0, controls.CoreColor[1]/255.0, controls.CoreColor[2]/255.0, controls.CoreColor[3]);

    const timeLocation= gl.getUniformLocation(fireball.prog, 'u_Time');
    time+=0.01;
    gl.uniform1f(timeLocation, time);

    const centerLocation= gl.getUniformLocation(fireball.prog, 'u_Center');
    gl.uniform3f(centerLocation, 0.0,0.0,0.0);

    const eruptionLocation= gl.getUniformLocation(fireball.prog, 'u_Eruption');
    gl.uniform1f(eruptionLocation, controls.degreeOfEruption);

    const biasLocation= gl.getUniformLocation(fireball.prog, 'u_ColorBias');
    gl.uniform1f(biasLocation, controls.ColorBias);
    
    if(controls.tesselations != prevTesselations)
    {
      prevTesselations = controls.tesselations;
      icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, prevTesselations);
      icosphere.create();
    }
  
    renderer.render(camera, fireball, [
       icosphere, 
       //square,
       //cube,
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
