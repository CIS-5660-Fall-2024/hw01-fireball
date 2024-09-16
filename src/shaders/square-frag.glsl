#version 300 es
precision highp float;

uniform vec2 u_Dimensions;
uniform float u_Time;

in vec2 fs_Pos;
out vec4 out_Col;

void main() {
    vec2 pos = fs_Pos;
    float dist = length(pos);
    float angle = atan(pos.y, pos.x);
    
    float innerRadius = 1.2;
    float outerRadius = 2.2;
    
    if (dist > innerRadius && dist < outerRadius) {
        float rotationSpeed = 0.75; 
        float rotatedAngle = angle + u_Time * rotationSpeed;
        
        float rings = sin(dist * 25.0 + rotatedAngle * 5.0) * 0.5 + 0.5;
        float pattern = rings;
        
        float gaps = step(0.98, fract(dist * 30.0 + rotatedAngle * 2.0));
        pattern *= 0.5 + gaps * 0.5;
        
        vec3 color1 = vec3(0.78, 0.22, 0.11);
        vec3 color2 = vec3(0.79f, 0.28f, 0.28f);
        vec3 ringColor = mix(color1, color2, pattern);
        
        float alpha = smoothstep(innerRadius, innerRadius + 0.02, dist) 
                    * smoothstep(outerRadius, outerRadius - 0.02, dist);
        alpha *= 0.1 + pattern * 0.3; 
        
        out_Col = vec4(ringColor, alpha);
    } else {
        out_Col = vec4(0.0);
    }
}