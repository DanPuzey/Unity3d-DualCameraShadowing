Shader "Custom/RenderLastDepthTexture" {
	Properties {
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

        sampler2D _LightBuffer;

		struct Input {
			float2 uv_LightBuffer;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_LightBuffer, IN.uv_LightBuffer);
			o.Albedo = c.rgb;            
		}
		ENDCG
	}
	FallBack "Diffuse"
}
