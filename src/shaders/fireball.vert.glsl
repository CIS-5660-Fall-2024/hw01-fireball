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
uniform highp int u_Time;
uniform float u_TailSpeed;
uniform int u_FbmOctaves;

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.

#define PI 3.14159265
#define t float(u_Time) / 100.0

float random(in float x) { return fract(sin(x) * 43758.5453); }

vec3 rand3(vec3 p) { return mod(((p * 34.0) + 1.0) * p, 289.0); }

vec3 mod289_3(vec3 x) { return x - floor(x * (1. / 289.)) * 289.; }
vec4 mod289_4(vec4 x) { return x - floor(x * (1. / 289.)) * 289.; }

vec4 permute(vec4 v) { return mod289_4(((v * 34.0) + 1.0) * v); }

vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }

float snoise(in vec3 v) {
    const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
    const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

    // First corner
    vec3 i  = floor(v + dot(v, C.yyy) );
    vec3 x0 =   v - i + dot(i, C.xxx) ;

    // Other corners
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min( g.xyz, l.zxy );
    vec3 i2 = max( g.xyz, l.zxy );

    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
    vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

    // Permutations
    i = mod289_3(i);
    vec4 p = permute( permute( permute(
                i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
            + i.y + vec4(0.0, i1.y, i2.y, 1.0 ))
            + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

    // Gradients: 7x7 points over a square, mapped onto an octahedron.
    // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
    float n_ = 0.142857142857; // 1.0/7.0
    vec3  ns = n_ * D.wyz - D.xzx;

    vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

    vec4 x = x_ *ns.x + ns.yyyy;
    vec4 y = y_ *ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);

    vec4 b0 = vec4( x.xy, y.xy );
    vec4 b1 = vec4( x.zw, y.zw );

    vec4 s0 = floor(b0)*2.0 + 1.0;
    vec4 s1 = floor(b1)*2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));

    vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy;
    vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww;

    vec3 p0 = vec3(a0.xy,h.x);
    vec3 p1 = vec3(a0.zw,h.y);
    vec3 p2 = vec3(a1.xy,h.z);
    vec3 p3 = vec3(a1.zw,h.w);

    //Normalise gradients
    vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;

    // Mix final noise value
    vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
    m = m * m;
    return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1),
                                dot(p2,x2), dot(p3,x3) ) );
}

float triangle_wave(float x, float freq, float amplitude) {
    return abs(mod(x * freq, amplitude) - (0.5 * amplitude));
}

#define FBM_AMPLITUD_INITIAL mix(0.05, 0.1, triangle_wave(t, 1.0, 0.5));
#define FBM_SCALE_SCALAR mix(2.5, 3.0, triangle_wave(t, 0.1, 0.5));
#define FBM_AMPLITUD_SCALAR mix(0.8, 1.0, triangle_wave(t, 0.5, 3.5));

float fbm3(vec3 pos) {
    // Initial values
    float value = 0.5;
    float amplitude = FBM_AMPLITUD_INITIAL;

    // Loop of octaves
    for (int i = 0; i < u_FbmOctaves; i++) {
        value += amplitude * snoise(pos);
        pos *= FBM_SCALE_SCALAR;
        amplitude *= FBM_AMPLITUD_SCALAR;
    }

    return value;
}

float bias(float b, float val) {
    return pow(val, log(b) / log(0.5));
}

void main()
{
    fs_Col = vs_Col; // Pass the vertex colors to the fragment shader for interpolation

    // Pass the vertex normals to the fragment shader for interpolation.
    // Transform the geometry's normals by the inverse transpose of the
    // model matrix. This is necessary to ensure the normals remain
    // perpendicular to the surface after the surface is transformed by
    // the model matrix.
    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);

    vec4 pos = vs_Pos;
    vec3 randPos = rand3(pos.xyz);

    // Low frequency, high amplitude
    vec4 vertPos = pos + vs_Nor * ((0.05 * sin(t * 4.0 + pos.x) + 0.02) + (0.01 * cos(t * 1.5 + pos.y) + 0.04)) + (0.05 * sin(t * 2.2 + pos.z * pos.x) + 0.1);

    // High frequency, low amplitude (relatively, using FBM)
    vertPos += vs_Nor * fbm3(vs_Nor.xyz);

    float falloff = clamp(dot(vs_Nor.xyz, vec3(0, 1, 0)), 0.0, 1.0);
    falloff = bias(0.00001, falloff);
    vertPos.y += 4.0 * falloff;

    float weight = 0.0;
    if (vertPos.y >= 1.0 && vertPos.y < 2.5) {
        weight = mix(0.0, 1.0, (vertPos.y - 1.0) / 1.5);
    } else if (vertPos.y >= 2.0) {
        weight = 1.0;
    }
    vertPos.x += weight * mix(0.3, 0.45, triangle_wave(t, 2.0, 2.0)) * sin((-vertPos.y + t * mix(0.2, 7.0, u_TailSpeed / 10.0)) * 3.0);
    vertPos.z += weight * mix(0.5, 0.6, triangle_wave(t, 0.75, 1.5)) * sin((-vertPos.y + 2.0 * t * mix(0.3, 5.0, u_TailSpeed / 10.0)) * 2.0);

    vec4 modelposition = u_Model * vertPos;   // Temporarily store the transformed vertex positions for use below

    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_ViewProj * modelposition; // gl_Position is a built-in variable of OpenGL which is used to render the final positions of the geometry's vertices
}