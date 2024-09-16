#version 300 es
precision highp float;

uniform mat4 u_ViewProj;

in vec4 vs_Pos;
in vec4 vs_Nor;

out vec4 fs_Pos;
out vec4 fs_Nor;

void main() {
    fs_Pos = vs_Pos;
    fs_Nor = vs_Nor;
    gl_Position = u_ViewProj * vs_Pos;
}
