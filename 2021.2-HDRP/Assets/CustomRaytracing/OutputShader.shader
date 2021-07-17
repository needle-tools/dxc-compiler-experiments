Shader "Unlit/OutputShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [KeywordEnum(UV, UV2)]
        _Channel ("UV Channel", Float) = 0
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
            #pragma multi_compile_local _CHANNEL_UV _CHANNEL_UV2
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                #ifdef _CHANNEL_UV
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                #else
                o.uv = v.uv2;
                #endif
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // #ifdef _CHANNEL_UV
                // return float4(1,0,0,1);
                // #else
                // return float4(0,1,0,1);
                // #endif
                
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
