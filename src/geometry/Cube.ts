import {vec3, vec4} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

class Cube extends Drawable {
  indices: Uint32Array;
  positions: Float32Array;
  normals: Float32Array;
  center: vec4;
  size: number;

  constructor(center: vec3, size: number) {
    super();
    this.center = vec4.fromValues(center[0], center[1], center[2], 1);
    this.size = size * 0.5;
  }

  create() {
    // triangle indeices
    this.indices = new Uint32Array([0, 1, 2, 0, 2, 3, // front
                                    4, 5, 6, 4, 6, 7, // top 
                                    8, 9, 10, 8, 10, 11, // right
                                    12, 13, 14, 12, 14, 15, // left 
                                    16, 17, 18, 16, 18, 19, // bot
                                    20, 21, 22, 20, 22, 23]); // back

    // face normals                               
    this.normals = new Float32Array([ 0, 0, 1, 0, // front
                                      0, 0, 1, 0,
                                      0, 0, 1, 0,
                                      0, 0, 1, 0, 

                                      0, 1, 0, 0, // top
                                      0, 1, 0, 0,
                                      0, 1, 0, 0,
                                      0, 1, 0, 0, 

                                      1, 0, 0, 0,  // right
                                      1, 0, 0, 0,
                                      1, 0, 0, 0,
                                      1, 0, 0, 0, 

                                      -1, 0, 0, 0, // left
                                      -1, 0, 0, 0,
                                      -1, 0, 0, 0,
                                      -1, 0, 0, 0, 

                                      0, -1, 0, 0, // bot
                                      0, -1, 0, 0,
                                      0, -1, 0, 0,
                                      0, -1, 0, 0, 

                                      0, 0, -1, 0, // back
                                      0, 0, -1, 0,
                                      0, 0, -1, 0,
                                      0, 0, -1, 0]); 
    
    // vertex positions, yeah yeah i know it looks ugly but...                                  
    this.positions = new Float32Array([ -this.size, -this.size, this.size, 1, // front
                                        this.size, -this.size, this.size, 1,
                                        this.size, this.size, this.size, 1,
                                        -this.size, this.size, this.size, 1, 

                                        -this.size, this.size, this.size, 1, // top
                                        this.size, this.size, this.size, 1,
                                        this.size, this.size, -this.size, 1,
                                        -this.size, this.size, -this.size, 1,

                                        this.size, -this.size, this.size, 1, // right
                                        this.size, -this.size, -this.size, 1, 
                                        this.size, this.size, -this.size, 1,
                                        this.size, this.size, this.size, 1,

                                        -this.size, -this.size, this.size, 1, // left
                                        -this.size, -this.size, -this.size, 1,
                                        -this.size, this.size, -this.size, 1,
                                        -this.size, this.size, this.size, 1,

                                        -this.size, -this.size, this.size, 1, // bot 
                                        this.size, -this.size, this.size, 1, 
                                        this.size, -this.size, -this.size, 1,
                                        -this.size, -this.size, -this.size, 1,

                                        -this.size, -this.size, -this.size, 1, // back
                                        this.size, -this.size, -this.size, 1,
                                        this.size, this.size, -this.size, 1,
                                        -this.size, this.size, -this.size, 1]);
                                      

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

    console.log(`Created Cube :)`);
  }
};

export default Cube;
