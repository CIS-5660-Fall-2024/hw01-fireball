#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.
uniform float u_Tick;
// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

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
	for (int i = 0; i < 6; ++i) {
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

    vec3 m = vec3( fbm( p + 4.0*q + 8.0*r + vec3(.7*2.,42./(3.43),03213.3) ),
                   fbm( p + 4.0*q + 8.0*r + vec3(.3*2.,48./(3.43),3.321) ),
                   fbm( p + 4.0*q + 8.0*r + vec3(67.*2.,42./(3.43),0.321) ));

    return fbm( p + 4.0*r +8.*m);
}

float gradient(vec3 pos){
    return clamp(length(pos)/2.,0.,1.);
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

void main()
{
    vec4 diffuseColor = u_Color;
    vec4 topColor = u_Color;

    float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));

    diffuseTerm = clamp(diffuseTerm, 0., 1.);

    float ambientTerm = 0.99f;
    float lightIntensity = diffuseTerm + ambientTerm;
    float direction = dot(normalize(fs_Nor.xyz), normalize(fs_Pos.xyz - vec3(0,0,5.)));
    diffuseColor = vec4(mix(diffuseColor.xyz, topColor.xyz + (fbm(fs_Pos.xyz) * 0.33f), bias(((fs_Pos.y) / (1.5f)), 0.27f + (abs(sin(u_Tick / 10.f))) * 0.1f)), 1.f);


    vec3 pos = vec3(fs_Pos[0], fs_Pos[1], fs_Pos[2]);
    pos = (pos+vec3(1000.,0,0))/5.;
    if(fs_Pos.y<0.)
        diffuseColor = u_Color;

    out_Col = vec4(diffuseColor.xyz*(gain(0.8,gradient(pos)*pattern(pos/5.-vec3(0,mod(u_Tick/100.,10000.),0)))),1.);
}
