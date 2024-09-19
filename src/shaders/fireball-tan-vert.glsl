#version 300 es
precision highp float;

uniform mat4 u_ViewProj;
uniform mat4 u_Model;

uniform float u_Time;

in vec3 vs_Pos;
in vec3 vs_Nor;
in vec3 vs_Tan;

out vec3 fs_Pos;
out vec3 fs_eye_pos;

float sumOfSines(vec3 pos) {
    return sin(pos.x * 2.1 + u_Time * 0.5) * 1.224
            + sin(pos.y * 4.13 + u_Time * 2.13) * 2.2
            + sin(pos.z * 3.87 + u_Time * 1.24) * 3.01;
}

// FBM implementation from https://www.shadertoy.com/view/4dS3Wd
float hash(float p) { p = fract(p * 0.011); p *= p + 7.5; p *= p + p; return fract(p); }
float noise(vec3 x) {
    const vec3 step = vec3(110, 241, 171);

    vec3 i = floor(x);
    vec3 f = fract(x);
 
    // For performance, compute the base input to a 1D hash from the integer part of the argument and the 
    // incremental change to the 1D based on the 3D -> 1D wrapping
    float n = dot(i, step);

    vec3 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(mix( hash(n + dot(step, vec3(0, 0, 0))), hash(n + dot(step, vec3(1, 0, 0))), u.x),
                   mix( hash(n + dot(step, vec3(0, 1, 0))), hash(n + dot(step, vec3(1, 1, 0))), u.x), u.y),
               mix(mix( hash(n + dot(step, vec3(0, 0, 1))), hash(n + dot(step, vec3(1, 0, 1))), u.x),
                   mix( hash(n + dot(step, vec3(0, 1, 1))), hash(n + dot(step, vec3(1, 1, 1))), u.x), u.y), u.z);
}
float fbm(vec3 x, int octaves, vec3 shift, float persistence) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < octaves; ++i) {
		v += a * noise(x);
		x = x * 2.0 + shift;
		a *= persistence;
	}
	return v;
}

uniform float u_ScaleY;
uniform float u_TaperFactor;

vec3 transformPoint(vec3 pos) {
    // sum of sines to offset along normal to make sphere not uniform
    float offset = (sumOfSines(pos) + 1.0) * 0.5;
    pos *= offset * 0.01 + 1.5;

    float taper = 1.0 - pos.y * 0.5;
    pos.xz *= pow(taper, u_TaperFactor);
    pos.y *= u_ScaleY;

    float sway = 0.5 * sin(u_Time * 2.0 + -pos.y * 0.5);
    float yFactor = (1.0 + pos.y) * 0.5;
    pos.x += sway * yFactor;

    vec3 move = vec3((u_Time * 2.0), (u_Time * 2.82 + 1.0), (u_Time * 2.64 + 2.0));

    float fbmv = fbm((pos + move) * 1.0, 8, vec3(100.0), 0.8);
    fbmv = fbm(fbmv * 0.1 + pos + move, 8, vec3(50.0), 0.5) * 1.1;

    vec3 direction = normalize(vec3(0.0, 10.0, 0.0) - pos);

    pos += direction * abs(fbmv);

    return pos;
}

uniform vec3 u_Eye, u_Ref, u_Up;
out vec3 eye_relative_pos;

void main() {
    vec3 transformedPos = (u_Model * vec4(vs_Pos, 1.0)).xyz;
    mat3 matN = transpose(inverse(mat3(u_Model)));

    vec3 new_normal = matN * vs_Nor;

    vec3 fPos = transformPoint(transformedPos);

    fs_eye_pos = u_Eye;
    eye_relative_pos = fPos - u_Eye;

    fs_Pos = fPos;
    gl_Position = u_ViewProj * vec4(fPos, 1.0);
}
