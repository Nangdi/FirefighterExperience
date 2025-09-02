using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class IgniteSwitch : MonoBehaviour
{
    public float igniteTime = 5;
    public float invisibleTime = 7;
    public float elapsedTime;
    private bool ignite = false;

    private ParticleSystem particleSystem;
    private void Awake()
    {
        TryGetComponent(out particleSystem);
    }
    private void OnEnable()
    {
        GameManager.instance.onGameEnd += ResetData;
    }
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (!GameManager.instance.startGame) return;
        
        elapsedTime += Time.deltaTime;
        if(elapsedTime >= igniteTime && !ignite)
        {
            if(ignite == false)
            {
                //점화
                ignite = true;
            }
        }
        if(elapsedTime >= invisibleTime && particleSystem.isPlaying)
        {
            //연기스탑
            StartCoroutine(StopSmoke_co());
            // alpha 값 서서히 내려서 없애기

        }
    }
    public void ResetData()
    {
        ignite = false;
        elapsedTime = 0;
        SetColorAlpha(1);
        StartCoroutine(StopSmoke_co());
    }
    private IEnumerator StopSmoke_co()
    {
         SetColorAlpha(0);
         yield return new WaitForSeconds(2);
        particleSystem.Stop();

    }
    public void IgniteSmoke()
    {
        particleSystem.Play();
    }
    private void SetColorAlpha(float value)
    {
        var main = particleSystem.main;
        Color c = main.startColor.color;
        c.a = value;
        main.startColor = c;
    }
    private void OnDisable()
    {
        GameManager.instance.onGameEnd -= ResetData;
    }
}
