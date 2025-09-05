using FernandoOleaDev.FyreSystem;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Xml;
using UnityEngine;

public class FireManager : MonoBehaviour
{
    public static FireManager instance;

    [SerializeField] private List<BurnableObject[]> burnableObjectGroup = new List<BurnableObject[]>();
    [SerializeField] private BurnableObject[] burnableObjects_1;
    [SerializeField] private BurnableObject[] burnableObjects_2;
    [SerializeField] private BurnableObject[] burnableObjects_3;
    [SerializeField] private BurnableObject[] wallObs;
    [SerializeField] private List<ParticleSystem[]> waterJetGroup = new List<ParticleSystem[]>();
    [SerializeField] private ParticleSystem[] waterjets_1;
    [SerializeField] private ParticleSystem[] waterjets_2;
    [SerializeField] private ParticleSystem[] waterjets_3;

    public Dictionary<BurnableObject, ParticleSystem> burnObWaterJetpairs = new Dictionary<BurnableObject, ParticleSystem>();
    private int startCount =0;
    private void Awake()
    {
        if(instance == null)
        {
            instance = this;
            DontDestroyOnLoad(this);
        }
        else
        {
            Destroy(this);
        }

        burnableObjectGroup.Add(burnableObjects_1);
        burnableObjectGroup.Add(burnableObjects_2);
        burnableObjectGroup.Add(burnableObjects_3);
        waterJetGroup.Add(waterjets_1);
        waterJetGroup.Add(waterjets_2);
        waterJetGroup.Add(waterjets_3);
        DicInit();
    }
    private void OnEnable()
    {
        GameManager.instance.onGameEnd += AllResetObject;
    }
    private void OnDisable()
    {
        if(GameManager.instance !=null)
        GameManager.instance.onGameEnd -= AllResetObject;
    }
    //불붙이는 메소드
    public void IgniteObject(int num , int index)
    {
        burnableObjectGroup[num][index].Ignite(burnableObjectGroup[num][index].transform.position);
        burnableObjectGroup[num][index].StartBurned(10);
    }
    //불끄는 메소드
    public void ExtinguishObject(int num, int index)
    {
        burnableObjectGroup[num][index].Extinguish();
    }
    //모든오브젝트 데이터 리셋
    public void AllResetObject()
    {
        for (int i = 0; i < burnableObjectGroup.Count; i++)
        {
            for (int k = 0; k < burnableObjectGroup[i].Length; k++)
            {
                burnableObjectGroup[i][k].Extinguish();

                if (burnableObjectGroup[i][k].transform.childCount != 0)
                {

                    ParticleSystem ps = burnableObjectGroup[i][k].transform.GetChild(0).GetComponent<ParticleSystem>();
                    var main = ps.main;
                    var sizeCurve = main.startSize;

                    sizeCurve.constantMax = 5; // 1씩 감소시키기
                    main.startSize = sizeCurve;
                }
            }
        }
        for (int i = 0; i < wallObs.Length; i++)
        {
            wallObs[i].Extinguish();
        }
    }
    //첫시작 smoke 시작메소드
    public void StartSmoke()
    {
        startCount++;
        if (startCount >= 3)
        {
            IgniteObject(0, 0);
            IgniteObject(1, 0);
            IgniteObject(2, 0);
        }
    }
    public IEnumerator ReservationSmoke_co(IgniteSwitch igniteSwitch ,float reservationTime)
    {
        yield return new WaitForSeconds(reservationTime);
        igniteSwitch.StartSmoke();
    }
    public IEnumerator ReservationBurnWall_co(float reservationTime)
    {
        yield return new WaitForSeconds(reservationTime);
        for (int i = 0; i < wallObs.Length; i++)
        {
            wallObs[i].StartBurned(10);
        }
      
    }
    public int SetFireSize(int num , int index ,float amount)
    {
       ParticleSystem ps = burnableObjectGroup[num][index].transform.GetChild(0).GetComponent<ParticleSystem>();
        ParticleSystem waterJetPs = burnObWaterJetpairs[burnableObjectGroup[num][index]];
        StartCoroutine(WaterShot_co(waterJetPs));
        if (index ==3 && burnableObjectGroup[num].Length >=5)
        {
            SetFireSize(num, 4 ,amount);
        }
        var main = ps.main;
        var sizeCurve = main.startSize;

        sizeCurve.constantMax += amount; // 1씩 감소시키기
        if(sizeCurve.constantMax <= 0)
        {
            index -= 1;
            if(index < 0)
            {
                index = 0;
                GameManager.instance.particleFadeControllers[num].StopParticle();
            }
        }
        main.startSize = sizeCurve;
        return index;
    }
    public void ResetFireSize()
    {
        for (int i = 0; i < burnableObjectGroup.Count; i++)
        {
            for (int k = 0; k < burnableObjectGroup[i].Length; k++)
            {
                ParticleSystem ps = burnableObjectGroup[i][k].transform.GetChild(0).GetComponent<ParticleSystem>();
                var main = ps.main;
                var sizeCurve = main.startSize;

                sizeCurve.constantMax = 5; // 1씩 감소시키기
                main.startSize = sizeCurve;
            }
        }
    }
    public IEnumerator WaterShot_co(ParticleSystem waterJet)
    {
        waterJet.Play();
        yield return new WaitForSeconds(3.5f);
        waterJet.Stop(true , ParticleSystemStopBehavior.StopEmitting); 


    }
    private void DicInit()
    {
        for (int i = 0; i < burnableObjectGroup.Count; i++)
        {
            for (int k = 0; k < burnableObjectGroup[i].Length; k++)
            {
                burnObWaterJetpairs[burnableObjectGroup[i][k]] = waterJetGroup[i][k];
            }
        }
    }
}
