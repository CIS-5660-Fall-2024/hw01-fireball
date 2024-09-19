#version 300 es
precision highp float;

uniform vec2 u_Dimensions;
uniform float u_Time;

in vec3 fs_Pos;

in vec3 fs_eye_pos;

in vec3 eye_relative_pos;

out vec4 out_Col;

// FBM implementation from https://www.shadertoy.com/view/4dS3Wd
float hash(float p) { p = fract(p * 0.011); p *= p + 7.5; p *= p + p; return fract(p); }
float noise(vec3 x) {
    const vec3 step = vec3(110, 241, 171);

    vec3 i = floor(x);
    vec3 f = fract(x);
 
    // For performance, compute the base input to a 1D hash from the integer part of the argument and the 
    // incremental change to the 1D based on the 3D -> 1D wrapping
    float n = dot(i, step);

    vec3 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(mix( hash(n + dot(step, vec3(0, 0, 0))), hash(n + dot(step, vec3(1, 0, 0))), u.x),
                   mix( hash(n + dot(step, vec3(0, 1, 0))), hash(n + dot(step, vec3(1, 1, 0))), u.x), u.y),
               mix(mix( hash(n + dot(step, vec3(0, 0, 1))), hash(n + dot(step, vec3(1, 0, 1))), u.x),
                   mix( hash(n + dot(step, vec3(0, 1, 1))), hash(n + dot(step, vec3(1, 1, 1))), u.x), u.y), u.z);
}
float fbm(vec3 x, int octaves, vec3 shift, float persistence) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < octaves; ++i) {
		v += a * noise(x);
		x = x * 2.0 + shift;
		a *= persistence;
	}
	return v;
}

uniform vec3 baseColor;
uniform vec3 highlightColor;
uniform vec3 outlineColor;
uniform float lighting;

uniform float u_Black;

void main() {

    if (u_Black > 0.0) {
        out_Col = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec3 dFdxPos = dFdx( eye_relative_pos );
    vec3 dFdyPos = dFdy( eye_relative_pos );
    vec3 facenormal = normalize( cross(dFdxPos,dFdyPos ));
    // out_Col = vec4(facenormal*0.5 + 0.5,1.0);
    vec3 lightDir = normalize(fs_eye_pos - fs_Pos);
    float lambert = max(dot(facenormal, lightDir), 0.0);
    // out_Col = vec4(vec3(1.0, 0.5, 0.0) * lambert, 1.0);

    // calculate offset with fbm
    vec3 time = vec3(0.0, -u_Time * 10.0, 0.0);
    float scaleFactor = 2.0;
    float f = fbm(fs_Pos * scaleFactor + time, 8, vec3(100.0), 0.5);
    float h1 = fbm((fs_Pos + vec3(1.0, 0.0, 0.0)) * scaleFactor + time, 8, vec3(100.0), 0.5);
    float v1 = fbm((fs_Pos + vec3(0.0, 1.0, 0.0)) * scaleFactor + time, 8, vec3(100.0), 0.5);
    float z1 = fbm((fs_Pos + vec3(0.0, 0.0, 1.0)) * scaleFactor + time, 8, vec3(100.0), 0.5);
    vec3 bump = normalize(vec3(h1 - f, v1 - f, z1 - f));

    // use this vector to displace fbm sample point
    vec3 newSamplePoint = fs_Pos + bump * 1.0;
    newSamplePoint = newSamplePoint * vec3(1.0, 1.0, 1.0);
    float noise = fbm(newSamplePoint, 8, vec3(100.0), 0.5);

    float gradient = pow(3.5 - newSamplePoint.y, 1.5) * 0.5;
    float product = noise * gradient;
    
    vec3 color;

    // Interpolate between shadow, base, and highlight colors based on noise
    if (noise < 0.3) {
        color = mix(outlineColor, baseColor, noise / 0.3);
    } else if (noise < 0.7) {
        color = mix(baseColor, highlightColor, (noise - 0.3) / 0.4);
    } else {
        color = highlightColor;
    }
    // shift color to red as it reaches edge of sphere
    float edgeFactor = 1.0 - dot(facenormal, lightDir);
    color = mix(color, outlineColor * 2.0, smoothstep(0.0, 1.0, edgeFactor));

    const float levels = 3.0;
    // toon lighting on color
    float level = floor(lambert * levels) / levels + 0.5;

    if (lighting > 0.0) {
        color = color * level;
    }

    out_Col = vec4(color, 1.0);
}
