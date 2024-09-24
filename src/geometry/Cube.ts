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

      this.indices = this.createIndices();
      this.normals = this.createNormals();
      this.positions = this.createPositionsFromCenter();

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

    createIndices(): Uint32Array {
        let indices = [];

        for (let i = 0; i < 24; i += 4) {
            indices.push(i);
            indices.push(i + 1);
            indices.push(i + 2);
            indices.push(i);
            indices.push(i + 2);
            indices.push(i + 3);
        }

        return new Uint32Array(indices);
    }

    createNormals(): Float32Array {
        let normals = [];

        //top
        for (let i = 0; i < 4; i++) {
            normals.push(0, 1, 0, 0);
        }

        //bottom
        for (let i = 0; i < 4; i++) {
            normals.push(0, -1, 0, 0);
        }

        //front
        for (let i = 0; i < 4; i++) {
            normals.push(0, 0, 1, 0);
        }

        //back
        for (let i = 0; i < 4; i++) {
            normals.push(0, 0, -1, 0);
        }

        //left-side
        for (let i = 0; i < 4; i++) {
            normals.push(-1, 0, 0, 0);
        }

        //right-side
        for (let i = 0; i < 4; i++) {
            normals.push(1, 0, 0, 0);
        }

        return new Float32Array(normals);
    }

    createPositionsFromCenter(): Float32Array {
        let positions = [];
        let sideLength = 2; 

        //top
        positions.push(this.center[0] - sideLength / 2, this.center[1] + sideLength / 2, this.center[2] - sideLength / 2, 1);
        positions.push(this.center[0] + sideLength / 2, this.center[1] + sideLength / 2, this.center[2] - sideLength / 2, 1);
        positions.push(this.center[0] + sideLength / 2, this.center[1] + sideLength / 2, this.center[2] + sideLength / 2, 1);
        positions.push(this.center[0] - sideLength / 2, this.center[1] + sideLength / 2, this.center[2] + sideLength / 2, 1);
                                                                                                     
        //bottom                                                                                     
        positions.push(this.center[0] - sideLength / 2, this.center[1] - sideLength / 2, this.center[2] - sideLength / 2, 1);
        positions.push(this.center[0] + sideLength / 2, this.center[1] - sideLength / 2, this.center[2] - sideLength / 2, 1);
        positions.push(this.center[0] + sideLength / 2, this.center[1] - sideLength / 2, this.center[2] + sideLength / 2, 1);
        positions.push(this.center[0] - sideLength / 2, this.center[1] - sideLength / 2, this.center[2] + sideLength / 2, 1);
                                                                                                     
        //front                                                                                           
        positions.push(this.center[0] - sideLength / 2, this.center[1] - sideLength / 2, this.center[2] + sideLength / 2, 1);
        positions.push(this.center[0] + sideLength / 2, this.center[1] - sideLength / 2, this.center[2] + sideLength / 2, 1);
        positions.push(this.center[0] + sideLength / 2, this.center[1] + sideLength / 2, this.center[2] + sideLength / 2, 1);
        positions.push(this.center[0] - sideLength / 2, this.center[1] + sideLength / 2, this.center[2] + sideLength / 2, 1);

        //back                                                                                           
        positions.push(this.center[0] - sideLength / 2, this.center[1] - sideLength / 2, this.center[2] - sideLength / 2, 1);
        positions.push(this.center[0] + sideLength / 2, this.center[1] - sideLength / 2, this.center[2] - sideLength / 2, 1);
        positions.push(this.center[0] + sideLength / 2, this.center[1] + sideLength / 2, this.center[2] - sideLength / 2, 1);
        positions.push(this.center[0] - sideLength / 2, this.center[1] + sideLength / 2, this.center[2] - sideLength / 2, 1);

        //left-side                                                                                      
        positions.push(this.center[0] - sideLength / 2, this.center[1] - sideLength / 2, this.center[2] - sideLength / 2, 1);
        positions.push(this.center[0] - sideLength / 2, this.center[1] - sideLength / 2, this.center[2] + sideLength / 2, 1);
        positions.push(this.center[0] - sideLength / 2, this.center[1] + sideLength / 2, this.center[2] + sideLength / 2, 1);
        positions.push(this.center[0] - sideLength / 2, this.center[1] + sideLength / 2, this.center[2] - sideLength / 2, 1);

        //right-side                                                                                      
        positions.push(this.center[0] + sideLength / 2, this.center[1] - sideLength / 2, this.center[2] - sideLength / 2, 1);
        positions.push(this.center[0] + sideLength / 2, this.center[1] - sideLength / 2, this.center[2] + sideLength / 2, 1);
        positions.push(this.center[0] + sideLength / 2, this.center[1] + sideLength / 2, this.center[2] + sideLength / 2, 1);
        positions.push(this.center[0] + sideLength / 2, this.center[1] + sideLength / 2, this.center[2] - sideLength / 2, 1);

        return new Float32Array(positions);
    }
};

export default Cube;
