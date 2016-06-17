Shader "Custom/UseGlobalShadowData" {
    Properties{
        _Color("Color", Color) = (1,1,1,1)
    }
    SubShader{
        Tags{ "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _GlobalShadowMap;
        sampler2D _LastCameraDepthTexture;

        struct Input {
            float2 uv_GlobalShadowMap;
            float2 uv_LastCameraDepthTexture;
        };

        fixed4 _Color;

        void surf(Input IN, inout SurfaceOutputStandard o) {
            fixed4 s = tex2D(_GlobalShadowMap)

            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D(_GlobalShadowMap, IN.uv_GlobalShadowMap) * _Color;
            o.Albedo = c.rgb;
        }

        //half4 LightingReuseGlobal_Prepass(SurfaceOutput s, float4 light) {
        //    half4 s = tex2d(_GlobalShadowMap, )
        //    half4 c = s.Albedo * s
        //}
        ENDCG
    }
    FallBack "Diffuse"

}
