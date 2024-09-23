import {mat4, vec3, vec4} from 'gl-matrix';
import Drawable from './Drawable';
import Camera from '../../Camera';
import {gl} from '../../globals';
import ShaderProgram from './ShaderProgram';

// In this file, `gl` is accessible because it is imported above
class OpenGLRenderer {
  objColor = vec4.fromValues(0, 0, 1, 1);

  constructor(public canvas: HTMLCanvasElement) {
  }

  setClearColor(r: number, g: number, b: number, a: number) {
    gl.clearColor(r, g, b, a);
  }

  setObjColor(r: number, g: number, b: number, a: number) {
    this.objColor = vec4.fromValues(r, g, b, a);
  }

  setSize(width: number, height: number) {
    this.canvas.width = width;
    this.canvas.height = height;
  }

  setTime(time: number, prog: ShaderProgram) {
    prog.setTime(time);
  }

  setCamPos(campos: vec3, prog: ShaderProgram) {
    prog.setCamPos(campos);
  }

  setSpinSpeed(speed: number, prog: ShaderProgram) {
    prog.setSpinSpeed(speed);
  }

  setCross(cross: number, prog: ShaderProgram) {
    prog.setCross(cross);
  }

  setSwirl(swirl: number, prog: ShaderProgram) {
    prog.setSwirl(swirl);
  }

  setRad(rad: number, prog: ShaderProgram) {
    prog.setRad(rad);
  }


  clear() {
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  }

  render(camera: Camera, prog: ShaderProgram, drawables: Array<Drawable>) {
    let model = mat4.create();
    let viewProj = mat4.create();
    let color = this.objColor;

    mat4.identity(model);
    mat4.multiply(viewProj, camera.projectionMatrix, camera.viewMatrix);
    prog.setModelMatrix(model);
    prog.setViewProjMatrix(viewProj);
    prog.setGeometryColor(color);
  

    for (let drawable of drawables) {
      prog.draw(drawable);
    }
  }
};

export default OpenGLRenderer;
