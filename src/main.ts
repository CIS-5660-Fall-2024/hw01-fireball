import {mat4, vec2, vec3} from 'gl-matrix';
const Stats = require('stats-js');
import * as DAT from 'dat.gui';
import Cube from './geometry/Cube';
import Icosphere from './geometry/Icosphere';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';
import ModelLoader from './loader';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 5,
  'Load Scene': loadScene, // A function pointer, essentially
  renderEyes: true,
  taper: 1.2,
  height: 1.8,
  baseColor: [1.0 * 255, 0.5 * 255, 0.2 * 255],
  highlightColor: [1.0 * 255, 1.0 * 255, 0.3 * 255],
  outlineColor: [0.9 * 255, 0.35 * 255, 0.35 * 255],
  model: false,
  lighting: true,
};

// let square: Square;
let time: number = 0;
let cube: Cube;

function loadScene() {
  // square = new Square(vec3.fromValues(0, 0, 0));
  // square.create();
  cube = new Cube(vec3.fromValues(0, 0, 0));
  cube.create();
}

function main() {
  window.addEventListener('keypress', function (e) {
    // console.log(e.key);
    switch(e.key) {
      // Use this if you wish
    }
  }, false);

  window.addEventListener('keyup', function (e) {
    switch(e.key) {
      // Use this if you wish
    }
  }, false);

  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // Add controls to the gui
  const gui = new DAT.GUI();
  gui.add(controls, 'renderEyes');
  gui.add(controls, 'taper', 1.0, 2.0);
  gui.add(controls, 'height', 1.3, 5.0);
  gui.addColor(controls, 'baseColor');
  gui.addColor(controls, 'highlightColor');
  gui.addColor(controls, 'outlineColor');
  gui.add(controls, 'model');
  gui.add(controls, 'lighting');

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

  const camera = new Camera(vec3.fromValues(0, 0, -10), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(164.0 / 255.0, 233.0 / 255.0, 1.0, 1);
  gl.enable(gl.DEPTH_TEST);

  const flat = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/flat-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/flat-frag.glsl')),
  ]);
  
  const lambert = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/lambert-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/lambert-frag.glsl')),
  ]);

  const fire = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/fireball-tan-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/fireball-tan-frag.glsl')),
  ]);

  const fire_black = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/fireball-tan-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/fireball-black.glsl')),
  ]);

  const background = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/sphere-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/sphere-frag.glsl')),
  ]);

  function processKeyPresses() {
    // Use this if you wish
  }

  const ml = new ModelLoader();
  let head = ml.loadModel('./stylized_anime_female_head.glb');
  let sphere = ml.loadModel('./icosphere.glb');
  console.log(sphere);

  // This function will be called every frame
  function tick() {

    time = performance.now() / 1000;
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();
    processKeyPresses();
    // renderer.render(camera, flat, [
    //   square,
    // ], time);

    // sphere if you want to render the icosphere otherwise head
    let modelList = controls.model ? head : sphere;

    camera.updateProjectionMatrix();


    // background
    let viewNoTranslation = mat4.clone(camera.viewMatrix);
    viewNoTranslation[12] = 0;
    viewNoTranslation[13] = 0;
    viewNoTranslation[14] = 0;
    background.setUniformFloat('u_Time', time);

    // set depth test mode to less than or equal to
    gl.depthFunc(gl.LEQUAL);

      background.setUniformMat4('u_Proj', camera.projectionMatrix);
      background.setUniformMat4('u_View', viewNoTranslation);
      background.draw(cube);
    
    gl.depthFunc(gl.LESS);

    // put shaders into list
    let shaders = [fire, fire_black];

    for (let model of modelList) {
      
      let b = controls.lighting ? 1.0 : 0.0;

      // set uniforms of shaders

      for (let shader of shaders) {
        shader.setUniformFloat('lighting', b);
        shader.setUniformFloat('u_TaperFactor', controls.taper);
        shader.setUniformFloat('u_ScaleY', controls.height);
        shader.setUniformVec3('baseColor', vec3.fromValues(controls.baseColor[0] / 255.0, controls.baseColor[1] / 255.0, controls.baseColor[2] / 255.0));
        shader.setUniformVec3('highlightColor', vec3.fromValues(controls.highlightColor[0] / 255.0, controls.highlightColor[1] / 255.0, controls.highlightColor[2] / 255.0));
        shader.setUniformVec3('outlineColor', vec3.fromValues(controls.outlineColor[0] / 255.0, controls.outlineColor[1] / 255.0, controls.outlineColor[2] / 255.0));
      }
      // multiply transform by scale matrix
      let scale = mat4.create();
      mat4.fromScaling(scale, vec3.fromValues(1.05, 1.05, 1.05));
      // scale in local space
      let out = mat4.create();
      mat4.multiply(out, scale, model.transform);

      if (!controls.model) {
        gl.depthMask(false);
        fire_black.setModelMatrix(out);
        renderer.render(camera, fire_black, [
          model,
        ], time);
      }

      gl.depthMask(true);
      fire.setModelMatrix(model.transform);
      renderer.render(camera, fire, [
        model,
      ], time);
    }

    if (controls.renderEyes && !controls.model) {
      lambert.setUniformFloat('u_ScaleY', controls.height);
      lambert.setUniformFloat('u_TaperFactor', controls.taper);
      let offset = 0.5;
      lambert.setUniformVec3('u_Offset', vec3.fromValues(offset, 0, 0));
      for (let model of sphere) {
        lambert.setModelMatrix(model.transform);
        renderer.render(camera, lambert, [
          model,
        ], time);
      }
      lambert.setUniformVec3('u_Offset', vec3.fromValues(-offset, 0, 0));
      for (let model of sphere) {
        lambert.setModelMatrix(model.transform);
        renderer.render(camera, lambert, [
          model,
        ], time);
      }
    }

    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
    // flat.setDimensions(window.innerWidth, window.innerHeight);
    flat.setUniformVec2('u_Dimensions', vec2.fromValues(window.innerWidth, window.innerHeight));
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();
  // flat.setDimensions(window.innerWidth, window.innerHeight);
  flat.setUniformVec2('u_Dimensions', vec2.fromValues(window.innerWidth, window.innerHeight));

  // Start the render loop
  tick();
}

main();
