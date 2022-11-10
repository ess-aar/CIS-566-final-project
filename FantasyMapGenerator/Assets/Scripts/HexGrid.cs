using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HexGrid : MonoBehaviour
{

    public int width = 10;
    public int height = 10;

	public HexCell[] cellPrefab;

    HexCell[] cells;

	void Awake()
	{
		// create new hecx prefabs spanning the grid
		cells = new HexCell[height * width];

		for (int z = 0, i = 0; z < height; z++)
		{
			for (int x = 0; x < width; x++)
			{

				// create cell and set the position of this instance
				CreateCell(x, z, i++);
			}
		}
	}

	void CreateCell(int x, int z, int i)
	{
		Vector3 position;
		
		position.y = 0f;
		position.z = z * (HexMetrics.outer_radius * 1.5f);
		position.x = (x + z * 0.5f - z / 2) * (HexMetrics.inner_radius * 2f);
        //position.z = z * 2f;
        //position.x = x * 2f;

        HexCell cell = cells[i] = Instantiate<HexCell>(cellPrefab[Random.Range(0,6)]);
		cell.transform.SetParent(transform, false);
		cell.transform.localPosition = position;
	}

}
