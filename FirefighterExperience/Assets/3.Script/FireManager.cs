using FernandoOleaDev.FyreSystem;
using System.Collections;
using System.Collections.Generic;
using System.Xml;
using UnityEngine;

public class FireManager : MonoBehaviour
{
    public static FireManager instance;

    [SerializeField] private List<BurnableObject[]> particleSystems = new List<BurnableObject[]>();
    [SerializeField] private BurnableObject[] burnableObjects_1;
    [SerializeField] private BurnableObject[] burnableObjects_2;
    [SerializeField] private BurnableObject[] burnableObjects_3;
    [SerializeField] private BurnableObject[] wallObs;

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

        particleSystems.Add(burnableObjects_1);
        particleSystems.Add(burnableObjects_2);
        particleSystems.Add(burnableObjects_3);
    }
    //불붙이는 메소드
    public void IgniteObject(int num , int index)
    {
        particleSystems[num][index].Ignite(particleSystems[num][index].transform.position);
        particleSystems[num][index].StartBurned(10);
    }
    //불끄는 메소드
    public void ExtinguishObject(int num, int index)
    {
        particleSystems[num][index].Extinguish();
    }
    //모든오브젝트 데이터 리셋
    public void AllResetObject()
    {
        for (int i = 0; i < particleSystems.Count; i++)
        {
            for (int k = 0; k < particleSystems[i].Length; k++)
            {
                particleSystems[i][k].Extinguish();
            }
        }
    }
    //첫시작 smoke 시작메소드
    public void StartSmoke()
    {
        startCount++;
        if(startCount >= 3)
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
    public int SetFireSize(int num , int index)
    {
       ParticleSystem ps = particleSystems[num][index].transform.GetChild(0).GetComponent<ParticleSystem>();
        if (index ==3 && particleSystems[num].Length >=5)
        {
            SetFireSize(num, 4);
        }
        var main = ps.main;
        var sizeCurve = main.startSize;

        sizeCurve.constantMax -= 1.0f; // 1씩 감소시키기
        Debug.Log(sizeCurve.constantMax);
        if(sizeCurve.constantMax <= 0)
        {
            index -= 1;
            if(index <= 0)
            {
                index = 0;
            }
        }
        main.startSize = sizeCurve;
        return index;
    }
}
