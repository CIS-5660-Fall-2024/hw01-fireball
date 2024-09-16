#version 300 es
precision highp float;

uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform float u_Time;

uniform vec3 u_CameraPosition;

in vec4 vs_Pos;
out vec2 fs_Pos;

void main() {
    vec3 billboardCenter = (u_Model * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
    vec3 offsetPos = billboardCenter + vec3(vs_Pos.xy, 0.0);
    gl_Position = u_ViewProj * vec4(offsetPos, 1.0);
    fs_Pos = vs_Pos.xy;
}