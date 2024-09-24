#version 300 es

precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.
uniform vec4 u_Color2; 
uniform float u_Time; 
uniform float u_Gain;

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos; 
in float fs_Displacement; 

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

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

#define OCTAVES 9
#define PERSISTANCE 0.1;
#define LACUNARITY 5.0; 
float fbm(vec3 position) {
     float amplitude = 3.5; 
     float frequency = 1.5; 
     float total = 0.; 

     for (int i = 0; i < OCTAVES; ++i) {
          total += perlinNoise(position * frequency) * amplitude; 
          amplitude *= PERSISTANCE; 
          frequency *= LACUNARITY; 
     }
     return clamp(total, -1., 1.);
}

float turbulencefbm(vec3 p, int octaves, float persistance, float lacunarity) {
     float amplitude = 2.5; 
     float frequency = 1.0; 
     float total = 0.0; 
     float normalization = 0.0; 

     for (int i = 0; i < octaves; ++i) {
          float noiseValue = perlinNoise(p * frequency); 
          noiseValue = abs(noiseValue);

          total += noiseValue * amplitude; 
          normalization += amplitude; 
          amplitude *= persistance; 
          frequency *= lacunarity; 
     }

     total /= normalization; 

     return total; 
}

vec3 linearToSRGB(vec3 value) {
     vec3 lt = vec3(lessThanEqual(value.rgb, vec3(0.0031308))); 
     vec3 v1 = value * 12.92; 
     vec3 v2 = pow(value.rgb, vec3(0.41666)) * 1.055 - vec3(0.055); 

     return mix(v2, v1, lt); 
}

float remap(float value, float min1, float max1, float min2, float max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

float triangle_wave(float x, float freq, float amplitude) {
     return abs(mod((x * freq), amplitude) - (0.5 * amplitude)); 
}

void main() {
     vec3 albedo = u_Color.xyz; 

     vec3 displacementFactor = 1. - vec3(10. * fs_Displacement); 
     displacementFactor.y = triangle_wave(displacementFactor.y, 15., 8.); 

     albedo = mix(albedo, u_Color2.xyz, smoothstep(0., 10. * u_Gain, displacementFactor));  

     vec3 lightdir = normalize(vec3(3., 3., 0.)); 

     vec3 diffuse = u_Color2.xyz; 

     vec3 finalcolor = albedo * (diffuse + vec3(0.1)); 
     finalcolor = linearToSRGB(finalcolor);

     out_Col = vec4(albedo, 1.);
}

