using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HexCell : MonoBehaviour
{

    public bool is_cell_collapsed = false;
    public int entropy;
    public Tile tile;
    public int x;
    public int z;

    public List<TileInterface> available_tiles; // tiles available to be placed in this cell

    public Vector2 getPosition()
    {
        return new Vector2(x, z);
    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void setTilePrefabs(List<TileInterface> t_prefabs)
    {
        this.available_tiles = new List<TileInterface>();
        foreach (TileInterface t in t_prefabs)
        {
            this.available_tiles.Add(t);
        }
    }

    public void collapseCell(TileInterface t)
    {
        
        this.tile = Instantiate<Tile>(t.prefab);
        //Debug.Log("Rotation before: " + this.tile.transform.rotation);
        this.tile.transform.SetParent(transform, false);
        this.tile.transform.rotation = Quaternion.AngleAxis(-90 + t.rotateAngle, Vector3.up);
        //Debug.Log("Rotation after: " + this.tile.transform.rotation);
        this.is_cell_collapsed = true;
        this.entropy = 1000000;
        //Debug.Log("Cell : (" + this.x + ", " + this.z + ")");
        //foreach (HexMetrics.NeighborDirections edge in t.edge_map.Keys)
        //{
        //    Debug.Log("Direction: " + edge + ", Feature: " + t.edge_map[edge]);
        //}
        //foreach (HexMetrics.NeighborDirections edge in t.edge_map.Keys)
        //{
        //    Debug.Log("Direction: " + edge + ", Feature: " + t.edge_map[edge]);
        //}


        //Debug.Log("Cell Collapsed: (" + this.x + ", " + this.z +")");
    }

    public void updateEntropy(TileInterface t, HexMetrics.NeighborDirections dir)
    {
        if (this.is_cell_collapsed)
            return;
        //Debug.Log("Before Removing Tiles " + available_tiles.Count);
        //Debug.Log("Contraint direction " + dir);

        HexMetrics.TerrainFeature this_edge_feature_constraint = t.edge_map[dir];
        //Debug.Log("Contraint feature: " + this_edge_feature_constraint);

        this.available_tiles.RemoveAll(tile => tile.edge_map[HexMetrics.inverse_neighbor_dir[dir]] != this_edge_feature_constraint);
        this.entropy = this.available_tiles.Count;
        //Debug.Log("Updated entropy for (" + x + ", " + z + ") to : " + this.entropy);
        //this.available_tiles.RemoveAll(tile => tile.edge_map[dir] != this_edge_feature_constraint);
        //Debug.Log("Removed Tiles " + available_tiles.Count);

        //foreach (Tile print_tile in available_tiles)
        //{
        //    Debug.Log("Tile (" + x + ", " + z + ") in dir " + HexMetrics.inverse_neighbor_dir[dir] + ": " + print_tile.name);
        //}

        //Tile _t = this.available_tiles[Random.Range(0, available_tiles.Count - 1)];
        //Debug.Log("Filling with: " + _t.name);
        //collapseCell(_t);
        //collapseCell(this.available_tiles[1]);
    }

    
}
