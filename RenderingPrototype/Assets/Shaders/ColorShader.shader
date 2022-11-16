Shader "Hidden/ColorShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            uniform sampler2D _MainTex;

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

            // Inigo Quilez - 2D SDFs
            float sdCircle(float2 p, float r)
            {
                return length(p) - r;
            }

            float sdTriangleIsosceles(float2 p, float2 q )
            {
                p.x = abs(p.x);
                float2 a = p - q * clamp(dot(p, q) / dot(q, q), 0.0, 1.0);
                float2 b = p - q * float2(clamp(p.x / q.x, 0.0, 1.0), 1.0);
                float s = -sign( q.y );
                float2 d = min(float2( dot(a, a), s * (p.x * q.y - p.y *q.x) ),
                            float2( dot(b,b), s*(p.y-q.y)  ));
                return -sqrt(d.x)*sign(d.y);
            }

            float4 frag (v2f_img input) : COLOR
            {
                // Sample color texture and output same color
                float4 base = tex2D(_MainTex, input.uv);
                return base * fbm2D(10.0 * input.uv); // TODO: divide UV by screen dims to avoid stretching
            }
            ENDCG
        }
    }
}
