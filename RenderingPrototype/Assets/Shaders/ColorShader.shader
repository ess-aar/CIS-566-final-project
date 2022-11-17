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

            #define PI                3.1415926535897932384626433832795
            #define LAND_COLOR        float4(0.807843137254902f, 0.909803921568627f, 0.513725490196078f, 1.f)
            #define WATER_COLOR       float4(0.537254901960784f, 0.894117647058824f, 0.968627450980392f, 1.f)
            #define MOUNTAIN_COLOR    float4(0.470588235294118f, 0.317647058823529f, 0.156862745098039f, 1.f)
            #define SCATTER_GRID_SIZE 20.0

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
                float2 gridUV = input.uv; // TODO: change this to ndc
                
                // Sample color texture and map color ID to final color
                float4 base = tex2D(_MainTex, texUV);
                float4 color = base;

                if (distance(base, LAND_COLOR) <= 0.5) {
                    color = float4(0.73, 0.58, 0.39, 1.0);
                }
                else if (distance(base, WATER_COLOR) <= 0.5) {
                    color = float4(0.74, 0.76, 0.69, 1.0);
                }

                // Scatter assets over the map
                float2 cellCoord = frac(SCATTER_GRID_SIZE * gridUV) - 0.5; // remap so that middle of cell is origin
                float2 gridId = floor(SCATTER_GRID_SIZE * gridUV);

                // If the base color ID matches the mountains color, then scatter mountains
                bool drawMountains = false;
                if (distance(base, LAND_COLOR) <= 0.5) { // this should match the feature mask color
                    drawMountains = true;
                }
                if (drawMountains) {
                    color = placeMountains(color, cellCoord, gridId);
                }  

                // Uncomment for visualizing grid values
                //color.rg += gridId * 0.1;
                //color += noise2Df(gridId);

                //if (cellCoord.x > 0.38 || cellCoord.y > 0.38) color = float4(0.4, 0.3, 1.0, 1.0);
                
                return color; // * fbm2D(10.0 * input.uv); // TODO: divide UV by screen dims to avoid stretching
            }
            ENDCG
        }
    }
}
