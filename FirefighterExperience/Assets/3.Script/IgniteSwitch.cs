using FernandoOleaDev.FyreSystem;
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
    private bool startSmoke = false;
    private ParticleSystem particleSystem;

    [SerializeField] private BurnableObject tartgetBurn;
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
        if (!startSmoke) return;
        
        elapsedTime += Time.deltaTime;
        if(elapsedTime >= igniteTime && !ignite)
        {
            if(ignite == false)
            {
                //점화
                tartgetBurn.Ignite(tartgetBurn.transform.position);
                tartgetBurn.StartBurned(10);
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
    }
    private IEnumerator StopSmoke_co()
    {
         SetColorAlpha(0);
         yield return new WaitForSeconds(2);
        particleSystem.Stop();
        startSmoke = false;

    }
    public void StartSmoke()
    {
        SetColorAlpha(1);
        particleSystem.Play();
        startSmoke = true;
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
        if (GameManager.instance != null)
            GameManager.instance.onGameEnd -= ResetData;
    }
}
