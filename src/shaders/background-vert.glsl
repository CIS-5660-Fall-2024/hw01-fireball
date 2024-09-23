#version 300 es
precision highp float;

in vec4 vs_Pos;
out vec3 fs_Pos;

void main() {
  fs_Pos = vs_Pos.xyz;
  gl_Position = vs_Pos;
}
