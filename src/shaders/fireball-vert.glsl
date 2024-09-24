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
uniform float u_time;
uniform float fbmamplitude;
uniform float fbmfrequency;
in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

 
out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Pos;
//out float wavet;
const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.

float sinfunction(vec4 p){
    return sin(vs_Pos.y * 2.0 + u_time * 2.0);
}

float fBM(vec4 p) {
    float amplitude = fbmamplitude;
    float frequency = fbmfrequency;
    float persistence = 0.5; 
    int octaves = 5; 

    float total = 0.0;

    
    for (int i = 0; i < octaves; i++) {
        total += sinfunction(p * frequency) * amplitude; 
        frequency *= 2.0; 
        amplitude *= persistence; 
    }

    return total;
}

float sawtooth_wave(float x, float freq, float amplitude){
    return (x*freq-floor(x*freq))*amplitude;
}

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation
    float wave = fBM(vs_Pos); // Wave effect along the Y-axis
    //wavet=wave;
    // Modify the X and Z coordinates with a sine wave.
    vec4 modifiedPos = vs_Pos;
    modifiedPos.x += wave * 0.1*sawtooth_wave(wave,1.0,1.0);  // Amplitude of the wave is 0.3 on X-axis
    modifiedPos.z += wave * 0.1;  // Amplitude of the wave is 0.3 on Z-axis
    modifiedPos.y += wave * 0.1;
    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.


    vec4 modelposition = u_Model * modifiedPos;   // Temporarily store the transformed vertex positions for use below
    fs_Pos = modelposition;
    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
}


