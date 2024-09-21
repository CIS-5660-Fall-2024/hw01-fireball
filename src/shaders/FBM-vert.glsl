#version 300 es
//This is a vertex shader.

uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;
uniform mat4 u_ViewProj;
uniform float u_Time;
uniform float u_Scale;

in vec4 vs_Pos;             // The array of vertex positions passed to the shader
in vec4 vs_Nor;             // The array of vertex normals passed to the shader
in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;
out vec4 fs_Pos;
out vec4 fs_LightVec;
out vec4 fs_Col;

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.

vec3 hash(vec3 p3)
{
	p3 = fract(p3 * vec3(.1031,.11369,.13787));
    p3 += dot(p3, p3.yxz+19.19);
    return -1.0 + 2.0 * fract(vec3(p3.x+p3.y, p3.x+p3.z, p3.y+p3.z)*p3.zyx);
}

float noise(vec3 p)
{
    const float K1 = 0.333333333;
    const float K2 = 0.166666667;
    
    vec3 i = floor(p + (p.x + p.y + p.z) * K1);
    vec3 d0 = p - (i - (i.x + i.y + i.z) * K2);
    
    vec3 e = step(vec3(0.0), d0 - d0.yzx);
	vec3 i1 = e * (1.0 - e.zxy);
	vec3 i2 = 1.0 - e.zxy * (1.0 - e);
    
    vec3 d1 = d0 - (i1 - K2);
    vec3 d2 = d0 - (i2 - K1);
    vec3 d3 = d0 - 0.5;
    
    vec4 h = max(0.6 - vec4(dot(d0, d0), dot(d1, d1), dot(d2, d2), dot(d3, d3)), 0.0);
    vec4 n = h * h * h * h * vec4(dot(d0, hash(i)), dot(d1, hash(i + i1)), dot(d2, hash(i + i2)), dot(d3, hash(i + 1.0)));
    
    return dot(vec4(31.316), n);
}

void main() {
    float a = u_Scale;
    float n = a * noise(a * vs_Pos.xyz);
    vec3 pos = vs_Pos.xyz * vec3(
        mix(1.2, 1.5, smoothstep(-1.0, 1.0, sin(0.8 * u_Time + n))),
        mix(1.2, 1.5, smoothstep(-1.0, 1.0, sin(1.2 * u_Time + n))),
        mix(1.2, 1.5, smoothstep(-1.0, 1.0, sin(-0.2 * u_Time + n)))
    );
    fs_Pos = vec4(pos,1);
    fs_Col = vs_Col;
    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);
    vec4 modelposition = u_Model * fs_Pos;
    gl_Position = u_ViewProj * modelposition;

}