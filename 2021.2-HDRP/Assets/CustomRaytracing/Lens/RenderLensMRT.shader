// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

Shader "Unlit/RenderUV1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

        CGINCLUDE

        #include "UnityCG.cginc"
        #pragma multi_compile_local _TARGET_CHANNEL_UV _TARGET_CHANNEL_UV2

        struct appdata
        {
            float4 vertex : POSITION;
            float4 normal : NORMAL;
            float2 uv : TEXCOORD0;
            float2 uv2 : TEXCOORD1;
        };

        struct v2f
        {
            float4 vertex : SV_POSITION;
            float2 uv : TEXCOORD0;
            #ifdef _TARGET_CHANNEL_UV2
            float2 uv2 : TEXCOORD1;
            #endif
            float3 objectPos : TEXCOORD2;
            float3 objectNormal : TEXCOORD3;
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;
        float4 _Color;

        v2f vert (appdata v)
        {
            v2f o;
            #ifdef _TARGET_CHANNEL_UV
            float2 mappedUv = v.uv;
            #else
            float2 mappedUv = v.uv2;
            #endif
            #if UNITY_UV_STARTS_AT_TOP
            mappedUv.y = 1 - mappedUv.y;
            #endif
            o.vertex = float4(mappedUv * 2 - 1, 1, 1);
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);

            o.objectPos = v.vertex;
            o.objectNormal = v.normal;
            
            return o;
        }

        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // MRT shader
            struct FragmentOutput
            {
                half4 pos : SV_Target0;
                half4 dir : SV_Target1;
            };
            
            FragmentOutput frag (v2f i) : SV_Target
            {
                FragmentOutput o;

                // sample texture for debugging
                float4 col = tex2D(_MainTex, i.uv);
                
                // o.pos = frac(i.uv.x * 10);
                // o.dir = frac(i.uv.y * 10);
                // o.pos *= col;
                // o.dir *= col;

                o.pos = float4(i.objectPos, 1);
                o.dir = float4(i.objectNormal, 1);
                
                return o;
            }
            ENDCG
        }
    }
}
