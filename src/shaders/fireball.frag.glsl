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
uniform vec4 u_Color2;
uniform highp int u_Time;
uniform vec4 u_Direction;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

#define PI 3.14159265
#define t float(u_Time) / 100.0

float bias(float b, float val) {
    return pow(val, log(b) / log(0.5));
}

float easeInOutSin(float x) {
    return -(cos(PI * x) - 1.0) / 2.0;
}

float tween(float a, float b) {
    return mix(a, b, easeInOutSin(0.5 * sin(t * 2.0) + 0.5));
}

float sawtooth(float x, float freq, float amp) {
    return (x * freq - floor(x * freq)) * amp;
}

void main()
{
    // Material base color (before shading)
    vec4 col1 = u_Color;
    vec4 col2 = u_Color2;
    vec4 final = vec4(0, 0, 0, 1);

    // Calculate the diffuse term for Lambert shading
    float ambientTerm = 1.0;
    float diffuse = clamp(dot(normalize(fs_Nor), normalize(fs_LightVec)) + ambientTerm, 0.0, 1.0);

    float weight = clamp(dot(u_Direction.xyz, fs_Nor.xyz), 0.0, 1.0);
    float uv = bias(0.3, weight);

    float outer = tween(0.6, 0.7);
    vec3 col2adj = col2.xyz * mix(1.0, 1.7, sawtooth(t, 0.7, 1.0));

    float threshold = 0.05;
    if (uv < outer - threshold) {
        final = col1;
    } else if (uv >= outer - threshold && uv <= outer + threshold) {
        float tVal = clamp((uv - (outer - threshold)) / 0.1, 0.0, 1.0);
        vec3 newCol = mix(col1.rgb, col2adj, tVal);
        final = vec4(newCol, 1);
    } else if (uv > outer + threshold && uv < 0.82) {
        final = vec4(col2adj, 1);
    } else {
        final = col1;
    }

    // Compute final shaded color
    weight = weight / 1.25 + 0.2;
    out_Col = vec4(final.rgb * weight, 1.0);
}
