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

uniform float u_Time;  // time in seconds
uniform float u_ColorGain;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec3 fs_Displacement;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

float bias(float b, float t)
{
    return pow(t, log(b) / log(0.5f));
}

float gain(float g, float t)
{
    if (t < 0.5)
    {
        return bias(1.0 - g, 2.0 * t) / 2.0;
    }
    else
    {
        return 1.0 - bias(1.0 - g, 2.0 - 2.0 * t) / 2.0;
    }
}

// v from 0 to 1
vec3 mapColor(float v)
{
    v = clamp(v, 0.0, 1.0);
    v = gain(u_ColorGain, v);

    if (v < 0.8)
    {
        float t = clamp(v / 0.8, 0.0, 1.0);

        vec3 red = vec3(1.0, 0.165, 0.02);
        vec3 orange = vec3(1.0, 0.647, 0.0);

        return red * (1.0 - t) + orange * t;
    }
    else
    {
        float t = clamp((v - 0.8) / 0.2, 0.0, 1.0);
        vec3 orange = vec3(1.0, 0.647, 0.0);
        vec3 yellow = vec3(1.0, 0.9, 0.1);

        return orange * (1.0 - t) + yellow * t;
    }

    return vec3(0.5);
}

void main()
{
    // Material base color (before shading)
    vec4 diffuseColor = fs_Col;

    float displDot = dot(normalize(fs_Displacement), normalize(fs_Nor.xyz));
    float v = 0.5 * (displDot + 1.0);

    diffuseColor.xyz = mapColor(v);

    // Calculate the diffuse term for Lambert shading
    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
    // Avoid negative lighting values
    // diffuseTerm = clamp(diffuseTerm, 0, 1);

    float ambientTerm = 0.2;

    float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                        //to simulate ambient lighting. This ensures that faces that are not
                                                        //lit by our point light are not completely black.

    // Compute final shaded color
    out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
}
