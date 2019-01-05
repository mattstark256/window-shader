// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Window Shader 3"
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
        };

		sampler2D _IndoorTex;
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


		void vert (inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);

			// Find the point on the indoor wall that is being viewed
			half3 viewVectorLocal = ObjSpaceViewDir(v.vertex);
			half2 indoorPoint = v.vertex + viewVectorLocal * (_Depth - v.vertex.z) / viewVectorLocal.z;

			// Transform it using "Indoor position and scale" values
			indoorPoint -= half2 (_IndoorOffset.x, _IndoorOffset.y);
			indoorPoint /= half2 (_IndoorOffset.z, _IndoorOffset.w);
			indoorPoint += half2 (0.5, 0.5);

			o.indoorUV = indoorPoint;
		}
		

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb * c.a;
			o.Smoothness = tex2D(_SpecularTex, IN.uv_SpecularTex).r;

			if (IN.indoorUV.x > 0 &&
				IN.indoorUV.x < 1 &&
				IN.indoorUV.y > 0 &&
				IN.indoorUV.y < 1)
			{
				o.Emission = tex2D(_IndoorTex, IN.indoorUV) * _IndoorTint * (1 - c.a);
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
