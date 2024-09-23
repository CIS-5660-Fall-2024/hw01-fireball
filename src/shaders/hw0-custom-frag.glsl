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
in vec4 fs_WorldPos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.



vec3 det_rand_pos(vec3 p)
{
    float x = fract(sin(dot(p, vec3(12.989, 78.233, 97.253))) * 10967.839);
    float y = fract(sin(dot(p, vec3(87.252, 44.240, 33.827))) * 84424.717);
    float z = fract(sin(dot(p, vec3(55.421, 73.210, 67.251))) * 49081.493);
    return vec3(x, y, z);
}

vec3 det_rand_col(vec3 p)
{
    float x = fract(sin(dot(p, vec3(62.989, 75.253, 17.257))) * 88967.439);
    float y = fract(sin(dot(p, vec3(27.252, 41.240, 23.826))) * 64424.727);
    float z = fract(sin(dot(p, vec3(45.421, 73.210, 47.259))) * 29081.413);
    return vec3(x, y, z);
}

vec3 getNoise(vec3 gridCoords)
{
    vec3 centerCell = floor(gridCoords);

    float minDist = 3.0;
    vec3 closestColor = vec3(0.0);

    for (int i = -1; i <= 1; i++)
    {
        for (int j = -1; j <= 1; j++)
        {
            for (int k = -1; k <=1; k++)
            {
                vec3 cell = centerCell + vec3(float(i), float(j), float(k));
                vec3 color = det_rand_col(cell);
                vec3 pos = cell + det_rand_pos(cell);
                float dist = length(gridCoords - pos);
                if (dist < minDist)
                {
                    minDist = dist;
                    closestColor = color;
                }
            }
        }
    }

    float intensity = min(1.0, 0.8 * 0.2 + minDist);
    return closestColor * intensity;
}

void main()
{
    // Material base color (before shading)
    vec4 diffuseColor = u_Color;

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

    vec3 gridCoords = vec3(fs_WorldPos) * 2.5;
    vec3 closestColor = getNoise(gridCoords);

    out_Col.xyz = 0.5 * out_Col.xyz + 0.5 * closestColor;
}