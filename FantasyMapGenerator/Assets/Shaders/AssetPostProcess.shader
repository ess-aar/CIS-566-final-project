Shader "Hidden/AssetPostProcess"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_CameraPos ("camera_position", Vector) = (0,0,0,0)
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
			uniform float4 _CameraPos;
			uniform float4x4 _InvCamProjMatrix;

            #define PI                 3.1415926535897932384626433832795
            #define LAND_COLOR         float4(0.f, 1.f, 0.f, 1.f)
            #define WATER_COLOR        float4(0.f, 0.f, 1.f, 1.f)
            #define MOUNTAIN_COLOR     float4(1.f, 0.f, 0.f, 1.f)
            #define FOREST_COLOR       float4(1.f, 1.f, 0.f, 1.f)
            #define MOUNTAIN_GRID_SIZE 5.0
            #define MOUNTAINS_PER_CELL 7
            #define FOREST_GRID_SIZE   6.0
            #define TREES_PER_CELL     10

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

            float sdCircle(float2 p, float r)
            {
                return length(p) - r;
            }

            float sdSegment(in float2 p, in float2 a, in float2 b)
            {
                float2 pa = p - a;
                float2 ba = b - a;
                float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
                return length(pa - ba * h);
            }

            float sdEgg(in float2 p, in float ra, in float rb)
            {
                const float k = sqrt(3.0);
                p.x = abs(p.x);
                float r = ra - rb;
                return ((p.y<0.0)       ? length(float2(p.x,  p.y    )) - r :
                        (k*(p.x+r)<p.y) ? length(float2(p.x,  p.y-k*r)) :
                                        length(float2(p.x+r,p.y    )) - 2.0*r) - rb;
            }

            float sdUnevenCapsule(float2 p, float r1, float r2, float h)
            {
                p.x = abs(p.x);
                float b = (r1-r2)/h;
                float a = sqrt(1.0-b*b);
                float k = dot(p,float2(-b,a));
                if( k < 0.0 ) return length(p) - r1;
                if( k > a*h ) return length(p-float2(0.0,h)) - r2;
                return dot(p, float2(a,b) ) - r1;
            }

            float triangleArea(float2 a, float2 b, float2 c)
            {
                return abs(a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y)) * 0.5;
            }

            bool pointInTriangle(float2 p, float2 a, float2 b, float2 c)
            {
                float totalArea = triangleArea(a, b, c);
                float sum = 0.0;
                
                sum += triangleArea(p, a, b);
                sum += triangleArea(p, a, c);
                sum += triangleArea(p, b, c);
                
                if (totalArea >= sum - 0.001) return true;
                
                return false;
            }

            float mountainOutlineSDF(float2 uv, float2 p, float s, float thickness)
            {    
                // Find distance to vertices and distance to midpoints
                float distToVertex = 0.33 * (s * 1.73);
                float distToMidpoint = 0.04 * (s * 1.73); // change (1.0 / 25.0) to some other number for height
                
                // Find vertices of equilateral triangle
                float2 A = p + float2(0.0, distToVertex);
                float2 B = p + float2(s * 0.5, distToMidpoint);
                float2 C = p + float2(-s * 0.5, distToMidpoint);
                
                // Outline segments
                float f = sdSegment(uv, A, B);
                float g = sdSegment(uv, A, C);
                float dMin = min(f, g);
                
                if (dMin < thickness) return dMin;
                
                return -1.0;
            }

            float4 drawMountain(in float3 baseCol, float2 uv, float2 p, float sideLength, float thickness)
            {                
                // Find distance to vertices and distance to midpoints
                float distToVertex = 0.33 * (sideLength * 1.73);
                float distToMidpoint = 0.04 * (sideLength * 1.73); // change 25.0 to some other number for height
                
                // Find vertices of equilateral triangle
                float2 A = p + float2(0.0, distToVertex);
                float2 B = p + float2(sideLength * 0.5, distToMidpoint);
                float2 C = p + float2(-sideLength * 0.5, distToMidpoint);
                
                // Background color is map "paper" color
                float3 col = baseCol;
                float jitter = noise1Df(50.0 * uv.y) * 0.008;
                
                if (pointInTriangle(uv, A, B, C)) {
                    if (uv.x < p.x - jitter && uv.x > C.x) {  
                        float t = (uv.x - C.x) / (p.x - jitter - C.x);                       
                        float3 fadeColor = lerp(col, float3(0.3, 0.3, 0.3) * col, t);
                        col = fadeColor;
                    }
                    else {
                        col = float4(0.93, 0.75, 0.55, 1.0);
                    }      
                }
                
                return float4(col.xyz, 1.0);
            }

            //float4 placeMountains(float4 baseColor, float2 cellCoord, float2 gridId)
            float4 placeMountains(float4 baseColor, float2 uv, float2 gridId)
            {
                float4 col = baseColor;
                // Place a circular sample randomly within each cell
                for (int n = 0; n < MOUNTAINS_PER_CELL; ++n) {
                    float r = rand(float2(n, n));
                    float jitterScale = 10.0 * noise1Df(float(n)) + 10.0;
                    for (int y = -1; y <= 1; ++y) {
                        for (int x = -1; x <= 1; ++x) {
                            float2 neighborOffset = float2(x, y);
                            float jitter = noise2Df(gridId + neighborOffset + r);
                            float2 uvOffset = float2(jitter, frac(jitterScale * jitter)) - float2(0.5, 0.5);
                            //uvOffset = vec2(r, yValues[n]) - vec2(0.5);
                            col = drawMountain(col, MOUNTAIN_GRID_SIZE * uv, gridId + uvOffset + neighborOffset, 0.5, 0.01);
                            float e = mountainOutlineSDF(MOUNTAIN_GRID_SIZE * uv, gridId + uvOffset + neighborOffset, 0.5, 0.01);
                            if (e > 0.0) col = lerp(col, float4(0.0, 0.0, 0.0, 0.0), 1.0);
                        }
                    }
                }

                return col;
            }

            float4 drawTree(in float4 baseCol, float2 uv, float2 gridId, float ra, in float rb)
            {
                float4 col = baseCol;

                float leaves_sdf = sdEgg( uv - gridId, 0.09, 0.01 );
                float tree_sdf = sdUnevenCapsule( uv - gridId + float2(0, 0.2), 0.02, 0.02, 0.175 );
                float min_sdf = min(tree_sdf, leaves_sdf);
                
                if (min_sdf <= 0.0) {
                    col = float4(0, 0, 0, 0);
                    if (leaves_sdf < -0.025 || tree_sdf < -0.015) {
                        if (uv.x < gridId.x) {
                            
                            col = lerp(float4(0.4, 0.4, 0.4, 1.0), baseCol,  1.0 - (gridId.x - uv.x) * 15.0);
                        }
                        else {
                            col = float4(0.9, 0.93, 0.7, 1.0);
                        }
                    }
                }
                
                return col;
            }

            float4 placeTrees(float4 baseColor, float2 uv, float2 gridId)
            {
                float4 col = baseColor;
                // Place a circular sample randomly within each cell
                for (int n = 0; n < TREES_PER_CELL; ++n) {
                    float r = rand(float2(n, n));
                    float jitterScale = 10.0 * noise1Df(float(n)) + 10.0;
                    for (int y = -1; y <= 1; ++y) {
                        for (int x = -1; x <= 1; ++x) {
                            float2 neighborOffset = float2(x, y);
                            float jitter = noise2Df(gridId + neighborOffset + r);
                            float2 uvOffset = float2(jitter, frac(jitterScale * jitter)) - float2(0.5, 0.5);
                            //uvOffset = vec2(r, yValues[n]) - vec2(0.5);
                            col = drawTree(col, FOREST_GRID_SIZE * uv, gridId + uvOffset + neighborOffset, 0.0, 0.0);
                        }
                    }
                }

                return col;
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

                if (distance(base, MOUNTAIN_COLOR) <= 0.5) {
                    color = float4(0.93, 0.75, 0.55, 1.0);
                }
                if (distance(base, FOREST_COLOR) <= 0.5) {
                    color = float4(0.9, 0.93, 0.7, 1.0);
                }

                // Scatter assets over the map
                float2 cellCoordMountain = frac(MOUNTAIN_GRID_SIZE * gridUV) - 0.5; // remap so that middle of cell is origin
                float2 gridIdMountain = floor(MOUNTAIN_GRID_SIZE * gridUV);

                float2 cellCoordTree = frac(FOREST_GRID_SIZE * gridUV) - 0.5; // remap so that middle of cell is origin
                float2 gridIdTree = floor(FOREST_GRID_SIZE * gridUV);

                // If the base color ID matches the mountains color, then scatter mountains
                bool drawMountains = false;
                bool drawTrees = false;

                if (distance(base, MOUNTAIN_COLOR) <= 0.5) { // this should match the feature mask color
                    drawMountains = true;
                }
                else if (distance(base, FOREST_COLOR) <= 0.5) {
                    drawTrees = true;
                }

                if (drawMountains) {
                    color = placeMountains(color, gridUV, gridIdMountain);
                }  
                if (drawTrees) {
                    color = placeTrees(color, gridUV, gridIdTree);
                }

                // Uncomment for visualizing grid values
                //color.rg += gridId * 0.1;
                //color += noise2Df(gridId);

                //if (cellCoord.x > 0.38 || cellCoord.y > 0.38) color = float4(0.4, 0.3, 1.0, 1.0);

                // Uncomment for test mountain
                // color = float4(1.0, 1.0, 1.0, 1.0);
                // color = drawMountain(color, SCATTER_GRID_SIZE * gridUV, float2(0.0, 0.0), 0.5, 0.01);
                // float e = mountainOutlineSDF(SCATTER_GRID_SIZE * gridUV, float2(0.0, 0.0), 0.5, 0.01);
                // if (e > 0.0) color = lerp(color, float4(0.0, 0.0, 0.0, 0.0), 1.0);
                
                // FBM pass for paper look
                float fbm = pow(fbm2D(5.0 * gridUV), 1.0);

                return color * fbm;
            }
            ENDCG
        }
    }
}