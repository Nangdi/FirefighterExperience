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
    //burnableObject �迭���� �������Ͳ��� index
    [SerializeField] private int targetIndex =3;
    private bool isTrigger;
    //��ȣ�� ������������
    public bool isPlaying;
    //isPlaying �����ð�
    public float playTime;
    //isplaying = false�Ǵ� ���ؽð�
    public float targetTime =5;
    //��ȣ���������� ������ �ð�
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
                //�Ҳ��� �޼ҵ� ����
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
