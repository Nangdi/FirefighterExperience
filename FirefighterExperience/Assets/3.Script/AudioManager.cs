using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioManager : MonoBehaviour
{
    public static AudioManager Instance { get; private set; }

    [Header("Audio Sources")]
    [SerializeField] private AudioSource bgmSource;
    [SerializeField] private AudioSource sfxSourcePrefab;
    [SerializeField] private int sfxPoolSize = 10;

    private List<AudioSource> sfxPool;
    public AudioClip bgm;
    public AudioClip[] sfxs;

    [Header("Volume Settings")]
    [Range(0f, 1f)] public float bgmVolume = 1f;
    [Range(0f, 1f)] public float sfxVolume = 1f;

    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);

        sfxPool = new List<AudioSource>();
        for (int i = 0; i < sfxPoolSize; i++)
        {
            AudioSource src = Instantiate(sfxSourcePrefab, transform);
            src.playOnAwake = false;
            sfxPool.Add(src);
        }
    }
    private void Start()
    {
        bgmVolume = JsonManager.instance.gameSettingData.bgmVolume;
        sfxVolume = JsonManager.instance.gameSettingData.sfxVolume;
    }
    // ==============================
    // BGM
    // ==============================
    public void PlayBGM()
    {
        bgmSource.clip = bgm;
        bgmSource.volume = bgmVolume;
        bgmSource.loop = true;
        bgmSource.Play();
    }

    public void StopBGM() => bgmSource.Stop();

    public void SetBGMVolume(float volume)
    {
        bgmVolume = Mathf.Clamp01(volume);
        bgmSource.volume = bgmVolume;   // 실행 중에도 바로 반영
    }

    // ==============================
    // SFX
    // ==============================
    public AudioSource PlaySFX(int audioNum, bool loop = false, float fadeOutDuration = 0f)
    {
        if (audioNum < 0 || audioNum >= sfxs.Length) return null;

        AudioClip clip = sfxs[audioNum];
        if (clip == null) return null;

        AudioSource src = GetAvailableSFXSource();
        src.clip = clip;
        src.volume = sfxVolume;
        src.loop = loop;
        src.Play();

        if (!loop && fadeOutDuration > 0f)
        {
            StartCoroutine(AutoFadeOutCoroutine(src, fadeOutDuration));
        }

        return src;
    }

    public void SetSFXVolume(float volume)
    {
        sfxVolume = Mathf.Clamp01(volume);

        // 현재 재생 중인 SFX에도 즉시 반영
        foreach (var src in sfxPool)
        {
            if (src.isPlaying)
                src.volume = sfxVolume;
        }
    }

    private IEnumerator AutoFadeOutCoroutine(AudioSource src, float fadeDuration)
    {
        float clipLength = src.clip.length;
        float startFadeTime = Time.time + clipLength - fadeDuration;

        while (Time.time < startFadeTime && src.isPlaying)
        {
            yield return null;
        }

        float startVolume = src.volume;
        float t = 0f;
        while (t < fadeDuration && src.isPlaying)
        {
            t += Time.deltaTime;
            src.volume = Mathf.Lerp(startVolume, 0f, t / fadeDuration);
            yield return null;
        }

        src.Stop();
        src.volume = startVolume;
    }

    private AudioSource GetAvailableSFXSource()
    {
        foreach (var src in sfxPool)
        {
            if (!src.isPlaying)
                return src;
        }
        return sfxPool[0];
    }
    
}
