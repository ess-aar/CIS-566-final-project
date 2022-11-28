Shader "Hidden/EdgePostProcess"
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

            #define PI                3.1415926535897932384626433832795
            #define MOUNTAIN_COLOR    float4(1.f, 0.f, 0.f, 1.f)
            #define FOREST_COLOR      float4(1.f, 1.f, 0.f, 1.f)

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

            float4 convertToGreyscale(float4 col)
            {
                float greyVal = dot(col, float4(0.21, 0.72, 0.07, 0.0));
                return float4(float3(greyVal, greyVal, greyVal), 1.0);
            }
            
            float4 frag (v2f_img input) : COLOR {
                float horizontal[9] = { -1.0, 0.0, 1.0,
                                        -2.0, 0.0, 2.0,
                                        -1.0, 0.0, 1.0 
                                      };  

            
                float vertical[9] = { 1.0, 2.0, 1.0,
                                      0.0, 0.0, 0.0,
                                      -1.0, -2.0, -1.0 
                                    }; 

                float2 texUV = input.uv;

                float2 fragCoord = input.uv * _ScreenParams.xy;
                float2 gridUV = (2.0 * fragCoord.xy - _ScreenParams.xy) / _ScreenParams.y;

                float4 baseColor = tex2D(_MainTex, texUV);
                float4 color = baseColor;

                // If asset mask, we should not apply outlines
                if (distance(baseColor, MOUNTAIN_COLOR) <= 0.5) {
                    return baseColor;
                }
                if (distance(baseColor, FOREST_COLOR) <= 0.5) {
                    return baseColor;
                }
                    
                // Outline thickness
                float2 delta = float2(0.001, 0.001);
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
                        horizontalSum += convertToGreyscale(tex2D(_MainTex, (texUV + offset * delta))) * horizontal[kx + 3 * ky];
                        verticalSum += convertToGreyscale(tex2D(_MainTex, (texUV + offset * delta))) * vertical[kx + 3 * ky];
                    }
                }
                
                float sum = 1.0 - sqrt(horizontalSum * horizontalSum + verticalSum * verticalSum);
                float3 sumColor = float3(sum, sum, sum); 

                // Any outline should be black
                if (length(sumColor.xyz) <= 1.5) color = float4(0.0, 0.0, 0.0, 0.0);

                // FBM pass for paper look
                float fbm = pow(fbm2D(5.0 * gridUV), 1.0);

                //return lerp(baseColor, color, 0.5) * fbm;
                //return float4(convertToGreyscale(baseColor));
                return color;
            }	

			ENDCG
        }	
	} 
}