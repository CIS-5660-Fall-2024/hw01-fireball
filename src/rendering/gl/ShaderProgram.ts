import {vec4, mat4, vec3} from 'gl-matrix';
import Drawable from './Drawable';
import {gl} from '../../globals';

var activeProgram: WebGLProgram = null;

export class Shader {
  shader: WebGLShader;

  constructor(type: number, source: string) {
    this.shader = gl.createShader(type);
    gl.shaderSource(this.shader, source);
    gl.compileShader(this.shader);
    
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);


    if (!gl.getShaderParameter(this.shader, gl.COMPILE_STATUS)) {
      throw gl.getShaderInfoLog(this.shader);
    }
  }
};

class ShaderProgram {
  prog: WebGLProgram;

  attrPos: number;
  attrNor: number;
  attrCol: number;

  unifModel: WebGLUniformLocation;
  unifModelInvTr: WebGLUniformLocation;
  unifViewProj: WebGLUniformLocation;
  unifColor: WebGLUniformLocation;

  unifTime: WebGLUniformLocation;
  unifCamPos: WebGLUniformLocation;

  unifSpinSpeed: WebGLUniformLocation;
  unifCross: WebGLUniformLocation;
  unifSwirl: WebGLUniformLocation;
  unifRad: WebGLUniformLocation;

  constructor(shaders: Array<Shader>) {
    this.prog = gl.createProgram();
  
    for (let shader of shaders) {
      gl.attachShader(this.prog, shader.shader);
    }
    gl.linkProgram(this.prog);
    if (!gl.getProgramParameter(this.prog, gl.LINK_STATUS)) {
      throw gl.getProgramInfoLog(this.prog);
    }

    this.attrPos = gl.getAttribLocation(this.prog, "vs_Pos");
    this.attrNor = gl.getAttribLocation(this.prog, "vs_Nor");
    this.attrCol = gl.getAttribLocation(this.prog, "vs_Col");
    this.unifModel      = gl.getUniformLocation(this.prog, "u_Model");
    this.unifModelInvTr = gl.getUniformLocation(this.prog, "u_ModelInvTr");
    this.unifViewProj   = gl.getUniformLocation(this.prog, "u_ViewProj");
    this.unifColor      = gl.getUniformLocation(this.prog, "u_Color");

    this.unifTime       = gl.getUniformLocation(this.prog, "u_Time");
    this.unifCamPos     = gl.getUniformLocation(this.prog, "u_CamPos");
    
    this.unifSpinSpeed  = gl.getUniformLocation(this.prog, "u_SpinSpeed");
    this.unifCross      = gl.getUniformLocation(this.prog, "u_Cross");
    this.unifSwirl      = gl.getUniformLocation(this.prog, "u_Swirl");
    this.unifRad        = gl.getUniformLocation(this.prog, "u_Rad");
  }

  use() {
    if (activeProgram !== this.prog) {
      gl.useProgram(this.prog);
      activeProgram = this.prog;
    }
  }

  setModelMatrix(model: mat4) {
    this.use();
    if (this.unifModel !== -1) {
      gl.uniformMatrix4fv(this.unifModel, false, model);
    }

    if (this.unifModelInvTr !== -1) {
      let modelinvtr: mat4 = mat4.create();
      mat4.transpose(modelinvtr, model);
      mat4.invert(modelinvtr, modelinvtr);
      gl.uniformMatrix4fv(this.unifModelInvTr, false, modelinvtr);
    }
  }

  setViewProjMatrix(vp: mat4) {
    this.use();
    if (this.unifViewProj !== -1) {
      gl.uniformMatrix4fv(this.unifViewProj, false, vp);
    }
  }

  setGeometryColor(color: vec4) {
    this.use();
    if (this.unifColor !== -1) {
      gl.uniform4fv(this.unifColor, color);
    }
  }

  setTime(time: number) {
    this.use();
    if (this.unifTime !== -1) {
      gl.uniform1f(this.unifTime, time);
    }
  }

  setCamPos(campos: vec3) {
    this.use();
    if (this.unifCamPos !== -1) {
      gl.uniform3fv(this.unifCamPos, campos);
    }
  }

  setSpinSpeed(speed: number) {
    this.use();
    if (this.unifSpinSpeed !== -1) {
      gl.uniform1f(this.unifSpinSpeed, speed);
    }
  }

  setCross(cross: number) {
    this.use();
    if (this.unifCross !== -1) {
      gl.uniform1f(this.unifCross, cross);
    }
  }
  
  setSwirl(swirl: number) {
    this.use();
    if (this.unifSwirl !== -1) {
      gl.uniform1f(this.unifSwirl, swirl);
    }
  }

  setRad(rad: number) {
    this.use();
    if (this.unifRad !== -1) {
      gl.uniform1f(this.unifRad, rad);
    }
  }

  draw(d: Drawable) {
    this.use();

    if (this.attrPos != -1 && d.bindPos()) {
      gl.enableVertexAttribArray(this.attrPos);
      gl.vertexAttribPointer(this.attrPos, 4, gl.FLOAT, false, 0, 0);
    }

    if (this.attrNor != -1 && d.bindNor()) {
      gl.enableVertexAttribArray(this.attrNor);
      gl.vertexAttribPointer(this.attrNor, 4, gl.FLOAT, false, 0, 0);
    }

    d.bindIdx();
    gl.drawElements(d.drawMode(), d.elemCount(), gl.UNSIGNED_INT, 0);

    if (this.attrPos != -1) gl.disableVertexAttribArray(this.attrPos);
    if (this.attrNor != -1) gl.disableVertexAttribArray(this.attrNor);
  }
};

export default ShaderProgram;
