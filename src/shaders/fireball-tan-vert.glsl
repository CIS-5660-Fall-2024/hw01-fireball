#version 300 es
precision highp float;

uniform mat4 u_ViewProj;
uniform mat4 u_Model;

uniform float u_Time;

in vec3 vs_Pos;
in vec3 vs_Nor;
in vec3 vs_Tan;

out vec3 fs_Pos;
out vec3 fs_eye_pos;

float sumOfSines(vec3 pos) {
    return sin(pos.x * 2.1 + u_Time * 0.5) * 1.224
            + sin(pos.y * 4.13 + u_Time * 2.13) * 2.2
            + sin(pos.z * 3.87 + u_Time * 1.24) * 3.01;
}

// Simplex Noise as input to FBM
// Both noise functions taken from https://www.shadertoy.com/view/ss2cDK
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}
float noise(vec3 v){ 
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

  //  x0 = x0 - 0. + 0.0 * C 
  vec3 x1 = x0 - i1 + 1.0 * C.xxx;
  vec3 x2 = x0 - i2 + 2.0 * C.xxx;
  vec3 x3 = x0 - 1. + 3.0 * C.xxx;

// Permutations
  i = mod(i, 289.0 ); 
  vec4 p = permute( permute( permute( 
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients
// ( N*N points uniformly over a square, mapped onto an octahedron.)
  float n_ = 1.0/7.0; // N=7
  vec3  ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z *ns.z);  //  mod(p,N*N)

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

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

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
float fbm(vec3 x, int octaves, float amplitude, float frequency, vec3 shift, float lacunarity, float gain) {
	float value = 0.0;
    for (int i = 0; i < octaves; ++i) {
        float sn = noise(x * frequency);
        value += amplitude * sn;
        x += shift;
        frequency *= lacunarity;
		amplitude *= gain;
	}
	return value;
}

// from https://www.shadertoy.com/view/Xt23Ry
float rand(float co) { return fract(sin(co*(91.3458)) * 47453.5453); }

vec3 transformPoint(vec3 pos) {
    // sum of sines to offset along normal to make sphere not uniform
    float offset = (sumOfSines(pos) + 1.0) * 0.5;
    pos *= offset * 0.01 + 1.5;

    float taper = 1.1 - pos.y * 0.5;
    pos.xz *= taper;
    pos.y *= 2.0;

    float sway = 0.5 * sin(u_Time * 2.0 + -pos.y * 0.5);
    float yFactor = (1.0 + pos.y) * 0.5;
    pos.x += sway * yFactor;

    vec3 move = vec3((u_Time * 2.0), (u_Time * 2.82 + 1.0), (u_Time * 2.64 + 2.0));

    float fbmv = fbm(pos + move, 8, 0.5, 1.0, vec3(8), 2.0, 0.5);
    fbmv = fbm(fbmv * 0.1 + pos + move, 8, 0.5, 1.0, vec3(8), 2.0, 0.5);

    vec3 direction = normalize(vec3(0.0, 10.0, 0.0) - pos);

    pos += direction * abs(fbmv);

    return pos;
}

uniform vec3 u_Eye, u_Ref, u_Up;
out vec3 eye_relative_pos;

void main() {
    vec3 transformedPos = (u_Model * vec4(vs_Pos, 1.0)).xyz;
    mat3 matN = transpose(inverse(mat3(u_Model)));

    vec3 new_normal = matN * vs_Nor;

    vec3 fPos = transformPoint(transformedPos);

    fs_eye_pos = u_Eye;
    eye_relative_pos = fPos - u_Eye;

    gl_Position = u_ViewProj * vec4(fPos, 1.0);
}
