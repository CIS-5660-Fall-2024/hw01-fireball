#version 300 es
precision highp float;

uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_Dimensions;
uniform float u_Time;

in vec2 fs_Pos;
out vec4 out_Col;


vec3 fade(vec3 t) { 
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0); 
}

float grad(int hash, vec3 p) {
    int h = hash & 15;
    float u = h < 8 ? p.x : p.y;
    float v = h < 4 ? p.y : (h == 12 || h == 14 ? p.x : p.z);
    return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v);
}

float perlinNoise3D(vec3 p) {
    vec3 Pi = floor(p);
    vec3 Pf = p - Pi;
    Pi = mod(Pi, 289.0); 
    vec3 fadePf = fade(Pf);

    float n000 = grad(int(dot(Pi, vec3(1.0, 57.0, 113.0))), Pf);
    float n001 = grad(int(dot(Pi + vec3(0.0, 0.0, 1.0), vec3(1.0, 57.0, 113.0))), Pf - vec3(0.0, 0.0, 1.0));
    float n010 = grad(int(dot(Pi + vec3(0.0, 1.0, 0.0), vec3(1.0, 57.0, 113.0))), Pf - vec3(0.0, 1.0, 0.0));
    float n011 = grad(int(dot(Pi + vec3(0.0, 1.0, 1.0), vec3(1.0, 57.0, 113.0))), Pf - vec3(0.0, 1.0, 1.0));
    float n100 = grad(int(dot(Pi + vec3(1.0, 0.0, 0.0), vec3(1.0, 57.0, 113.0))), Pf - vec3(1.0, 0.0, 0.0));
    float n101 = grad(int(dot(Pi + vec3(1.0, 0.0, 1.0), vec3(1.0, 57.0, 113.0))), Pf - vec3(1.0, 0.0, 1.0));
    float n110 = grad(int(dot(Pi + vec3(1.0, 1.0, 0.0), vec3(1.0, 57.0, 113.0))), Pf - vec3(1.0, 1.0, 0.0));
    float n111 = grad(int(dot(Pi + vec3(1.0, 1.0, 1.0), vec3(1.0, 57.0, 113.0))), Pf - vec3(1.0, 1.0, 1.0));

    vec3 blend = fadePf;
    return mix(mix(mix(n000, n100, blend.x), mix(n010, n110, blend.x), blend.y),
               mix(mix(n001, n101, blend.x), mix(n011, n111, blend.x), blend.y),
               blend.z);
}


float fbm3DPerlin(float x, float y, float z) {
    float total = 0.0;
    float persistence = 0.6;
    int octaves = 8;
    float freq = 1.0;
    float amp = 0.5;
    for(int i = 0; i < octaves; i++) {
        total += perlinNoise3D(vec3(x, y, z) * freq) * amp;
        freq *= 2.0;
        amp *= persistence;
    }
    return total;
}


void main() {
  float noise = fbm3DPerlin(fs_Pos.x, fs_Pos.y, u_Time * 0.1);
  if (noise > 0.3) {
    out_Col = vec4(1.0, 1.0, 1.0, 1.0); 
  } else {
    out_Col = vec4(0.0, 0.0, 0.0, 1.0);  
  }
}
