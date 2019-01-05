Shader "Custom/Window Shader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_IndoorTex("Indoor texture", 2D) = "white" {}
		_FloorTex("Floor texture", 2D) = "white" {}
		_SideTex("Side texture", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
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
        fixed4 _Color;

		sampler2D _FloorTex;
		sampler2D _SideTex;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            //fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            //o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            //o.Metallic = _Metallic;
            //o.Smoothness = _Glossiness;
            //o.Alpha = c.a;

			// Get the viewed point relative to the surface
			half3 viewPointLocal = half3 (IN.uv_IndoorTex.x % 1, IN.uv_IndoorTex.y % 1, 0);

			// Get the viewing direction vector relative to the surface
			half3 k = o.Normal;
			half3 j = half3 (0, 1, 0); // For now we will just assume the surface is vertical
			half3 i = normalize(cross(k, j));
			// j = normalize(cross(i, k)); // Something like this can be used for non-vertical surfaces
			half3 viewVector = normalize(IN.viewDir);
			half3 viewVectorLocal = half3 (
				dot(viewVector, i),
				dot(viewVector, j),
				dot(viewVector, k));

			// Try rendering back wall
			half3 indoorVector = viewPointLocal + viewVectorLocal * -(1 / viewVectorLocal.z);
			if (indoorVector.x > 0 &&
				indoorVector.x < 1 &&
				indoorVector.y > 0 &&
				indoorVector.y < 1)
			{
				float2 indoorTextureUV = float2(indoorVector.x, indoorVector.y);
				o.Emission = tex2D(_IndoorTex, indoorTextureUV);
			}
			else
			{
				// Try rendering side walls
				half distanceToIndoorSurface = (viewVectorLocal.x > 0) ? viewPointLocal.x : viewPointLocal.x - 1;
				indoorVector = viewPointLocal + viewVectorLocal * -(distanceToIndoorSurface / viewVectorLocal.x);
				if (indoorVector.y > 0 &&
					indoorVector.y < 1)
				{
					float2 indoorTextureUV = float2(indoorVector.z, indoorVector.y);
					o.Emission = tex2D(_SideTex, indoorTextureUV);
				}
				else
				{
					// Render floor or ceiling
					if (viewVectorLocal.y != 0) // This prevents a zero divisor error
					{
						distanceToIndoorSurface = (viewVectorLocal.y > 0) ? viewPointLocal.y : viewPointLocal.y - 1;
						indoorVector = viewPointLocal + viewVectorLocal * -(distanceToIndoorSurface / viewVectorLocal.y);
						float2 indoorTextureUV = float2(indoorVector.x, indoorVector.z);
						o.Emission = tex2D(_FloorTex, indoorTextureUV);
					}
				}
			}
        }
        ENDCG
    }
    FallBack "Diffuse"
}
