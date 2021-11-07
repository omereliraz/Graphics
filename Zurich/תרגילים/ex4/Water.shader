Shader "CG/Water"
{
    Properties
    {
        _CubeMap("Reflection Cube Map", Cube) = "" {}
        _NoiseScale("Texture Scale", Range(1, 100)) = 10 
        _TimeScale("Time Scale", Range(0.1, 5)) = 3 
        _BumpScale("Bump Scale", Range(0, 0.5)) = 0.05
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
                #include "CGUtils.cginc"
                #include "CGRandom.cginc"

                #define DELTA 0.01

                // Declare used properties
                uniform samplerCUBE _CubeMap;
                uniform float _NoiseScale;
                uniform float _TimeScale;
                uniform float _BumpScale;

                struct appdata // object space. we want to change to world-space
                { 
                    float4 vertex   : POSITION;
                    float3 normal   : NORMAL;
                    float4 tangent  : TANGENT;
                    float2 uv       : TEXCOORD0;
                };

                struct v2f
                {
                    float4 pos      : SV_POSITION;
                    float2 uv       : TEXCOORD0;
                    float3 normal   : TEXCOORD1;
                    float4 worldPos : TEXCOORD2;
                    float4 objectPos : TEXCOORD3;
                    float4 tangent  : TEXCOORD4;

                    
                };

                // Returns the value of a noise function simulating water, at coordinates uv and time t
                float waterNoise(float2 uv, float t)
                {
                    // Smaple perlin noise at coordinets
                    float toRet = perlin3d(float3(0.5*uv.x,0.5*uv.y, 0.5*t)) + 0.5 * perlin3d(float3(uv.x,uv.y, t)) +
                                    0.2 * perlin3d(float3(2 * uv.x, 2 * uv.y, 3 * t));
                    return toRet; // normlise to [0,1]
                }

                // Returns the world-space bump-mapped normal for the given bumpMapData and time t
                float3 getWaterBumpMappedNormal(bumpMapData i, float t)
                {
                    // generated noise function as the heightmap
                    //sample the function waterNoise directly at the given uv and caluclate normal
                    float f_du = (waterNoise(i.uv + i.du, t) - waterNoise(i.uv, t)) / i.du;
	                float f_dv = (waterNoise(i.uv + i.dv, t) - waterNoise(i.uv, t)) / i.dv;

	                //cross proudct and normolize res = nh
	                float3 nh = normalize(float3(-f_du * i.bumpScale, -f_dv * i.bumpScale, 1));

	                //calculate the binormla
	                float3 binormal = cross(i.tangent, i.normal);

	                // remember that nz comes before ny
                    return nh.x * i.tangent + nh.z * i.normal + nh.y * binormal;
                }


                v2f vert (appdata input)
                {
                    v2f output;
                    output.uv = input.uv;
                    output.normal = input.normal;
                    output.worldPos = mul(unity_ObjectToWorld, input.vertex);
                    output.objectPos = input.vertex;
                    //output.tangent = mul(unity_ObjectToWorld, input.tangent);
                    output.tangent = input.tangent;
                    float waterN = ((waterNoise(input.uv * _NoiseScale, _Time.y * _TimeScale)+ 1)/2)*_BumpScale;
                    output.pos = UnityObjectToClipPos(input.vertex + waterN);
                    return output;
                }

            
                fixed4 frag (v2f input) : SV_Target
                {
                    //֦sample waterNoise using the UV coordinates multiplied by the NoiseScale property normalized to 0-1
                    // float waterN = (waterNoise(input.uv * _NoiseScale, 0) + 1)/2;
                    float waterN = (waterNoise(input.uv * _NoiseScale, _Time.y * _TimeScale)+1)/2;

                    float3 v = normalize(_WorldSpaceCameraPos - input.worldPos.xyz); //light
					float3 n = normalize(mul(unity_ObjectToWorld,input.normal)); //camera

                    //part 6- calling bump map normals: creating bumpMapData
                    bumpMapData i;
                    i.normal = n;
                    i.tangent = normalize(input.tangent);
                    i.uv = input.uv * _NoiseScale;
                    i.du = DELTA;
                    i.dv = DELTA;
                    i.bumpScale = _BumpScale;

                    //getting water bump map normal
                    float3 waterBunmpNormal = getWaterBumpMappedNormal(i, _Time.y * _TimeScale);
                    //calculate the reflected view direction r. r = 2(dot(v,n)n -v    
                    //float3 r = 2 * dot(v,n)*n - v;
                    float3 r = 2 * dot(v,waterBunmpNormal)*waterBunmpNormal - v;

                    //sample _cubeMap into ReflectedColor
                    half4 ReflectedColor = texCUBE(_CubeMap, r);

                    //set each color to - color = (1-max{0, dot(n, v)} + 0.2)* ReflectedColor
                    //fixed4 color = (1 - max(0, dot(n,v)) + 0.2) * ReflectedColor;
                    fixed4 color = (1 - max(0, dot(waterBunmpNormal,v)) + 0.2) * ReflectedColor;
                    
                    return color;
                }

            ENDCG
        }
    }
}
