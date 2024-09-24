#version 300 es
precision highp float;

// The vertex shader used to render the background of the scene

in vec4 vs_Pos;
out vec2 fs_Pos;

void main() {
  fs_Pos = 2.0 * vs_Pos.xy - 1.0;
  gl_Position = vs_Pos;
}
