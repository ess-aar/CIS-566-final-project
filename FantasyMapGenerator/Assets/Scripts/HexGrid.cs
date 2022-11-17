using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HexGrid : MonoBehaviour
{

    public int width = 10;
    public int height = 10;
	public bool is_grid_collapsed = false;
	public int collapsedCellCount = 0;
	public int max_retries = 0;

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
		this.max_retries = this.tile_prefabs.Count;
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
			Debug.Log("=================== No Tiles for Cell + (" + cell.x + ", " + cell.z + ")  :( ==================");
			this.collapsedCellCount++;
			cell.is_cell_collapsed = true;
			return null;
		}

		//Debug.Log("=================== Picking Tile for Cell + (" + cell.x + ", " + cell.z + ") ==================");

		Vector2 cell_pos = new Vector2(cell.x, cell.z);

		bool can_place_tile = true;
		TileInterface potential_tile = null;
		int num_cur_retry = 0;
		do
		{
			Random.seed = System.DateTime.Now.Millisecond;
			potential_tile = cell.available_tiles[Random.Range(0, cell.available_tiles.Count - 1)];

			foreach (HexMetrics.NeighborDirections dir in HexMetrics.neighbor_directions.Keys)
			{
				Vector2 hex_coord = HexMetrics.getNeighborOffset(dir, (int)cell_pos.y);
				hex_coord += cell_pos;

				if (hex_coord.x >= 0 && hex_coord.x < this.width && hex_coord.y >= 0 && hex_coord.y < this.height)
				{
					//Debug.Log("Cell Position Neighbor: " + hex_coord.x + " " + hex_coord.y);
					HexCell neighbor = this.cells[(int)hex_coord.x + (int)hex_coord.y * this.width];

					if (!neighbor.is_cell_collapsed)
					{

						if (!neighbor.neighboring_features[(int)potential_tile.edge_map[dir]] && neighbor.num_unique_neighboring_features == 2)
						{
							Debug.Log("Tile " + potential_tile.prefab.name+ " Rejected for Cell + (" + cell.x + ", " + cell.z + ")  :( ");
							can_place_tile = false;
							break;
						}
					}
				}
			}
			num_cur_retry++;
		}
		while (!can_place_tile && num_cur_retry < this.max_retries);

		if (num_cur_retry >= this.max_retries && !can_place_tile)
        {
			Debug.Log("Couldn't find Tile to place for Cell + (" + cell.x + ", " + cell.z + ")  :( ");
			potential_tile = null;
        }
		return potential_tile;
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
