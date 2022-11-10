using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WFC : MonoBehaviour
{

    public HexGrid grid;
    public Tile[] tile_prefabs;



    // Start is called before the first frame update
    void Start()
    {
        performWFC();
        //grid = gameObject.GetComponent(typeof(HexGrid)) as HexGrid;
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void performWFC()
    {
        while (!this.grid.is_grid_collapsed)
        {
            for (int i = 0; i < this.grid.height * this.grid.width; ++i)
            {
                //int z = i / this.grid.width;
                //int x = i % this.grid.width;
                //this.grid.CreateCell(x, z, i);
                this.grid.cells[i].collapseCell(tile_prefabs[Random.Range(0, tile_prefabs.Length)]);
                
            }
            this.grid.is_grid_collapsed = true;
        }
    }
}
