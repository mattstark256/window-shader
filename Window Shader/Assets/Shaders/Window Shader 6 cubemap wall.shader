﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Window Shader 6 cubemap wall"
{
    Properties
    {
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_SpecularTex("Specular", 2D) = "black" {}

		_PlaneDepth("Depth", Range(0,5)) = 1
		_IndoorTint("Indoor tint", Color) = (1,1,1,1)
		_CubeDiffuse("Cubemap Diffuse Map", CUBE) = "" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
		sampler2D _SpecularTex;

        struct Input
        {
            float2 uv_MainTex;
			float2 uv_SpecularTex;
			float3 planePoint;
        };

		half _PlaneDepth;
		fixed4 _IndoorTint;
		samplerCUBE _CubeDiffuse;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
		// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void vert (inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);

			// Find the corresponding point on the indoor plane
			half3 viewVectorLocal = ObjSpaceViewDir(v.vertex);
			o.planePoint = v.vertex + viewVectorLocal * (_PlaneDepth - v.vertex.z) / viewVectorLocal.z;
		}
		
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb * c.a;
			o.Smoothness = tex2D(_SpecularTex, IN.uv_SpecularTex).r;
			o.Emission = texCUBE(_CubeDiffuse, IN.planePoint) * _IndoorTint * (1 - c.a);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
