#version 300 es
precision highp float;

#define PI 3.141592653589793
#define TWO_PI 6.28318530718
#define HALF_PI 1.5707963267948966

uniform vec2 u_Dimensions;
uniform vec4 u_Color;
uniform vec4 u_FlameColor;
uniform float u_Time;

in vec3 fs_Pos;
out vec4 out_Col;

// Musgrave FBM noise from @deanthecoder
// https://www.shadertoy.com/view/mdy3R1
float sum2(vec2 v) { return dot(v, vec2(1)); }

float n31(vec3 p) {
        const vec3 s = vec3(7, 157, 113);
        vec3 ip = floor(p);
        p = fract(p);
        p = p * p * (3. - 2. * p);
        vec4 h = vec4(0, s.yz, sum2(s.yz)) + dot(ip, s);
        h = mix(fract(sin(h) * 43758.545), fract(sin(h + s.x) * 43758.545), p.x);
        h.xy = mix(h.xz, h.yw, p.y);
        return mix(h.x, h.y, p.z);
}

float fbm(vec3 p, int octaves, float roughness) {
        float sum = 0.,
              amp = 1.,
              tot = 0.;
        roughness = clamp(roughness, 0., 1.);
        for (int i = 0; i < octaves; i++) {
                sum += amp * n31(p);
                tot += amp;
                amp *= roughness;
                p *= 2.;
        }
        return sum / tot;
}

float musgraveFbm(vec3 p, int octaves, float dimension, float lacunarity) {
        float sum = 0.,
              amp = 1.,
              m = pow(lacunarity, -dimension);
        for (int i = 0; i < octaves; i++) {
                float n = n31(p) * 2. - 1.;
                sum += n * amp;
                amp *= m;
                p *= lacunarity;
        }
        return sum;
}
// End of borrowed code

// Wavy FBM
vec3 waveFbm(vec3 p) {
    vec3 n = p * vec3(20, 30, 10);
    n += .4 * fbm(p * 3., 3, 3.);
    return sin(n) * .5 + .5;
}

// Superformula from @mickdermack
// https://www.shadertoy.com/view/MdXXDB
float sf2d( float m, float a, float b, float n1, float n2, float n3, float phi ) {
    return pow((pow(abs(cos(m*phi/4.0)/a),n2) + pow(abs(sin(m*phi/4.0)/b), n3)), -(1.0/n1));
}

// Hash a 2D coordinate from @Dave_Hoskins
// https://www.shadertoy.com/view/XdGfRR
float hash(vec2 p)
{
	uvec2 q = uvec2(ivec2(p)) * uvec2(1597334673U, 3812015801U);
	uint n = (q.x ^ q.y) * 1597334673U;
	return float(n) * 2.328306437080797e-10;
}

// Triangle wave
float triangle(float t, float period)
{
    float p2 = period / 2.0;
    return abs(mod(t, period) - p2) / p2;
}

// Easing functions from @glslify
// https://github.com/glslify/glsl-easings
float backInOut(float t) {
  float f = t < 0.5
    ? 2.0 * t
    : 1.0 - (2.0 * t - 1.0);

  float g = pow(f, 3.0) - f * sin(f * PI);

  return t < 0.5
    ? 0.5 * g
    : 0.5 * (1.0 - g) + 0.5;
}

float exponentialInOut(float t) {
  return t == 0.0 || t == 1.0
    ? t
    : t < 0.5
      ? +0.5 * pow(2.0, (20.0 * t) - 10.0)
      : -0.5 * pow(2.0, 10.0 - (t * 20.0)) + 1.0;
}

void main() {
    vec2 uv = gl_FragCoord.xy;
    float time = u_Time / 40.;

    // Scale, tile, and animate grid
    float nShapes = 20.0;
    float animSpeed = 120.0;
    uv.x /= u_Dimensions.y;
    uv.y = (uv.y - animSpeed * time) / u_Dimensions.y;
    float h = hash(floor(nShapes * uv));
    float h2 = hash(floor(nShapes * uv) + 3.);
    uv = 2.0 * fract(nShapes * uv) - vec2(1.0);
    
    // FBM background
    float fbm = musgraveFbm(waveFbm(fs_Pos * vec3(.05, .15, .15)) * vec3(100, 6, 20), 8, 0., 3.);
    vec3 col = vec3(fbm);

    // Supershape stars
    if (h2 > 0.9) {
        // Rotate shape
        float phi = atan(uv.y, uv.x);
        phi += sign(h - 0.5) * (h + 0.5) * time;

        // Generate supershape
        float t1 = triangle(time + h, h + 0.5);
        float t2 = exponentialInOut(triangle(time + h, 2. * (h + 0.5)));
        float m = 3.0 + floor(7.0 * h),
                n1 = mix(4.0, 6.0 + 10.0*h, t1),
                n2 = mix(2.0 + 4.0*h, 10.0 + 6.0*h, t2);
        float r = sf2d(m, 0.75, 0.75, n1, n2, n2, phi);

        // Output color
        float l = length(uv);
        if (l < r) {
            if (l < r - 0.05) {
                col = mix(vec3(0.0), vec3(1.0), 0.5 * cos(TWO_PI * (l + sin(time + h))) + 0.5);
            } else {
                col = mix(u_FlameColor.rgb, u_Color.rgb, h);
            }
        }
    }
    
    out_Col = vec4(col, 1.0);
}
