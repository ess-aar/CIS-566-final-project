Shader "Hidden/EdgeDetectShader"
{
    Properties {
		_MainTex ("Texture", 2D) = "white" {}
	}
	
	SubShader {

        Pass 
        {
            CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag

            #include "UnityCG.cginc"
		
            uniform sampler2D _MainTex;
            
            float4 frag (v2f_img input) : COLOR {
                // Outline thickness
                float2 delta = float2(0.001, 0.001);

                float horizontal[9] = { -1.0, 0.0, 1.0,
                                        -2.0, 0.0, 2.0,
                                        -1.0, 0.0, 1.0 
                                      };  

            
                float vertical[9] = { 1.0, 2.0, 1.0,
                                      0.0, 0.0, 0.0,
                                      -1.0, -2.0, -1.0 
                                    }; 
                    
                float4 horizontalSum = float4(0.0, 0.0, 0.0, 0.0);
                float4 verticalSum = float4(0.0, 0.0, 0.0, 0.0);

                for (int i = -1; i <= 1; i++) {
                    for (int j = -1; j <= 1; j++) {
                        // Matrix coordinates
                        int kx = i + 1;
                        int ky = j + 1;

                        // Get current UV coordinate
                        float2 offset = float2(i, j);

                        // Sample input texture
                        horizontalSum += tex2D(_MainTex, (input.uv + offset * delta)) * horizontal[kx + 3 * ky];
                        verticalSum += tex2D(_MainTex, (input.uv + offset * delta)) * vertical[kx + 3 * ky];
                    }
                }
                
                float4 baseColor = tex2D(_MainTex, input.uv);
                float sum = 1.0 - sqrt(horizontalSum * horizontalSum + verticalSum * verticalSum);
                return lerp(baseColor, float4(sum, sum, sum, 1), baseColor.a);
            }	

			ENDCG
        }	
	} 
}
