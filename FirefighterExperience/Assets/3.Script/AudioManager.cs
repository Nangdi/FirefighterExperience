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

    // ==============================
    // BGM
    // ==============================
    public void PlayBGM( float volume = 1f)
    {
        bgmSource.clip = bgm;
        bgmSource.volume = volume;
        bgmSource.loop = true;
        bgmSource.Play();
    }

    public void StopBGM() => bgmSource.Stop();

    // ==============================
    // SFX
    // ==============================
    public AudioSource PlaySFX(int audioNum, float volume = 1f, bool loop = false, float fadeOutDuration = 0f)
    {
        AudioClip clip = sfxs[audioNum];

        if (clip == null) return null;

        AudioSource src = GetAvailableSFXSource();
        src.clip = clip;
        src.volume = volume;
        src.loop = loop;
        src.Play();

        // ������ �ƴϰ�, ���̵�ƿ� �ð��� �����Ǿ� ������ �ڵ� ���̵�ƿ� �ڷ�ƾ ����
        if (!loop && fadeOutDuration > 0f)
        {
            StartCoroutine(AutoFadeOutCoroutine(src, fadeOutDuration));
        }

        return src;
    }

    private IEnumerator AutoFadeOutCoroutine(AudioSource src, float fadeDuration)
    {
        float clipLength = src.clip.length;
        float startFadeTime = Time.time + clipLength - fadeDuration; // �������� ���̵� ��������

        // ���̵� ���� �������� ���
        while (Time.time < startFadeTime && src.isPlaying)
        {
            yield return null;
        }

        // ���̵� ����
        float startVolume = src.volume;
        float t = 0f;
        while (t < fadeDuration && src.isPlaying)
        {
            t += Time.deltaTime;
            src.volume = Mathf.Lerp(startVolume, 0f, t / fadeDuration);
            yield return null;
        }

        src.Stop();
        src.volume = startVolume; // ���� ����� ���� ���� ���� ����
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
