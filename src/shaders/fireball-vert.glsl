#version 300 es

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.
uniform float u_Tick;
uniform float u_Scale;
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
out vec4 fs_Pos;

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.


float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

float noise(vec3 p){
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


float fbm(vec3 x) {
	float v = 0.0;
	float a = 0.5;
	vec3 shift = vec3(100);
	for (int i = 0; i < 8; ++i) {
		v += a * noise(x);
		x = x * 2.0;// + shift;
		a *= 0.5;
	}
	return v;
}


float pattern(vec3 p)
{
    vec3 q = vec3( fbm( p + vec3(0.0,0.0,0.3) ),
                   fbm( p + vec3(5.2,1.3,5.8) ),
                   fbm( p + vec3(5.9,14.3,56.8) ) );

    vec3 r = vec3( fbm( p + 4.0*q + vec3(1.7,9.2,43) ),
                   fbm( p + 4.0*q + vec3(8.3,2.8,23) ),
                   fbm( p + 4.0*q + vec3(167,942,3) ));

    return fbm( p + 4.0*r );
}

float easeOutQuad(float x) {
    return 1.0f - (1.0f - x) * (1.0f - x);
}

float bias(float b, float t){
    return pow(t, log(b)/log(0.5));
}

float gain(float g, float t){
    if(t<0.5){
        return bias(1.-g,2.*t)/2.;
    }
    else{
        return 1.-bias(1.-g,2.-2.*t)/2.;
    }
}

vec3 CalculateFlames(vec3 pos) {

    // The bigger lower level shapes
    float noise = noise(pos.xyz * 2.f + (u_Tick / 60.f));

    float height = bias((pos.y + 1.f) / 2.f, 0.1f);

    // Create shape on bottom half
    if(pos.y < 0.f) {
        float desiredY = pos.y * easeOutQuad(abs(pos.y + noise / 3.f));
        pos.y = mix(pos.y, desiredY, height);
    }

    // Find verticle angle of the position
    float angleFromXZ = dot(pos, vec3(0.f, 1.f, 0.f));

    // Use noise to compute flames
    float flames = abs(mix(pos.y, pos.y + noise, angleFromXZ)) * 1.2f + 0.4f;

    // Interpolate flames based on height
    pos.y = mix(pos.y, flames, height);

    return pos;
}

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation
    float t = u_Tick/100. + 20.;;
    float s = gain(0.4,(mod(sqrt(t/(sqrt(2.)*10.)),1000.)));
    float c = bias(0.8,(mod(sqrt(t*sqrt(3.)/2.+3.141592653589/2.),1000.)));
    fs_Pos = vs_Pos; 
    float n = bias(0.8,noise(vec3(fs_Pos*(+ 1.-2.*s*s + 2.*c*c-1.))));
    float f = bias(0.8,fbm(vec3(fs_Pos*(2.*c+c*s+2.*s))));
    float p = bias(0.9,pattern(vec3(fs_Pos/10.*(s+c)*20.)));
    fs_Pos = vec4(CalculateFlames(fs_Pos.xyz),1.);
    fs_Pos = vec4(fs_Pos.xyz*n,1)+vec4(fs_Pos.xyz*f,1.)+ (fs_Pos.y>0.? vec4(0,abs(p),0,0):vec4(0.));
    fs_Pos = vec4(fs_Pos.xyz*u_Scale,1);
    
    
    
    
    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.

    vec4 modelposition = u_Model * fs_Pos;   // Temporarily store the transformed vertex positions for use below

    fs_LightVec = vec4(0,-1.,0,1.);// lightPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
}
