using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestClosestPoint : MonoBehaviour {

    [SerializeField] private Collider otherCollider;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnDrawGizmos() {
        if (otherCollider == null) {
            return;
        }
        Vector3 closestPosint = Physics.ClosestPoint(transform.position, otherCollider, otherCollider.transform.position, otherCollider.transform.rotation);
        Gizmos.color = Color.magenta;
        Gizmos.DrawSphere(closestPosint, 0.01f);
    }
}
