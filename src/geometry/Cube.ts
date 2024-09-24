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

  const indices = [];
  for (let i = 0; i < 6; i++) {
    const x = i * 4;
    indices.push(x, x+1, x+2);
    indices.push(x, x+2, x+3); 
  }
  this.indices = new Uint32Array(indices);
   this.normals = new Float32Array([
                                0, 0,  1, 0,
                                0, 0,  1, 0,
                                0, 0,  1, 0,
                                0, 0,  1, 0,
                                
                                1, 0,  0, 0,
                                1, 0,  0, 0,
                                1, 0,  0, 0,
                                1, 0,  0, 0,
                                
                                0, 0, -1, 0,
                                0, 0, -1, 0,
                                0, 0, -1, 0,
                                0, 0, -1, 0,
                                
                                -1, 0,  0, 0,
                                -1, 0,  0, 0,
                                -1, 0,  0, 0,
                                -1, 0,  0, 0,
                                
                                0, 1,  0, 0,
                                0, 1,  0, 0,
                                0, 1,  0, 0,
                                0, 1,  0, 0,
                                
                                0, -1,  0, 0,
                                0, -1,  0, 0,
                                0, -1,  0, 0,
                                0, -1,  0, 0    
                                ]);
   this.positions = new Float32Array([

                                    // Front side 0-3
                                    -1, -1,  1, 1, 
                                    -1,  1,  1, 1,   
                                    1,  1,  1, 1,   
                                    1, -1,  1, 1,   

                                    // Right side 4-7
                                    1, -1,  1, 1,     
                                    1,  1,  1, 1,   
                                    1,  1, -1, 1,   
                                    1, -1, -1, 1,   

                                    // Back side 8-11
                                    1, -1, -1, 1,   
                                    1,  1, -1, 1,  
                                    -1,  1, -1, 1,   
                                    -1, -1, -1, 1,   

                                    // Left side 12-15
                                    -1, -1, -1, 1,   
                                    -1,  1, -1, 1,   
                                    -1,  1,  1, 1,   
                                    -1, -1,  1, 1,   

                                    // Top side 16-19
                                    -1,  1,  1, 1,   
                                    -1,  1, -1, 1,   
                                    1,  1, -1, 1,   
                                    1,  1,  1, 1,   

                                    // Bottom side 20-23
                                    -1, -1,  1, 1,  
                                    1, -1,  1, 1,  
                                    1, -1, -1, 1,   
                                    -1, -1, -1, 1  
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

  }
};

export default Cube;
