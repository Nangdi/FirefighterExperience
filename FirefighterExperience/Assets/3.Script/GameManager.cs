using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GameManager : MonoBehaviour
{

    private static GameManager _instance;

    public static GameManager instance
    {
        get
        {
            // 이미 있으면 반환
            if (_instance != null) return _instance;

            // 씬 안에서 찾아봄
            _instance = FindObjectOfType<GameManager>();

            // 없다면 새로 생성
            //if (_instance == null)
            //{
            //    GameObject go = new GameObject("GameManager");
            //    _instance = go.AddComponent<GameManager>();
            //    DontDestroyOnLoad(go); // 씬 전환에도 유지
            //}

            return _instance;
        }
    }


    [SerializeField] private List<IgniteSwitch[]> igniteGroup = new List<IgniteSwitch[]>();

    [SerializeField] private IgniteSwitch[] igniteSwitches_1;
    [SerializeField] private IgniteSwitch[] igniteSwitches_2;
    [SerializeField] private IgniteSwitch[] igniteSwitches_3;
    [SerializeField] private PlayerController[] players;
    [SerializeField] private GameObject[] fakeWindows;
    [SerializeField] public ParticleFadeController[] particleFadeControllers;
    [SerializeField] private SpriteRenderer blackScreen;
    public float gameTime = 140;
    public float nextIgniteTime;
    public float currentTime;
    public bool startGame;
    public event Action onGameEnd;
    public bool ReadyWater;

    public bool FastPlay;
    private void Awake()
    {
        // 중복 방지
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
        //Application.runInBackground = true;
        ///*if (Display.displays.Length > 1) */Display.displays[1].Activate();
        ///*if (Display.displays.Length > 2) */Display.displays[2].Activate();
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
            //게임종료
            Debug.Log("게임종료 시간초과");
            GameEnd();
        }
    }
    public void GameEnd()
    {
        currentTime = 0;
        nextIgniteTime = 0;
        startGame = false;
        ReadyWater = false;
        FadeScreen(1);
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
        Debug.Log("브금재생되는곳");
        FadeScreen(0);
        AudioManager.Instance.PlayBGM();
        StartCoroutine(FireManager.instance.ReservationBurnWall_co(35));
        StartCoroutine(GameStartDelay(45));

        //불붙는배경음
        AudioManager.Instance.PlaySFX(0,0.5f, false, 5);
    }
    //여기서 시간차로
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
                Debug.Log($"{time}초 후 예약완료");




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
        Debug.Log("게임시작!");
    }
    public void FadeScreen(float targetAlpha)
    {
        //StopAllCoroutines(); // 여러 코루틴이 겹치지 않도록
        StartCoroutine(FadeCoroutine(targetAlpha));
    }

    private IEnumerator FadeCoroutine(float targetAlpha)
    {
        Color startColor = blackScreen.color;
        float startAlpha = startColor.a;
        float t = 0f;

        while (t < 2)
        {
            t += Time.deltaTime;
            float newAlpha = Mathf.Lerp(startAlpha, targetAlpha, t / 2);
            blackScreen.color = new Color(startColor.r, startColor.g, startColor.b, newAlpha);
            yield return null;
        }

        // 마지막 보정
        blackScreen.color = new Color(startColor.r, startColor.g, startColor.b, targetAlpha);
    }
}
