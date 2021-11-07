Shader "CG/Bricks"
{
    Properties
    {
        [NoScaleOffset] _AlbedoMap ("Albedo Map", 2D) = "defaulttexture" {}
        _Ambient ("Ambient", Range(0, 1)) = 0.15
        [NoScaleOffset] _SpecularMap ("Specular Map", 2D) = "defaulttexture" {}
        _Shininess ("Shininess", Range(0.1, 100)) = 50
        [NoScaleOffset] _HeightMap ("Height Map", 2D) = "defaulttexture" {}
        _BumpScale ("Bump Scale", Range(-100, 100)) = 40
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "CGUtils.cginc"

				// From UnityCG
				uniform fixed4 _LightColor0;

                // Declare used properties
                uniform sampler2D _AlbedoMap;
                uniform float _Ambient;
                uniform sampler2D _SpecularMap;
                uniform float _Shininess;
                uniform sampler2D _HeightMap;
                uniform float4 _HeightMap_TexelSize;
                uniform float _BumpScale;

                struct appdata
                { 
                    float4 vertex   : POSITION;
                    float3 normal   : NORMAL;
                    float4 tangent  : TANGENT;
                    float2 uv       : TEXCOORD0;
                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
                    float2 uv : TEXCOORD0;
					float3 normal : NORMAL;
					float4 worldPos: TEXCOORD1;
					float4 tangent  : TANGENT;

                };

                v2f vert (appdata input)
                {
                    v2f output;
                    output.uv =  input.uv;
					output.normal = mul(unity_ObjectToWorld, input.normal);
					output.pos = UnityObjectToClipPos(input.vertex);
					output.worldPos = mul(unity_ObjectToWorld, input.vertex); // move po to world space
					output.tangent = mul(unity_ObjectToWorld, input.tangent); //move to tanget space
					return output;
                }

				fixed4 frag(v2f input) : SV_Target
				{
					//Calculate the n֦ h֦ l directions as needed
					float3 l = normalize(_WorldSpaceLightPos0.xyz);
					float3 v = normalize(_WorldSpaceCameraPos - input.worldPos.xyz);
					//float3 h = normalize(l + v);
					float3 n = normalize(input.normal);
					//normilze t before usage 
					float3 t = normalize(input.tangent);
					//Sample the albedo map at u,v to get the albedo value
					fixed4 albedo = tex2D(_AlbedoMap, input.uv);
					//Sample the specular map at u,v to get the specularity value
					fixed4 specular = tex2D(_SpecularMap, input.uv);

					
					// Note that the texel may not be square

					bumpMapData i;
					i.normal = n;       // Mesh surface normal at the point
					i.tangent = t;      // Mesh surface tangent at the point
					i.uv = input.uv;           // UV coordinates of the point
					i.heightMap = _HeightMap; // Heightmap texture to use for bump mapping
					// Use the size of the ִHeightMap texture texels as du and dv 
					i.du = _HeightMap_TexelSize.x;// Increment size for u partial derivative approximation
					i.dv = _HeightMap_TexelSize.y;// Increment size for v partial derivative approximation
					// Use the ִBumpScale material property֦ divided by 10000 as the bumpScale parameter֬
					i.bumpScale = (_BumpScale/10000);     // Bump scaling factor
					float3 retVal = getBumpMappedNormal(i);

					// Finally֦ exchange the normal used in step 4 to calculate the lighting with the new bump-mapped normals֥

					//Pass on the ִAmbient material property as the ambientIntensity parameter
					//Pass on the ִShininess material property as the shininess parameter

                    return fixed4(blinnPhong(retVal, v, l, _Shininess, albedo, specular, _Ambient),1);
                }

            ENDCG
        }
    }
}
