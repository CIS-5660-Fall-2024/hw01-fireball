import {vec3, vec4} from 'gl-matrix';
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
  'UpperFireColor': [255, 230, 77],
  'LowerFireColor': [255, 126, 51],
  'EnableBackground': true,
  'FireIntensity': 2,
  'Reset': resetFireball
};


let icosphere: Icosphere;
let square: Square;
let cube: Cube;
let prevTesselations: number = 5;
let time: number = 0;
function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, controls.tesselations);
  icosphere.create();
  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();
  cube = new Cube(vec3.fromValues(0, 0, 0));
  cube.create();
}

function resetFireball() {
    controls.EnableBackground = true;
    controls.FireIntensity = 2;
    controls.UpperFireColor = [255, 230, 77];
    controls.LowerFireColor = [255, 126, 51];
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
  gui.addColor(controls, 'UpperFireColor');
  gui.addColor(controls, 'LowerFireColor');
  gui.add(controls, 'EnableBackground');
  gui.add(controls, 'FireIntensity', 1, 3).step(0.5);
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

  const camera = new Camera(vec3.fromValues(0, 0, 5), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(0, 0, 0, 1);
  gl.enable(gl.DEPTH_TEST);
  gl.enable(gl.BLEND);
  gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA); //alpha blending

  const shader = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/custom-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/custom-frag.glsl')),
  ]);

  const backGroundShader = new ShaderProgram([
      new Shader(gl.VERTEX_SHADER, require('./shaders/bg-vert.glsl')),
      new Shader(gl.FRAGMENT_SHADER, require('./shaders/bg-frag.glsl')),
  ]);

  // This function will be called every frame
  function tick() {
    gui.updateDisplay();
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

    const normalizedColorUpper = vec4.fromValues(controls.UpperFireColor[0] / 255, controls.UpperFireColor[1] / 255, controls.UpperFireColor[2] / 255, 1);
    shader.setUpperColor(normalizedColorUpper);
    const normalizedColorLower = vec4.fromValues(controls.LowerFireColor[0] / 255, controls.LowerFireColor[1] / 255, controls.LowerFireColor[2] / 255, 1);
    shader.setLowerColor(normalizedColorLower);

    time++;
    shader.setTime(time);
    shader.setCameraPos(vec4.fromValues(camera.controls.eye[0], camera.controls.eye[1], camera.controls.eye[2], 0));
    shader.setFireIntensity(controls.FireIntensity);

    if (controls.EnableBackground) {
        backGroundShader.setTime(time);

        gl.depthMask(false);
        renderer.render(camera, backGroundShader, [
            square,
        ]);
        gl.depthMask(true);
    }

    renderer.render(camera, shader, [
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
    backGroundShader.setDimensions(window.innerWidth, window.innerHeight);
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();
  backGroundShader.setDimensions(window.innerWidth, window.innerHeight);

  // Start the render loop
  tick();
}

main();
