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
uniform float u_Gain; 

uniform bool u_StopMotion; 

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Pos; 
out float fs_Displacement; 

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.

vec3 hash33( vec3 p ) {                        
	p = vec3( dot(p,vec3(127.1,311.7, 74.7)),
			  dot(p,vec3(269.5,183.3,246.1)),
			  dot(p,vec3(113.5,271.9,124.6)));

	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float perlinNoise( in vec3 x )
{
    // grid
    vec3 p = floor(x);
    vec3 w = fract(x);
    
    // quintic interpolant
    vec3 u = w*w*w*(w*(w*6.0-15.0)+10.0);

    
    // gradients
    vec3 ga = hash33( p+vec3(0.0,0.0,0.0) );
    vec3 gb = hash33( p+vec3(1.0,0.0,0.0) );
    vec3 gc = hash33( p+vec3(0.0,1.0,0.0) );
    vec3 gd = hash33( p+vec3(1.0,1.0,0.0) );
    vec3 ge = hash33( p+vec3(0.0,0.0,1.0) );
    vec3 gf = hash33( p+vec3(1.0,0.0,1.0) );
    vec3 gg = hash33( p+vec3(0.0,1.0,1.0) );
    vec3 gh = hash33( p+vec3(1.0,1.0,1.0) );
    
    // projections
    float va = dot( ga, w-vec3(0.0,0.0,0.0) );
    float vb = dot( gb, w-vec3(1.0,0.0,0.0) );
    float vc = dot( gc, w-vec3(0.0,1.0,0.0) );
    float vd = dot( gd, w-vec3(1.0,1.0,0.0) );
    float ve = dot( ge, w-vec3(0.0,0.0,1.0) );
    float vf = dot( gf, w-vec3(1.0,0.0,1.0) );
    float vg = dot( gg, w-vec3(0.0,1.0,1.0) );
    float vh = dot( gh, w-vec3(1.0,1.0,1.0) );
	
    // interpolation
    return va + 
           u.x*(vb-va) + 
           u.y*(vc-va) + 
           u.z*(ve-va) + 
           u.x*u.y*(va-vb-vc+vd) + 
           u.y*u.z*(va-vc-ve+vg) + 
           u.z*u.x*(va-vb-ve+vf) + 
           u.x*u.y*u.z*(-va+vb+vc-vd+ve-vf-vg+vh);
}

float bias(float b, float t) {
    return pow(t, log(b) / log(0.5f)); 
}

float gain(float g, float t) {
    if (t < 0.5f) {
        return bias(1. - g, 2.*t) / 2.; 
    } else {
        return 1. - bias(1.-g, 2. - 2.*t) / 2.; 
    }
}

float fbm(vec3 p) {
    float amplitude = 1.;
    float frequency = 0.4;

    float y = perlinNoise(p*frequency) * 1.2;
    y += perlinNoise(p*frequency*20.1)*.3; 
    
    //y += perlinNoise(p*frequency*1.72)*4. 

     return y; 
}

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation

    mat3 invTranspose = mat3(u_ModelInvTr);

    float time = u_Time * 0.07;
    if (u_StopMotion) {
        time = floor(u_Time * 0.10);
    }
    //time = floor(u_Time * 0.3); 
    float displacement = 0.1 * fbm(2. * vs_Pos.xyz - vec3(0., time, 0.));
    fs_Displacement = displacement; 
    vec4 vertex_pos = vs_Pos; 
    vertex_pos += vs_Nor * displacement; 

    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.

    vec4 modelposition = u_Model * vertex_pos;   // Temporarily store the transformed vertex positions for use below
    fs_Pos = modelposition; 
    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    vec4 final_pos = u_ViewProj * modelposition; 

    gl_Position = final_pos; // gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
}
