#version 300 es
precision highp float;

uniform vec3 u_Eye, u_Ref, u_Up;
uniform vec2 u_Dimensions;
uniform float u_Time;

in vec2 fs_Pos;
out vec4 out_Col;

float rand(vec2 n) {
    return fract(sin(cos(dot(n, vec2(12.9898,12.1414)))) * 83758.5453);
}

float noise(vec2 n) {
    const vec2 d = vec2(0.0, 1.0);
    vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
    return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
}

float fbm(vec2 n) {
    float total = 0.0, amplitude = 1.0;
    for (int i = 0; i <5; i++) {
        total += noise(n) * amplitude;
        n += n*1.7;
        amplitude *= 0.47;
    }
    return total;
}


void main() {
    vec3 redColor = vec3(0.7, 0.0, 0.0);
    vec3 blueColor = vec3(0.0, 0.0, 1.0);
    vec3 blackColor = vec3(0.1, 0.0, 0.1);

    float noise = fbm(fs_Pos.xy + u_Time * 0.001);

    float gradient = smoothstep(0.0, 1.0, fs_Pos.y * noise + 0.5);

    vec3 color = mix(redColor, blueColor, gradient);

    color = mix(color, blackColor * 1.1, gradient * 0.5);

    out_Col = vec4(color, 1.0);
    //out_Col = vec4(0.5 * (fs_Pos + vec2(1.0)), 0.5 * (sin(u_Time * 3.14159 * 0.01) + 1.0), 1.0);
}
