#version 300 es

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.

uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering. In this assignment,
                            // this will be the result of traversing your scene graph.

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.
                            // This allows us to transform the object's normals properly
                            // if the object has been non-uniformly scaled.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself

uniform float u_Time;  // time in seconds
uniform float u_TimeScale;

uniform float u_PlumeHeight;

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.

out vec3 fs_Displacement;   // displaced vertex

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.

vec3 getCoarseDisplacement(vec3 pos, vec3 dir)
{
    float scaledTime = u_Time * u_TimeScale;

    float displ = 0.0;
    displ += sin(scaledTime * 2.0 + pos.x * 10.7) * 0.06;
    displ += sin(scaledTime * 0.9 + pos.y * 3.5 + 2.1) * 0.05;
    displ += sin(scaledTime * (-2.5) + pos.z * 12.1 + 0.8) * 0.053;

    return displ * dir;
}

vec3 getFineDisplacement(vec3 pos, vec3 dir)
{
    float displ = 0.0;

    int nOctaves = 4;

    float freqMult = 1.8;    
    float ampMult = 0.7;
    
    float phaseChange = 0.5;

    float phase = 0.0;
    float amp = 0.01;
    float posFreq = 50.0;
    float timeFreq = 10.0;

    for (int i = 0; i < nOctaves; i++)
    {
        displ += amp * sin(phase + 0.1 + pos.x * posFreq * 0.9);
        displ += amp * sin(phase + 0.4 + pos.y * posFreq * 0.7);
        displ += amp * sin(phase + 0.9 + pos.z * posFreq * 1.1);
        
        amp *= ampMult;
        timeFreq *= freqMult;
        posFreq *= freqMult;
        phase += phaseChange;
    }

    return displ * dir;
}

float triangleWave(float x)
{
    return abs(mod(x, 2.0) - 1.0);
}

float bias(float b, float t)
{
    return pow(t, log(b) / log(0.5f));
}

vec3 getPlumeDisplacement(vec3 refPos)
{
    if (refPos.y < 1.5)
        return vec3(0.0);

    
    float scaledTime = u_Time * u_TimeScale;
    float s = 0.0;
    s += triangleWave(0.3 + scaledTime * 0.21 + refPos.x * 48.0 + refPos.z * 53.1);
    s += triangleWave(0.9 + scaledTime * 0.19 + refPos.x * 57.2 - refPos.z * 42.9);
    s += triangleWave(0.2 + scaledTime * 0.1 - refPos.x * 29.9);
    s += triangleWave(1.0 + scaledTime * 0.15 + refPos.z * 61.0);

    float h = s / 4.0;
    h = bias(0.3, h);

    return h * u_PlumeHeight * vec3(0.0, 1.0, 0.0);
}

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.


    vec4 modelposition = u_Model * vs_Pos;   // Temporarily store the transformed vertex positions for use below

    vec3 refPos = modelposition.xyz;
    vec3 refDir = normalize(refPos);

    vec3 displacement = vec3(0.);
    displacement += getCoarseDisplacement(refPos, refDir);
    displacement += getFineDisplacement(refPos, refDir);
    displacement += getPlumeDisplacement(refPos);

    fs_Displacement = displacement;
    modelposition.xyz += displacement;

    fs_Col = vec4(1.0, 0.0, 0.0, 1.0);

    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
}

