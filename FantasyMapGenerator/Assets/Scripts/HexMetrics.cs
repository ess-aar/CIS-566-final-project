using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HexMetrics : MonoBehaviour
{
	public const float outer_radius = 1f;
	public const float inner_radius = outer_radius * 0.866025404f;
	public enum NeighborDirections { Left, Right, Upper_Left, Upper_Right, Lower_Left, Lower_Right };

    public Dictionary<NeighborDirections, Vector2> neighbor_directions = new Dictionary<NeighborDirections, Vector2>
    {
        { NeighborDirections.Left, new Vector2(-1, 0) },
        //new Vector2(1, 0),
        //new Vector2(0, 1),
        //new Vector2(1, 1),
        //new Vector2(0, -1),
        //new Vector2(1, -1)
    };


    public enum TerrainFeature { Water, Land };

    public static Dictionary<Color, TerrainFeature> color_to_feature = new Dictionary<Color, TerrainFeature>
    {
        { new Color(0.808f, 0.910f, 0.514f, 1f), TerrainFeature.Land },
        { new Color(0.537f, 0.894f, 0.969f, 1f), TerrainFeature.Water },
    };

    public static Dictionary<NeighborDirections, Vector2> direction_to_textureUV = new Dictionary<NeighborDirections, Vector2>
    {
        { NeighborDirections.Left, new Vector2(51, 256) },
        { NeighborDirections.Right, new Vector2(460, 256) },
        { NeighborDirections.Upper_Left, new Vector2(153, 410) },
        { NeighborDirections.Upper_Right, new Vector2(384, 410) },
        { NeighborDirections.Lower_Left, new Vector2(153, 102) },
        { NeighborDirections.Lower_Right, new Vector2(384, 102) }
    };
}
