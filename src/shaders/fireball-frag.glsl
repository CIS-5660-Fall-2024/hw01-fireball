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
uniform float u_time;
// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;
in float wavet;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

vec3 random3(vec3 p) {
    // A new method for generating pseudo-random values
    return fract(sin(vec3(
        dot(p, vec3(12.9898, 78.233, 45.164)),
        dot(p, vec3(93.989, 67.345, 33.271)),
        dot(p, vec3(39.346, 84.765, 27.345))
    )) * 43758.5453123);
}

// Impulse
float impulse(float x, float k) {
    float h = k * x;
    return h * exp(1.0 - h);
}

float sawtooth_wave(float x, float freq, float amplitude){
    return (x*freq-floor(x*freq))*amplitude;
}
// 3D Worley Noise function
float WorleyNoise(vec3 uv) {
    uv *= 3.0; // The space is scaled to 3x3 instead of 1x1.
    vec3 uvInt = floor(uv);
    vec3 uvFract = fract(uv);
    float minDist = 100.0; // Initialize minimum distance to a large value.

    // Iterate over the neighboring cells to find the closest feature point
    for(int z = -1; z <= 1; ++z){
        for(int y = -1; y <= 1; ++y) {
            for(int x = -1; x <= 1; ++x) {
                vec3 neighbor = vec3(float(x), float(y), float(z)); // Neighboring cell
                vec3 point = random3(uvInt + neighbor); // Random point within the neighboring cell
                vec3 diff = neighbor + point - uvFract; // Vector between fragment and the point
                float dist = length(diff); // Euclidean distance
                minDist = min(minDist, dist); // Store the smallest distance
            }
        }
    }

    return minDist; // Return the minimum distance to the closest point
}

void main()
{
   // Calculate the Worley noise value without any smoothstep or time-related modifications
    float worleyTerm = WorleyNoise(fs_Pos.xyz+vec3(u_time/2.0));

    vec3 fireballColor = mix(vec3(1.0, 0.5, 0.0), vec3(1.0, 1.0, 0.0), worleyTerm); 
    // Modify the base color with Worley noise
    vec3 color = fireballColor * u_Color.xyz;

    // Set final output color
    out_Col = vec4(color, u_Color.a);
}


