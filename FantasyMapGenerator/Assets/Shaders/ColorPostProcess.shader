Shader "Hidden/ColorPostProcess"
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

            #define PI                3.1415926535897932384626433832795
            #define LAND_COLOR        float4(0.f, 1.f, 0.f, 1.f)
            #define WATER_COLOR       float4(0.f, 0.f, 1.f, 1.f)
            #define MOUNTAIN_COLOR    float4(1.f, 0.f, 0.f, 1.f)
            #define FOREST_COLOR      float4(1.f, 1.f, 0.f, 1.f)
            #define SCATTER_GRID_SIZE 2.0
            #define ASSETS_PER_CELL   3

            float noise1Df(float x) {
                return sin(2.0 * x) + sin(PI * x);
            }

            float noise1D(float x) {
                return sin(x);
            }

            float rand(float2 uv)
            {
                return frac(sin(dot(uv.xy, float2(12.9898,78.233))) * 43758.5453123);
            }

            float noise2Df(float2 p) {
                return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
            }

            float2x2 rotate2D(float angle)
            {
                return float2x2(cos(angle), -sin(angle), 
                                sin(angle), cos(angle));
            }

            float2x2 identity()
            {
                return float2x2(1, 0,
                                0, 1);
            }

            float sdCircle(float2 p, float r)
            {
                return length(p) - r;
            }

            float sdCirclePos(float2 queryPos, float2 p, float r)
            {
                return length(queryPos - p) - r;
            }

            float sdTriangleIsosceles(in float2 queryPos, in float2 pos, in float2 q, in float2x2 rot)
            {
                float2 p = mul(queryPos - pos, rot);
                p.x = abs(p.x);
                float2 a = p - q*clamp( dot(p,q)/dot(q,q), 0.0, 1.0 );
                float2 b = p - q*float2( clamp( p.x/q.x, 0.0, 1.0 ), 1.0 );
                float s = -sign( q.y );
                float2 d = min( float2( dot(a,a), s*(p.x*q.y-p.y*q.x) ),
                            float2( dot(b,b), s*(p.y-q.y)  ));
                return -sqrt(d.x)*sign(d.y);
            }

            float4 drawCompass(float4 baseColor, float2 pos, float2 gridUV)
            {
                float4 color = baseColor;
                float4 outerColor = float4(0.34, 0.26, 0.33, 1.0);
                float4 cardinalColor = float4(0.72, 0.58, 0.55, 1.0);
                float4 diagonalColor = float4(0.44, 0.39, 0.53, 1.0);
                float4 largeCircleColor = float4(0.35, 0.4, 0.2, 1.0);
                float4 smallCircleColor = float4(0.9, 0.93, 0.7, 1.0);

                // Draw compass
                float dMin = 1.0;
                
                // Outer circles
                float innerCircle = sdCirclePos(gridUV, pos + float2(-1.3, -0.5), 0.11);
                float outerCircle = sdCirclePos(gridUV, pos + float2(-1.3, -0.5), 0.15);
                dMin = max(-innerCircle, outerCircle);
                if (dMin < 0.0) {
                    if (dMin < -0.008) {
                        color = outerColor;     
                    }
                    else {
                        color = float4(0.0, 0.0, 0.0, 0.0);   
                    }
                }

                // NE, NW, SE, SW needles
                float southeast = sdTriangleIsosceles(gridUV, pos + float2(-1.18, -0.62), float2(0.015, 0.12), rotate2D(0.785398));
                float southwest = sdTriangleIsosceles(gridUV, pos + float2(-1.42, -0.62), float2(0.015, 0.12), rotate2D(-0.785398));
                float northeast = sdTriangleIsosceles(gridUV, pos + float2(-1.18, -0.38), float2(0.015, 0.12), rotate2D(3.0 * 0.785398));
                float northwest = sdTriangleIsosceles(gridUV, pos + float2(-1.42, -0.38), float2(0.015, 0.12), rotate2D(-3.0 * 0.785398));
                if (southeast < 0.0 || southwest < 0.0 || northeast < 0.0 || northwest < 0.0) {
                    color = diagonalColor;
                }

                // N, S, E, W needles
                float north = sdTriangleIsosceles(gridUV, pos + float2(-1.3, -0.25), float2(0.03, 0.2), rotate2D(2.0 * 1.5708));
                float south = sdTriangleIsosceles(gridUV, pos + float2(-1.3, -0.75), float2(0.03, 0.2), identity()); 
                float east = sdTriangleIsosceles(gridUV, pos + float2(-1.05, -0.5), float2(0.03, 0.2), rotate2D(1.5708));
                float west = sdTriangleIsosceles(gridUV, pos + float2(-1.55, -0.5), float2(0.03, 0.2), rotate2D(-1.5708)); 
                if (north < 0.0 || south < 0.0 || east < 0.0 || west < 0.0) {
                    if (north < -0.008 || south < -0.008 || east < -0.008 || west < -0.008) {
                        color = cardinalColor;    
                    }
                    else {
                        color = float4(0.0, 0.0, 0.0, 0.0);   
                    }      
                }  
                
                // Innermost circles
                float smallCircle1 = sdCirclePos(gridUV, pos + float2(-1.3, -0.5), 0.07);
                if (smallCircle1 < 0.0) color = largeCircleColor;
                float smallCircle2 = sdCirclePos(gridUV, pos + float2(-1.3, -0.5), 0.04);
                if (smallCircle2 < 0.0) color = smallCircleColor;

                return color;
            }

            float4 frag (v2f_img input) : COLOR
            {
                // Get uv coordinates
                float2 texUV = input.uv;

                float2 fragCoord = input.uv * _ScreenParams.xy;
                float2 gridUV = (2.0 * fragCoord.xy - _ScreenParams.xy) / _ScreenParams.y;
                
                // Sample color texture and map color ID to final color
                float4 base = tex2D(_MainTex, texUV);
                float4 color = base;

                if (distance(base, LAND_COLOR) <= 0.5) {
                    color = float4(1.0, 0.9, 0.7, 1.0);
                }
                else if (distance(base, WATER_COLOR) <= 0.55) {
                    color = float4(0.74, 0.76, 0.89, 1.0);
                }
                else if (distance(base, MOUNTAIN_COLOR) <= 0.55) {
                    //color = float4(0.71, 0.54, 0.39, 1.0);
                }
                else if (distance(base, FOREST_COLOR) <= 0.55) {
                    //color = float4(0.54, 0.76, 0.49, 1.0);
                }
                else {
                    color = float4(0.0, 0.0, 0.0, 0.0);
                }

                // Draw compass
                float2 maxDim = _ScreenParams.xy / _ScreenParams.y;
                float2 compassPos = float2(maxDim.x + 0.9, 0.0);
                color = drawCompass(color, compassPos, gridUV);
                
                return color;
            }
            ENDCG
        }
    }
}