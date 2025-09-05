using FernandoOleaDev.FyreSystem;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerManager : MonoBehaviour
{
    public enum PlayerNum 
    { 
      player_1,
      player_2,
      player_3
    }

    public PlayerNum playerNum;
    //burnableObject 배열에서 누구부터끌지 index
    [SerializeField] private int targetIndex =3;
    private bool isTrigger;
    //신호가 들어오는중인지
    public bool isPlaying;
    //isPlaying 유지시간
    public float playTime;
    //isplaying = false되는 기준시간
    public float targetTime =5;
    //신호받을때마다 갱신할 시간
    public float updateTime;
    private void OnEnable()
    {
        GameManager.instance.onGameEnd += ResetPlayerSetting;
    }
    private void OnDisable()
    {
        if(GameManager.instance !=null)
        GameManager.instance.onGameEnd -= ResetPlayerSetting;
    }

    private void Update()
    {
        if (!GameManager.instance.startGame) return;
        if (isPlaying)
        {
            updateTime += Time.deltaTime;
            if (updateTime >= 2)
            {
                isPlaying = false;
                updateTime = 0;
            }
            playTime += Time.deltaTime;
            if (playTime >= targetTime && !isTrigger)
            {
                //불끄는 메소드 실행
                playTime = 0;
                AudioManager.Instance.PlaySFX(3, 1, false, 1);
                targetTime = Random.Range(5f, 6f);
                targetIndex = FireManager.instance.SetFireSize((int)playerNum, targetIndex ,-2);
            }
        }
        else
        {

        }
    }
    public void UpdatePlaying()
    {
        isPlaying = true;
        updateTime = 0;
    }
    public void ResetPlayerSetting()
    {
        targetIndex = 3;
        updateTime = 0;
        isPlaying = false;
        playTime = 0;
    }
   
}
