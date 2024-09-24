#version 300 es
precision highp float;

uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_Dimensions;
uniform float u_Time;

in vec2 fs_Pos;
out vec4 out_Col;

// From mini-minecraft
vec3 noise( vec3 p ) {
    return normalize(fract(sin(vec3(
                                         dot(p, vec3(127.1, 311.7, 74.7)),
                                         dot(p, vec3(269.5, 183.3, 246.1)),
                                         dot(p, vec3(419.2, 371.9, 156.3))
                                         )) * 43758.5453f) * 2.f - vec3(1.f, 1.f, 1.f));
}

vec3 interpolatedNoise ( vec3 p, float frequency) {

    vec3 scaledP = p * frequency;
    vec3 flooredP = floor(scaledP);
    vec3 ceiledP = ceil(scaledP);

    vec3 noise1 = noise(vec3(flooredP));
    vec3 noise2 = noise(vec3(flooredP.xy, ceiledP.z));
    vec3 noise3 = noise(vec3(flooredP.x, ceiledP.y, flooredP.z));
    vec3 noise4 = noise(vec3(flooredP.x, ceiledP.y, ceiledP.z));
    vec3 noise5 = noise(vec3(ceiledP.x, flooredP.yz));
    vec3 noise6 = noise(vec3(ceiledP.x, flooredP.y, ceiledP.z));
    vec3 noise7 = noise(vec3(ceiledP.xy, flooredP.z));
    vec3 noise8 = noise(vec3(ceiledP.xyz));

    noise1 = mix(noise1, noise2, fract(scaledP.z));
    noise3 = mix(noise3, noise4, fract(scaledP.z));
    noise5 = mix(noise5, noise6, fract(scaledP.z));
    noise7 = mix(noise7, noise8, fract(scaledP.z));

    noise1 = mix(noise1, noise3, fract(scaledP.y));
    noise5 = mix(noise5, noise7, fract(scaledP.y));

    noise1 = mix(noise1, noise5, fract(scaledP.x));


    return noise1;

}

vec3 fbm ( vec3 p, float octaves, float amplitude, float persistance, float scale ) {
    vec3 total = vec3(0.f);
    
    for (float i = 0.0; i < octaves; i += 1.0) {
        float frequency = scale * pow(2.0, i);
        float innerAmplitude = pow(persistance, i);

        total += innerAmplitude*interpolatedNoise(p, frequency);

    }
    return amplitude*total;
}

void main() {

  float cloud = fbm(vec3((fs_Pos + vec2(u_Time / 1028.0, 0.0)) / vec2(10.0, 1.0), 0.0) - u_Eye + vec3(0.0, 0.0, u_Time/10000.0), 8.0, 2.0, 0.5, 7.0).x;
  cloud = smoothstep(0.3, 0.6, cloud);

  vec3 gradient1 = mix(vec3(0.5, 0.2, 0.7), vec3(1.0, 0.8, 0.9), fs_Pos.y * 0.5 + 0.5); 
  vec3 gradient2 = mix(vec3(0.7, 0.5, 1.0), vec3(1.0, 0.7, 1.0), fs_Pos.y * 0.5 + 0.5); 
  vec3 col = mix(gradient1, gradient2, cloud);
  out_Col = vec4(col, 1.0);
  
  //vec4(0.5 * (fs_Pos + vec2(1.0)), 0.5 * (sin(u_Time * 3.14159 * 0.01) + 1.0), 1.0);
}
