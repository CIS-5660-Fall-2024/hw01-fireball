import * as THREE from 'three';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js';
import * as BufferGeometryUtils from 'three/examples/jsm/utils/BufferGeometryUtils.js';
import Drawable from './rendering/gl/Drawable';
import {gl} from './globals';

class ModelDrawable extends Drawable {

    indices: Uint32Array;
    positions: Float32Array;
    normals: Float32Array;
    tangents: Float32Array;

    create(): void {
        
    }

    setPositions(positions: Float32Array): void {
        this.positions = positions;
        this.generatePos();
        gl.bindBuffer(gl.ARRAY_BUFFER, this.bufPos);
        gl.bufferData(gl.ARRAY_BUFFER, this.positions, gl.STATIC_DRAW);
    }

    setNormals(normals: Float32Array): void {
        this.normals = normals;
        this.generateNor();
        gl.bindBuffer(gl.ARRAY_BUFFER, this.bufNor);
        gl.bufferData(gl.ARRAY_BUFFER, this.normals, gl.STATIC_DRAW);
    }

    setTangents(tangents: Float32Array): void {
        this.tangents = tangents;
        this.generateTan();
        gl.bindBuffer(gl.ARRAY_BUFFER, this.bufTan);
        gl.bufferData(gl.ARRAY_BUFFER, this.tangents, gl.STATIC_DRAW);
    }

    setIndices(indices: Uint32Array): void {
        this.indices = indices;
        this.count = indices.length;
        this.generateIdx();
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.bufIdx);
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, this.indices, gl.STATIC_DRAW);
    }

}

class ModelLoader {

    constructor() {

    }

    loadModel(path: string): Array<ModelDrawable> {
        // load the obj and get the vertex data
        var loader = new GLTFLoader();
        var drawables: ModelDrawable[] = [];
        loader.load(
            path,
            function (object) {
                object.scene.traverse(function (child) {
                    if (child instanceof THREE.Mesh) {
                        // extract the geometry
                        var geometry = child.geometry;

                        // merge
                        geometry = BufferGeometryUtils.mergeVertices(geometry);
                        var vertices = geometry.attributes.position.array;

                        var hasNormals = geometry.attributes.normal !== undefined;
                        if (!hasNormals) {
                            geometry.computeVertexNormals();
                        }
                        var normals = geometry.attributes.normal.array;

                        var indices = geometry.index.array;

                        var hasTangents = geometry.attributes.tangent !== undefined;
                        var tangents = hasTangents ? geometry.attributes.tangent.array : null;

                        var model = new ModelDrawable();
                        model.setPositions(new Float32Array(vertices));
                        model.setNormals(new Float32Array(normals));
                        model.setIndices(new Uint32Array(indices));
                        if (hasTangents) {
                            model.setTangents(tangents);
                        }

                        drawables.push(model);
                        
                    }
                })
            }
        );
        return drawables;
    }
}
export default ModelLoader;
