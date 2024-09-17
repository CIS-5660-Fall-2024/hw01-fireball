#version 300 es
precision highp float;

uniform vec2 u_Dimensions;
uniform float u_Time;

in vec3 fs_Pos;
in vec3 fs_Tan;
in vec3 fs_BiTan;

in vec3 fs_eye_pos;

in vec3 eye_relative_pos;

out vec4 out_Col;

void main() {

    vec3 dFdxPos = dFdx( eye_relative_pos );
    vec3 dFdyPos = dFdy( eye_relative_pos );
    vec3 facenormal = normalize( cross(dFdxPos,dFdyPos ));
    // out_Col = vec4(facenormal*0.5 + 0.5,1.0);
    vec3 lightDir = normalize(fs_eye_pos - fs_Pos);
    float lambert = max(dot(facenormal, lightDir), 0.0);
    out_Col = vec4(vec3(1.0, 0.5, 0.0) * lambert, 1.0);
}
