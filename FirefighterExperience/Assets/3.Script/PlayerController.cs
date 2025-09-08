using FernandoOleaDev.FyreSystem;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
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
    public float holdingTime;
    //isplaying = false되는 기준시간
    public float targetTime =5;
    //신호받을때마다 갱신할 시간
    public float breakawayTime;
    private void OnEnable()
    {
        GameManager.instance.onGameEnd += ResetPlayerSetting;
    }
    private void OnDisable()
    {
        if(GameManager.instance !=null)
        GameManager.instance.onGameEnd -= ResetPlayerSetting;
    }
    private void Start()
    {
        targetTime = JsonManager.instance.gameSettingData.warterDelay;
    }
    private void Update()
    {
        if (!GameManager.instance.startGame) return;
        if (isPlaying)
        {
            breakawayTime += Time.deltaTime;
            if (breakawayTime >= 2)
            {
                isPlaying = false;
                breakawayTime = 0;
            }
            holdingTime += Time.deltaTime;
            if (holdingTime >= targetTime && !isTrigger)
            {
                //불끄는 메소드 실행
                holdingTime = 0;
                AudioManager.Instance.PlaySFX(3, false, 1);
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
        breakawayTime = 0;
    }
    public void ResetPlayerSetting()
    {
        targetIndex = 3;
        breakawayTime = 0;
        isPlaying = false;
        holdingTime = 5;
    }
   
}
