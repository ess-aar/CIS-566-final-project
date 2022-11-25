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
            #define SCATTER_GRID_SIZE 10.0

            float noise2Df(float2 p) {
                return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
            }

            float sdCircle(float2 p, float r)
            {
                return length(p) - r;
            }

            float4 placeMountains(float4 baseColor, float2 cellCoord, float2 gridId)
            {
                // Place a circular sample randomly within each cell
                for (int y = -1; y <= 1; ++y) {
                    for (int x = -1; x <= 1; ++x) {
                        float2 neighborOffset = float2(x, y);
                        float jitter = noise2Df(gridId + neighborOffset);
                        float2 uvOffset = float2(jitter, frac(10.0 * jitter)) - float2(0.5, 0.5);
                        float d = sdCircle(cellCoord - neighborOffset - uvOffset, 0.15);
                        if (d < 0.0) {
                            return float4(1.0, 0.0, 0.0, 1.0);
                        }
                    }
                }

                return baseColor;
            }

            float4 frag (v2f_img input) : COLOR
            {
                // Get uv coordinates
                float2 texUV = input.uv;
                //float2 gridUV = input.uv; // TODO: divide UV by screen dims to avoid stretching

                float2 fragCoord = input.uv * _ScreenParams.xy;
                float2 gridUV = (2.0 * fragCoord.xy - _ScreenParams.xy) / _ScreenParams.y;
                
                // Sample color texture and map color ID to final color
                float4 base = tex2D(_MainTex, texUV);
                float4 color = base;

                if (distance(base, LAND_COLOR) <= 0.55) {
                    color = float4(0.68, 0.54, 0.39, 1.0);
                    //color = float4(0.0, 1.0, 0.0, 1.0);
                }
                else if (distance(base, WATER_COLOR) <= 0.55) {
                    color = float4(0.74, 0.76, 0.89, 1.0);
                    //color = float4(0.0, 0.0, 1.0, 1.0);
                }
                else if (distance(base, MOUNTAIN_COLOR) <= 0.55) {
                    color = float4(0.71, 0.54, 0.39, 1.0);
                }
                else if (distance(base, FOREST_COLOR) <= 0.55) {
                    color = float4(0.54, 0.76, 0.49, 1.0);
                }

                // Scatter assets over the map
                float2 cellCoord = frac(SCATTER_GRID_SIZE * gridUV) - 0.5; // remap so that middle of cell is origin
                float2 gridId = floor(SCATTER_GRID_SIZE * gridUV);

                // If the base color ID matches the mountains color, then scatter mountains
                bool drawMountains = false;
                if (distance(base, MOUNTAIN_COLOR) <= 0.5) { // this should match the feature mask color
                    drawMountains = true;
                }
                if (drawMountains) {
                    color = placeMountains(color, cellCoord, gridId);
                }  

                // Uncomment for visualizing grid values
                //color.rg += gridId * 0.1;
                //color += noise2Df(gridId);

                //if (cellCoord.x > 0.38 || cellCoord.y > 0.38) color = float4(0.4, 0.3, 1.0, 1.0);
                
                return color;
            }
            ENDCG
        }
    }
}