#version 300 es
precision highp float;

uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_Dimensions;
uniform float u_Time;

in vec3 fs_Pos;
in vec3 fs_Nor;
out vec4 out_Col;

void main() {
    vec3 lightDir = normalize(u_Eye - fs_Pos);
    float lambert = max(dot(fs_Nor, lightDir), 0.0);
    out_Col = vec4(vec3(1.0, 0.5, 0.0) * lambert, 1.0);
}
