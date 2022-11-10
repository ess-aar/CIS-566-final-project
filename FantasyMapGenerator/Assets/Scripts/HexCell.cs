using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HexCell : MonoBehaviour
{

    public bool is_cell_collapsed = false;
    public int entropy;
    public Tile tile;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void collapseCell(Tile t)
    {
        this.tile = Instantiate<Tile>(t);
        this.tile.transform.SetParent(transform, false);
        //this.tile.transform.localPosition = transform.position;
        this.is_cell_collapsed = true;
    }
}
