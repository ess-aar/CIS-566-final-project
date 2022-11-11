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
}
