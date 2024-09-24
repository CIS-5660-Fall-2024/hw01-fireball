import {vec4, mat4, vec2} from 'gl-matrix';
import Drawable from './Drawable';
import {gl} from '../../globals';

var activeProgram: WebGLProgram = null;

export class Shader {
  shader: WebGLShader;

  constructor(type: number, source: string) {
    this.shader = gl.createShader(type);
    gl.shaderSource(this.shader, source);
    gl.compileShader(this.shader);

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
  unifView: WebGLUniformLocation;
  unifTime: WebGLUniformLocation;
  unifProj: WebGLUniformLocation;
  screenSize: WebGLUniformLocation;
  unifMouse: WebGLUniformLocation;
  unifDrag: WebGLUniformLocation;

  unifC0: WebGLUniformLocation;
  unifC1: WebGLUniformLocation;
  unifC2: WebGLUniformLocation;
  unifC3: WebGLUniformLocation;
  unifC4: WebGLUniformLocation;

  unifFreq: WebGLUniformLocation;
  unifAmp: WebGLUniformLocation;
  unifWave: WebGLUniformLocation;

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
    this.unifProj   = gl.getUniformLocation(this.prog, "u_Proj");
    this.unifView   = gl.getUniformLocation(this.prog, "u_View");
    this.unifC0      = gl.getUniformLocation(this.prog, "c0");
    this.unifC1      = gl.getUniformLocation(this.prog, "c1");
    this.unifC2      = gl.getUniformLocation(this.prog, "c2");
    this.unifC3      = gl.getUniformLocation(this.prog, "c3");
    this.unifC4      = gl.getUniformLocation(this.prog, "c4");
    this.screenSize      = gl.getUniformLocation(this.prog, "screenSize");
    this.unifTime = gl.getUniformLocation(this.prog, "u_Time");
    this.unifMouse = gl.getUniformLocation(this.prog, "u_Mouse");
    this.unifDrag = gl.getUniformLocation(this.prog, "u_Drag");
    this.unifFreq = gl.getUniformLocation(this.prog, "u_Freq");
    this.unifAmp = gl.getUniformLocation(this.prog, "u_Amp");
    this.unifWave = gl.getUniformLocation(this.prog, "u_Wave");
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
  setViewMatrix(v: mat4)
  {
    this.use();
    if (this.unifView !== -1) {
      gl.uniformMatrix4fv(this.unifView, false, v);
    }
  }
  setProjectionMatrix(p: mat4)
  {
    this.use();
    if(this.unifProj!==-1)
    {
      gl.uniformMatrix4fv(this.unifProj, false, p);
    }
  }
  setMouse(mouse: vec2)
  {
    this.use();
    if(this.unifMouse!==-1)
    {
      gl.uniform2fv(this.unifMouse, mouse);
    }
  }
  setDrag(drag: vec2)
  {
    this.use();
    if(this.unifDrag!==-1)
    {
      gl.uniform2fv(this.unifDrag, drag);
    }
  }

  setC0(color: vec4) {
    this.use();
    if (this.unifC0 !== -1) {
      gl.uniform4fv(this.unifC0, color);
    }
  }
  setC1(color: vec4) {
    this.use();
    if (this.unifC1 !== -1) {
      gl.uniform4fv(this.unifC1, color);
    }
  }
  setC2(color: vec4) {
    this.use();
    if (this.unifC2 !== -1) {
      gl.uniform4fv(this.unifC2, color);
    }
  }
  setC3(color: vec4) {
    this.use();
    if (this.unifC3 !== -1) {
      gl.uniform4fv(this.unifC3, color);
    }
  }
  setC4(color: vec4) {
    this.use();
    if (this.unifC4 !== -1) {
      gl.uniform4fv(this.unifC4, color);
    }
  }

  setScreenSize(size: vec2)
  {
    this.use();
    if(this.screenSize !== -1) {
      gl.uniform2fv(this.screenSize, size)
    }
  }

  setTime(time: number) {
    this.use();
    if (this.unifTime !== -1) {
      gl.uniform1f(this.unifTime, time);
    }
  }

  setFrequence(freq: number){
    this.use();
    if (this.unifFreq !== -1) {
      gl.uniform1f(this.unifFreq, freq);
    }
  }

  setAmplitude(amp: number){{
    this.use();
    if (this.unifAmp !== -1) {
      gl.uniform1f(this.unifAmp, amp);
    }
  }}

  setWaveLength(wave: number){
    this.use();
    if (this.unifWave !== -1) {
      gl.uniform1f(this.unifWave, wave);
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
