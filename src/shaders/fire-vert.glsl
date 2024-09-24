#version 300 es

uniform mat4 u_Model;                       
uniform mat4 u_ModelInvTr; 
uniform mat4 u_ViewProj;   
uniform float u_Time;
uniform float u_Bias;

in vec4 vs_Pos;            
in vec4 vs_Nor;             
in vec4 vs_Col;            
out vec4 fs_Nor;            
out vec4 fs_LightVec;      
out vec4 fs_Col;          
out vec4 fs_Pos;        
out float fs_Displacement;

const vec4 lightPos = vec4(5, 5, 3, 1); 

vec3 random3(vec3 p)
{
    return fract(sin(vec3((dot(p, vec3(127.1f, 311.7f, 191.999f))))) * 43758.5453f);
}

float surflet3D(vec3 p, vec3 gridPoint) {
    // Compute the distance between p and the grid point along each axis, and warp it with a
    // quintic function so we can smooth our cells
    vec3 t2 = abs(p - gridPoint);
    vec3 v1 = 6.f * vec3(pow(t2[0], 5.f),
                                    pow(t2[1], 5.f),
                                    pow(t2[2], 5.f));
    vec3 v2 = 15.f * vec3(pow(t2[0], 4.f),
                                    pow(t2[1], 4.f),
                                    pow(t2[2], 4.f));
    vec3 v3 = 10.f * vec3(pow(t2[0], 3.f),
                                    pow(t2[1], 3.f),
                                    pow(t2[2], 3.f));
    vec3 t = vec3(1.f) - v1 + v2 - v3;
    // Get the random vector for the grid point (assume we wrote a function random2
    // that returns a vec2 in the range [0, 1])
    vec3 gradient = random3(gridPoint) * 2.f - vec3(1.f);
    // Get the vector from the grid point to P
    vec3 diff = p - gridPoint;
    // Get the value of our height field by dotting grid->P with our gradient
    float height = dot(diff, gradient);
    // Scale our height field (i.e. reduce it) by our polynomial falloff function
    return height * t.x * t.y * t.z;
}

float perlinNoise3D(vec3 p) {
    float surfletSum = 0.f;
    // Iterate over the eight integer corners surrounding a 3D grid cell
    for(int dx = 0; dx <= 1; ++dx) {
        for(int dy = 0; dy <= 1; ++dy) {
            for(int dz = 0; dz <= 1; ++dz) {
                surfletSum += surflet3D(p, floor(p) + vec3(dx, dy, dz));
            }
        }
    }
    return surfletSum;
}

// Rougher noise to modifiy the sphere shape
float fbm3D(vec3 p) {
    float total = 0.0;
    float amplitude = 1.0; 
    float frequency = 1.0;
    int octaves = 10;

    for (int i = 0; i < octaves; i++) {
        total += amplitude * perlinNoise3D(p * frequency); 
        frequency *= 2.0; 
        amplitude *= 0.6;
    }
    return total;
}

// Finer noise to modify the surface
float fbm3DFine(vec3 p) {
    float total = 0.0;
    float amplitude = 1.0; 
    float frequency = 1.0;
    int octaves = 15;

    for (int i = 0; i < octaves; i++) {
        total += amplitude * perlinNoise3D(p * frequency); 
        // higher frequency each time
        frequency *= 3.0; 
        // lower the amplitude each time
        amplitude *= 0.3;
    }
    return total;
}

// Finest noise to modify the surface
float fbm3DFiner(vec3 p) {
    float total = 0.0;
    float amplitude = 1.0; 
    float frequency = 1.0;
    int octaves = 15;

    for (int i = 0; i < octaves; i++) {
        total += amplitude * perlinNoise3D(p * frequency); 
        // higher frequency each time
        frequency *= 4.0; 
        // lower the amplitude each time
        amplitude *= 0.4;
    }
    return total;
}

mat3 rotationMatrixY(float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return mat3(
        c, 0.0, -s,
        0.0, 1.0, 0.0,
        s, 0.0, c
    );
}

float rand(vec3 co) {
    return fract(sin(dot(co.xyz ,vec3(12.9898,78.233, 45.164))) * 43758.5453);
}

float GetBias(float time, float bias)
{
  return (time / ((((1.0/bias) - 2.0)*(1.0 - time))+1.0));
}

void main()
{
    vec4 originalPosition = vs_Pos;
    vec4 distortedPosition = vs_Pos; 

    float noiselayer = fbm3D(vs_Pos.xyz);
    float noiselayer1 = fbm3DFine(vs_Pos.xyz);
    float noiselayer2 = fbm3DFiner(vs_Pos.xyz);

    // Apply rotation to the sphere
    float angle = u_Time * 0.01;
    distortedPosition.xyz = rotationMatrixY(angle) * originalPosition.xyz;
    originalPosition.xyz = rotationMatrixY(angle) * originalPosition.xyz;

    // Change sphere shape 
    distortedPosition.y += 0.8 * (sin(noiselayer * 1.4 + u_Time * 0.01));
    originalPosition.y += 0.75 * (sin(u_Time * 0.01));

    float blendFactor = smoothstep(-0.5, 0.5, vs_Pos.y);
    distortedPosition = mix(originalPosition, distortedPosition, blendFactor);

    distortedPosition.x += sin(u_Time * 0.01) * 0.5;

    // Make the sphere ununiformly deform by add details to the surface
    float displacement = mix(noiselayer2 * 0.3, noiselayer1 * 0.6 ,sin(u_Time * 0.005));  
    
    // Pass the displacement value to the fragment shader
    fs_Displacement = displacement;

    // Expand along the normal direction by bias time
    float timeBias = GetBias(sin(u_Time * 0.02), u_Bias); 
    distortedPosition.xyz += vs_Nor.xyz * displacement * 1.5 * timeBias;


    fs_Col = vs_Col;                      

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);         

    vec4 modelposition = u_Model * distortedPosition; 

    fs_Pos = modelposition;

    fs_LightVec = lightPos - modelposition; 

    gl_Position = u_ViewProj * modelposition;
}
