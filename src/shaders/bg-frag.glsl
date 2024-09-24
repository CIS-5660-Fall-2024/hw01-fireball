#version 300 es
precision highp float;

uniform vec2 u_Dimensions;
uniform float u_Time;

in vec3 fs_Pos;
out vec4 out_Col;

float bias(float t, float b) {
    return (t / ((((1.0 / b) - 2.0) * (1.0 - t)) + 1.0));
}


//gradient color to immitate the sun
vec3 gradient(vec2 uv, float dist) {
    float angle = atan(uv.y, uv.x);
    float influenceRadius = 0.26f + (sin(20.f * (angle - u_Time * 0.001f)) + 1.f) * 0.002f;
    influenceRadius += (cos(30.f * (angle + u_Time * 0.001f)) + 1.f) * 0.001f;
    float outerInfluenceRadius = mix(0.25f, 0.5f, bias((sin(u_Time * 0.006f) + 1.f) * 0.5f, 0.8f)) + (sin(10.f * (angle - u_Time * 0.001f)) + 1.f) * 0.02f;
    outerInfluenceRadius += (cos(30.f * (angle + u_Time * 0.001f)) + 1.f) * 0.004f;
    if (dist < influenceRadius) {
        return mix(vec3(1.0, 1.f, 0.0), vec3(1.0, 0.0, 0.0), (influenceRadius - dist) / 0.2f);
    }
    else if (dist < outerInfluenceRadius) {
        return mix(vec3(1.0, 0.2f, 0.1f), vec3(1.f, 1.f, 0.f), (outerInfluenceRadius - dist) / (outerInfluenceRadius - influenceRadius));
    }
    else {
        float scale = mix(0.5f, 0.65f, bias((sin(u_Time * 0.006f) + 1.f) * 0.5f, 0.8f));
        float t = (dist - outerInfluenceRadius)/scale;
        t = bias(t, 0.4f);
        return mix(vec3(0.f), vec3(1.f, 0.2f, 0.1f), 1.f - t);
    }
}


void main() {
    vec2 uv = (gl_FragCoord.xy - vec2(0.5f) * u_Dimensions) / u_Dimensions.y;

    float dist = length(uv);

    vec3 color = gradient(uv, dist);

    out_Col = vec4(color, 1.0);
}
