Shader "Custom/WriteDepthBuffer"
{
    Properties
    {
        _DiffuseTexture("Diffuse Texture", 2D) = "white" {}
        _DiffuseTint("Diffuse Tint", Color) = (1, 1, 1, 1)
    }

        SubShader
        {
            Tags {
                "RenderType" = "Opaque"
            }
            LOD 100

            // No culling or depth
            ZTest Always

            Pass
            {
                Tags { "LightMode" = "ForwardBase" }

                CGPROGRAM
                #pragma target 3.0
                #pragma vertex vert
                #pragma fragment frag
                #pragma multi_compile_fwdbase
                #pragma fragmentoption ARB_precision_hint_fastest

                #include "UnityCG.cginc"
                #include "UnityLightingCommon.cginc"
                #include "AutoLight.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                    float4 diff : COLOR0; // diffuse lighting colour
                    float3 normal: NORMAL;
                    UNITY_FOG_COORDS(1)
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float3 lightDir : TEXCOORD0;
                    float3 normal : TEXCOORD1;
                    float2 uv : TEXCOORD2;
                    LIGHTING_COORDS(3, 4)
                };

                struct fragOut
                {
                    float4 col: SV_COLOR;
                    float dep : SV_DEPTH;
                };

                sampler2D _DiffuseTexture;
                float4 _DiffuseTint;

                v2f vert(appdata_base v)
                {
                    v2f o;

                    o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                    o.uv = v.texcoord;
                    o.lightDir = normalize(ObjSpaceLightDir(v.vertex));
                    o.normal = normalize(v.normal).xyz;

                    TRANSFER_VERTEX_TO_FRAGMENT(o)

                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    fixed4 col = tex2D(_DiffuseTexture, i.uv);

                    float3 L = normalize(i.lightDir);
                    float3 N = normalize(i.normal);

                    float attenuation = LIGHT_ATTENUATION(i) * 2;
                    float4 ambient = UNITY_LIGHTMODEL_AMBIENT * 2;

                    float NdotL = saturate(dot(N, L));
                    float4 diffuseTerm = NdotL * _LightColor0 * _DiffuseTint * attenuation;

                    col = (ambient + diffuseTerm) * col;

                    UNITY_APPLY_FOG(i.fogCoord, col);

                    fragOut o;
                    o.col = col;
                    o.dep = 0;

                    return col;
                }
                ENDCG
            }
        }

            FallBack "Diffuse"
}
