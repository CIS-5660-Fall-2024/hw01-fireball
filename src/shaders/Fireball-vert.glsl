#version 300 es
//This is a vertex shader.

uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform float u_Time;
uniform float u_Scale;
uniform float u_Size;

in vec4 vs_Pos;             // The array of vertex positions passed to the shader
in vec4 vs_Nor;             // The array of vertex normals passed to the shader
in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;
out vec4 fs_Pos;
out vec4 fs_LightVec;
out vec4 fs_Col;

const vec4 lightPos = vec4(5, 5, 3, 1);

float rand(vec3 n) { 
    return fract(sin(dot(n, vec3(12.9898, 4.1414, 3.991))) * 43758.5453);
}

float noise(vec3 p){
    vec3 ip = floor(p);
    vec3 u = fract(p);
    u = u*u*(3.0-2.0*u);

    return mix(
        mix(
            mix(rand(ip), rand(ip + vec3(1.0, 0.0, 0.0)), u.x),
            mix(rand(ip + vec3(0.0, 1.0, 0.0)), rand(ip + vec3(1.0, 1.0, 0.0)), u.x), u.y),
        mix(
            mix(rand(ip + vec3(0.0, 0.0, 1.0)), rand(ip + vec3(1.0, 0.0, 1.0)), u.x),
            mix(rand(ip + vec3(0.0, 1.0, 1.0)), rand(ip + vec3(1.0, 1.0, 1.0)), u.x), u.y), u.z);
}

const mat3 mtx = mat3(
    0.80,  0.60, 0.0,
   -0.60,  0.80, 0.0,
    0.0,   0.0,  1.0
);

float fbm( vec3 p )
{
    float f = 0.0;
    f += 0.500000*noise( p + u_Time); p = mtx*p*2.02;
    f += 0.031250*noise( p ); p = mtx*p*2.01;
    f += 0.250000*noise( p ); p = mtx*p*2.03;
    f += 0.125000*noise( p ); p = mtx*p*2.01;
    f += 0.062500*noise( p ); p = mtx*p*2.04;
    f += 0.015625*noise( p + sin(u_Time) );

    return f/0.96875;
}

float bias(float b, float t) {
    return pow(t, log(b) / log(0.5));
}

float gain(float g, float t) {
    if (t < 0.5) {
        return bias(1.-g, 2.*t) / 2.;
    } else {
        return 1. - bias(1.-g, 2.- 2.*t) / 2.;
    }
}



void main() {
    fs_Col = vs_Col;
    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);
    vec4 modelposition = u_Model * vs_Pos;

    modelposition.x *= u_Size * gain(modelposition.y - 1.0, 0.15);
    modelposition.z *= u_Size * gain(modelposition.y - 1.0, 0.15);
    modelposition.y *= 1.50;
    modelposition.x += fbm(modelposition.xyz) - 0.5;
    modelposition.z += fbm(modelposition.xyz) - 0.5;
    modelposition.y += fbm(modelposition.xyz) * 0.1 + 0.13;
    modelposition.y += bias(abs(cos(u_Time * 0.8)), 0.3);
    gl_Position = u_ViewProj * modelposition;
    fs_Pos = modelposition;
}

