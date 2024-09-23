#version 300 es
precision highp float;

// The vertex shader used to render the background of the scene

uniform mat4 u_ViewProj;
uniform mat4 u_Model;

in vec4 vs_Pos;
out vec3 fs_Pos;

void main() {
  vec4 modelposition = u_Model * vs_Pos;
  gl_Position = u_ViewProj * modelposition;
  fs_Pos = modelposition.xyz;
}
