using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tile : MonoBehaviour
{

    public int edge_0 = 0;
    public Dictionary<HexMetrics.NeighborDirections, HexMetrics.TerrainFeature> edge_map = new Dictionary<HexMetrics.NeighborDirections, HexMetrics.TerrainFeature>();
    
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void GenerateTileEdgeFeatures()
    {
        foreach(HexMetrics.NeighborDirections dir in HexMetrics.direction_to_textureUV.Keys)
        {

            Vector2 uvs = HexMetrics.direction_to_textureUV[dir];
            Color color = ((Texture2D)this.GetComponent<Renderer>().sharedMaterial.mainTexture).GetPixel((int)uvs.x, (int)uvs.y);
            edge_map[dir] = HexMetrics.color_to_feature[color];
        }
    }
}
