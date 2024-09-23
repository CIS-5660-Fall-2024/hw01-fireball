import {vec3, vec4} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

class TesCube extends Drawable {
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
    let inSize = this.size;
    let outSize = this.size * 2.0;
    // triangle indeices
    this.indices = new Uint32Array([0, 1, 2, 0, 2, 3, // top in
                                    4, 5, 6, 4, 6, 7, // right in 
                                    8, 9, 10, 8, 10, 11, // left in 
                                    12, 13, 14, 12, 14, 15, // bot in

                                    16, 17, 18, 16, 18, 19, // top out
                                    20, 21, 22, 20, 22, 23, // right out
                                    24, 25, 26, 24, 26, 27, // left out 
                                    28, 29, 30, 28, 30, 31, // bot out

                                    32, 33, 34, 32, 34, 35, // front join
                                    36, 37, 38, 36, 38, 39,
                                    40, 41, 42, 40, 42, 43,
                                    44, 45, 46, 44, 46, 47,

                                    48, 49, 50, 48, 50, 51, // back join
                                    52, 53, 54, 52, 54, 55,
                                    56, 57, 58, 56, 58, 59,
                                    60, 61, 62, 60, 62, 63,

                                    64, 65, 66, 64, 66, 67, // front out
                                    68, 69, 70, 68, 70, 71, // back out
                                    72, 73, 74, 72, 74, 75, // front in
                                    76, 77, 78, 76, 78, 79 // back in
                                    ]); 

    // face normals                               
    this.normals = new Float32Array([ 0, 1, 0, 0, // top in
                                      0, 1, 0, 0,
                                      0, 1, 0, 0,
                                      0, 1, 0, 0, 

                                      1, 0, 0, 0,  // right in
                                      1, 0, 0, 0,
                                      1, 0, 0, 0,
                                      1, 0, 0, 0, 

                                      -1, 0, 0, 0, // left in
                                      -1, 0, 0, 0,
                                      -1, 0, 0, 0,
                                      -1, 0, 0, 0, 

                                      0, -1, 0, 0, // bot in
                                      0, -1, 0, 0,
                                      0, -1, 0, 0,
                                      0, -1, 0, 0,

                                      0, -1, 0, 0, // top out
                                      0, -1, 0, 0,
                                      0, -1, 0, 0,
                                      0, -1, 0, 0, 

                                      -1, 0, 0, 0,  // right out
                                      -1, 0, 0, 0,
                                      -1, 0, 0, 0,
                                      -1, 0, 0, 0, 

                                      1, 0, 0, 0, // left out
                                      1, 0, 0, 0,
                                      1, 0, 0, 0,
                                      1, 0, 0, 0, 

                                      0, 1, 0, 0, // bot out
                                      0, 1, 0, 0,
                                      0, 1, 0, 0,
                                      0, 1, 0, 0,

                                      0, 0, 1, 0, // front join
                                      0, 0, 1, 0,
                                      0, 0, 1, 0,
                                      0, 0, 1, 0,

                                      0, 0, -1, 0, // back join
                                      0, 0, -1, 0,
                                      0, 0, -1, 0,
                                      0, 0, -1, 0,

                                      0, 0, 1, 0, // front out
                                      0, 0, 1, 0,
                                      0, 0, 1, 0,
                                      0, 0, 1, 0,

                                      0, 0, -1, 0, // back out
                                      0, 0, -1, 0,
                                      0, 0, -1, 0,
                                      0, 0, -1, 0,

                                      0, 0, 1, 0, // front in
                                      0, 0, 1, 0,
                                      0, 0, 1, 0,
                                      0, 0, 1, 0,

                                      0, 0, -1, 0, // back in
                                      0, 0, -1, 0,
                                      0, 0, -1, 0,
                                      0, 0, -1, 0
                                    
                                    ]); 
    
