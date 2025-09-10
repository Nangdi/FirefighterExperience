using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomSPManager : SerialPortManager
{
    protected override void Awake()
    {
        base.Awake();
    }
    protected override void Start()
    {
        base.Start();
    }
    protected override void ReceivedData(string data)
    {
        switch (data)
        {
            case "80A":
                if (!GameManager.instance.startGame)
                {
                Debug.Log("게임시작");
                    GameManager.instance.GameStart();
                }
                break;
            case "80B":
                Debug.Log("Player 1번 소화기");
                GameManager.instance.SendPortToPlayer(0);

                break;
            case "80C":
                Debug.Log("Player 2번 소화기");
                GameManager.instance.SendPortToPlayer(1);
                break;
            case "80D":
                Debug.Log("Player 3번 소화기");
                GameManager.instance.SendPortToPlayer(2);
                break;

        }

    }
}
