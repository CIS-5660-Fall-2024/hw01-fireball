#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.

uniform float u_Time;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec3 fs_Noise;
in vec4 fs_Center;
in vec4 fs_ScreenspaceCenter;
in vec4 fs_projPos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

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

void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = u_Color;

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        diffuseTerm = clamp(diffuseTerm, 0.f, 1.f);

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        // Compute final shaded color
        float screenDistance = length(fs_projPos.xy - fs_ScreenspaceCenter.xy);
        float distance = 2.0 * length(fs_Pos - fs_Center);
        float multiply = mix(screenDistance, distance, 0.2);

        vec3 cameraPos = normalize(fs_ScreenspaceCenter.rgb - fs_Center.rgb);

        // variation of IQ's cosine palettes
        vec3 color = vec3(0.7, 0.0, 0.6) + vec3(0.3, 0.3, 0.2) * cos(vec3(multiply * 1.5) + fs_Noise + vec3(0.0, 0.43, 0.57));
        out_Col =  vec4(color, 1.0);
        //vec4(vec3(length(fs_Pos - fs_Center)) / 2.0, 1.0); //vec4(vec3(diffuseColor) * lightIntensity, diffuseColor.a);
        //out_Col = vec4(fs_Nor.rgb, 1.0); 
        
        //vec4(vec3(0.5*fbm(vec3(fs_Pos + vec4(10.0)), 5.0, 1.0, 0.5, 1.0) + vec3(0.5)), diffuseColor.a);
}