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
    //저장할 json 객체 , 경로설정
    public static void SaveData<T>(T jsonObject, string path) where T : new()
    {
        if (jsonObject == null)
            jsonObject = new T();  // 기본 생성자로 객체 초기화
        string json = JsonUtility.ToJson(jsonObject, true);
        File.WriteAllText(path, json);
        Debug.Log($"저장됨: {path}");
    }

    public static T LoadData<T>(string path, T data) where T : new()
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
}
