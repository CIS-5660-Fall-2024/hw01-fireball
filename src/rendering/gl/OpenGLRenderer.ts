import {mat4, vec4, vec2} from 'gl-matrix';
import Drawable from './Drawable';
import Camera from '../../Camera';
import {gl} from '../../globals';
import ShaderProgram from './ShaderProgram';

// In this file, `gl` is accessible because it is imported above
class OpenGLRenderer {
  mouse_x: number = 0;
  mouse_y: number = 0;
  mouse_drag_x: number = 0;
  mouse_drag_y: number = 0;
  is_drag: boolean = false;
  constructor(public canvas: HTMLCanvasElement) {
    canvas.addEventListener('mousedown', (event: MouseEvent) => {
      this.is_drag = true;
    });
    canvas.addEventListener('mouseup', (event: MouseEvent) => {
      this.is_drag = false;
    });
    canvas.addEventListener('mousemove', (event: MouseEvent) => {
      const rect = canvas.getBoundingClientRect();
      this.mouse_x = event.clientX - rect.left;
      this.mouse_y = event.clientY - rect.top;
      if(this.is_drag){
        this.mouse_drag_x = event.clientX - rect.left;
        this.mouse_drag_y = event.clientY - rect.top;
      }
    });
  }

  setClearColor(r: number, g: number, b: number, a: number) {
    gl.clearColor(r, g, b, a);
  }

  setSize(width: number, height: number) {
    this.canvas.width = width;
    this.canvas.height = height;
  }

  clear() {
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  }

  render(camera: Camera, prog: ShaderProgram, drawables: Array<Drawable>) {
    let model = mat4.create();
    let viewProj = mat4.create();
    let color = vec4.fromValues(1, 0, 0, 1);

    mat4.identity(model);
    mat4.multiply(viewProj, camera.projectionMatrix, camera.initialViewMatrix);
    prog.setModelMatrix(model);
    prog.setViewProjMatrix(viewProj);
    prog.setViewMatrix(camera.viewMatrix);
    prog.setMouse(vec2.fromValues(this.mouse_x,this.mouse_y));
    prog.setDrag(vec2.fromValues(this.mouse_drag_x,this.mouse_drag_y));
    prog.setProjectionMatrix(camera.projectionMatrix);
    prog.setScreenSize(vec2.fromValues(this.canvas.width, this.canvas.height));

    //prog.setGeometryColor(color);

    for (let drawable of drawables) {
      prog.draw(drawable);
    }
  }
};

export default OpenGLRenderer;
