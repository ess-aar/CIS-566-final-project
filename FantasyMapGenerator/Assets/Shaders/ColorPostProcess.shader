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
            #define EPSILON           0.001
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

            float2 noise2Dv(float2 p ) {
                return frac(sin(float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5,183.3)))) * 43758.5453);
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

            float WorleyNoise(float2 uv) {
                uv *= 10.0; // Now the space is 10x10 instead of 1x1. Change this to any number you want.
                float2 uvInt = floor(uv);
                float2 uvFract = frac(uv);
                float minDist = 1.0; // Minimum distance initialized to max.
                for(int y = -1; y <= 1; ++y) {
                    for(int x = -1; x <= 1; ++x) {
                        float2 neighbor = float2(float(x), float(y)); // Direction in which neighbor cell lies
                        float2 p = noise2Dv(uvInt + neighbor); // Get the Voronoi centerpoint for the neighboring cell
                        float2 diff = neighbor + p - uvFract; // Distance between fragment coord and neighbor’s Voronoi point
                        float dist = length(diff);
                        minDist = min(minDist, dist);
                    }
                }
                return minDist;
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

            float bias(float t, float b) {
                return (t / ((((1.0 / b) - 2.0) * (1.0 - t)) + 1.0));
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
                if (smallCircle1 < 0.0) {
                    if (smallCircle1 < -0.008) {
                        color = largeCircleColor;
                    }
                    else {
                        color = float4(0.0, 0.0, 0.0, 0.0);
                    }
                }
                float smallCircle2 = sdCirclePos(gridUV, pos + float2(-1.3, -0.5), 0.04);
                if (smallCircle2 < 0.0) {
                    if (smallCircle2 < -0.008) {
                        color = smallCircleColor;
                    }
                    else {
                        color = float4(0.0, 0.0, 0.0, 0.0);
                    }
                }

                return color;
            }

            float4 frag (v2f_img input) : COLOR
            {
                float horizontal[9] = { -1.0, 0.0, 1.0,
                                        -2.0, 0.0, 2.0,
                                        -1.0, 0.0, 1.0 
                                      };  

            
                float vertical[9] = { 1.0, 2.0, 1.0,
                                      0.0, 0.0, 0.0,
                                      -1.0, -2.0, -1.0 
                                    }; 

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

                // // Outline pass to determine whether or not to draw asset
                // float deltaOffset = WorleyNoise(50.0 * texUV.xy) * 0.025;
                // float2 delta = float2(0.002 + deltaOffset, 0.002); // outline thickness
                // float4 horizontalSum = float4(0.0, 0.0, 0.0, 0.0);
                // float4 verticalSum = float4(0.0, 0.0, 0.0, 0.0);
                
                // for (int i = -1; i <= 1; i++) {
                //     for (int j = -1; j <= 1; j++) {
                //         // Matrix coordinates
                //         int kx = i + 1;
                //         int ky = j + 1;

                //         // Get current UV coordinate
                //         float2 offset = float2(i, j);

                //         // Sample input texture
                //         horizontalSum += tex2D(_MainTex, (texUV - offset * delta)) * horizontal[kx + 3 * ky];
                //         verticalSum += tex2D(_MainTex, (texUV - offset * delta)) * vertical[kx + 3 * ky];
                //     }
                // }
                
                // float4 sum = sqrt(horizontalSum * horizontalSum + verticalSum * verticalSum);
                // float3 outlineColor = float3(0.0, 0.0, 0.0);
                // if (length(sum) >= 0.5) outlineColor = float3(1.0, 0.0, 0.0);
                
                // // Horizontal lines
                // float u = fmod(texUV.y, 0.01);
                // float fbm = fbm2D(100.0 * texUV.xy);
                // if (u < 0.002 && u > 0.0) {
                //     if (distance(color, float4(1.0, 0.9, 0.7, 1.0)) <= 0.2 || distance(color, MOUNTAIN_COLOR) <= 0.5 || distance(color, FOREST_COLOR) <= 0.5) {
                //         //col = vec3(0.68, 0.54, 0.39);
                //     }
                //     else {
                //         if (distance(outlineColor, float3(1.0, 0.0, 0.0)) <= 0.5) {
                //             color = lerp(float4(0.0, 0.0, 0.0, 1.0), float4(0.74, 0.76, 0.89, 1.0), bias(fbm, 0.65)); 
                //         }       
                //     }
                // }
                
                return color;
            }
            ENDCG
        }
    }
}