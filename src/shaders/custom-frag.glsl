#version 300 es
precision highp float;

uniform vec4 u_Color; 
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;
in float fs_Time;

out vec4 out_Col; 

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p, vec2(213.8325, 5123.7973)),
                 dot(p, vec2(5912.545,7501.3))))
                 * 401.5903);
}

vec3 random3(vec3 p) {
    return fract(vec3(dot(p, vec3(113.48875, 2311.7, 592.123)),
                       dot(p, vec3(931.215, 2531.737, 14212.22)),
                       dot(p, vec3(6421.253, 46123.73, 83.11))));

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

vec4 lerp(vec4 min, vec4 max, float t) {
    return min + t * (max - min);
}

//idk if this is right
float fit(float var, float imin, float imax, float omin, float omax) {
    return (var / (imax - imin)) * (omax - omin);
}

void main()
{   
    // WorleyNoise3D(gl_FragCoord.xyz * 0.6 + fs_Time * 0.2)
    float baseNoise = fit(mod(WorleyNoise3D(vec3(fs_Pos.xyz) + fs_Time * 0.0001) + fs_Time * 0.001, 0.11), 0.0, 0.1, 0.0, 1.0);
    float MinNoise = 1.0 - baseNoise;
    float noise = max(baseNoise, MinNoise);
    float noise2 = min(baseNoise, MinNoise);
    float dist = sqrt(fs_Pos.x * fs_Pos.x + fs_Pos.y * fs_Pos.y + fs_Pos.z * fs_Pos.z);
    vec4 color = lerp(vec4(1.0, 0, 0, 1), u_Color, fit(dist, 0.8, 2.0, 0.0, 1.0));
    vec4 diffuseColor = vec4(noise, noise, noise, 1.0) * color;

    diffuseColor += vec4(noise2, noise2,noise2, 1.0) * (color * 0.5);

    out_Col = vec4(diffuseColor.rgb, noise * 0.6);

}
