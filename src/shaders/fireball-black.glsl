#version 300 es
precision highp float;

in vec3 fs_Pos;

in vec3 fs_eye_pos;

in vec3 eye_relative_pos;

out vec4 out_Col;

void main() {

    out_Col = vec4(vec3(0.0), 1.0);
}
