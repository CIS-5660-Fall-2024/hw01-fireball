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

uniform float u_Time;            // Amount time has advanced since render start.


in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.


out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Pos;

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.

const float LARGE_FLICKER_MAGNITUDE = 0.5;


float bias (float b, float t) {
    return pow(t, log(b) / log(0.5));
}

float fireballSilhouetteDisplacement (vec3 position) {
    float shrinkAmount = 0.0;

    float t_height = (position.y + 1.0) / 2.0;

    // lerp
    // shrinkAmount = ((1.0 - t_height) * 0.0) + (t_height * 1.0);

    // bias
    shrinkAmount = 1.0 * bias(0.5, pow(t_height, 1.4));

    return shrinkAmount;
}

float largeFlickerDisplacement (vec3 position, float time) {
    float t_height = (position.y + 1.0) / 2.0;

    return 
        ( // the first sine is large steady waver, the others are "noise"/irregularly offset smaller flickers
            sin(((position.y - time) * 1.6)) 
            + max(0.0, (sin(position.y - (time * 3.0)) - 0.75) * 1.2) 
            + max(0.0, sin(position.y - (time * 4.0) + 1.5) - 0.75) 
            + max(0.0, (sin(position.y - (time * 3.0) + 2.25) - 0.75) * 1.5)
            + max(0.0, (sin(position.y - (time * 4.0) + 2.8) - 0.75))
        )
        * LARGE_FLICKER_MAGNITUDE 
        * bias(0.3, t_height);
}

void main()
{
    vec3 vertexPosition = vs_Pos.xyz;
    vec3 shrinkDirection = vec3(-vs_Pos.x, 0, -vs_Pos.z);

    // create the fireball silhouette
    vertexPosition += shrinkDirection * fireballSilhouetteDisplacement(vertexPosition);

    // offset large displacement
    vertexPosition += vec3(largeFlickerDisplacement(vertexPosition, u_Time), 0.0, 0.0);


    fs_Col = vs_Col;                            // Pass the vertex colors to the fragment shader for interpolation
    fs_Pos = vec4(vertexPosition, vs_Pos.w);                            // Pass the vertex position to fragment shader


    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.

    // vec4 modelposition = u_Model * vec4(vertexPosition.xyz, 0);   // Temporarily store the transformed vertex positions for use below
    vec4 modelposition = u_Model * vec4(vertexPosition, vs_Pos.w);   // Temporarily store the transformed vertex positions for use below

    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
}
