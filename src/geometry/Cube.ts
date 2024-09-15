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
    0, 1, 2, // side 1 (front)
    0, 2, 3, 
    4, 5, 6, // side 2 (back)
    4, 6, 7,
    8, 9, 10, // side 3 (right)
    8, 10, 11,
    12, 13, 14, // side 4 (left)
    12, 14, 15,
    16, 17, 18, // side 5 (top)
    16, 18, 19, 

    20, 21, 22, // side 6 (bottom)
    20, 22, 23
  ]);

  this.normals = new Float32Array([
    0, 0, 1, 0, // side 1 (front)
    0, 0, 1, 0,
    0, 0, 1, 0,
    0, 0, 1, 0,

    0, 0, -1, 0, // side 2 (back)
    0, 0, -1, 0,
    0, 0, -1, 0,
    0, 0, -1, 0,

    1, 0, 0, 0, // side 3 (right)
    1, 0, 0, 0,
    1, 0, 0, 0,
    1, 0, 0, 0,

    -1, 0, 0, 0, // side 4 (left)
    -1, 0, 0, 0,
    -1, 0, 0, 0,
    -1, 0, 0, 0,

    0, 1, 0, 0, // side 5 (top)
    0, 1, 0, 0,
    0, 1, 0, 0,
    0, 1, 0, 0,

    0, -1, 0, 0, // side 6 (bottom)
    0, -1, 0, 0,
    0, -1, 0, 0,
    0, -1, 0, 0
  ]);

  this.positions = new Float32Array([
    -1, -1, 1, 1, // side 1 (front)
    1, -1, 1, 1,
    1, 1, 1, 1,
    -1, 1, 1, 1,

    1, -1, -1, 1, // side 1 (back)
    -1, -1, -1, 1,
    -1, 1, -1, 1,
    1, 1, -1, 1,

    1, -1, 1, 1, // side 1 (right)
    1, -1, -1, 1,
    1, 1, -1, 1,
    1, 1, 1, 1,

    -1, -1, -1, 1, // side 1 (left)
    -1, -1, 1, 1,
    -1, 1, 1, 1,
    -1, 1, -1, 1,

    -1, 1, 1, 1, // side 1 (top)
    1, 1, 1, 1,
    1, 1, -1, 1,
    -1, 1, -1, 1,

    -1, -1, -1, 1, // side 1 (bottom)
    1, -1, -1, 1,
    1, -1, 1, 1,
    -1, -1, 1, 1,
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
