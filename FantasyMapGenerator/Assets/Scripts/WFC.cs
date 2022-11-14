using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WFC : MonoBehaviour
{

    public HexGrid grid;
    public Tile[] tile_prefabs;
    public int num_seeds = 0;



    // Start is called before the first frame update
    void Start()
    {
        generateTileEdgeData();
        this.grid.SetupGrid(tile_prefabs);

        //num_seeds = Random.Range(1, 5);
        //num_seeds = 4;
        generateSeeds();

        performWFC();
        //testFillGrid();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void generateTileEdgeData()
    {
        for (int i = 0; i < 7; ++i)
        {
            tile_prefabs[i].GenerateTileEdgeFeatures();
        }
    }

    void generateSeeds()
    {

        for (int i = 0; i < num_seeds; ++i)
        {
            int rand_index = Random.Range(0, tile_prefabs.Length - 1);
            //int rand_index = 3;
            Tile t = tile_prefabs[rand_index];
            //Debug.Log("Tile Selected as Seed: " + rand_index);

            Vector2 this_cell_pos = new Vector2(Random.Range(0, this.grid.width - 1), Random.Range(0, this.grid.height - 1));
            //Vector2 this_cell_pos = new Vector2(2, 2);
            //Debug.Log("Seed Position: " + this_cell_pos.x + " " + this_cell_pos.y);

            if (!this.grid.cells[(int)this_cell_pos.x + (int)this_cell_pos.y * this.grid.width].is_cell_collapsed) {

                // collapse cell
                this.grid.cells[(int)this_cell_pos.x + (int)this_cell_pos.y * this.grid.width].collapseCell(t);
                this.grid.collapsedCellCount++;
                //this.grid.cells[(int)this_cell_pos.x + (int)this_cell_pos.y * this.grid.width].collapseCell(tile_prefabs[0]);

                // propogate entropy
                this.grid.propagate(t, this_cell_pos);
            }
        }
    }

    void performWFC()
    {
        //while (!this.grid.is_grid_collapsed)
        for(int i = 0; i < (int)(this.grid.height * this.grid.width); i++)
        {
            //Debug.Log("============== LOOP " + i + " =============");
            // get cells with the minimum entropy this iteration
            List<HexCell> cells_to_collapse = this.grid.getCellsWithMinEntropy();
            //Debug.Log("Cells to collapse: " + cells_to_collapse.Count);

            if (cells_to_collapse.Count == 0)
                break;

            foreach (HexCell cell in cells_to_collapse)
            {
                // pick tile based on rules and neighbors
                Tile tile_to_instantiate = this.grid.pickTileToInstantiate(cell);

                if (tile_to_instantiate == null)
                    break;

                // collapse each cell
                cell.collapseCell(tile_to_instantiate);
                this.grid.collapsedCellCount++;

                // propogate entropy decrease to neighbors
                this.grid.propagate(tile_to_instantiate, cell.getPosition());
            }
            this.grid.checkIfGridIsCollapsed();
        }
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
}
