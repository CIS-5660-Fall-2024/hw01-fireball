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

uniform vec4 c0;
uniform vec4 c1;
uniform vec4 c2;
uniform vec4 c3;
uniform vec4 c4;

uniform float u_Time;
uniform vec2 screenSize;
uniform vec2 u_Mouse;
uniform mat4 u_View;
uniform vec2 u_Drag;

uniform float u_Freq;
uniform float u_Amp;
uniform float u_Wave;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;

in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

const int _VolumeSteps = 40;
const float _StepSize = 0.08; 
const float _Density = 0.1;

const float _SphereRadius = 0.2;
const float _PulseAmp = 0.05;
const float _PulseFreq = 3.0;
const float _WaveStr = 0.5;
const vec3 _NoiseAnim = vec3(-0.50, -1.0, 0.0);

const mat3 m = mat3( 1.00,  0.80,  0.0,
              0.0,  1.0, 0.0,
              0.0, 0.0,  1.0 );

float hash( float n )
{
    return fract(sin(n)*43758.5453);
}


float sqlen(in vec3 p)
{
    return (p.x*p.x+p.y*p.y+p.z*p.z);
}

float Heart(in vec3 p)
{
    p = vec3(p.z,p.y,p.x);
    float h=p.x*p.x+p.y*p.y+2.0*p.z*p.z-1.0,pyyy=p.y*p.y*p.y;
    float v=h*h*h-(p.x*p.x)*pyyy;
    
    vec3 g=vec3(6.0*p.x*h*h-2.0*p.x*pyyy,
                    6.0*p.y*h*h-3.0*p.x*p.x*p.y*p.y-0.3*p.z*p.z*p.y*p.y,
                    12.0*p.z*h*h-0.2*p.z*pyyy);

    float pulse = (sin(u_Time*0.1f*_PulseFreq)-1.0)*4.0;
	pulse = pow(8.0,pulse);
    
    return 5.0*(v/length(g)+pulse*_PulseAmp);
}

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0 + 113.0*p.z;

    float res = mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                        mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
                    mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                        mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
    return res;
}

float fbm( vec3 p )
{
    float f;
    f = 0.5000*noise( p ); p = m*p*2.02;
    f += 0.2500*noise( p ); p = m*p*2.03;
    f += 0.1250*noise( p ); p = m*p*2.01;
    f += 0.0625*noise( p );	
    return f;
}

float distanceFunc(vec3 p, vec3 mousePos)
{	
	float d = sqlen(p) - _SphereRadius;
    d = min(d, sin(d*u_Wave-u_Time*0.1f*_PulseFreq)+_WaveStr); 
	d += fbm(p*u_Freq + _NoiseAnim*u_Time*0.1f) * u_Amp;
    d = min(d,Heart(p));

    float mouseEffect = exp(-length(p - mousePos) * 2.0);
    d -= mouseEffect * 2.0;
	return d;
}

vec4 gradient(float x)
{	
	x = clamp(x, 0.0, 0.999);
	float t = fract(x*4.0);
	vec4 c;
	if (x < 0.25) {
		c =  mix(c0, c1, t);
	} else if (x < 0.5) {
		c = mix(c1, c2, t);
	} else if (x < 0.75) {
		c = mix(c2, c3, t);
	} else {
		c = mix(c3, c4, t);		
	}
	return c;
}

vec4 shade(float d)
{	
	return gradient(d);
}

vec4 volumeFunc(vec3 p, vec3 mousePos)
{
	float d = distanceFunc(p, mousePos);
	return shade(d);
}

vec4 rayMarch(vec3 rayOrigin, vec3 rayStep, out vec3 pos, vec3 mousePos)
{
	vec4 sum = vec4(0, 0, 0, 0);
	pos = rayOrigin;
	for(int i=0; i<_VolumeSteps; i++) {
		vec4 col = volumeFunc(pos, mousePos);
		col.a *= _Density;
		col.rgb *= col.a;
		sum = sum + col*(1.0 - sum.a);	

        if (sum.a > 1.0) {
            break;
        }
		pos += rayStep;
	}
	return sum;
}


void main()
{
    out_Col = fs_Col;
    float screen_x=screenSize.x;
    float screen_y=screenSize.y;

    vec2 p = (gl_FragCoord.xy / vec2(screen_x,screen_y))*2.0-1.0;

    p.x *= screen_x/ screen_y;
    
    float roty = -( u_Drag.x / screen_x)*4.0;
    float rotx = ( u_Drag.y / screen_y)*4.0;
    

    float zoom = 4.0;

    vec3 ro = zoom*normalize(vec3(cos(roty), cos(rotx), sin(roty)));
    vec3 ww = normalize(vec3(0.0,0.0,0.0) - ro);
    vec3 uu = normalize(cross( vec3(0.0,1.0,0.0), ww ));
    vec3 vv = normalize(cross(ww,uu));
    vec3 rd = normalize( p.x*uu + p.y*vv + 1.5*ww );

    vec2 mouseNDC = (u_Mouse / screenSize) * 2.0 - 1.0;
    mouseNDC.y = -mouseNDC.y;
    vec3 mouseRayDir = normalize(mouseNDC.x * uu + mouseNDC.y * vv + 1.5 * ww);
    float mouseDistance = 2.0;
    vec3 mousePos = ro + mouseRayDir * mouseDistance;

    vec3 hitPos;
    ro += rd*2.0;
    vec4 col = rayMarch(ro, rd*_StepSize, hitPos, mousePos);
    out_Col = col;
}
