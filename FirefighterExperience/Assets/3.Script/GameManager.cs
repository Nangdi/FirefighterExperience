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
    [SerializeField] private PlayerManager[] players;
    [SerializeField] private GameObject[] fakeWindows;
    [SerializeField] public ParticleFadeController[] particleFadeControllers;
    public float gameTime = 140;
    public float nextIgniteTime;
    public float currentTime;
    public bool startGame;
    public event Action onGameEnd;
    public bool ReadyWater;

    public bool FastPlay;
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
        AudioManager.Instance.StopBGM();
        GameEnd();
    }
    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.A))
        {
            GameStart();
        }
        if (Input.GetKeyDown(KeyCode.R))
        {
            Instantiate(fakeWindows[0]);
            Instantiate(fakeWindows[0]);
            Instantiate(fakeWindows[1]);
            Instantiate(fakeWindows[1]);
            Instantiate(fakeWindows[2]);
            Instantiate(fakeWindows[2]);
        }
        if (!startGame) return;
        if (Input.GetKeyDown(KeyCode.S))
        {
            Time.timeScale = 5;
        }
        else if(Input.GetKeyUp(KeyCode.S))
        {
            Time.timeScale = 1;
        }
        if (ReadyWater)
        {
            if (Input.GetKeyDown(KeyCode.Q))
            {
                SendPortToPlayer(0);
            }
            if (Input.GetKeyDown(KeyCode.W))
            {
                SendPortToPlayer(1);
            }
            if (Input.GetKeyDown(KeyCode.E))
            {
                SendPortToPlayer(2);
            }

        }

        currentTime += Time.deltaTime;
        if (currentTime >= gameTime && startGame)
        {
            startGame = false;
            //��������
            Debug.Log("�������� �ð��ʰ�");
            GameEnd();
        }
    }
    public void GameEnd()
    {
        currentTime = 0;
        nextIgniteTime = 0;
        startGame = false;
        ReadyWater = false;
        for (int i = 0; i < particleFadeControllers.Length; i++)
        {
            particleFadeControllers[i].StopParticle();
        }
        AudioManager.Instance.StopBGM();
        onGameEnd.Invoke();
    }
    public void GameStart()
    {
        startGame = true;
        IgniteSmoke();
        Debug.Log("�������Ǵ°�");
        AudioManager.Instance.PlayBGM();
        StartCoroutine(FireManager.instance.ReservationBurnWall_co(35));
        StartCoroutine(GameStartDelay(45));

        //�Һٴ¹����
        AudioManager.Instance.PlaySFX(0,0.5f, false, 5);
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
                Debug.Log($"{time}�� �� ����Ϸ�");




            }
        }
       
           
       

    }
    
    public void SendPortToPlayer(int index)
    {
        players[index].UpdatePlaying();
    }

    public IEnumerator GameStartDelay(float delay)
    {


        yield return new WaitForSeconds(delay);
        ReadyWater = true;
        Instantiate(fakeWindows[0]);
        Instantiate(fakeWindows[0]);
        Instantiate(fakeWindows[1]);
        Instantiate(fakeWindows[1]);
        Instantiate(fakeWindows[2]);
        Instantiate(fakeWindows[2]);
        for (int i = 0; i < particleFadeControllers.Length; i++)
        {
            particleFadeControllers[i].PlayParticle();
        }
       
        AudioManager.Instance.PlaySFX(1, 0.5f, false, 3);
        Debug.Log("���ӽ���!");
    }
}
