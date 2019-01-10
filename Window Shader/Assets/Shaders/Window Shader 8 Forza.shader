// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Window Shader 8 Forza"
{
    Properties
    {
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_SpecularTex("Specular", 2D) = "black" {}

		_IndoorTex("Indoor texture", 2D) = "white" {}
		_RoomDepth("Depth", Range(0,5)) = 2
		_RoomWidth("Width", Range(0,5)) = 2
		_IndoorTint("Indoor tint", Color) = (1,1,1,1)
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

			float4 objPos;
        };

		sampler2D _IndoorTex;
		half _RoomDepth;
		half _RoomWidth;
		//half4 _IndoorOffset;
		fixed4 _IndoorTint;
		//fixed4 _BackgroundColor;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
		// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)


		void vert (inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);

			o.objPos = v.vertex;
		}
		

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb * c.a;
			o.Smoothness = tex2D(_SpecularTex, IN.uv_MainTex).r;

			// Find the viewed point
			half3 viewedPoint = IN.objPos;
			// Find the view vector in object space
			half3 viewVector = ObjSpaceViewDir(IN.objPos);

			// Project it to the back wall
			half3 roomIntersection = viewedPoint + viewVector * (_RoomDepth - viewedPoint.z) / viewVector.z;

			// If it's too far left or right, project it to the side walls
			if (abs(roomIntersection.x) > _RoomWidth / 2)
			{
				if (viewVector.x < 0)
				{
					roomIntersection = viewedPoint + viewVector * (_RoomWidth / 2 - viewedPoint.x) / viewVector.x;
				}
				else
				{
					roomIntersection = viewedPoint + viewVector * (-_RoomWidth / 2 - viewedPoint.x) / viewVector.x;
				}
			}

			// If it's too far up or down, project it to the floor or ceiling
			if (abs(roomIntersection.y) > _RoomWidth / 2)
			{
				if (viewVector.y < 0)
				{
					roomIntersection = viewedPoint + viewVector * (_RoomWidth / 2 - viewedPoint.y) / viewVector.y;
				}
				else
				{
					roomIntersection = viewedPoint + viewVector * (-_RoomWidth / 2 - viewedPoint.y) / viewVector.y;
				}
			}

			// Map the room to a 2D texture by projecting it from a point at (0, 0, -_RoomDepth / 2)
			half2 roomUV = roomIntersection * (_RoomDepth * 1.5) / (roomIntersection.z + _RoomDepth / 2);
			roomUV /= 3;
			roomUV /= _RoomWidth;
			roomUV += half2 (0.5, 0.5);

			o.Emission = tex2D(_IndoorTex, roomUV) * _IndoorTint * (1 - c.a);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
