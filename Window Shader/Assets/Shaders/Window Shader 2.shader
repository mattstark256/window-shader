Shader "Custom/Window Shader 2"
{
    Properties
    {
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0

		_IndoorTex("Indoor texture", 2D) = "white" {}
		_Depth("Depth", Range(0,2)) = 1
		_IndoorOffset("Indoor position and scale", Vector) = (0,0,1,1)
		_IndoorTint("Indoor tint", Color) = (1,1,1,1)
		_BackgroundColor("Background color", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
		sampler2D _IndoorTex;

        struct Input
        {
            float2 uv_MainTex;
			float2 uv_IndoorTex;

			float3 viewDir;
        };

		half _Glossiness;
		half _Metallic;
		half _Depth;
		half4 _IndoorOffset;
		fixed4 _IndoorTint;
		fixed4 _BackgroundColor;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb * c.a;
			o.Smoothness = _Glossiness;
            o.Metallic = _Metallic;

			// Get the viewed point relative to the surface
			half3 viewPointLocal = half3 (IN.uv_MainTex.x, IN.uv_MainTex.y, 0);

			// Get the viewing direction vector relative to the surface
			half3 k = o.Normal;
			half3 j = half3 (0, 1, 0); // We assume the surface is vertical.
			half3 i = normalize(cross(k, j));
			// j = normalize(cross(i, k)); // Something like this can be used for non-vertical surfaces
			half3 viewVector = normalize(IN.viewDir);
			half3 viewVectorLocal = half3 (
				dot(viewVector, i),
				dot(viewVector, j),
				dot(viewVector, k));

			half3 indoorVector = viewPointLocal + viewVectorLocal * -(_Depth / viewVectorLocal.z);
			indoorVector -= half3 (_IndoorOffset.x, _IndoorOffset.y, 0);
			indoorVector /= half3 (_IndoorOffset.z, _IndoorOffset.w, 1);
			if (indoorVector.x > 0 &&
				indoorVector.x < 1 &&
				indoorVector.y > 0 &&
				indoorVector.y < 1)
			{
				float2 indoorTextureUV = float2 (indoorVector.x, indoorVector.y);
				o.Emission = tex2D(_IndoorTex, indoorTextureUV) * _IndoorTint * (1 - c.a);
			}
			else
			{
				o.Emission = _BackgroundColor * (1 - c.a);
			}
        }
        ENDCG
    }
    FallBack "Diffuse"
}
