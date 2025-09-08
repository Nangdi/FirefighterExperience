using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GameSettingPanel : MonoBehaviour
{
    public GameObject settingPanel;

    public Slider bgmVolumeSlider;
    public Slider sfxVolumeSlider;

    private void Start()
    {
        bgmVolumeSlider.value = JsonManager.instance.gameSettingData.bgmVolume;
        sfxVolumeSlider.value = JsonManager.instance.gameSettingData.sfxVolume;
    }



    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            if (!Application.isEditor)
            {
                Cursor.visible = !Cursor.visible;
            }
            settingPanel.SetActive(!settingPanel.activeSelf);
        }
    }

}
