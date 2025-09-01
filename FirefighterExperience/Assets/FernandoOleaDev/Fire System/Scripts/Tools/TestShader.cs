using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestShader : MonoBehaviour {

    public MeshRenderer meshRenderer;
    public Material material;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (material == null) {
            material = meshRenderer.sharedMaterial;
        }
        material.SetVector("_IgnitePosition", transform.position);
        RaycastHit hit;
        Vector3 direction = meshRenderer.transform.position - transform.position;
        if (Physics.Raycast(transform.position, direction, out hit, Mathf.Infinity)) {
            material.SetVector("TextCoords", hit.textureCoord2);
        }
    }

    
}
