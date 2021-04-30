#include "Assets/DXC Shader Graph Particles/InstancingSetup.cginc"
// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it uses non-square matrices
#pragma exclude_renderers gles

#define UNITY_PARTICLE_INSTANCE_DATA MyParticleInstanceData

struct MyParticleInstanceData
            {
                float3x4 transform;
                uint color;
                float speed;
            };

void GetInstancedData_half(float4 texcoord, out float4 color, out float2 uv) {
    color = half4(1,1,1,1);
    vertInstancingColor(color);
    vertInstancingUVs(texcoord, uv);
}

void GetInstancedData_float(float4 texcoord, out float4 color, out float2 uv) {
    color = float4(1,1,1,1);
    vertInstancingColor(color);
    vertInstancingUVs(texcoord, uv);
}

void GetPositionData_half(out float4x4 objectToWorld, out float4x4 worldToObject)
{
    #if !defined(UNITY_COMPILER_DXC) || !defined(UNITY_PARTICLE_INSTANCING_ENABLED)
    objectToWorld = float4x4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);
    worldToObject = float4x4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);
    #else
    vertInstancingMatrices(objectToWorld, worldToObject);
    #endif
}

void GetPositionData_float(out float4x4 objectToWorld, out float4x4 worldToObject)
{
    #if !defined(UNITY_COMPILER_DXC) || !defined(UNITY_PARTICLE_INSTANCING_ENABLED)
    objectToWorld = float4x4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);
    worldToObject = float4x4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);
    #else
    vertInstancingMatrices(objectToWorld, worldToObject);
    #endif
}