using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[System.Serializable]
public class SeedCell
{
    public HexCell cell;
    public HexMetrics.TerrainFeature feature;
}


public class SelectionManager : MonoBehaviour
{
    public Camera cam;
    public Material selectionMaterial;
    public Image seedUIImage;
    public List<Tile> tilePrefabs;
    public List<Sprite> sprites;
    private int activeTileIdx = 0;
    private int layerMask = 1 << 6; //LayerMask.GetMask("Cell");
    private List<SeedCell> selection = new List<SeedCell>();
    private Coroutine selectionRoutine;

    void Update()
    {   
        if(Input.GetKeyUp(KeyCode.Tab))
        {
            activeTileIdx = (activeTileIdx + 1) % tilePrefabs.Count;
            // Debug.Log("====== " + tilePrefabs[activeTileIdx].name + " =======");
            seedUIImage.sprite = sprites[activeTileIdx];
        }

        if(Input.GetKeyUp(KeyCode.Return))
        {
            Destroy(seedUIImage);
            // seedUIImage.sprite = null;
        }

    }

    void FixedUpdate()
    {
        if(Input.GetMouseButtonDown(0))
        {
            // Debug.Log("Start!");
            StartSelection(); 
        }

        if(Input.GetMouseButtonUp(0))
        {
            EndSelection();
            // Debug.Log("End!");
        }
    }

    public void changeSeed()
    {
        activeTileIdx = (activeTileIdx + 1) % tilePrefabs.Count;
        // Debug.Log("====== " + tilePrefabs[activeTileIdx].name + " =======");
        seedUIImage.sprite = sprites[activeTileIdx];
    }

    public List<SeedCell> getSeeds()
    {
      return selection;
    }

    public void clearSeeds()
    {
      foreach(var seedCell in selection)
      {
        Destroy(seedCell.cell.tile.gameObject);
      }
      selection.Clear();
      Debug.Log("seed list count = " + selection.Count);
    }

    public void resetSeedUI()
    {
      activeTileIdx = 0;
      seedUIImage.sprite = sprites[activeTileIdx];
    }

    public void StartSelection()
    {
        if(selectionRoutine != null) return;
    
        selectionRoutine = StartCoroutine (SelectionRoutine ());
    }
    
    public void EndSelection()
    {
        if(selectionRoutine == null) return;
    
        StopCoroutine (selectionRoutine);
        selectionRoutine = null;
    
        // OnSelectionChanged.Invoke(new HashSet<GameObject>(selection);
    }
    
    private IEnumerator SelectionRoutine()
    {
        // selection.Clear();
        // Debug.Log("Starting coroutine");
        
        while(true)
        {
            var ray = cam.ScreenPointToRay(Input.mousePosition);
         
            if(Physics.Raycast(ray, out var hit, 50, layerMask))
            {
                // Debug.Log("Raycast: " + hit.transform);
                // hit.transform.GetComponent<Renderer>().material = selectionMaterial;
                var cell = hit.transform.GetComponent<HexCell>();
                cell.fillCell(tilePrefabs[activeTileIdx]);
                // cell.tile.GetComponent<Renderer>().material = selectionMaterial;
                // Debug.Log("Raycast: " + cell.x + ", " + cell.z);

                var seedCell = new SeedCell();
                seedCell.cell = cell;
                seedCell.feature = (HexMetrics.TerrainFeature)activeTileIdx;

                if(!selection.Contains(seedCell)) selection.Add(seedCell);
            }
    
            yield return null;
        }
    }
}
