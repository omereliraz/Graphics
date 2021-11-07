Shader "CG/BlinnPhongGouraud"
{
	Properties
	{
		_DiffuseColor("Diffuse Color", Color) = (0.14, 0.43, 0.84, 1)
		_SpecularColor("Specular Color", Color) = (0.7, 0.7, 0.7, 1)
		_AmbientColor("Ambient Color", Color) = (0.05, 0.13, 0.25, 1)
		_Shininess("Shininess", Range(0.1, 50)) = 10
	}
		SubShader
	{
		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

		// From UnityCG
		uniform fixed4 _LightColor0;

	// Declare used properties
	uniform fixed4 _DiffuseColor;
	uniform fixed4 _SpecularColor;
	uniform fixed4 _AmbientColor;
	uniform float _Shininess;

	struct appdata
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		fixed4 color : COLOR0;

	};

	v2f vert(appdata input)
	{
		v2f output; // initialize output struct
		float4 colorA = _AmbientColor * _LightColor0; // calculate Ambient Reflectance
		float4 colorD = max(dot(_LightColor0, input.normal), 0) * _DiffuseColor * _LightColor0; // calculate
				// Diffuse (Lambertian) Reflectance. 'max' is used to zero negetive values from dot product

		// calculate Specular Reflectance:
		float4 v = normalize(UnityObjectToClipPos(_WorldSpaceCameraPos)); // viewpoint direction 
		float4 halfwayVector = ((_LightColor0 + v) / 2) / length((_LightColor0 + v) / 2);
		float4 colorS = pow(max(dot(input.normal, halfwayVector), 0), _Shininess) * _SpecularColor * _LightColor0;

		output.color = (colorD + colorA + colorS); // calculate final color
		output.pos = UnityObjectToClipPos(input.vertex); // find the clip-space position of the vertex
		return output;
	}

	fixed4 frag(v2f input) : SV_Target
	{
		return input.color;
	}


ENDCG
}
	}
}