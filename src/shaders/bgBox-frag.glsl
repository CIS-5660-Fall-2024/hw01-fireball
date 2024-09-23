#version 300 es
precision highp float;

uniform vec4 u_Color; 

in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;
in float fs_Time;

out vec4 out_Col; 


vec3 random3(vec3 p) {
    return fract(vec3(dot(p, vec3(113.48875, 2311.7, 592.123)),
                       dot(p, vec3(931.215, 2531.737, 14212.22)),
                       dot(p, vec3(6421.253, 46123.73, 83.11))));

}

float noise( in vec3 x ) {
    // grid
    vec3 p = floor(x);
    vec3 w = fract(x);
    
    // quintic interpolant
    vec3 u = w*w*w*(w*(w*6.0-15.0)+10.0);
    
    // gradients
    vec3 ga = random3( p+vec3(0.0,0.0,0.0) );
    vec3 gb = random3( p+vec3(1.0,0.0,0.0) );
    vec3 gc = random3( p+vec3(0.0,1.0,0.0) );
    vec3 gd = random3( p+vec3(1.0,1.0,0.0) );
    vec3 ge = random3( p+vec3(0.0,0.0,1.0) );
    vec3 gf = random3( p+vec3(1.0,0.0,1.0) );
    vec3 gg = random3( p+vec3(0.0,1.0,1.0) );
    vec3 gh = random3( p+vec3(1.0,1.0,1.0) );
    
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

float WorleyNoise3D(vec3 pos) {
    pos *= 0.6; // Now the space is 10x10 instead of 1x1. Change this to any number you want.
    vec3 posInt = floor(pos);
    vec3 posFract = fract(pos);
    float minDist = 1.0; // Minimum distance initialized to max.
    for(int y = -1; y <= 1; ++y) {
        for(int x = -1; x <= 1; ++x) {
            for (int z = -1; z <= 1; ++z) {
                vec3 neighbor = vec3(float(x), float(y), float(z));
                vec3 point = random3(posInt + neighbor);
                vec3 diff = neighbor + point - posFract;
                float dist = length(diff);
                minDist = min(minDist, dist);
            }
        }
    }
    return minDist;
}

float fbm(vec3 p, int oct) {
    float total = 0.0;
    int octaves = oct;
    float freqScale = 2.0;
    float ampScale = 0.5;
    float amplitude = 0.5;
    float frequency = 1.0;
   
    for (int i = 0; i < octaves; i++) {
        total += amplitude * noise(p * frequency);
        frequency *= freqScale;
        amplitude *= ampScale;
    }
    return total;
}

vec3 colorGrad(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.00, 0.33, 0.67);
    return a + b * cos(2.0 * 3.141592 * ((c * t) + d));
}

void main() {

        vec4 diffuseColor = vec4(1.0, 1.0, 1.0, 1.0);//u_Color;
        float star1 = step(WorleyNoise3D(cross(fs_Pos.xyz, fs_Nor.xyz) * 8.0), fbm(fs_Pos.xyz, 4) + (cos(fs_Time * 0.001)*0.01));
        float star2 = step(WorleyNoise3D(cross(fs_Pos.xyz, fs_Nor.xyz) * 10.0), fbm(fs_Pos.xyz, 8) + (sin(fs_Time * 0.001)*0.01));
        float starNoise = star1 + star2;
        vec3 galaxy = mix(colorGrad(noise(fs_Pos.xyz * 0.8)), vec3(1.0), abs(noise(fs_Pos.xyz * 0.1)) * 10.0);
        out_Col = vec4(diffuseColor.rgb * galaxy * starNoise, diffuseColor.a);
}
