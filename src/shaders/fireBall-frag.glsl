#version 300 es
precision highp float;

uniform vec4 u_Color; 
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;
in float fs_Time;
in vec4 fs_camPos;
in float hwarp;
in float fbmNoise;
in float fs_mode;

out vec4 out_Col; 

vec4 lerp(vec4 min, vec4 max, float t) {
    return min + t * (max - min);
}

float pCurve(float x, float a, float b) {
    float k = pow(a+b, a+b) / (pow(a,a) * pow(b,b));
    return k * (x, a) * pow(1.0-x,b);
}

float fallOff(vec3 look, vec3 nor) {
    return dot(normalize(nor), vec3(lerp(vec4(normalize(nor), 1.0), vec4(normalize(look), 1.0), 1.0)));
}

vec3 random3(vec3 p) {
    return fract(vec3(dot(p, vec3(113.48875, 2311.7, 592.123)),
                       dot(p, vec3(931.215, 2531.737, 14212.22)),
                       dot(p, vec3(6421.253, 46123.73, 83.11))));

}

float bias(float t, float bias) {
  return (t / ((((1.0 / bias) - 2.0) * (1.0 - t)) + 1.0));
}

float gain(float g, float t) {
    if (t < 0.5) {
        return bias(1.0 - g, 2.0*t) / 2.0;
    } else { 
        return 1.0 - bias(1.0 - g, 1.0 - 2.0*t) / 2.0;
    }
}

float smoothsetp(float p) {
    return 6.0 * pow(p, 5.0) - 15.0 * pow(p, 4.0) + 10.0 * pow(p, 3.0);
}

vec3 smoothsetp3D(vec3 p) {
    return vec3(gain(0.85, smoothsetp(p.x)), gain(0.85, smoothsetp(p.y)), gain(0.85, smoothsetp(p.z)));
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

//idk if this is right
float fit(float var, float imin, float imax, float omin, float omax) {
    return (var / (imax - imin)) * (omax - omin);
}

vec2 swirl(vec2 p, float swirlFactor) {
    float r = length(p);
    float theta = atan(p.y, p.x) - fs_Time*0.01; 

    theta += swirlFactor * r;
    return vec2(r * cos(theta), r * sin(theta));
}

vec3 colorGrad(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.00, 0.33, 0.67);
    return a + b * cos(2.0 * 3.141592 * ((c * t) + d));
}

vec3 colorGrad2(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(2.0, 1.0, 0.0);
    vec3 d = vec3(0.50, 0.20, 0.25);
    return a + b * cos(2.0 * 3.141592 * ((c * t) + d));
}

void main()
{   
    float baseNoise = fit(mod(WorleyNoise3D(vec3(fs_Pos.xyz) + fs_Time * 0.0001) + fs_Time * 0.001, 0.11), 0.0, 0.1, 0.0, 1.0);

    float dist = length(fs_Pos) * 0.86;

    vec3 color = colorGrad(fbmNoise);//u_Color.xyz;
    vec4 secColor = vec4(smoothsetp3D(u_Color.xyz), 1.0);
    vec4 colorTest = vec4(0.0);
    colorTest = lerp(vec4(color + fit(hwarp, 1.0, 1.6, 1.0, 0.0) * (1.0 - abs(fs_Pos.y)), 1.0), secColor, (fallOff(fs_camPos.xyz, fs_Nor.xyz)));
    colorTest = vec4(colorTest.xyz + vec3(1.0) * (smoothsetp(0.60-fbmNoise)), colorTest.a);
    if (fs_mode == 0.0) {
        colorTest = lerp(colorTest, vec4(0.0, 0.0, 0.0, 1.0), step(1.0-fallOff(fs_camPos.xyz, fs_Nor.xyz) + dist, 1.7));
    } else {
        colorTest = lerp(vec4(vec3(1.0) * (1.0-hwarp), 1.0), vec4(vec3(0.0)*4.0, 1.0), step(1.0-fallOff(fs_camPos.xyz, fs_Nor.xyz) + dist , 1.8));
    }
    
    float offset;
    for (float i = 1.0; i<6.0 +2.0*fs_mode; i+= 1.0) {
        offset = pCurve(0.4, 0.1 * i, 8.0);
        if (fs_mode == 0.0) {
            colorTest = lerp(colorTest, vec4(vec3(mod(i+1.0, 2.0)), 1.0), step(1.0-fallOff(fs_camPos.xyz, fs_Nor.xyz) + dist, 1.7 - offset));
        } else {
            // colorTest = lerp(vec4(colorTest.xyz * (2.0-hwarp) * (vec3(1.0) - colorGrad(fbmNoise)), 1.0), vec4(vec3(color.xyz)*4.0, 1.0), step(1.0-fallOff(fs_camPos.xyz, fs_Nor.xyz) + dist, 1.8 - offset));
            colorTest = lerp(vec4(colorTest.xyz * (3.0-hwarp) * (colorGrad2(fbmNoise + fs_Time*0.001)), 1.0), vec4(vec3(mod(i, 2.0)), 1.0), step(1.0-fallOff(fs_camPos.xyz, fs_Nor.xyz) + dist, 1.8 - offset));
        }
    }

    out_Col = colorTest;
    
}
