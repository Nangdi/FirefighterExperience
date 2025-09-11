using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
public class GameSettingData
{
    //배경음볼륨
    public float bgmVolume =1f;
    //효과음볼륨
    public float sfxVolume=0.5f;
    //총 게임시간
    public float playTime=140f;
    //소화기 딜레이시간
    public float warterDelay = 5f;
    //컨트롤러신호대기시간 (게임준비시간)
    public float ReadyTime = 45f;
    public int[] displayIndex = { 0, 1, 2 };
}
public class PortJson
{
    public string com = "COM4";
    public int baudLate = 19200;
}

public class JsonManager : MonoBehaviour
{

    public static JsonManager instance;
    public GameSettingData gameSettingData;
    public PortJson portJson;
    private string gameDataPath;
    private string portPath;
    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else if (instance != this)
        {
            Destroy(gameObject);
        }

        portPath = Path.Combine(Application.streamingAssetsPath, "port.json");
        gameDataPath = Path.Combine(Application.persistentDataPath, "gameSettingData.json");

        gameSettingData = LoadData(gameSettingData, gameDataPath);
        portJson = LoadData(portJson, portPath);
    }

    //저장할 json 객체 , 경로설정
    public static void SaveData<T>(T jsonObject, string path) where T : new()
    {
        if (jsonObject == null)
            jsonObject = new T();  // 기본 생성자로 객체 초기화
        string json = JsonUtility.ToJson(jsonObject, true);
        File.WriteAllText(path, json);
        Debug.Log($"저장됨: {path}");
    }

    public static T LoadData<T>(T data, string path) where T : new()
    {
        {
            if (!File.Exists(path))
            {
                Debug.LogWarning("JSON 파일이 존재하지 않습니다.");
                SaveData(data, path);
            }
            Debug.Log("JSON로드");
            string json = File.ReadAllText(path);
            T jsonData = JsonUtility.FromJson<T>(json);
            return jsonData;
        }

        //예시 실행코드
        //JsonManager.LoadData(파일경로 , 데이터클래스);

    }

    public void SaveSettingData()
    {
        gameSettingData.bgmVolume = AudioManager.Instance.bgmVolume;
        gameSettingData.sfxVolume = AudioManager.Instance.sfxVolume;
        SaveData(gameSettingData, gameDataPath);
    }
}
