import { vec3, vec4 } from 'gl-matrix';
// import * as Stats from 'stats-js';
import * as DAT from 'dat.gui';
import Square from './geometry/Square';
import Icosphere from './geometry/Icosphere';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import { setGL } from './globals';
import ShaderProgram, { Shader } from './rendering/gl/ShaderProgram';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const color = [255, 28, 28];
const flameColor = [255, 180, 28];
// const color = [240, 240, 240];
// const flameColor = [83, 115, 217];
const flameHeight = 0.5;

const controls = {
  'color': color,
  'flameColor': flameColor,
  'flameHeight': flameHeight,
  'Reset Fireball': loadScene, // A function pointer, essentially
};

let square: Square;
let icosphere: Icosphere;
let time: number = 0;

function loadScene() {
  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();
  icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, 5);
  icosphere.create();
  controls.color = color;
  controls.flameColor = flameColor;
  controls.flameHeight = flameHeight;
  time = 0;
}

function main() {
  window.addEventListener('keypress', function (e) {
    // console.log(e.key);
    switch (e.key) {
      // Use this if you wish
    }
  }, false);

  window.addEventListener('keyup', function (e) {
    switch (e.key) {
      // Use this if you wish
    }
  }, false);


  // Initial display for framerate
  // const stats = Stats();
  // stats.setMode(0);
  // stats.domElement.style.position = 'absolute';
  // stats.domElement.style.left = '0px';
  // stats.domElement.style.top = '0px';
  // document.body.appendChild(stats.domElement);

  // Add controls to the gui
  const gui = new DAT.GUI();
  gui.addColor(controls, 'color').listen();
  gui.addColor(controls, 'flameColor').listen();
  gui.add(controls, 'flameHeight', 0, 1).step(.01).listen();
  gui.add(controls, 'Reset Fireball');

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

  const camera = new Camera(vec3.fromValues(0, 1.2, 6), vec3.fromValues(0, 1.2, 0));

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(0.2, 0.2, 0.2, 1);
  gl.enable(gl.DEPTH_TEST);
  gl.enable(gl.BLEND);
  gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

  const fireball = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/fireball-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/fireball-frag.glsl')),
  ]);

  const background = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/background-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/background-frag.glsl')),
  ]);

  const progs = [fireball, background];

  const vec4FromColor = ((color: number[], alpha: number) => {
    return vec4.fromValues(color[0] / 255.0, color[1] / 255.0, color[2] / 255.0, alpha);
  });

  // This function will be called every frame
  function tick() {
    camera.update();
    // stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();

    for (const prog of progs) {
      prog.setColor(vec4FromColor(controls.color, 1.0));
      prog.setFlameColor(vec4FromColor(controls.flameColor, 1.0));
      prog.setFlameHeight(controls.flameHeight);
      prog.setDimensions(window.innerWidth, window.innerHeight);
    }

    renderer.clear();

    renderer.render(camera, background, [square], time);
    renderer.render(camera, fireball, [icosphere], time);
    time++;
    // stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function () {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
    for (const prog of progs) {
      prog.setDimensions(window.innerWidth, window.innerHeight);
    }
  }, false);

  // Start the render loop
  tick();
}

main();
