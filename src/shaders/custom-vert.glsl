#version 300 es

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.
precision highp float;

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
uniform vec4 u_CameraPos;
uniform float u_Intensity;

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Pos;

float triangleWave(float x, float freq, float amplitude)
{
    return abs(mod((x * freq), amplitude) - (0.5 * amplitude));
}

vec3 rotatePoint3d(vec3 point, vec3 center, vec3 axis, float angle)
{
    angle = angle / 180.f * 3.1415f;

    vec3 translatedPoint = point - center;

    vec3 normalizedAxis = normalize(axis);

    float cosAngle = cos(angle);
    float sinAngle = sin(angle);

    // Rodrigues' rotation formula
    vec3 rotatedPoint = translatedPoint * cosAngle +
        cross(normalizedAxis, translatedPoint) * sinAngle +
        normalizedAxis * dot(normalizedAxis, translatedPoint) * (1.0 - cosAngle);

    rotatedPoint += center;

    return rotatedPoint;
}

float mod289(float x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 perm(vec4 x) { return mod289(((x * 34.0) + 1.0) * x); }

float noise(vec3 p) {
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}

float bias(float t, float b) {
    return (t / ((((1.0 / b) - 2.0) * (1.0 - t)) + 1.0));
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

    vec3 pos = modelposition.xyz;
    float radius = 0.4f;
    float t = 0.003f * u_Time;

    float noiseVal = noise(pos * 10.f);

    float height = mix(u_Intensity, 2.f * u_Intensity, bias((sin(t * 2.f) + 1.f) * 0.5f, 0.8f));
    radius += height * triangleWave(pos.x - 1.f, 1.f, 2.0) - 0.1f;

    radius += 0.2f * (sin(25.0f * (pos.x - t)) + 1.0f) * 0.5f;
    radius += 0.4f * (sin(15.0f * (pos.y - t * 0.7f)) + 1.0f) * 0.5f;
    radius += 0.05f * (cos(30.0f * (pos.z + t)) + 1.0f) * 0.5f;
    radius += 0.2f * noiseVal;

    float lowerLimit = mix(0.2f * u_Intensity, 0.325f * u_Intensity, bias((sin(t * 2.f) + 1.f) * 0.5f, 0.8f));
    float lowerRadius = mix(lowerLimit, 1.f, pos.y + 1.f);
    lowerRadius = mix(lowerLimit + 0.3f, lowerRadius, abs(pos.x));
    lowerRadius += 0.04f * (sin(12.f * (pos.x - t)) + 1.f) * 0.5f;
    lowerRadius += 0.01f * (sin(30.f * (pos.y + t)) + 1.f) * 0.5f;

    float blendFactor = smoothstep(-0.2, 0.2, pos.y);
    float finalRadius = mix(lowerRadius, radius, blendFactor);

    modelposition.y = vec3(normalize(pos) * finalRadius).y;

    if (pos.y > 0.f) {
        float sign = (pos.x > 0.f) ? -1.f : 1.f;
        modelposition.xyz = rotatePoint3d(modelposition.xyz, vec3(0.f), vec3(0.f, 0.f, 1.f), sign * 15.f);
        
    }

    modelposition.x += (sin(5.0f * (modelposition.y - t)) + 1.0f) * 0.03f;
    modelposition.x += (sin(12.0f * (modelposition.y - t)) + 1.0f) * 0.01f;
    modelposition.x += 0.02f * noiseVal;

    fs_LightVec = u_CameraPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
    fs_Pos = modelposition;
}
