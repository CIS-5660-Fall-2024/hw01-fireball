#version 300 es

uniform float u_Time; 

uniform float u_Freq;
uniform float u_Amp;
uniform float u_FlameHeight;

uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;

in vec4 vs_Pos;
in vec4 vs_Nor;
in vec4 vs_Col;

out vec4 fs_Nor;
out vec4 fs_LightVec;
out vec4 fs_Col;
out vec4 fs_Pos;

const vec4 lightPos = vec4(5, 5, 3, 1);

// From Toolbox Functions
float sawtoothWave(float x, float freq, float amplitude) {
    return (x * freq - floor(x * freq)) * amplitude;
}

float triangleWave(float x, float freq, float amplitude) {
    return abs(mod(x * freq, amplitude) - (0.5 * amplitude));
}

float impulse(float k, float x) {
    float h = k * x;
    return h * exp(1.0 - h);
}

// Credit to IQ and LYGIA
#define RANDOM_SCALE vec4(.1031, .1030, .0973, .1099)
vec3 random3(vec3 p) {
    p = fract(p * RANDOM_SCALE.xyz);
    p += dot(p, p.yxz + 19.19);
    return fract((p.xxy + p.yzz) * p.zyx);
}

float noise3D(vec3 p) {
    return fract(sin(dot(p, vec3(12.9898, 78.233, 128.852))) * 43758.5453) * 2.0 - 1.0;
}

float fbm(vec3 position) {
    float frequency = 1.0;
    float amplitude = 1.0;

    float total = 0.0;
    int octaves = 5;
    // start with 5
    for (int i = 0; i < octaves; i++) {
        total += amplitude * noise3D(frequency * position);
        frequency *= 2.0;  
        amplitude *= 0.5;  
    }
    return total;
}

void main() {
    // Pass through the vertex color and position to the fragment shader
    fs_Col = vs_Col;
    fs_Pos = vs_Pos;

    // Low-Frequency, High-Amplitude Displacement Layer with Triangle Wave
    float lowFreqAmplitude = 0.45 * u_Amp; 
    float lowFreqFrequency = 0.73 * u_Freq;  
    vec3 lowFreqDisplacement = vec3(
        triangleWave(vs_Pos.x + u_Time * 0.01, lowFreqFrequency, lowFreqAmplitude), 
        sin(vs_Pos.y * lowFreqFrequency + u_Time * 0.01), 
        triangleWave(vs_Pos.z + u_Time * 0.01, lowFreqFrequency, lowFreqAmplitude)) * lowFreqAmplitude;
    vec4 lowFreqPos = vs_Pos + vec4(lowFreqDisplacement, 0.0);

    // High-Frequency, Low-Amplitude Layer with Sawtooth Wave
    float highFreqAmplitude = 0.05;  
    vec3 highFreqDisplacement = vec3(
        fbm(vs_Pos.xyz * 3.0) + sawtoothWave(vs_Pos.x + u_Time * 0.05, 5.0, highFreqAmplitude),
        fbm(vs_Pos.yzx * 1.77), 
        fbm(vs_Pos.zxy * 5.0) + sawtoothWave(vs_Pos.z + u_Time * 0.05, 5.0, highFreqAmplitude)) * highFreqAmplitude;

    vec3 randDisplacement = random3(highFreqDisplacement) * 0.02;

    // Combining low freq with high freq
    vec4 finalPos = lowFreqPos + vec4(highFreqDisplacement + randDisplacement, 0.0);

    float rippleEffect = cos(u_Time * 0.03 + fbm(vs_Pos.xyz * 1.5)) * 0.08;
    finalPos += vec4(vs_Nor.xyz * rippleEffect * 2.81, 0.0);

    // For flame tapering effect
    float flameHeight = clamp(finalPos.y, 0.1, 0.7);  // Control height for taper
    float taperFactor = mix(1.0, 0.1, flameHeight);   // Narrow tip as height increases
    finalPos.x *= taperFactor;  
    finalPos.y *= u_FlameHeight;  
    finalPos.z *= taperFactor;

    if (finalPos.y > 0.9) {
        float curlAmount = sin(u_Time * 0.02 + finalPos.y * 4.11) * 0.28;  
        finalPos.x += curlAmount;
        finalPos.z += curlAmount;
    }

    mat3 normalMatrix = mat3(u_ModelInvTr);
    fs_Nor = vec4(normalMatrix * vec3(vs_Nor), 0.0);

    // Final transformed position with deformation
    vec4 modelPosition = u_Model * finalPos;

    // Calculate the light vector from the light source
    fs_LightVec = lightPos - modelPosition - vec4(10.0, 50.0, 5.0, 1.0);

    // Output the final transformed position to the vertex shader
    gl_Position = u_ViewProj * modelPosition;
}