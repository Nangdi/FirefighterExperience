using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public static GameManager instance;
    [SerializeField] private IgniteSwitch[] igniteSwitches;

    public float gameTime = 140;
    public float nextIgniteTime;
    public float currentTime;
    public bool startGame;
    public event Action onGameEnd;
    
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
        startGame = false;
    }
    private void Start()
    {
        GameEnd();
    }
    private void Update()
    {
        if (!startGame) return;


        currentTime += Time.deltaTime;
        if(currentTime >= gameTime && startGame)
        {
            startGame = false;
            //게임종료
            GameEnd();
        }
    }
    public void GameEnd()
    {
        currentTime = 0;
        nextIgniteTime = 0;
        onGameEnd.Invoke();
    }
    public void GameStart()
    {
        startGame = true;
        IgniteSmoke();
    }
    private void IgniteSmoke()
    {
        for (int i = 0; i < igniteSwitches.Length; i++)
        {
            igniteSwitches[i].IgniteSmoke();
        }
    }
    

}
