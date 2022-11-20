using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class WFC : MonoBehaviour
{

    public HexGrid grid;
    public TileInterface tile_interface;
    public Tile[] original_tile_prefabs;
    public TileInterface[] tile_prefabs;
    public int num_seeds = 0;
    public int cur_iter = 0;



    // Start is called before the first frame update
    void Start()
    {
 
        generateTilesWithRotation();
        generateTileEdgeData();
        this.grid.SetupGrid(tile_prefabs);

        //num_seeds = Random.Range(1, 5);
        //num_seeds = 4;
        generateSeeds();

        InvokeRepeating("performWFC", 1.0f, 0.05f);


        //testFillGrid();
        //testAllTiles();
    }

    // Update is called once per frame
    void Update()
    {
        if (cur_iter >= (int)(this.grid.height * this.grid.width))
        {
            CancelInvoke();
        }
    }

    void generateTilesWithRotation()
    {
        for (int i = 0; i < original_tile_prefabs.Length; ++i)
        {
            List<TileInterface> new_tiles;
            new_tiles = original_tile_prefabs[i].GenerateRotatedTiles(tile_interface);
            tile_prefabs = tile_prefabs.Concat(new_tiles.ToArray()).ToArray();
        }
    }

    void generateTileEdgeData()
    {
        
        for (int i = 0; i < tile_prefabs.Length; ++i)
        {
            tile_prefabs[i].GenerateTileEdgeFeatures();
            
        }
    }

    void generateSeeds()
    {
        for (int i = 0; i < num_seeds; ++i)
        {
            bool can_use_seed = true;

            Vector2 this_cell_pos = new Vector2(Random.Range(0, this.grid.width - 1), Random.Range(0, this.grid.height - 1));
            //Vector2 this_cell_pos = new Vector2(2, 2);
            //Debug.Log("Seed Position: " + this_cell_pos.x + " " + this_cell_pos.y);
            HexCell seedCell = this.grid.cells[(int)this_cell_pos.x + (int)this_cell_pos.y * this.grid.width];

            int retries = 10;
            while (!seedCell.is_cell_collapsed)
            {
                int rand_index = Random.Range(0, seedCell.available_tiles.Count - 1);
                //int rand_index = 13;
                TileInterface t = seedCell.available_tiles[rand_index];
                //Debug.Log("Tile Selected as Seed: " + rand_index);
                
                can_use_seed = this.grid.checkPropagate(t, this_cell_pos);
                Debug.Log("can use tile : " + t.prefab.name + " at (" + this_cell_pos.x + ", " + this_cell_pos.y + ") ? " + can_use_seed);

                if(can_use_seed)
                {
                  // collapse cell
                  seedCell.collapseCell(t);
                  this.grid.collapsedCellCount++;

                  // propogate entropy
                  this.grid.propagate(t, this_cell_pos);
                }

                retries--;
                if (retries == 0)
                {
                  break;
                }
            }
        }
    }
    
    void performWFC()
    {
        //while (!this.grid.is_grid_collapsed)
        //for(int i = 0; i < (int)(this.grid.height * this.grid.width); i++)
        //{
            //Debug.Log("============== LOOP " + i + " =============");
            // get cells with the minimum entropy this iteration

        List<HexCell> cells_to_collapse = this.grid.getCellsWithMinEntropy();
        //Debug.Log("Cells to collapse: " + cells_to_collapse.Count);

        if (cells_to_collapse.Count == 0)
            return;

        foreach (HexCell cell in cells_to_collapse)
        {
            // pick tile based on rules and neighbors
            TileInterface tile_to_instantiate = this.grid.pickTileToInstantiate(cell);

            if (tile_to_instantiate == null)
                break;

            // collapse each cell
            cell.collapseCell(tile_to_instantiate);
            this.grid.collapsedCellCount++;

            // propogate entropy decrease to neighbors
            this.grid.propagate(tile_to_instantiate, cell.getPosition());
        }
        this.grid.checkIfGridIsCollapsed();
        cur_iter++;
        //}
    }

    void performWFC2()
    {
        //while (!this.grid.is_grid_collapsed)
        //for(int i = 0; i < (int)(this.grid.height * this.grid.width); i++)
        //{
            //Debug.Log("============== LOOP " + i + " =============");
            // get cells with the minimum entropy this iteration

        List<HexCell> cells_to_collapse = this.grid.getCellsWithMinEntropy();
        //Debug.Log("Cells to collapse: " + cells_to_collapse.Count);

        if (cells_to_collapse.Count == 0)
            return;

        foreach (HexCell cell in cells_to_collapse)
        {
            int retries = 100;
            // while (!cell.is_cell_collapsed)
            while (!cell.is_cell_collapsed && retries > 0)
            {
                // pick tile based on rules and neighbors
                TileInterface tile_to_instantiate = this.grid.pickTileToInstantiate(cell);

                if (tile_to_instantiate == null)
                    break;

                bool can_propagate = this.grid.checkPropagate(tile_to_instantiate, cell.getPosition());
                Debug.Log("can use tile : " + tile_to_instantiate.prefab.name + " with angle " + tile_to_instantiate.rotateAngle + " at (" + cell.getPosition().x + ", " + cell.getPosition().y + ") ? " + can_propagate);

                if (can_propagate)
                {
                    // collapse each cell
                    cell.collapseCell(tile_to_instantiate);
                    this.grid.collapsedCellCount++;

                    // propogate entropy decrease to neighbors
                    this.grid.propagate(tile_to_instantiate, cell.getPosition());
                }

                retries--;
                if(retries == 0)
                {
                  cell.entropy = 99999;
                  break;
                }
            }
        }
        this.grid.checkIfGridIsCollapsed();
        cur_iter++;
        //}
    }

    void testFillGrid()
    {
        while (!this.grid.is_grid_collapsed)
        {
            foreach(HexCell cell in this.grid.cells)
            {
                if(!cell.is_cell_collapsed)
                    cell.collapseCell(tile_prefabs[4]);
                    //cell.collapseCell(tile_prefabs[Random.Range(0, tile_prefabs.Length - 1)]);
            }
            this.grid.is_grid_collapsed = true;
        }
    }

    void testAllTiles()
    {
        for (int i = 0; i < tile_prefabs.Length; ++i)
        {
            this.grid.cells[i].collapseCell(tile_prefabs[i]);
        }
    }
}
