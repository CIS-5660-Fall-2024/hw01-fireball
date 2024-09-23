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
    let face_axes: number[] = [0, 0, 1, 1, 2, 2];
    let face_dirs: number[] = [-1, 1, -1, 1, -1, 1];
    let n_faces: number = face_axes.length;

    let indices_lst: number[] = []
    let normals_lst: number[] = []
    let positions_lst: number[] = []

    for (let f: number = 0; f < n_faces; f++) {
      let axis: number = face_axes[f]
      let dir: number = face_dirs[f]

      // add indices
      let idx: number = positions_lst.length / 4
      let tri1: number[] = [idx, idx + 1, idx + 3]
      let tri2: number[] = [idx, idx + 2, idx + 3]
      indices_lst.push(...tri1)
      indices_lst.push(...tri2)

      // add positions
      for (let a: number = -1; a < 2; a += 2) {
        for (let b: number = -1; b < 2; b += 2) {
          let pos: number[] = [this.center[0], this.center[1], this.center[2], 1]
          pos[axis] += dir
          pos[(axis + 1) % 3] += a
          pos[(axis + 2) % 3] += b

          positions_lst.push(...pos)
        }
      }

      // add normals
      let nor: number[] = [0, 0, 0, 0]
      nor[axis] = dir
      for (let i: number = 0; i < 4; i++) {
        normals_lst.push(...nor)
      }
    }


    this.indices = Uint32Array.from(indices_lst)
    this.normals = Float32Array.from(normals_lst)
    this.positions = Float32Array.from(positions_lst)

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
