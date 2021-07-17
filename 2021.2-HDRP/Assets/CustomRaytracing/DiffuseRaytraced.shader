Shader "RayTracing/DxrDiffuse"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_Texture("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		// basic rasterization pass that will allow us to see the material in SceneView
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			float4 _Color;
			sampler2D _Texture;

			v2f vert(appdata v)
			{
				v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float4 tex = tex2D(_Texture, i.uv);
				return float4(tex.rgb * _Color.rgb, 1);
			}
			
			ENDCG
		}

		// ray tracing pass
		Pass
		{
			Name "DxrPass"
			Tags{ "LightMode" = "DxrPass" }

			HLSLPROGRAM

			#pragma raytracing DxrPass

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"					   
			#include "Common.cginc"

			float4 _Color;
			TEXTURE2D(_Texture);
			SAMPLER(sampler_Texture);

			[shader("closesthit")]
			void ClosestHit(inout RayPayload rayPayload : SV_RayPayload, AttributeData attributeData : SV_IntersectionAttributes)
			{
				// stop if we have reached max recursion depth
				if(rayPayload.depth + 1 == gMaxDepth)
				{
					return;
				}

				// compute vertex data on ray/triangle intersection
				IntersectionVertex currentvertex;
				GetCurrentIntersectionVertex(attributeData, currentvertex);

				
				// transform normal to world space
				float3x3 objectToWorld = (float3x3)ObjectToWorld3x4();
				float3 worldNormal = normalize(mul(objectToWorld, currentvertex.normalOS));
								
				float3 rayOrigin = WorldRayOrigin();
				float3 rayDir = WorldRayDirection();
				// get intersection world position
				float3 worldPos = rayOrigin + RayTCurrent() * rayDir;

				// get random vector
				float3 randomVector = float3(nextRand(rayPayload.randomSeed), nextRand(rayPayload.randomSeed), nextRand(rayPayload.randomSeed)) * 2 - 1;

				// get random scattered ray dir along surface normal

				
				float3 scatterRayDir = normalize(worldNormal + randomVector * 0.02);
				float3 reflectDir = reflect(WorldRayDirection(), scatterRayDir);
				scatterRayDir = reflectDir; 
				
				RayDesc rayDesc;
				rayDesc.Origin = worldPos;
				rayDesc.Direction = scatterRayDir;
				rayDesc.TMin = 0.001;
				rayDesc.TMax = 100;

				// Create and init the scattered payload
				RayPayload scatterRayPayload;
				scatterRayPayload.color = float3(0.0, 0.0, 0.0);
				scatterRayPayload.randomSeed = rayPayload.randomSeed;
				scatterRayPayload.depth = rayPayload.depth + 1;				


				float2 uv = currentvertex.texCoord0;

				// texture LOD / mip level is non-trivial in a raytrace shader, see
				// https://graphics.stanford.edu/papers/trd/trd_jpg.pdf
				// https://media.contentapi.ea.com/content/dam/ea/seed/presentations/2019-ray-tracing-gems-chapter-20-akenine-moller-et-al.pdf
				
				float lod = 0; // ComputeTextureLOD(uv, 0);
				float4 tex = _Texture.SampleLevel(sampler_Texture, uv, lod);

				// rayPayload.color = float4(currentvertex.texCoord0,0,1);
				rayPayload.color = float4(tex.rgb * _Color.rgb, 1);
				
				if(rayPayload.depth > 2) return;
				// shoot scattered ray
				TraceRay(_RaytracingAccelerationStructure, RAY_FLAG_NONE, RAYTRACING_OPAQUE_FLAG, 0, 1, 0, rayDesc, scatterRayPayload);
				
				rayPayload.color += scatterRayPayload.color * 0.5;

				// rayPayload.color = scatterRayPayload.depth * 0.5f;
				
				return;
			}			

			ENDHLSL
		}
	}
		
	Fallback "HDRP/Lit"
}