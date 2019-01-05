// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Window Shader 3 2 layer"
{
    Properties
    {
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_SpecularTex("Specular", 2D) = "black" {}

		_IndoorTex("Indoor texture", 2D) = "white" {}
		_Depth("Depth", Range(0,5)) = 1
		_IndoorOffset("Indoor position and scale", Vector) = (0,0,1,1)
		_IndoorTint("Indoor tint", Color) = (1,1,1,1)
		_BackgroundColor("Background Color", Color) = (0,0,0,1)

		_IndoorTex2("Indoor texture 2", 2D) = "white" {}
		_Depth2("Depth 2", Range(0,5)) = 1
		_IndoorOffset2("Indoor position and scale 2", Vector) = (0,0,1,1)
		_IndoorTint2("Indoor tint 2", Color) = (1,1,1,1)
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
			float2 indoorUV;
			float2 indoorUV2;
        };

		sampler2D _IndoorTex;
		half _Depth;
		half4 _IndoorOffset;
		fixed4 _IndoorTint;
		fixed4 _BackgroundColor;

		sampler2D _IndoorTex2;
		half _Depth2;
		half4 _IndoorOffset2;
		fixed4 _IndoorTint2;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
		// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)


		void vert (inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);

			// Find the point on the indoor wall that is being viewed
			half3 viewVectorLocal = ObjSpaceViewDir(v.vertex);
			half2 indoorPoint = v.vertex + viewVectorLocal * (_Depth - v.vertex.z) / viewVectorLocal.z;
			half2 indoorPoint2 = v.vertex + viewVectorLocal * (_Depth2 - v.vertex.z) / viewVectorLocal.z;

			// Transform it using "Indoor position and scale" values
			indoorPoint -= half2 (_IndoorOffset.x, _IndoorOffset.y);
			indoorPoint /= half2 (_IndoorOffset.z, _IndoorOffset.w);
			indoorPoint += half2 (0.5, 0.5);
			indoorPoint2 -= half2 (_IndoorOffset2.x, _IndoorOffset2.y);
			indoorPoint2 /= half2 (_IndoorOffset2.z, _IndoorOffset2.w);
			indoorPoint2 += half2 (0.5, 0.5);

			o.indoorUV = indoorPoint;
			o.indoorUV2 = indoorPoint2;
		}
		

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb * c.a;
			o.Smoothness = tex2D(_SpecularTex, IN.uv_SpecularTex).r;

			float4 e;

			if (IN.indoorUV.x > 0 &&
				IN.indoorUV.x < 1 &&
				IN.indoorUV.y > 0 &&
				IN.indoorUV.y < 1)
			{
				e = tex2D(_IndoorTex, IN.indoorUV) * _IndoorTint;
			}
			else
			{
				e = _BackgroundColor;
			}

			if (IN.indoorUV2.x > 0 &&
				IN.indoorUV2.x < 1 &&
				IN.indoorUV2.y > 0 &&
				IN.indoorUV2.y < 1)
			{
				float4 e2 = tex2D(_IndoorTex2, IN.indoorUV2) * _IndoorTint2;
				e = lerp(e, e2, e2.a);
			}

			o.Emission = e * (1 - c.a);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
