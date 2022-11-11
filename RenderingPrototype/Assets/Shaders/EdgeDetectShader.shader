Shader "Hidden/EdgeDetectShader"
{
    Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_DeltaX ("Delta X", Float) = 0.01
		_DeltaY ("Delta Y", Float) = 0.01
	}
	
	SubShader {

        Pass 
        {
            CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag

            #include "UnityCG.cginc"
		
            uniform sampler2D _MainTex;
            float _DeltaX;
            float _DeltaY; 

            #define PI 3.1415926535897932384626433832795

            float noise2Df(float2 p) {
                return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
            }

            float cosineInterpolate(float a, float b, float t)
            {
                float cos_t = (1.f - cos(t * PI)) * 0.5f;
                return lerp(a, b, cos_t);
            }

            float interpolateNoise2D(float x, float y) 
            {
                // Get integer and fractional components of current position
                int intX = int(floor(x));
                float fractX = frac(x);
                int intY = int(floor(y));
                float fractY = frac(y);

                // Get noise value at each of the 4 vertices
                float v1 = noise2Df(float2(intX, intY));
                float v2 = noise2Df(float2(intX + 1, intY));
                float v3 = noise2Df(float2(intX, intY + 1));
                float v4 = noise2Df(float2(intX + 1, intY + 1));

                // Interpolate in the X, Y directions
                float i1 = cosineInterpolate(v1, v2, fractX);
                float i2 = cosineInterpolate(v3, v4, fractX);
                return cosineInterpolate(i1, i2, fractY);
            }

            float fbm2D(float2 p) 
            {
                float total = 0.f;
                float persistence = 0.5f;
                int octaves = 4;

                for(int i = 1; i <= octaves; i++)
                {
                    float freq = pow(2.f, float(i));
                    float amp = pow(persistence, float(i));

                    float perlin = interpolateNoise2D(p.x * freq, p.y * freq);
                    total += amp * (0.5 * (perlin + 1.0));
                }
                return total;
            }
            
            float4 frag (v2f_img input) : COLOR {
                float2 delta = float2(_DeltaX, _DeltaY);

                float horizontal[9] = { 1.0, 0.0, -1.0,
                                        2.0, 0.0, -2.0,
                                        1.0, 0.0, -1.0 
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
                
                float4 base = tex2D(_MainTex, input.uv);
                return base * 3.0 * fbm2D(10.0 * input.uv) * float4(0.8, 0.6, 0.5, 1.0);
                //float sum = 1.0 - sqrt(horizontalSum * horizontalSum + verticalSum * verticalSum);
                //return float4(sum, sum, sum, 1);
            }	

			ENDCG
        }	
	} 
}
