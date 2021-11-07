Shader "CG/Earth"
{
    Properties
    {
        [NoScaleOffset] _AlbedoMap ("Albedo Map", 2D) = "defaulttexture" {}
        _Ambient ("Ambient", Range(0, 1)) = 0.15
        [NoScaleOffset] _SpecularMap ("Specular Map", 2D) = "defaulttexture" {}
        _Shininess ("Shininess", Range(0.1, 100)) = 50
        [NoScaleOffset] _HeightMap ("Height Map", 2D) = "defaulttexture" {}
        _BumpScale ("Bump Scale", Range(1, 100)) = 30
        [NoScaleOffset] _CloudMap ("Cloud Map", 2D) = "black" {}
        _AtmosphereColor ("Atmosphere Color", Color) = (0.8, 0.85, 1, 1)
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

                // Declare used properties
                uniform sampler2D _AlbedoMap;
                uniform float _Ambient;
                uniform sampler2D _SpecularMap;
                uniform float _Shininess;
                uniform sampler2D _HeightMap;
                uniform float4 _HeightMap_TexelSize;
                uniform float _BumpScale;
                uniform sampler2D _CloudMap;
                uniform fixed4 _AtmosphereColor;

                struct appdata
                { 
                    float4 vertex : POSITION;

                };

                struct v2f
                {
                    float4 pos : SV_POSITION;
					float4 objectPos : TEXCOORD0;
					float4 worldPos  : TEXCOORD1;
                };

                v2f vert (appdata input)
                {
                    v2f output;
                    output.pos = UnityObjectToClipPos(input.vertex);
					output.worldPos = mul(unity_ObjectToWorld, input.vertex);
					output.objectPos = input.vertex;
                    return output;
                }

                fixed4 frag (v2f input) : SV_Target
                {
					//Calculate the n֦ h֦ l directions as needed
                    float3 normal = normalize(input.objectPos);
                	float3 n = normalize(mul(unity_ObjectToWorld, normal));
					float3 l = normalize(_WorldSpaceLightPos0.xyz); //light
					float3 v = normalize(_WorldSpaceCameraPos - input.worldPos.xyz); //camera
                 
					float2 uv = getSphericalUV(input.objectPos);
                	//Sample the ALbedo map at u,v to get the Albedo value
					fixed4 albedo = tex2D(_AlbedoMap, uv);
					//Sample the specular map at u,v to get the specularity value
					fixed4 specular = tex2D(_SpecularMap, uv);

					//calculate surface normal - we will calculate stuff as if input.normal is surface normal

					//set du and dv
					bumpMapData i;
					i.normal = n; 
					i.tangent = cross(normal, float3(0, 1, 0));//calculate tang
					i.uv = uv;
					i.heightMap = _HeightMap;
					i.du = _HeightMap_TexelSize.x;// Increment size for u partial derivative approximation
					i.dv = _HeightMap_TexelSize.y;// Increment size for v partial derivative approximation
					//use ִBumpScale m.p div to 1000
					i.bumpScale = (_BumpScale / 10000);
					//calculate the normal for ares of water like (1-ִSpecularMapֺ[u,v])*bumpMappedNormal + _SpecularMapֺ[u,v]*baseSurfaceNormal
					float3 finalnormal = (1 - specular) * getBumpMappedNormal(i) + (specular * n);

					//define the Lambert ׀diffuseׁ lighting at each point֥
					float3 lambert = max(0, dot(n, l));

                	//atmosphere = (1- max(0,dot(n,v)))*sqrt(lambert)+_atmospherecolor
					float atmosphere = (1 - max(0, dot(n, v))) * sqrt(lambert) * _AtmosphereColor;
				
					//clouds = cross(_cloudmap[u,v], (sqrt(lambert)+_ambient))
					fixed4 cloudmap = tex2D(_CloudMap, uv);
					float clouds = cloudmap * (sqrt(lambert) + _Ambient);
					//BlinnPhong + Atmosphere + Clouds֬
					return float4(blinnPhong(finalnormal, v, l, _Shininess, albedo, specular, _Ambient) + atmosphere + clouds, 1);

                }

            ENDCG
        }
    }
}
