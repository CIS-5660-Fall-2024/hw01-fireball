#version 300 es

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.

uniform float u_Time;

// Used for driving animation with music
uniform float u_Loudness;
uniform float u_Tempo; // BPM

uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering. In this assignment,
                            // this will be the result of traversing your scene graph.

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.
                            // This allows us to transform the object's normals properly
                            // if the object has been non-uniformly scaled.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Pos;            // The position of each vertex. This is implicitly passed to the fragment shader.
out float fs_MaxHeight;        // The maximum height of the geometry. This is passed to the fragment shader.

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.

const float PI = 3.14159265359;

float powPulse(float x, float k) {
    return pow(4.0 * x * (1.0 - x), k);
}

vec3 computeTangent(vec3 normal) {
    // Choose an arbitrary vector that is not parallel to the normal
    // (Specifically choosing these arbitrary vectors so that the computed tangent tends toward the positive y direction)
    vec3 arbitrary = vec3(0.0, 0.0, 1.0);
    if (abs(normal.z) > 0.999) {
        arbitrary = vec3(1.0, 0.0, 0.0);
    }

    // Compute the tangent vector
    vec3 tangent = normalize(cross(normal, arbitrary));

    return tangent;
}

const float domainNoiseScaleFactor = 0.1;      // controls domain scale of noise pattern
const float rangeNoiseScaleFactor = 0.2;       // controls range scale of noise pattern

float pseudoRandom( vec2 p ) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) *
                 43758.5453);
}

// Based on my own work, here: https://www.shadertoy.com/view/slsBzl
float noise2D(in vec2 position) {
    position /= domainNoiseScaleFactor;

    vec2 ij = floor(position);
    vec2 posFraction = fract(position);
    vec2 smoothedPositionFract = smoothstep(0.0,1.0,posFraction);

    // Coefficients for noise function
    float a = pseudoRandom(ij + vec2(0,0));
    float b = pseudoRandom(ij + vec2(1,0));
    float c = pseudoRandom(ij + vec2(0,1));
    float d = pseudoRandom(ij + vec2(1,1));

    float noise = a
        + (b-a)*smoothedPositionFract.x
        + (c-a)*smoothedPositionFract.y
        + (a-b-c+d)*smoothedPositionFract.x*smoothedPositionFract.y;

    return rangeNoiseScaleFactor * noise;
}

// Based on my own work, here: https://www.shadertoy.com/view/slsBzl
float fbm(in vec2 seed, int iterations) {
    float value = noise2D(seed);
    float domainScale = 1.0;
    float rangeScale = 1.0;

    for (int i = 1; i < iterations; i++) {
        domainScale *= 2.0;
        rangeScale /= 2.0;

        float value_i = rangeScale * noise2D(domainScale * seed);
        value += value_i;
    }

    return value;
}

void createBigRipples(inout vec3 modelposition) {
    float warpAmplitude = 0.035;
    float warpFreq = 5.0;
    float warpSpeed = 2000.0;
    float warpPhase = 0.0;
    float warpAmount = warpAmplitude * sin(warpFreq * PI * (modelposition.y - (u_Time / warpSpeed) + warpPhase));
    modelposition.xz += warpAmount * normalize(modelposition.xz);
}

void shapeIntoFire(inout vec3 modelposition) {
    modelposition.xz *= sqrt(-(modelposition.y - 1.0) / 2.0);
}

void createFireTendrils(inout vec3 modelposition, in vec3 tangent) {
    float noise = fbm(modelposition.xz + (u_Time / 2000.0), 2);
    // As we get towards the top of the flame, the tendrils should go upwards more than along their tangents.
    float upwardsFactor = pow(modelposition.y + 0.5, 3.0);
    vec3 direction = mix(tangent, vec3(0.0, 1.0, 0.0), upwardsFactor);
    modelposition += noise * direction;
}

void overallFireTransformation(inout vec3 modelposition, in vec3 tangent) {
    createBigRipples(modelposition);
    shapeIntoFire(modelposition);
    createFireTendrils(modelposition, tangent);
}

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(normalize(invTranspose * vec3(vs_Nor)), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.


    vec4 modelposition = u_Model * vs_Pos;   // Temporarily store the transformed vertex positions for use below

    vec3 tangent = computeTangent(fs_Nor.xyz);
    vec3 bitangent =  normalize(cross(fs_Nor.xyz, tangent));;
    vec3 dTangent = modelposition.xyz + (0.0001) * tangent;
    vec3 dBitangent = modelposition.xyz + (0.0001) * bitangent;

    /* Warp vertices in model space to look like fire */
    overallFireTransformation(modelposition.xyz, tangent);

    /* Approximate new normals */
    overallFireTransformation(dTangent, tangent);
    overallFireTransformation(dBitangent, tangent);
    fs_Nor = vec4(normalize(cross(dTangent - modelposition.xyz, dBitangent - modelposition.xyz)), 0.0);

    /* Distort vertices according to music loudness and tempo */

    // Since loudness is in DB, we need to convert it to a linear scale
    float distortionAmplitude = clamp(pow(10.0, (u_Loudness - 5.0) * 0.05), 0.05, 1.75);

    if (u_Tempo != 0.0) {
        float timePerBeat = (60.0 / u_Tempo) * 1000.0; // Time in milliseconds per beat
        // Repeats every timePerBeat, ranges from 0 to 1.
        // Phase shift u_Time so that the peak of the distortion is at the start of the beat
        float modTime = mod(u_Time, timePerBeat) / timePerBeat;
        float distortion = distortionAmplitude * powPulse(modTime, 7.0);
        modelposition.xyz += distortion * normalize(modelposition.xyz);
    }

    /* End distortion */

    fs_LightVec = lightPos;

    fs_Pos = modelposition;

    // Transform the top point on the sphere to get the maximum height of the geometry
    vec3 topPoint = vec3(0.01, 1.0, 0.01);
    overallFireTransformation(topPoint, vec3(1.0, 0.0, 0.0));
    fs_MaxHeight = topPoint.y;

    gl_Position = u_ViewProj * modelposition; // gl_Position is a built-in variable of OpenGL which is
                                              // used to render the final positions of the geometry's vertices
}
