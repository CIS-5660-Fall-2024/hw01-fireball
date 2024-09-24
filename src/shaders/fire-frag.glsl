#version 300 es
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.
uniform float u_Time;
uniform float u_Transparency;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;
in float fs_Displacement;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.


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

float fbm3D(vec3 p) {
    float total = 0.0;
    float amplitude = 1.0; 
    float frequency = 1.0;
    int octaves = 10;

    for (int i = 0; i < octaves; i++) {
        total += amplitude * perlinNoise3D(p * frequency); 
        frequency *= 2.0; 
        amplitude *= 0.5;
    }
    return total;
}

float fbmFireNoise(vec3 p) {
    float total = 0.0;
    float amplitude = 1.0;
    float frequency = 1.0;
    // Less octaves for fire noise
    int octaves = 5;

    for (int i = 0; i < octaves; i++) {
        total += amplitude * perlinNoise3D(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return total;
}

void main() {
    vec4 diffuseColor = u_Color;

    //Inner fire effect
    vec3 InnerPos = fs_Pos.xyz  + u_Time * 0.01;
    float InnerNoise = fbmFireNoise(InnerPos);

    // vec3 fireColor2 = fs_Col.xyz;
    vec3 InnerColor1 = vec3(0.8, 0.3, 0.0);
    vec3 InnerColor2 = vec3(1.0, 0.2, 0.5);  

    vec3 fireColor = mix(InnerColor1, InnerColor2, InnerNoise);
    vec4 InnerFire = vec4(fireColor * (1.0 - InnerNoise), 1); 


    //Get the position changed by time
    vec3 OuterPos = fs_Pos.xyz + u_Time * 0.0001;

    //Generate 3D FBM noise
    float Outernoise = fbm3D(OuterPos + u_Time * 0.001);

    vec3 OuterColor1 = vec3(0.8, 0.3, 0.0);
    vec3 OuterColor2 = vec3(1.0, 0.6, 0.0);  

    //gradient color correlate with fragment position
    float smoother = smoothstep(0.0, 1.0, fs_Displacement);

    vec3 gradientColor = mix(OuterColor1, OuterColor2, pow(smoother, 0.6)) ;
    vec4 OuterFire = vec4((gradientColor.rgb * (1.0-Outernoise)) * u_Color.rgb * 0.8, diffuseColor.a);

   out_Col = mix(OuterFire, InnerFire, InnerNoise);
   out_Col = vec4(out_Col.xyz * 1.5, u_Transparency);
}

