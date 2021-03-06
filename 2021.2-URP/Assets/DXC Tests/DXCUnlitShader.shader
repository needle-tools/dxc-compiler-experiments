Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert 
            #pragma fragment frag
            #pragma use_dxc 
            #pragma require Barycentrics 
            // #pragma exclude_renderers d3d11 
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
                #if defined(SHADER_STAGE_FRAGMENT)
                float3 barycentricWeights : SV_Barycentrics;
                #endif
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            #if defined(SHADER_STAGE_FRAGMENT)
            fixed4 frag (v2f i) : SV_Target
            {
                return float4(i.barycentricWeights, 1);
            }
            #endif
            
            ENDCG
        }
    }
}
