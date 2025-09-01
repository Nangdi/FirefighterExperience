using System;
using System.Collections;
using System.Collections.Generic;
using FernandoOleaDev.FyreSystem;
using UnityEngine;

public class IgniteAreaController : MonoBehaviour {

    public Vector3 igniteOffset;
    public BurnableObject thisBurnableObject;
    public float secondsToIgnite;
    public float igniteRadious;
    
    
    private float toIgnitePercent;
    private float elapsedSecondsToIgnite;
    private float toIgnitePercentOthers;
    private float elapsedSecondsToIgniteOthers;

    private BurnableObject otherBurnable;
    private List<BurnableObject> othersBurnables = new List<BurnableObject>();

    private bool checkingToIgnite;
    private bool checkingToIgniteOthers;

    // Start is called before the first frame update
    void Start() {

    }

    // Update is called once per frame
    void Update() {
        SetOffset();
        if (checkingToIgnite) {
            CheckToIgnite();
        }
        if (checkingToIgniteOthers) {
            CheckToIgniteOthers();
        }
    }

    private void CheckToIgnite() {
        elapsedSecondsToIgnite += Time.deltaTime;
        toIgnitePercent = elapsedSecondsToIgnite / secondsToIgnite;
        if (toIgnitePercent >= 1){
            RaycastHit hit;
            Vector3 direction;
            if (otherBurnable != null) {
                //direction = thisBurnableObject.transform.position - otherBurnable.transform.position;
                //if (Physics.Raycast(thisBurnableObject.transform.position, direction, out hit)) {
                    otherBurnable.Ignite(this.transform.position);
                //}
                checkingToIgnite = false;
            }
        }
    }
    
    private void CheckToIgniteOthers() {
        elapsedSecondsToIgniteOthers += Time.deltaTime;
        toIgnitePercentOthers = elapsedSecondsToIgniteOthers / secondsToIgnite;
        if (toIgnitePercentOthers >= 1){
            othersBurnables.ForEach(othersBurnable => {
                RaycastHit hit;
                Vector3 direction = othersBurnable.transform.position - thisBurnableObject.transform.position;
                if (Physics.Raycast(thisBurnableObject.transform.position, direction, out hit)) {
                   othersBurnable.Ignite(hit.point);
                }
                checkingToIgniteOthers = false;
            });
        }
    }

    private void SetOffset() {
        transform.position = transform.parent.position + igniteOffset;
        GetComponent<SphereCollider>().center = -igniteOffset;
    }

    private void OnTriggerEnter(Collider other) {
        if (otherBurnable != null) {
            return;
        }
        otherBurnable = other.gameObject.GetComponent<BurnableObject>();
        if (otherBurnable != null && (thisBurnableObject.IsBurning() && !thisBurnableObject.IsBurnedUp() )&& (!otherBurnable.IsBurning()&& !otherBurnable.IsBurnedUp())) {
            checkingToIgnite = true;
        }
    }

    private void OnTriggerExit(Collider other) {
        if (otherBurnable == other.gameObject.GetComponent<BurnableObject>()) {
            otherBurnable = null;
            checkingToIgnite = false;
            elapsedSecondsToIgnite = 0;
        } else {
            return;
        }
    }

    public void OnIgniteCheck() {
        Collider[] hitColliders = Physics.OverlapSphere(transform.position, igniteRadious);
        foreach (var hitCollider in hitColliders) {
            CheckBurnableCollider(hitCollider);
            checkingToIgniteOthers = true;
        }
    }

    private void CheckBurnableCollider(Collider collider) {
        BurnableObject burnable = collider.gameObject.GetComponent<BurnableObject>();
        if (burnable != null && (thisBurnableObject.IsBurning() && !thisBurnableObject.IsBurnedUp() )&& (!burnable.IsBurning()&& !burnable.IsBurnedUp() && !othersBurnables.Contains(burnable))) {
            othersBurnables.Add(burnable);
        }
    }
}
