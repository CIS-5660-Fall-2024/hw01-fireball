import {vec3, vec4} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

class Cube extends Drawable {
  indices: Uint32Array;
  positions: Float32Array;
  normals: Float32Array;
  center: vec4;
  scale: GLfloat;

  constructor(center: vec3, scale: GLfloat) {
    super(); // Call the constructor of the super class. This is required.
    this.center = vec4.fromValues(center[0], center[1], center[2], 1);
    this.scale = scale;
  }

  create() {

  this.indices = new Uint32Array([
    0,  1,  2,      0,  2,  3,    // Front face
    4,  5,  6,      4,  6,  7,    // Back face
    8,  9, 10,      8, 10, 11,    // Top face
   12, 13, 14,     12, 14, 15,    // Right face
   16, 17, 18,     16, 18, 19,    // Left face
   
  ]);
  this.normals = new Float32Array([
    // Front face
     0,  0,  -1,  0,
     0,  0,  -1,  0,
     0,  0,  -1,  0,
     0,  0,  -1,  0,
  
    // Back face
     0,  0, 1,  0,
     0,  0, 1,  0,
     0,  0, 1,  0,
     0,  0, 1,  0,
  
    // Top face
     0,  -1,  0,  0,
     0,  -1,  0,  0,
     0,  -1,  0,  0,
     0,  -1,  0,  0,
  
    // Right face
     -1,  0,  0,  0,
     -1,  0,  0,  0,
     -1,  0,  0,  0,
     -1,  0,  0,  0,
  
    // Left face
    1,  0,  0,  0,
    1,  0,  0,  0,
    1,  0,  0,  0,
    1,  0,  0,  0,
  ]);
  this.positions = new Float32Array([
    // Front face
    -1 * this.scale, -1 * this.scale,  1 * this.scale,  1,
     1 * this.scale, -1 * this.scale,  1 * this.scale,  1,
     1 * this.scale,  1 * this.scale,  1 * this.scale,  1,
    -1 * this.scale,  1 * this.scale,  1 * this.scale,  1,
  
    // Back face
    -1 * this.scale, -1 * this.scale, -1 * this.scale,  1,
    -1 * this.scale,  1 * this.scale, -1 * this.scale,  1,
     1 * this.scale,  1 * this.scale, -1 * this.scale,  1,
     1 * this.scale, -1 * this.scale, -1 * this.scale,  1,
  
    // Top face
    -1 * this.scale,  1 * this.scale, -1 * this.scale,  1,
    -1 * this.scale,  1 * this.scale,  1 * this.scale,  1,
     1 * this.scale,  1 * this.scale,  1 * this.scale,  1,
     1 * this.scale,  1 * this.scale, -1 * this.scale,  1,
  
    // Right face
     1 * this.scale, -1 * this.scale, -1 * this.scale,  1,
     1 * this.scale,  1 * this.scale, -1 * this.scale,  1,
     1 * this.scale,  1 * this.scale,  1 * this.scale,  1,
     1 * this.scale, -1 * this.scale,  1 * this.scale,  1,
  
    // Left face
    -1 * this.scale, -1 * this.scale, -1 * this.scale,  1,
    -1 * this.scale, -1 * this.scale,  1 * this.scale,  1,
    -1 * this.scale,  1 * this.scale,  1 * this.scale,  1,
    -1 * this.scale,  1 * this.scale, -1 * this.scale,  1,
  ]);

    for (let i = 0; i < this.positions.length; i += 4) {
        this.positions[i] += this.center[0];     
        this.positions[i + 1] += this.center[1]; 
        this.positions[i + 2] += this.center[2]; 
    }

    this.generateIdx();
    this.generatePos();
    this.generateNor();

    this.count = this.indices.length;
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.bufIdx);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, this.indices, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufNor);
    gl.bufferData(gl.ARRAY_BUFFER, this.normals, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufPos);
    gl.bufferData(gl.ARRAY_BUFFER, this.positions, gl.STATIC_DRAW);

    console.log(`Created cube`);
  }
};

export default Cube;
