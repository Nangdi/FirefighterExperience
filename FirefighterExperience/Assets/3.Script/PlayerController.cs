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
    //burnableObject �迭���� �������Ͳ��� index
    [SerializeField] private int targetIndex =3;
    private bool isTrigger;
    //��ȣ�� ������������
    public bool isPlaying;
    //isPlaying �����ð�
    public float holdingTime;
    //isplaying = false�Ǵ� ���ؽð�
    public float targetTime =5;
    //��ȣ���������� ������ �ð�
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
                //�Ҳ��� �޼ҵ� ����
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
