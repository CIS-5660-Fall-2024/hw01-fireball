import {vec3, vec4} from 'gl-matrix';
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
  tesselations: 5,
  color: [255, 0, 0, 1],  // initial color is red (RGB)
  'Load Scene': loadScene, // A function pointer, essentially
  // 'Lambert': changeToLambert,
  // 'Perlin': changeToPerlin,
  // 'Worley': changeToWorley,
  // 'Custom': changeToCustom,
  // 'Normal': changeToRegular,
  // 'Expand': changeToExpand,
  // 'Collapse': changeToCollapse,
  // 'Distort':changeToDistort,
};

var vertShader = require('./shaders/fireball-vert.glsl');
var fragShader = require('./shaders/fireball-frag.glsl');
function changeToLambert()
{
  fragShader = require('./shaders/lambert-frag.glsl');
}
function changeToPerlin()
{
  fragShader = require('./shaders/perlin-frag.glsl');
}
function changeToWorley()
{
  fragShader = require('./shaders/worley-frag.glsl');
}
function changeToCustom()
{
  fragShader = require('./shaders/custom-frag.glsl');
}
function changeToRegular()
{
  vertShader = require('./shaders/lambert-vert.glsl');
}
function changeToExpand()
{
  vertShader = require('./shaders/expand-vert.glsl');
}
function changeToCollapse()
{
  vertShader = require('./shaders/collapse-vert.glsl');
}
function changeToDistort()
{
  vertShader = require('./shaders/fireball-vert.glsl');
}
var prevFragShader = fragShader;
var prevVertShader = vertShader;

let icosphere: Icosphere;
let square: Square;
let cube: Cube;
let prevTesselations: number = 5;

var count = 1;

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
  gui.addColor(controls, 'color');

  // var fragShaderGUI = gui.addFolder('Frag Shaders');
  // fragShaderGUI.add(controls, 'Lambert');
  // fragShaderGUI.add(controls, 'Perlin');
  // fragShaderGUI.add(controls, 'Worley');
  // fragShaderGUI.add(controls, 'Custom');

  // var vertShaderGUI = gui.addFolder('Vert Shaders');
  // vertShaderGUI.add(controls, 'Normal');
  // vertShaderGUI.add(controls, 'Expand');
  // vertShaderGUI.add(controls, 'Collapse');
  // vertShaderGUI.add(controls, 'Distort');

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

  var activeShader = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, vertShader),
    new Shader(gl.FRAGMENT_SHADER, fragShader),
  ]);

  // const lambert = new ShaderProgram([
  //   new Shader(gl.VERTEX_SHADER, require('./shaders/lambert-vert.glsl')),
  //   new Shader(gl.FRAGMENT_SHADER, require('./shaders/worley-frag.glsl')),
  // ]);

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

    const normalizedColor = vec4.create();

    // Normalize each component by dividing by 255
    vec4.set(normalizedColor,
      controls.color[0] / 255.0,
      controls.color[1] / 255.0,
      controls.color[2] / 255.0,
      controls.color[3]
    );

    if (prevFragShader != fragShader || prevVertShader != vertShader)
      {
        activeShader = new ShaderProgram([
        new Shader(gl.VERTEX_SHADER, vertShader),
        new Shader(gl.FRAGMENT_SHADER, fragShader),
        ]);

        prevFragShader = fragShader;
        prevVertShader = vertShader;
      }

    renderer.renderFireball(camera, activeShader, [
      icosphere,
      // square,
      // cube,
    ], normalizedColor, vec4.fromValues(1.0,1.0,0,0));
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
