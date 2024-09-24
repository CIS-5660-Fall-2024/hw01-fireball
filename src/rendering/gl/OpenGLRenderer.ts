import {mat4, vec4, vec3} from 'gl-matrix';
import Drawable from './Drawable';
import Camera from '../../Camera';
import {gl} from '../../globals';
import ShaderProgram from './ShaderProgram';

// In this file, `gl` is accessible because it is imported above
class OpenGLRenderer {
  constructor(public canvas: HTMLCanvasElement) {
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

  render(camera: Camera, prog: ShaderProgram, drawables: Array<Drawable>, controls: any, card: boolean) {
    let model = mat4.create();
    let viewProj = mat4.create();
    let color = vec4.fromValues(controls.color[0]/255, controls.color[1]/255, controls.color[2]/255, controls.color[3]);
    let color2 = vec4.fromValues(controls.color2[0]/255, controls.color2[1]/255, controls.color2[2]/255, controls.color2[3]);

    mat4.identity(model);

    if (card) {
      // Compute the direction from the object to the camera
      let campos = camera.controls.eye; // Camera position
      let objpos = vec3.fromValues(model[12], model[13], model[14]); // Object position (assuming it's at the translation component of the matrix)
      let dirToCamera = vec3.create();
      vec3.subtract(dirToCamera, campos, objpos); // dirToCamera = campos - objpos
      vec3.normalize(dirToCamera, dirToCamera); // Normalize the direction

      // Use the direction to create a billboard rotation matrix
      let billboardMatrix = mat4.create();
      // You may use a helper function to compute the lookAt matrix, but instead of rotating the camera to face the object,
      // you are rotating the object to face the camera.
      mat4.targetTo(billboardMatrix, objpos, campos, camera.controls.up); // Up vector is typically (0, 1, 0)

      // Copy the rotation part of the billboard matrix to the model matrix
      model[0] = billboardMatrix[0]; model[1] = billboardMatrix[1]; model[2] = billboardMatrix[2];
      model[4] = billboardMatrix[4]; model[5] = billboardMatrix[5]; model[6] = billboardMatrix[6];
      model[8] = billboardMatrix[8]; model[9] = billboardMatrix[9]; model[10] = billboardMatrix[10];
    }

    mat4.multiply(viewProj, camera.projectionMatrix, camera.viewMatrix);
    
    prog.setModelMatrix(model);
    prog.setViewProjMatrix(viewProj);
    prog.setGeometryColor(color);
    prog.setGeometryColor2(color2); 
    prog.setGain(controls.gain); 
    prog.setResolution(this.canvas.width, this.canvas.height); 
    prog.setStarSpeed(controls.stars_speed); 
    prog.setStopMotion(controls.stop_motion); 
    prog.incrementTime(); 

    for (let drawable of drawables) {
      prog.draw(drawable);
    }
  }
};

export default OpenGLRenderer;
