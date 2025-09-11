using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
public class GameSettingData
{
    //���������
    public float bgmVolume =1f;
    //ȿ��������
    public float sfxVolume=0.5f;
    //�� ���ӽð�
    public float playTime=140f;
    //��ȭ�� �����̽ð�
    public float warterDelay = 5f;
    //��Ʈ�ѷ���ȣ���ð� (�����غ�ð�)
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

    //������ json ��ü , ��μ���
    public static void SaveData<T>(T jsonObject, string path) where T : new()
    {
        if (jsonObject == null)
            jsonObject = new T();  // �⺻ �����ڷ� ��ü �ʱ�ȭ
        string json = JsonUtility.ToJson(jsonObject, true);
        File.WriteAllText(path, json);
        Debug.Log($"�����: {path}");
    }

    public static T LoadData<T>(T data, string path) where T : new()
    {
        {
            if (!File.Exists(path))
            {
                Debug.LogWarning("JSON ������ �������� �ʽ��ϴ�.");
                SaveData(data, path);
            }
            Debug.Log("JSON�ε�");
            string json = File.ReadAllText(path);
            T jsonData = JsonUtility.FromJson<T>(json);
            return jsonData;
        }

        //���� �����ڵ�
        //JsonManager.LoadData(���ϰ�� , ������Ŭ����);

    }

    public void SaveSettingData()
    {
        gameSettingData.bgmVolume = AudioManager.Instance.bgmVolume;
        gameSettingData.sfxVolume = AudioManager.Instance.sfxVolume;
        SaveData(gameSettingData, gameDataPath);
    }
}
