using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{

    private static GameManager _instance;

    public static GameManager instance
    {
        get
        {
            // �̹� ������ ��ȯ
            if (_instance != null) return _instance;

            // �� �ȿ��� ã�ƺ�
            _instance = FindObjectOfType<GameManager>();

            // ���ٸ� ���� ����
            //if (_instance == null)
            //{
            //    GameObject go = new GameObject("GameManager");
            //    _instance = go.AddComponent<GameManager>();
            //    DontDestroyOnLoad(go); // �� ��ȯ���� ����
            //}

            return _instance;
        }
    }


    [SerializeField] private List<IgniteSwitch[]> igniteGroup = new List<IgniteSwitch[]>();

    [SerializeField] private IgniteSwitch[] igniteSwitches_1;
    [SerializeField] private IgniteSwitch[] igniteSwitches_2;
    [SerializeField] private IgniteSwitch[] igniteSwitches_3;
    public float gameTime = 140;
    public float nextIgniteTime;
    public float currentTime;
    public bool startGame;
    public event Action onGameEnd;

    private void Awake()
    {
        // �ߺ� ����
        if (_instance == null)
        {
            _instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else if (_instance != this)
        {
            Destroy(gameObject);
        }
    }
    private void Start()
    {
        igniteGroup.Add(igniteSwitches_1);
        igniteGroup.Add(igniteSwitches_2);
        igniteGroup.Add(igniteSwitches_3);

        GameEnd();
    }
    private void Update()
    {
        if (!startGame) return;


        currentTime += Time.deltaTime;
        if(currentTime >= gameTime && startGame)
        {
            startGame = false;
            //��������
            GameEnd();
        }
    }
    public void GameEnd()
    {
        currentTime = 0;
        nextIgniteTime = 0;
        startGame = false;
        onGameEnd.Invoke();
    }
    public void GameStart()
    {
        startGame = true;
        IgniteSmoke();
    }
    //���⼭ �ð�����
    private void IgniteSmoke()
    {
        for (int i = 0; i < igniteGroup.Count; i++)
        {
            for (int k = 0; k < igniteGroup[i].Length; k++)
            {
                float time = k * 10;
                if(k >= 4)
                {
                    time = (k - 1) * 10; 
                }
                StartCoroutine(FireManager.instance.ReservationSmoke_co(igniteGroup[i][k], time));
                Debug.Log($"{k * 10}�� �� ����Ϸ�");




            }
        }
    }
    

}
