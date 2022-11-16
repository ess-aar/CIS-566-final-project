using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HexGrid : MonoBehaviour
{

    public int width = 10;
    public int height = 10;
	public bool is_grid_collapsed = false;
	public int collapsedCellCount = 0;

	public HexCell cellPrefab;

    public HexCell[] cells;
	public List<TileInterface> tile_prefabs;

	void Awake()
	{
		// create new hecx prefabs spanning the grid
		cells = new HexCell[height * width];
	}

	public void SetupGrid(TileInterface[] t_prefabs)
	{
		this.tile_prefabs = new List<TileInterface>();
		foreach (TileInterface t in t_prefabs)
		{
			this.tile_prefabs.Add(t);
        }
        //Debug.Log("Grid Tile Prefabs Length: " + this.tile_prefabs.Count);

        for (int z = 0, i = 0; z < height; z++)
		{
			for (int x = 0; x < width; x++)
			{
				// create cell and set the position of this instance
				CreateCell(x, z, i++);
			}
		}
    }

	public void CreateCell(int x, int z, int i)
	{
		Vector3 position;
		
		position.y = 0f;
		position.z = z * (HexMetrics.outer_radius * 1.5f);
		position.x = (x + z * 0.5f - z / 2) * (HexMetrics.inner_radius * 2f);
        //position.z = z * 2f;
        //position.x = x * 2f;

        HexCell cell = cells[i] = Instantiate<HexCell>(cellPrefab);
        //cell.x = x - z / 2;
        //cell.x = x - (z - (z & 1)) / 2;
        cell.x = x;
        cell.z = z;
		cell.transform.SetParent(transform, false);
		cell.transform.localPosition = position;
		cells[i].setTilePrefabs(this.tile_prefabs);
		cell.entropy = this.tile_prefabs.Count;
		
	}

	public List<HexCell> getCellsWithMinEntropy()
	{
		List<HexCell> cells_with_min_entropy = new List<HexCell>();
		int min_entropy = 100000000;
		for (int i = 0; i < this.height * this.width; i++)
		{
			if (cells[i].entropy < min_entropy && !cells[i].is_cell_collapsed)
			{
				min_entropy = cells[i].entropy;
			}
		}
		//Debug.Log("Min entropy: " + min_entropy);
		for (int i = 0; i < this.height * this.width; i++)
		{
			if (cells[i].entropy == min_entropy && !cells[i].is_cell_collapsed)
			{
				//Debug.Log("Cell to Collapse: (" + cells[i].x + ", " + cells[i].z + ")");
				cells_with_min_entropy.Add(cells[i]);
			}
		}
		return cells_with_min_entropy;
	}

	public TileInterface pickTileToInstantiate(HexCell cell)
    {
		if (cell.available_tiles.Count == 0)
		{
			this.collapsedCellCount++;
			cell.is_cell_collapsed = true;
			return null;
		}

		return cell.available_tiles[Random.Range(0, cell.available_tiles.Count - 1)];
    }

	public void propagate(TileInterface t, Vector2 cell_pos)
    {
		foreach (HexMetrics.NeighborDirections dir in HexMetrics.neighbor_directions.Keys)
		{
			Vector2 hex_coord = HexMetrics.getNeighborOffset(dir, (int)cell_pos.y);
			hex_coord += cell_pos;

			if (hex_coord.x >= 0 && hex_coord.x < this.width && hex_coord.y >= 0 && hex_coord.y < this.height)
			{
				//Debug.Log("Cell Position Neighbor: " + hex_coord.x + " " + hex_coord.y);
				this.cells[(int)hex_coord.x + (int)hex_coord.y * this.width].updateEntropy(t, dir);
			}
		}
	}

	public bool checkIfGridIsCollapsed()
    {
		return collapsedCellCount == height * width;

	}
}
