// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Window Shader 5 small cubemap"
{
    Properties
    {
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_SpecularTex("Specular", 2D) = "black" {}


		_Radius("Radius", Range(0,10)) = 3
		_CubeDiffuse("Cubemap Diffuse Map", CUBE) = "" {}
		_CubeTint("Cubemap tint", Color) = (1,1,1,1)
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
			float3 spherePoint;
        };

		half _Radius;
		samplerCUBE _CubeDiffuse;
		fixed4 _CubeTint;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
		// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)


		void vert (inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);

			// http://ambrsoft.com/TrigoCalc/Sphere/SpherLineIntersection_.htm

			half3 A = v.vertex;
			half3 B = -ObjSpaceViewDir(v.vertex);

			half a = B.x*B.x + B.y*B.y + B.z*B.z;
			half b = 2 * (A.x*B.x + A.y*B.y + A.z*B.z);
			half c = A.x*A.x + A.y*A.y + A.z*A.z - _Radius*_Radius;

			half t = (-b + sqrt(b * b - 4 * a * c)) / (2 * a);

			o.spherePoint = A + B * t;
		}
		

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb * c.a;
			o.Smoothness = tex2D(_SpecularTex, IN.uv_SpecularTex).r;

			o.Emission = texCUBE(_CubeDiffuse, IN.spherePoint) * _CubeTint * (1 - c.a);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
