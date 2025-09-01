using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
[Serializable]
public class Example
{

}

public class JsonManager : MonoBehaviour
{
    //������ json ��ü , ��μ���
    public static void SaveData<T>(T jsonObject, string path) where T : new()
    {
        if (jsonObject == null)
            jsonObject = new T();  // �⺻ �����ڷ� ��ü �ʱ�ȭ
        string json = JsonUtility.ToJson(jsonObject, true);
        File.WriteAllText(path, json);
        Debug.Log($"�����: {path}");
    }

    public static T LoadData<T>(string path, T data) where T : new()
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
}
