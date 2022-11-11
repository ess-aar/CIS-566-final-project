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

            // TODO: fIxXXX

            Debug.Log("Direction:  " + dir);
            Vector2 uvs = HexMetrics.direction_to_textureUV[dir];
            Color color = ((Texture2D)this.GetComponent<Renderer>().sharedMaterial.mainTexture).GetPixel((int)uvs.x, (int)uvs.y);
            Vector3 col = new Vector3(color.r, color.g, color.b);


            Debug.Log("Color:  " + col);
            //edge_map[dir] = HexMetrics.color_to_feature[col];
            Vector3 land_col = new Vector3(0.807843137254902f, 0.909803921568627f, 0.513725490196078f);
            //Vector3 land_col = new Vector3(0.81f, 0.91f, 0.51f);
            Vector3 water_col = new Vector3(0.537f, 0.894f, 0.969f);
            if (col == land_col)
            {
                Debug.Log("Land");
                edge_map[dir] = HexMetrics.TerrainFeature.Land;
                Debug.Log("Edge Feature: " + dir + " " + edge_map[dir]);
            }
            else if (col.Equals(water_col))
            {
                Debug.Log("Water");
                edge_map[dir] = HexMetrics.TerrainFeature.Water;
                Debug.Log("Edge Feature: " + dir + " " + edge_map[dir]);
            }
            Debug.Log("Done!");
        }

        // get color of texture at edge
        //Color col = ((Texture2D) this.GetComponent<Renderer>().sharedMaterial.mainTexture).GetPixel(256, 256);
        
        //Debug.Log("Texture Color" + col);
    }
}
