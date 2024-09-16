#version 300 es

uniform mat4 u_ViewProj;
uniform mat4 u_Model;

in vec4 vs_Pos;
out vec3 fs_Pos;

void main() {
    fs_Pos = vs_Pos.xyz;
    gl_Position = u_ViewProj * u_Model * vs_Pos;
}