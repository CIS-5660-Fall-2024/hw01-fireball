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

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec3 fs_Pos;
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

// from https://www.shadertoy.com/view/4djSRW
vec3 hashOld33( vec3 p )
{
	p = vec3( dot(p,vec3(127.1,311.7, 74.7)),
			  dot(p,vec3(269.5,183.3,246.1)),
			  dot(p,vec3(113.5,271.9,124.6)));

	return fract(sin(p)*43758.5453123);
}

float surflet(vec3 p, vec3 gridPoint)
{
    vec3 t2 = abs(p - gridPoint);
    vec3 pow3 = t2 * t2 * t2;
    vec3 pow4 = pow3 * t2;
    vec3 pow5 = pow4 * t2;
    vec3 t = vec3(1.0) - 6.0 * pow5 + 15.0 * pow4 - 10.0 * pow3;
    vec3 gradient = hashOld33(gridPoint) * 2. - vec3(1.0, 1.0, 1.0);
    vec3 diff = p - gridPoint;
    float height = dot(diff, gradient);
    return height * t.x * t.y * t.z;
    return 0.0;
}

float perlinNoise3D(vec3 p) 
{
	float surfletSum = 0.0;
	for(int dx = 0; dx <= 1; ++dx) {
		for(int dy = 0; dy <= 1; ++dy) {
			for(int dz = 0; dz <= 1; ++dz) {
				surfletSum += surflet(p, floor(p) + vec3(dx, dy, dz));
			}
		}
	}
	return surfletSum;
}

uniform float u_Time;

float bias(float time, float b)
{
  return (time / ((((1.0/b) - 2.0)*(1.0 - time))+1.0));
}

void main()
{
    vec3 v = normalize(fs_Pos);
    float p = perlinNoise3D(v * 10.0 + vec3(127.1, 311.7, 715.2) * u_Time * 0.001);
    float s = sin(10.0 * p);
    // visualize contours using estimation of deriative
    // is closer to one when the value matches the gradient (top and bottom of wave)
    // multiply by 0.5 to make lines thicker (s will be closer to 1)
    s = 1.0 - smoothstep(0.0, 1.0, 0.5 * abs(s) / fwidth(s));
    // gradient
    vec3 col = 0.5 + 0.5 * cos(u_Time * p + vec3(0.0, 2.0, 4.0));
    float f = bias(fract(u_Time * 1.1), 0.8) * 0.5 + 0.5;
    vec3 c = col * s * f;

    // smooth transition to white
    c = smoothstep(vec3(1.0), c, vec3(length(c)));
    out_Col = vec4(c, 1.0);
}

