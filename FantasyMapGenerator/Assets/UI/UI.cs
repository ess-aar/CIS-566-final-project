using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class UI : MonoBehaviour
{

    public WFC wfc_engine;

    private void OnEnable()
    {
        VisualElement root = GetComponent<UIDocument>().rootVisualElement;

        Button button_restart = root.Q<Button>("RestartButton");
        Button button_clear = root.Q<Button>("ClearButton");

        button_restart.clicked += () => wfc_engine.initiateRestart();
        button_clear.clicked += () => wfc_engine.initiateClear();
    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
