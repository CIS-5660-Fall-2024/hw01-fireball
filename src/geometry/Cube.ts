import {vec3, vec4} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

class Cube extends Drawable {
  indices: Uint32Array;
  positions: Float32Array;
  normals: Float32Array;
  center: vec4;

  constructor(center: vec3) {
    super(); // Call the constructor of the super class. This is required.
    this.center = vec4.fromValues(center[0], center[1], center[2], 1);
  }

  create() {

  this.indices = new Uint32Array([
    0, 1, 2, 0, 2, 3, // For front face
    4, 5, 6, 4, 6, 7, // For back face
    8,9, 10, 8, 10, 11, // For left face
    12, 13, 14, 12, 14, 15, // For right face
    16, 17, 18, 16, 18, 19, // For top face
    20, 21, 22, 20, 22, 23, // For bottom face
  ]);

  this.normals = new Float32Array(this.normals = new Float32Array([
    // Front face (pos z)
     0.0,  0.0,  1, 0.0,
     0.0,  0.0,  1.0, 0.0,
     0.0,  0.0,  1.0, 0.0,
     0.0,  0.0,  1.0, 0.0,

    // Back face (neg z)
     0.0,  0.0, -1.0, 0.0,
     0.0,  0.0, -1.0, 0.0,
     0.0,  0.0, -1.0, 0.0,
     0.0,  0.0, -1.0, 0.0,

     // Left face (neg x)
    -1.0,  0.0,  0.0, 0.0,
    -1.0,  0.0,  0.0, 0.0,
    -1.0,  0.0,  0.0, 0.0,
    -1.0,  0.0,  0.0, 0.0,

     // Right face (pos x)
     1.0,  0.0,  0.0, 0.0,
     1.0,  0.0,  0.0, 0.0,
     1.0,  0.0,  0.0, 0.0,
     1.0,  0.0,  0.0, 0.0,

     // Top face (pos y)
     0.0,  1.0,  0.0, 0.0,
     0.0,  1.0,  0.0, 0.0,
     0.0,  1.0,  0.0, 0.0,
     0.0,  1.0,  0.0, 0.0,

    // Bottom face (neg y)
     0.0, -1.0,  0.0, 0.0,
     0.0, -1.0,  0.0, 0.0,
     0.0, -1.0,  0.0, 0.0,
     0.0, -1.0,  0.0, 0.0,

  ]));
  
 this.positions = new Float32Array([
    
    // Front face
    -1.0, -1.0,  1.0, 1.0,
     1.0, -1.0,  1.0, 1.0,
     1.0,  1.0,  1.0, 1.0,
    -1.0,  1.0,  1.0, 1.0,
    
    // Back face
    -1.0, -1.0, -1.0, 1.0,
     1.0, -1.0, -1.0, 1.0,
     1.0,  1.0, -1.0, 1.0,
    -1.0,  1.0, -1.0, 1.0,

    // Left face
    -1.0, -1.0, -1.0, 1.0,
    -1.0,  1.0, -1.0, 1.0,
    -1.0,  1.0,  1.0, 1.0,
    -1.0, -1.0,  1.0, 1.0,

    // Right face
     1.0, -1.0, -1.0, 1.0,
     1.0,  1.0, -1.0, 1.0,
     1.0,  1.0,  1.0, 1.0,
     1.0, -1.0,  1.0, 1.0,

    // Top face
    -1.0,  1.0, -1.0, 1.0,
    -1.0,  1.0,  1.0, 1.0,
     1.0,  1.0,  1.0, 1.0,
     1.0,  1.0, -1.0, 1.0,

    // Bottom face
    -1.0, -1.0, -1.0, 1.0,
    -1.0, -1.0,  1.0, 1.0,
     1.0, -1.0,  1.0, 1.0,
     1.0, -1.0, -1.0, 1.0,
  
  ]);

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
