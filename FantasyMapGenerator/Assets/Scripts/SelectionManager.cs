using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class SelectionManager : MonoBehaviour
{
    public Camera cam;
    public Material selectionMaterial;
    public Image seedUIImage;
    public List<Tile> tilePrefabs;
    public List<Sprite> sprites;
    private int activeTileIdx = 0;
    private List<HexCell> selection = new List<HexCell>();
    private Coroutine selectionRoutine;

    void Update()
    {   
        if(Input.GetKeyUp(KeyCode.Tab))
        {
            activeTileIdx = (activeTileIdx + 1) % tilePrefabs.Count;
            Debug.Log("====== " + tilePrefabs[activeTileIdx].name + " =======");
            seedUIImage.sprite = sprites[activeTileIdx];
        }

        if(Input.GetMouseButtonDown(0))
        {
            Debug.Log("Start!");
            StartSelection(); 
        }

        if(Input.GetMouseButtonUp(0))
        {
            EndSelection();
            Debug.Log("End!");
        }

        if(Input.GetKeyUp(KeyCode.Return))
        {
            Destroy(seedUIImage);
        }
    }

    public void changeSeed()
    {
        activeTileIdx = (activeTileIdx + 1) % tilePrefabs.Count;
        Debug.Log("====== " + tilePrefabs[activeTileIdx].name + " =======");
        seedUIImage.sprite = sprites[activeTileIdx];
    }

    public List<HexCell> getSeeds()
    {
      return selection;
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
        Debug.Log("Starting coroutine");
        
        while(true)
        {
            var ray = cam.ScreenPointToRay(Input.mousePosition);
         
            if(Physics.Raycast(ray, out var hit))
            {
                // Debug.Log("Raycast: " + hit.transform);
                // hit.transform.GetComponent<Renderer>().material = selectionMaterial;
                var cell = hit.transform.GetComponent<HexCell>();
                cell.fillCell(tilePrefabs[activeTileIdx]);
                // cell.tile.GetComponent<Renderer>().material = selectionMaterial;
                Debug.Log("Raycast: " + cell.x + ", " + cell.z);
                if(!selection.Contains(cell)) selection.Add(cell);
            }
    
            yield return null;
        }
    }
}