    // vertex positions, yeah yeah i know it looks ugly but...                                  
    this.positions = new Float32Array([ -inSize, inSize, inSize, 1, // top in
                                        inSize, inSize, inSize, 1,
                                        inSize, inSize, -inSize, 1,
                                        -inSize, inSize, -inSize, 1,

                                        inSize, -inSize, inSize, 1, // right in
                                        inSize, -inSize, -inSize, 1, 
                                        inSize, inSize, -inSize, 1,
                                        inSize, inSize, inSize, 1,

                                        -inSize, -inSize, inSize, 1, // left in
                                        -inSize, -inSize, -inSize, 1,
                                        -inSize, inSize, -inSize, 1,
                                        -inSize, inSize, inSize, 1,

                                        -inSize, -inSize, inSize, 1, // bottom in
                                        inSize, -inSize, inSize, 1, 
                                        inSize, -inSize, -inSize, 1,
                                        -inSize, -inSize, -inSize, 1,


                                        -outSize, outSize, outSize, 1, // top out
                                        outSize, outSize, outSize, 1,
                                        outSize, outSize, -outSize, 1,
                                        -outSize, outSize, -outSize, 1,
    
                                        outSize, -outSize, outSize, 1, // right out
                                        outSize, -outSize, -outSize, 1, 
                                        outSize, outSize, -outSize, 1,
                                        outSize, outSize, outSize, 1,
    
                                        -outSize, -outSize, outSize, 1, // left out
                                        -outSize, -outSize, -outSize, 1,
                                        -outSize, outSize, -outSize, 1,
                                        -outSize, outSize, outSize, 1,
    
                                        -outSize, -outSize, outSize, 1, // bottom out
                                        outSize, -outSize, outSize, 1, 
                                        outSize, -outSize, -outSize, 1,
                                        -outSize, -outSize, -outSize, 1,


                                        -outSize, -outSize, outSize, 1, // front join
                                        outSize, -outSize, outSize, 1,
                                        inSize, -inSize, -inSize, 1,
                                        -inSize, -inSize, -inSize, 1,

                                        outSize, -outSize, outSize, 1,
                                        outSize, outSize, outSize, 1,
                                        inSize, inSize, -inSize, 1,
                                        inSize, -inSize, -inSize, 1,

                                        outSize, outSize, outSize, 1,
                                        -outSize, outSize, outSize, 1,
                                        -inSize, inSize, -inSize, 1,
                                        inSize, inSize, -inSize, 1,

                                        -outSize, outSize, outSize, 1,
                                        -outSize, -outSize, outSize, 1,
                                        -inSize, -inSize, -inSize, 1,
                                        -inSize, inSize, -inSize, 1,
                                        
                                        -outSize, -outSize, -outSize, 1, // back join
                                        outSize, -outSize, -outSize, 1,
                                        inSize, -inSize, inSize, 1,
                                        -inSize, -inSize, inSize, 1,

                                        outSize, -outSize, -outSize, 1,
                                        outSize, outSize, -outSize, 1,
                                        inSize, inSize, inSize, 1,
                                        inSize, -inSize, inSize, 1,

                                        outSize, outSize, -outSize, 1,
                                        -outSize, outSize, -outSize, 1,
                                        -inSize, inSize, inSize, 1,
                                        inSize, inSize, inSize, 1,

                                        -outSize, outSize, -outSize, 1,
                                        -outSize, -outSize, -outSize, 1,
                                        -inSize, -inSize, inSize, 1,
                                        -inSize, inSize, inSize, 1,

                                        -outSize, -outSize, outSize, 1, // front out
                                        outSize, -outSize, outSize, 1,
                                        outSize, outSize, outSize, 1,
                                        -outSize, outSize, outSize, 1,

                                        -outSize, -outSize, -outSize, 1, // back out
                                        outSize, -outSize, -outSize, 1,
                                        outSize, outSize, -outSize, 1,
                                        -outSize, outSize, -outSize, 1,

                                        -inSize, -inSize, inSize, 1, // front in
                                        inSize, -inSize, inSize, 1,
                                        inSize, inSize, inSize, 1,
                                        -inSize, inSize, inSize, 1,

                                        -inSize, -inSize, -inSize, 1, // back in
                                        inSize, -inSize, -inSize, 1,
                                        inSize, inSize, -inSize, 1,
                                        -inSize, inSize, -inSize, 1

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

    console.log(`Created TesCube :)`);
  }
};

export default TesCube;
