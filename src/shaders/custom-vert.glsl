#version 300 es
uniform mat4 u_Model;       
uniform mat4 u_ModelInvTr;  
uniform mat4 u_ViewProj;    
uniform float u_Time;

in vec4 vs_Pos;             
in vec4 vs_Nor;             
in vec4 vs_Col;             

out vec4 fs_Nor;            
out vec4 fs_LightVec;       
out vec4 fs_Col;  
out float fs_Time;  
out vec4 fs_Pos;      

const vec4 lightPos = vec4(5, 5, 3, 1); 

void main()
{
    fs_Col = vs_Col;    
    fs_Time = u_Time;  
    

    float a = sin(u_Time * 0.005) * 3.141592 * 0.3;
    if (vs_Pos.y > 0.0) {
        a = a * -1.0;
    }
    mat4 rot = mat4(vec4(cos(a), 0, -sin(a), 0), vec4(0, 1, 0, 0), vec4(sin(a), 0, cos(a), 0), vec4(0,0,0,1));

    float tx = 1.0;
    
    vec4 pos = vs_Pos;
    vec4 morePos = vs_Pos;
    
    // THIS IS JANK SORRY
    // didnt want to go about adding more buffer attributes to 
    // distinguish inside vs outside, so I made them different
    // initial sizes and grouped them based on that. This size
    // difference is then adjusted so the points move around 
    // the same elipse, but start at different positions in the
    // cycle.

    float phaseOffset = 0.0;
    if (length(morePos) < 2.0) { 
        morePos *= 1.0;
        phaseOffset = 3.141592;
    } else {
        morePos *= 0.5; 
        phaseOffset = 0.0;
    } 

    // Sets up elipse paths for the points to move along 
    pos.z = cos(u_Time * 0.01 + (morePos.z * 3.141592 * 0.5) + phaseOffset) * 0.8;
    pos.y = morePos.y * (sin(u_Time * 0.01 + (morePos.z * 3.141592 * 0.5) + phaseOffset) * 0.3) + (morePos.y * 1.0);
    pos.x = morePos.x * (sin(u_Time * 0.01 + (morePos.z * 3.141592 * 0.5) + phaseOffset) * 0.3) + (morePos.x * 1.0);

    float s = 1.0;
    mat4 magic = mat4(vec4(s, 0, 0, 0), vec4(0, s, 0, 0), vec4(0, 0, s, 0), vec4(pos.x, pos.y, pos.z, 1));
    mat4 invMagic = mat4(vec4(s, 0, 0, 0), vec4(0, s, 0, 0), vec4(0, 0, s, 0), vec4(-pos.x, -pos.y, -pos.z, 1));

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);
    
    vec4 modelposition = u_Model * (magic * vec4(vec3(0), 1.0));
    fs_LightVec = lightPos - modelposition;
    fs_Pos = modelposition;
    gl_Position = u_ViewProj * modelposition;
}
