#version 300 es
precision highp float;
// This is a fragment shader. 

uniform vec4 u_Color;
uniform float u_Time;

in vec3 fs_Pos;
in vec4 fs_Col;


out vec4 out_Col;



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

float pattern( in vec3 p )
{
    return fbm( p + fbm( p + fbm( p ) ) );
}

void main() {
    vec3 dir = normalize(fs_Pos);
    vec3 color1 = vec3(0.04, 0.35, 0.53);
    vec3 color2 = vec3(0.53, 0.03, 0.05);
    vec3 sky = mix(color1, color2, dir.y * 0.5 + 0.5);
    float a = pattern(sky);
    out_Col = vec4(sky, 1.0) * abs(a);
}