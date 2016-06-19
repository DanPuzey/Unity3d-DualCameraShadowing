Shader "Custom/RenderGlobalTexture" {
	Properties {
        _Color("Color", Color) = (1,1,1,1)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _GlobalShadowMap;

		struct Input {
			float2 uv_GlobalShadowMap;
		};

		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
            fixed4 c = tex2D(_GlobalShadowMap, IN.uv_GlobalShadowMap) * _Color;
			o.Albedo = c.rgb;            
		}
		ENDCG
	}
	FallBack "Diffuse"
}
