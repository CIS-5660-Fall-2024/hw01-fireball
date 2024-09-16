#version 300 es
precision highp float;

uniform vec4 u_Color; 
uniform float u_Time; 
uniform vec3 u_NoiseScale;
uniform float u_AmbientTerm; 
uniform vec4 u_BaseColor;  

in vec4 fs_Nor; 
in vec4 fs_Pos; 
in vec4 fs_LightVec;
in vec4 fs_Col;

out vec4 out_Col;


float rand(vec3 p) {
    return fract(sin(dot(p, vec3(12.9898, 78.233, 54.53))) * 43758.5453);
}

float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float n = mix(mix(mix(rand(i + vec3(0, 0, 0)), rand(i + vec3(1, 0, 0)), f.x),
                      mix(rand(i + vec3(0, 1, 0)), rand(i + vec3(1, 1, 0)), f.x), f.y),
                  mix(mix(rand(i + vec3(0, 0, 1)), rand(i + vec3(1, 0, 1)), f.x),
                      mix(rand(i + vec3(0, 1, 1)), rand(i + vec3(1, 1, 1)), f.x), f.y), f.z);
    return n;
}

float fbm(vec3 p) {
    float total = 0.0;
    float amplitude = 0.5;
    vec3 shift = vec3(100.0);
    for (int i = 0; i < 5; i++) {
        total += amplitude * noise(p);
        p = p * 2.0 + shift;
        amplitude *= 0.5;
    }
    return total;
}

void main() {
    vec3 pos = fs_Pos.xyz * u_NoiseScale * 2.0f + u_Time;
    float noiseValue = fbm(pos);
    float distanceToOrigin = length(fs_Pos.xyz);
    float normalizedDistance = distanceToOrigin - 1.0f;
    float colorMixFactor = noiseValue + normalizedDistance * 2.0f;
    vec3 finalColor = mix(u_Color.rgb, u_BaseColor.rgb, colorMixFactor);
    float diffuseTerm = max(dot(normalize(fs_Nor), normalize(fs_LightVec)), 0.0);
    float lightIntensity = diffuseTerm + u_AmbientTerm;  
    out_Col = vec4(finalColor * lightIntensity, u_Color.a);
}