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

uniform float u_Time; 

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Pos;
out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.

vec3 random3(vec3 p)
{
    return fract(sin(vec3(dot(p, vec3(127.1f, 311.7f, 191.999f)),
                     dot(p, vec3(269.5f,183.3f, 472.6f)),
                     dot(p, vec3(377.4f,451.1f, 159.2f)))
                     * 43758.5453f));
}

float random1(float x)
{
    return fract(sin(x * 127.1) * 43758.5453);
}

// WorleyNoise function copied from the lecture notes
// float WorleyNoise(vec3 p) 
// {
//     vec3 pInt = floor(p);
//     vec3 pFract = fract(p);
//     float minDist = 1.0; // Minimum distance initialized to max.
//     for (int z = -1; z <= 1; ++z)
//     {
//         for(int y = -1; y <= 1; ++y) 
//         {
//             for(int x = -1; x <= 1; ++x) 
//             {
//                 vec3 neighbor = vec3(float(x), float(y), float(z)); // Direction in which neighbor cell lies
//                 vec3 point = random3(pInt + neighbor); // Get the Voronoi centerpoint for the neighboring cell
//                 vec3 diff = neighbor + point - pFract; // Distance between fragment coord and neighbor’s Voronoi point
//                 float dist = length(diff);
//                 minDist = min(minDist, dist);
//             }
//         }
//     }
//     return minDist;
// }
float WorleyNoise(float p) 
{
    float pInt = floor(p);
    float pFract = fract(p);
    float minDist = 1.0; // Minimum distance initialized to max.
            for(int x = -1; x <= 1; ++x) 
            {
                float neighbor = float(x); // Direction in which neighbor cell lies
                float point = random1(pInt + neighbor); // Get the Voronoi centerpoint for the neighboring cell
                float diff = neighbor + point - pFract; // Distance between fragment coord and neighbor’s Voronoi point
                float dist = length(diff);
                minDist = min(minDist, dist);
            }
    return minDist;
}




void main()
{
    float radius = 1.0f;

    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation

    fs_Pos = vs_Pos;
    


    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.


    vec4 modelposition = u_Model * vs_Pos;   // Temporarily store the transformed vertex positions for use below

    modelposition.x += WorleyNoise(vs_Pos.y + vs_Pos.z + cos(u_Time / 500.0)) ;
    modelposition.y += WorleyNoise(vs_Pos.z + vs_Pos.x + cos(u_Time / 1000.0)) ;
    modelposition.z += WorleyNoise(vs_Pos.x + vs_Pos.y + cos(u_Time / 3000.0)) ;


    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies




    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices


}