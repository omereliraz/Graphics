Shader "CG/Bonus"
{
    Properties
    {
        [Toggle] _shouldAnimate ("shouldAnimate", int) = 0  // used as boolean. 0 = false, 1 = true
        numOfRibbons ("numOfRibbons", int) = 5
        speed ("speed", float) = 1
        distance_reciprocal ("distance_reciprocal", float) = 0.15 // lower to curl more the ribbons (around the ball).
        ribbons_width ("ribbons_width", float) = 0.8
    }
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {

            Cull Off // this makes Double-Sided Rendering, which allows us to see the inside of the object

            CGPROGRAM

                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                #define PI 3.14159265
                
                // Declare used properties
                uniform int _shouldAnimate;
                uniform int numOfRibbons;
                uniform float speed;
                uniform float distance_reciprocal;
                uniform float ribbons_width;
            
                struct appdata
                { 
                    float4 vertex   : POSITION;
                };

                struct v2f
                {
                    float4 pos      : SV_POSITION;
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
                    const float3 up = float3(0, 1, 0);
                    const float3 left = normalize(float3(-1,0,0));

                    float3 pos = normalize(input.objectPos);
                    
                    float3 cross_pos_up = normalize(cross(pos, up));
                    float arcos_x3 = acos(dot(cross_pos_up, left)); //acos = Arccosine
                    float div = arcos_x3 / (PI * 2);
                    float sign_x5 = sign(dot(left, pos));
                    float reverse_side = mul(sign_x5, div);
                    float allRibbons = mul(reverse_side, numOfRibbons);
                    
                    float movement = _Time.y * speed; // this is used to animate the shader
                    allRibbons = (_shouldAnimate == 1) ? (allRibbons + movement) : (allRibbons);
                        
                    float y = dot(pos, up) / distance_reciprocal;

                    float frac_dot = frac(y + allRibbons);
                    float reversedStep = 1 - step(frac_dot, ribbons_width); // step = (frac >= width) ? 1 : 0.

                    return fixed4(pos.x, pos.y, pos.z, reversedStep); // we use pos to color it colorful
                }

            ENDCG
        }
    }
}
