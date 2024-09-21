#version 300 es
// This is a fragment shader.

precision highp float;

uniform vec4 u_Color;
uniform float u_Time;
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;
out vec4 out_Col;

// reference from: https://www.shadertoy.com/view/ftSSRR
// https://www.shadertoy.com/view/ldlXRS
// https://www.shadertoy.com/view/4sc3z2/

float colormap_red(float x) {
    if (x < 0.0) {
        return 54.0 / 255.0;
    } else if (x < 20049.0 / 82979.0) {
        return (829.79 * x + 54.51) / 255.0;
    } else {
        return 1.0;
    }
}

float colormap_green(float x) {
    if (x < 20049.0 / 82979.0) {
        return 0.0;
    } else if (x < 327013.0 / 810990.0) {
        return (8546482679670.0 / 10875673217.0 * x - 2064961390770.0 / 10875673217.0) / 255.0;
    } else if (x <= 1.0) {
        return (103806720.0 / 483977.0 * x + 19607415.0 / 483977.0) / 255.0;
    } else {
        return 1.0;
    }
}

float colormap_blue(float x) {
    if (x < 0.0) {
        return 54.0 / 255.0;
    } else if (x < 7249.0 / 82979.0) {
        return (829.79 * x + 54.51) / 255.0;
    } else if (x < 20049.0 / 82979.0) {
        return 127.0 / 255.0;
    } else if (x < 327013.0 / 810990.0) {
        return (792.02249341361393720147485376583 * x - 64.364790735602331034989206222672) / 255.0;
    } else {
        return 1.0;
    }
}

vec4 colormap(float x) {
    return vec4(colormap_red(x), colormap_green(x), colormap_blue(x), 1.0);
}

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
    vec3 uv = fs_Pos.xyz * 1.0;
    float shade = pattern(uv);
    vec4 diffuseColor = vec4(colormap(shade).rgb, 1);
    diffuseColor = vec4(colormap(u_Color.r*shade).r,colormap(u_Color.g*shade).g,colormap(u_Color.b*shade).b,1);
    out_Col = diffuseColor;
}