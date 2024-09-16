#version 300 es
precision highp float;

in vec3 fs_Pos;
out vec4 out_Col;

uniform float u_Time;

float hash(vec3 p) {
    p = fract(p * vec3(443.8975, 397.2973, 491.1871));
    p += dot(p.zxy, p.yxz + 19.19);
    return fract(p.x * p.y * p.z);
}

float star(vec3 p, float size, float threshold) {
    vec3 gridPos = floor(p * size);
    float n = hash(gridPos);
    if (n < threshold) return 0.0;
    
    vec2 starPos;
    float planeSelector = fract(n * 7919.0); 
    if (planeSelector < 0.33) {
        starPos = fract(p.xy * size) - 0.5;
    } else if (planeSelector < 0.66) {
        starPos = fract(p.xz * size) - 0.5;
    } else {
        starPos = fract(p.yz * size) - 0.5;
    }
    float starDist = length(starPos);
    float starShape = 1.0 - smoothstep(0.0, 0.05, starDist);
    float twinkle = sin(u_Time * 3.0) * 0.5 + 0.5;
    
    return starShape * twinkle;
}

float meteor(vec2 screenPos, vec2 pos, vec2 dir, float speed, float size) {
    vec2 p = screenPos - pos;
    float d = dot(p, dir);
    float l = length(p - d * dir);
    float meteor = smoothstep(size, 0.0, l) * smoothstep(1.0, 0.0, d);
    return meteor * smoothstep(1.0, 0.0, fract(d - u_Time * speed));
}

void main() {
    vec3 dir = normalize(fs_Pos);
    
    vec3 color1 = vec3(0.07, 0.22, 0.53);
    vec3 color2 = vec3(0.0, 0.00, 0.05);

    vec3 sky = mix(color1, color2, dir.y * 0.5 + 0.5);
    
    float stars = 0.0;
    vec3 dir1 = vec3(dir.x,dir.z,dir.y);
    vec3 dir2 = vec3(dir.y,dir.x,dir.z);
    vec3 dir3 = vec3(dir.z,dir.y,dir.x);
    stars += star(dir1, 70.0, 0.8) * 0.9;
    stars += star(dir2, 40.0, 0.75) * 1.1;
    stars += star(dir3, 90.0, 0.9) * 1.3;
    sky += vec3(stars);
    
    vec2 uv = vec2(atan(dir.z, dir.x), asin(dir.y));
    vec2 meteorPos1 = vec2(0.0, 1.0);
    vec2 meteorDir1 = normalize(vec2(1.0, -0.5));
    vec2 meteorPos2 = vec2(2.0, -1.0);
    vec2 meteorDir2 = normalize(vec2(1.0, 0.5));
    float meteorEffect1 = meteor(uv, meteorPos1, meteorDir1, -0.3, 0.01);
    float meteorEffect2 = meteor(uv, meteorPos2, meteorDir2, -0.3, 0.01);
    sky += vec3(1.0, 0.8, 0.6) * meteorEffect1;
    sky += vec3(1.0, 0.8, 0.6) * meteorEffect2;
    
    out_Col = vec4(sky, 1.0);
}