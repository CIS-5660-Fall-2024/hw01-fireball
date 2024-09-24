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

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;
uniform float u_Time;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.


// From lecture notes

float bias(float b, float val) {
    return pow(val, log(b) / log(0.5));
}

vec3 random3(vec3 p)
{
    return fract(sin(vec3((dot(p, vec3(127.1f, 311.7f, 191.999f))))) * 43758.5453f);
}


float surflet3D(vec3 p, vec3 gridPoint) {
    // Compute the distance between p and the grid point along each axis, and warp it with a
    // quintic function so we can smooth our cells
    vec3 t2 = abs(p - gridPoint);
    vec3 v1 = 6.f * vec3(pow(t2[0], 5.f),
                                    pow(t2[1], 5.f),
                                    pow(t2[2], 5.f));
    vec3 v2 = 15.f * vec3(pow(t2[0], 4.f),
                                    pow(t2[1], 4.f),
                                    pow(t2[2], 4.f));
    vec3 v3 = 10.f * vec3(pow(t2[0], 3.f),
                                    pow(t2[1], 3.f),
                                    pow(t2[2], 3.f));
    vec3 t = vec3(1.f) - v1 + v2 - v3;
    // Get the random vector for the grid point (assume we wrote a function random2
    // that returns a vec2 in the range [0, 1])
    vec3 gradient = random3(gridPoint) * 2.f - vec3(1.f);
    // Get the vector from the grid point to P
    vec3 diff = p - gridPoint;
    // Get the value of our height field by dotting grid->P with our gradient
    float height = dot(diff, gradient);
    // Scale our height field (i.e. reduce it) by our polynomial falloff function
    return height * t.x * t.y * t.z;
}

float perlinNoise3D(vec3 p) {
    float surfletSum = 0.f;
    // Iterate over the eight integer corners surrounding a 3D grid cell
    for(int dx = 0; dx <= 1; ++dx) {
        for(int dy = 0; dy <= 1; ++dy) {
            for(int dz = 0; dz <= 1; ++dz) {
                surfletSum += surflet3D(p, floor(p) + vec3(dx, dy, dz));
            }
        }
    }
    return surfletSum;
}

// Worley noise but make it 3D
float worleyNoise3D(vec3 pos) {
    pos *= 55.0; // Scale the input position to adjust the cell size
    vec3 posInt = floor(pos); // Integer part of the position
    vec3 posFract = fract(pos); // Fractional part of the position
    float minDist = 1.0; // Initialize the minimum distance to a very high value.

    // Loop through neighboring cells (in a 3x3x3 grid around the current position)
    for (int z = -1; z <= 1; ++z) {
        for (int y = -1; y <= 1; ++y) {
            for (int x = -1; x <= 1; ++x) {
                vec3 neighbor = vec3(float(x), float(y), float(z));
                vec3 cellPoint = random3(posInt + neighbor); // Random point within the neighboring cell
                vec3 diff = neighbor + cellPoint - posFract; // Distance vector to the point
                float distToPoint = length(diff);
                minDist = min(minDist, distToPoint); // Track the minimum distance
            }
        }
    }
    return minDist;
}


void main() {
    float noise = worleyNoise3D(fs_Pos.xyz + u_Time * 0.01);
    float invertedWorley = 1.0 - noise;

    float b = 0.3; 
    float biasedWorley = bias(b, invertedWorley);

    // Compute blend factor based on height
    float blendFactor = clamp(fs_Pos.y, 0.0, 1.0);
    blendFactor = pow(blendFactor, 0.5); // Adjust gradient for smoother transition

    blendFactor += (biasedWorley - 0.5) * 0.41;
    blendFactor = clamp(blendFactor, 0.0, 0.2);

    vec4 outerColor = vec4(0.5, 0.5, 0.5, 1.0);
    vec4 blendedColor = mix(outerColor, u_Color, step(noise, 0.881));

    // Apply lighting (Lambertian shading)
    float diffuseTerm = dot(normalize(fs_Nor.xyz), normalize(fs_LightVec.xyz));
    float ambientTerm = 0.6;
    float lightIntensity = max(diffuseTerm + ambientTerm, 0.0);

    // Compute final color with lighting
    vec4 finalColor = blendedColor * lightIntensity;

    // Output final color
    out_Col = vec4(finalColor.rgb, u_Color.a);
}