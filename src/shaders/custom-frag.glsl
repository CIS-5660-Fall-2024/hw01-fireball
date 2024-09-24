#version 300 es
#define N_OCTAVES 8

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

uniform vec4 u_UpperColor;
uniform vec4 u_LowerColor;
uniform float u_Time; 
uniform vec4 u_CameraPos;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

float CosineInterpolate(float a, float b, float x)
{
    float ft = x * 3.1415927;
    float f = (1.f - cos(ft)) * 0.5f;
    return  a * (1.f - f) + b * f;
}

float Noise3(int x, int y, int z) {
    return fract(sin(dot(vec3(x, y, z), vec3(127.1, 269.5, 631.2))) * 43758.5453);
}

float SmoothedNoise3d(int x, int y, int z) {
    float corners = (Noise3(x - 1, y - 1, z - 1) + Noise3(x + 1, y - 1, z - 1) + Noise3(x - 1, y + 1, z - 1) + Noise3(x + 1, y + 1, z - 1) +
                     Noise3(x - 1, y - 1, z + 1) + Noise3(x + 1, y - 1, z + 1) + Noise3(x - 1, y + 1, z + 1) + Noise3(x + 1, y + 1, z + 1)) / 64.f;
    float sides = (Noise3(x - 1, y, z - 1) + Noise3(x + 1, y, z - 1) + Noise3(x, y - 1, z - 1) + Noise3(x, y + 1, z - 1) +
                   Noise3(x - 1, y, z + 1) + Noise3(x + 1, y, z + 1) + Noise3(x, y - 1, z + 1) + Noise3(x, y + 1, z + 1) +
                   Noise3(x - 1, y - 1, z) + Noise3(x + 1, y - 1, z) + Noise3(x - 1, y + 1, z) + Noise3(x + 1, y + 1, z)) / 32.f;
    float center = (Noise3(x, y, z - 1) + Noise3(x, y, z + 1) + Noise3(x - 1, y, z) + Noise3(x + 1, y, z) + Noise3(x, y - 1, z) + Noise3(x, y + 1, z)) / 16.f;
    float middle = Noise3(x, y, z) / 8.f;
    return corners + sides + center + middle;
}

float InterpolatedNoise3d(float x, float y, float z)
{
    int integerX = int(x);
    float fractionalX = fract(x);

    int integerY = int(y);
    float fractionalY = fract(y);

    int integerZ = int(z);
    float fractionalZ = fract(z);

    float v1 = SmoothedNoise3d(integerX, integerY, integerZ);
    float v2 = SmoothedNoise3d(integerX + 1, integerY, integerZ);
    float v3 = SmoothedNoise3d(integerX, integerY + 1, integerZ);
    float v4 = SmoothedNoise3d(integerX + 1, integerY + 1, integerZ);
    float v5 = SmoothedNoise3d(integerX, integerY, integerZ + 1);
    float v6 = SmoothedNoise3d(integerX + 1, integerY, integerZ + 1);
    float v7 = SmoothedNoise3d(integerX, integerY + 1, integerZ + 1);
    float v8 = SmoothedNoise3d(integerX + 1, integerY + 1, integerZ + 1);

    float i1 = CosineInterpolate(v1, v2, fractionalX);
    float i2 = CosineInterpolate(v3, v4, fractionalX);
    float i3 = CosineInterpolate(v5, v6, fractionalX);
    float i4 = CosineInterpolate(v7, v8, fractionalX);
    float i5 = CosineInterpolate(i1, i2, fractionalY);
    float i6 = CosineInterpolate(i3, i4, fractionalY);

    return CosineInterpolate(i5, i6, fractionalZ);
}

float PerlinNoise3d(vec3 p)
{
    float x = p.x;
    float y = p.y;
    float z = p.z;
    float total = 0.f;
    float persistance = 0.6f;
    for (int i = 1; i <= N_OCTAVES; i++) {
        float frequency = pow(1.2f, float(i));
        float amplitutde = pow(persistance, float(i));

        total += InterpolatedNoise3d(x * frequency, y * frequency, z * frequency) * amplitutde;
    }
    return total;
}


vec3 calculateToonShading(vec3 normal, vec3 lightDir) {
    float intensity = max(dot(normal, lightDir), 0.f);
    const vec3 lightColor = vec3(1.f, 1.f, 1.f);

    //create bands
    if (intensity > 0.95f) {
        return lightColor;
    }
    else if (intensity > 0.6f) {
        return lightColor * 0.9f;
    }
    else if (intensity > 0.25f) {
        return lightColor * 0.6f;
    }
    else {
        return lightColor * 0.4;
    }
}


// rim color for glow
vec3 calculateRimLighting(vec3 normal, vec3 viewDir) {
    float edgeThreshold = 0.65f;
    const vec3 rimColor1 = vec3(1.f, 1.f, 0.f);
    const vec3 rimColor2 = vec3(1.f, 1.f, 1.f);
    float rim = 1.0 - max(dot(normal, viewDir), 0.0);
    vec3 rimColor = mix(rimColor1, rimColor2, rim - 0.15f);
    rim = smoothstep(edgeThreshold, 1.0, rim);
    return rimColor * rim;
}

void main()
{
    vec4 viewVec = normalize(u_CameraPos - fs_Pos);
    vec4 H = normalize(viewVec + fs_LightVec);


    // Base color gradient for fire
    vec3 fireColor = mix(u_LowerColor.xyz, u_UpperColor.xyz, fs_Pos.y - 0.1f);

    // Add some spots on the fire ball
    vec3 p = vec3(fs_Pos.xyz) * 2.f - 25.f * (sin(u_Time * 0.0003f) + 1.f);
    float n = PerlinNoise3d(p);
    float spotThreshold = 0.8f;
    if (n > spotThreshold) {
        fireColor = mix(vec3(1.0, 0, 0), fireColor, clamp(fs_Pos.y + 1.f, 0.8f, 0.95f));
    }

    vec3 toonColor = calculateToonShading(normalize(fs_Nor.xyz), normalize(fs_LightVec.xyz));
    vec3 rimLight = calculateRimLighting(normalize(fs_Nor.xyz), viewVec.xyz);
    vec3 color = fireColor * toonColor + rimLight;

    float alpha = mix(1.f, 0.5f, fs_Pos.y - 0.56f);

    out_Col = vec4(color, alpha);
}