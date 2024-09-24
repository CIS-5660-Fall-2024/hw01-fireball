#version 300 es
precision highp float;

uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_Dimensions;
uniform float u_Time;

uniform bool u_StopMotion; 

in vec2 fs_Pos;
out vec4 out_Col;

#define PI 3.14159

// -- below is shamelessly copied from https://www.shadertoy.com/view/MctXWS, check it out

vec2 random2(vec2 st, float seed){
    st = vec2( dot(st,vec2(127.1,311.7)),
              dot(st,vec2(269.5,183.3)) );
    return -1.0 + 2.0*fract(sin(st)*43758.5453123 * seed * 0.753421);
}

// Remap value
float map( float value, float fromMin, float fromMax, float toMin, float toMax ) 
{
    value = (value - fromMin) / (fromMax - fromMin);
    value = toMin + value * (toMax - toMin);
    return value;
}

// Remap value with stepped lerp
float mapStep( float value, float fromMin, float fromMax, float toMin, float toMax, float steps )
{
    value = (value - fromMin) / (fromMax - fromMin);
    value = floor(value * steps) / steps;
    value = toMin + value * (toMax - toMin);
    return value;
}

// Blender's mixRGB node, linear light mode
vec3 linearLight(in vec3 a, in vec3 b, in float factor)
{
    return a + factor * (2. * b - 1.);
}

float noise(vec2 st, float seed) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    vec2 u = f*f*(3.0-2.0*f);

    return mix( mix( dot( random2(i + vec2(0.0,0.0), seed ), f - vec2(0.0,0.0) ),
                     dot( random2(i + vec2(1.0,0.0), seed ), f - vec2(1.0,0.0) ), u.x),
                mix( dot( random2(i + vec2(0.0,1.0), seed ), f - vec2(0.0,1.0) ),
                     dot( random2(i + vec2(1.0,1.0), seed ), f - vec2(1.0,1.0) ), u.x), u.y);
}

float fbm (in float seed, in vec2 st, in float scale, in int octaves, in float roughness, in float lacunarity) {
    // Initial values
    float amplitude = .5;
    float frequency = 0.;
    float value = 0.;
    st *= scale;
    //
    // Loop of octaves
    for (int i = 1; i < octaves; i++) {
        value += amplitude * noise(st, seed);
        st *= lacunarity;
        amplitude *= roughness;
    }
    return value * .5 + .5;
}

// above is shamelessly copied from https://www.shadertoy.com/view/MctXWS

void main() {
  vec4 col; 
  
  // get a 0, 1 space to play around in
  vec2 uv = fs_Pos; 
  uv += 1.;
  uv *= 0.5; 
  uv = vec2(1. - uv.y, 1.0 - uv.x);
#if 0 
  if (distance(uv, vec2(0.5, 0.5)) < 0.3) {
    col = vec4(1., 0., 0., 1.); 
  } else {
    col = vec4(0.); 
  }
#endif

float time = u_Time * 0.01; 

if (u_StopMotion) {
  time = floor(u_Time * 0.12); 
}

vec2 uvScale = vec2(.5, .5);
uv = (uv * 2. - 1.) * uvScale;
uv.x += .75; 
float uvX = uv.x;
//uv *= (1. - step(1., abs(uv.y))) * (1. - step(1., abs(uv.x)));
vec2 uvFlame = uv + vec2(time * 2., 0.);

float roughness = 0.675;
int detail = 4;
float scale = 4.0;
float lacunarity = 2.0;
float noise1d = fbm(24., uvFlame, scale, detail, roughness, lacunarity);
vec3 noise3d = vec3(fbm(24., uvFlame, scale, detail, roughness, lacunarity), 
                    fbm(12., uvFlame, scale, detail, roughness, lacunarity),
                    fbm(33., uvFlame, scale, detail, roughness, lacunarity));

float lightFactor = clamp(map(uvX, 0.13, .87, 1., .06), .06, 1.);

vec3 light = linearLight(vec3(uv * vec2(1., 1.), 0.), noise3d, lightFactor);
light = abs(light) - vec3(.75, 0., 0.);
light = max(light, vec3(0.));
float lightLength = length(light);
float fireball_grad = clamp(map(uvX, -.24, 0.82, 0.0, 0.27), 0.0, 0.27);
lightLength -= fireball_grad;
lightLength = step(lightLength, -.01);

//noise1d *= uvX;
noise1d = mapStep(noise1d, .24, .77, .0, 2., 4.);
noise1d *= pow(uvX, 4.);

vec4 color = mix(vec4(0.), vec4(1., .37, .068, .3) * noise1d * 4., lightLength); 

out_Col = color;
}
