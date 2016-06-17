Shader "Custom/WriteDepthBuffer"
{
	Properties
	{
        _MainTex("Texture", 2D) = "white" {}
	}
	SubShader
	{
        Tags {
            "Queue" = "Geometry"
            //"IgnoreProjector" = "True"
            "RenderType" = "Opaque"
        }
        LOD 100

		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
            #pragma multi_compile_fwdadd_fullshadows
			
			#include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

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
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
                float4 diff : COLOR0; // diffuse lighting colour
			};

            struct fragOut
            {
                float4 col: SV_COLOR;
                float dep : SV_DEPTH;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);

                // get vertex normal in world space
                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                // dot product between normal and light direction for
                // standard diffuse (Lambert) lighting
                half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                // factor in the light color
                o.diff = nl * _LightColor0;

                // add ambient/light proble light
                o.diff.rgb += ShadeSH9(half4(worldNormal, 1));

				return o;
			}
			
			fragOut frag (v2f i) : SV_Target
			{
                fixed4 col = tex2D(_MainTex, i.uv);

                // apply lighting
                fixed alpha = col.w;
                col *= i.diff;
                col.w = alpha;

                UNITY_APPLY_FOG(i.fogCoord, col);

                fragOut o;
                o.col = col;
                o.dep = 0;

                return o;
			}
			ENDCG
		}
	}
}
