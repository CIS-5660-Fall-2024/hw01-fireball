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

uniform float u_pointsAmplitude;
uniform float u_fbmAmplitude;
uniform float u_timeSpeed;

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Pos;
out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.
out vec3 fs_Noise;
out vec4 fs_Center;
out vec4 fs_ScreenspaceCenter;
out vec4 fs_projPos;

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.

// From mini-minecraft
vec3 noise( vec3 p ) {
    return normalize(fract(sin(vec3(
                                         dot(p, vec3(127.1, 311.7, 74.7)),
                                         dot(p, vec3(269.5, 183.3, 246.1)),
                                         dot(p, vec3(419.2, 371.9, 156.3))
                                         )) * 43758.5453f) * 2.f - vec3(1.f, 1.f, 1.f));
}

vec3 interpolatedNoise ( vec3 p, float frequency) {

    vec3 scaledP = p * frequency;
    vec3 flooredP = floor(scaledP);
    vec3 ceiledP = ceil(scaledP);

    vec3 noise1 = noise(vec3(flooredP));
    vec3 noise2 = noise(vec3(flooredP.xy, ceiledP.z));
    vec3 noise3 = noise(vec3(flooredP.x, ceiledP.y, flooredP.z));
    vec3 noise4 = noise(vec3(flooredP.x, ceiledP.y, ceiledP.z));
    vec3 noise5 = noise(vec3(ceiledP.x, flooredP.yz));
    vec3 noise6 = noise(vec3(ceiledP.x, flooredP.y, ceiledP.z));
    vec3 noise7 = noise(vec3(ceiledP.xy, flooredP.z));
    vec3 noise8 = noise(vec3(ceiledP.xyz));

    noise1 = mix(noise1, noise2, fract(scaledP.z));
    noise3 = mix(noise3, noise4, fract(scaledP.z));
    noise5 = mix(noise5, noise6, fract(scaledP.z));
    noise7 = mix(noise7, noise8, fract(scaledP.z));

    noise1 = mix(noise1, noise3, fract(scaledP.y));
    noise5 = mix(noise5, noise7, fract(scaledP.y));

    noise1 = mix(noise1, noise5, fract(scaledP.x));


    return noise1;

}

vec3 fbm ( vec3 p, float octaves, float amplitude, float persistance, float scale ) {
    vec3 total = vec3(0.f);
    
    for (float i = 0.0; i < octaves; i += 1.0) {
        float frequency = scale * pow(2.0, i);
        float innerAmplitude = pow(persistance, i);

        total += innerAmplitude*interpolatedNoise(p, frequency);

    }
    return amplitude*total;
}

// function from demofox.org/biasgain.html (linked in slides)
// Assume t and bias are between 0 and 1
float bias ( float t , float bias) {
    return (t / ((((1.0 / bias) - 2.0)*(1.0 - t)) + 1.0));
}

void main()
{

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.

    vec4 newPos = vec4(vec3(vs_Pos) + u_fbmAmplitude * fbm(vec3(vs_Pos) + vec3(0.0, 0.0, u_Time/60.0), 5.0, 1.0, 0.5, 1.0), 1.f);
    
    newPos.y += u_pointsAmplitude*(0.125*sin((u_Time + 56.0)/60.0) + 0.875)*1.0*bias(clamp(dot(vs_Nor, vec4(0.0, 1.0, 0.0, 0.0)), 0.0, 1.0), 0.04);
    newPos.y += u_pointsAmplitude*(0.25*sin(u_Time/45.0) + 0.75)*0.5*bias(clamp(dot(vs_Nor, normalize(vec4(-0.5, 0.8, -0.5, 0.0))), 0.0, 1.0), 0.04);
    newPos.y += u_pointsAmplitude*(0.25*sin((u_Time + 4.05)/45.0) + 0.75)*bias(clamp(dot(vs_Nor, normalize(vec4(0.5, 0.8, 0.5, 0.0))), 0.0, 1.0), 0.04);
    newPos.y += u_pointsAmplitude*(0.25*sin((u_Time + 35.0)/40.0) + 0.75)*bias(clamp(dot(vs_Nor, normalize(vec4(-0.5, 0.8, 0.5, 0.0))), 0.0, 1.0), 0.04);
    newPos.y += u_pointsAmplitude*(0.25*sin((u_Time + 56.0)/35.0) + 0.75)*bias(clamp(dot(vs_Nor, normalize(vec4(0.5, 0.8, -0.5, 0.0))), 0.0, 1.0), 0.04);

    for (float i = 0.0; i < 10.0; i++) {
        float scale = 5.0;

        vec3 noisyDir = interpolatedNoise(vec3(0.0, 0.0, i), scale);

        vec3 moreNoise = interpolatedNoise(vec3(0.0, 0.0, i + 102.0), scale);
        if (dot(noisyDir, vec3(0.0, 1.0, 0.0)) < 0.0) {
            noisyDir *= -1.0;
        }
        newPos.rgb += u_pointsAmplitude*(abs(moreNoise.x) * 0.5 + 0.5)*(0.5*sin(u_Time / (15.0*moreNoise.y + 30.0) + i) + 0.5) * mix(vec3(0.0,1.0,0.0), noisyDir, 0.5) * 0.5*bias(clamp(dot(vs_Nor.rgb, noisyDir), 0.0, 1.0), 0.04);
    }
    
    
    newPos.y += sin(u_Time / 60.f);
    fs_Center = vec4(0.0, sin(u_Time / 60.f), 0.0, 1.0);
    
    vec4 modelposition = u_Model * newPos;   // Temporarily store the transformed vertex positions for use below
    fs_Pos = modelposition;
    fs_Noise = fbm(vec3(vs_Pos) + vec3(0.0, 0.0, u_Time/60.0), 5.0, 1.0, 0.5, 1.0);

    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices

    fs_projPos = gl_Position;
    fs_ScreenspaceCenter = u_ViewProj * fs_Center;
}