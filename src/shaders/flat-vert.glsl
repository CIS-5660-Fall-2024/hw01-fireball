#version 300 es
precision highp float;

// The vertex shader used to render the background of the scene

in vec4 vs_Pos;
out vec2 fs_Pos;
uniform float u_Time; 

void main() {
  fs_Pos = vs_Pos.xy;
  gl_Position = vs_Pos;
}
