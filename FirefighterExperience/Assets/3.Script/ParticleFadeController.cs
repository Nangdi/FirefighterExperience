using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticleFadeController : MonoBehaviour
{
    [SerializeField] private ParticleSystem[] particleSystems;

    void Awake()
    {
        // 파티클 렌더러에서 머티리얼 캐싱

        
    }
    public void PlayParticle()
    {
        for (int i = 0; i < particleSystems.Length; i++)
        {
            particleSystems[i].Play();
        }
    }
    public void StopParticle()
    {
        for (int i = 0; i < particleSystems.Length; i++)
        {
            particleSystems[i].Stop(true , ParticleSystemStopBehavior.StopEmitting);
        }
    }
}
