using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditorInternal;
#if UNITY_EDITOR
using System.IO;
using UnityEditor;
#endif
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.Serialization;
using Random = System.Random;

namespace FernandoOleaDev.FyreSystem {

    public enum VisualsType {
        Simple,
        Complex
    }

    public class MeshConfig {
        public Bounds bounds;
        public Vector3 initialGeneratePoint;
        public Collider collider;
    }
    public class BurnableObject : MonoBehaviour {

        #region Vars

        [Header("Events")]
        public UnityEvent OnBurnableIgnited = new UnityEvent();
        public UnityEvent OnBurnableBurnedUp = new UnityEvent();

        [Header("Burnable Values")]
        [Tooltip("The object ignites when the game starts")]
        [SerializeField] private bool igniteAtStart;
        [Tooltip("The object has infinite combustion")]
        [SerializeField] private bool infiniteCombustion;
        [Tooltip("Duration in seconds to propage flame over the whole object")]
        [SerializeField] private float flamePropagationSeconds = 5.0f;
        [Tooltip("Value to adjust propagation around the whole object")]
        [SerializeField] private float propagationSmooth = 4.0f;
        [Tooltip("Duration in seconds that object is burning")]
        [SerializeField] private float combustionSeconds = 10.0f;
        [Tooltip("Combustion's percent when it shows burn signs")]
        [Range(0,1)] [SerializeField] private float combustionsSignsAtCombustionPercent = 0.8f;
        [Tooltip("Duration in seconds to cool down object")]
        [SerializeField] private float coolingSeconds = 3.0f;
        [Tooltip("Curve used to describe cooling")]
        [SerializeField] private AnimationCurve coolingCurve = new AnimationCurve();

        [Header("Ignite Values")]
        [Tooltip("Duration in seconds to ignite another burnable object when it's in its area")]
        [SerializeField] private float secondsToIgnite = 1.0f;
        [Tooltip("Defines radious of the sphere area which it ignites other burnable objects (Representating by red wiresphere gizmo)")]
        [SerializeField] private float igniteRadious = 0.1f;
        [Tooltip("Offset of the sphere area")]
        [SerializeField] private Vector3 igniteRadiousOffset = new Vector3(0,0.1f,0);
        private IgniteAreaController igniteAreaController;

        [Header("Visuals")]
        [Tooltip("Particle system which spawn over the whole object when it combusts")]
        [SerializeField] private GameObject particlesFirePrefab;
        [Tooltip("Propagation's percent when particle system spawns")]
        [Range(0,1)] [SerializeField] private float particlesOnFlamePropagationPercent = 0.5f;
        [Tooltip("Combustion's percent when particle system stops emit")]
        [Range(0,1)] [SerializeField] private float particlesOffCombustionPercent = 0.85f;
        [Tooltip("Active / Deactive ashes spawn when object is cold")]
        [SerializeField] private bool withAshes = true;
        [Tooltip("Destroy Gameobject when object becomes ashes")]
        [SerializeField] private bool destroyAtAshes;
        [Tooltip("Duration in seconds to destroy ashes after ashes spawn")]
        [SerializeField] private float secondsToDestroyAshes = 10.0f;
        [Tooltip("Duration in seconds to dissapear object when object is cold")]
        [SerializeField] private float disappearSeconds = 2.0f;
        [Tooltip("Ashes particle system prefab")]
        [SerializeField] private GameObject particlesAshesPrefab;
        
        private GameObject particleFireGameobject;
        private List<ParticleSystem> particleSystems = new List<ParticleSystem>();
        private Material material;
        private GameObject particleAshesGameobject;
        private ParticleSystem ashesParticleSystem;
        
        [Header("Shader")]
        [Tooltip("Shader Hot color")]
        [SerializeField] private Color hot = Color.yellow;
        [Tooltip("Shader Warm color")]
        [SerializeField] private Color warm = new Color(255,98,0);
        [Tooltip("Burned signs color")]
        [ColorUsage(true, true)][SerializeField] private Color burnedEmissiveColor = new Color(255,98,0);
        [Tooltip("Color of the flame propagation border")]
        [ColorUsage(true, true)][SerializeField] private Color borderColor = new Color(0,8,191);

        [Header("Light")]
        [Tooltip("Generate light")]
        [SerializeField] private bool generateLight = true;
        [Tooltip("Max intensity of the light")]
        [SerializeField] private float maxLightIntensity = 10.0f;
        [Tooltip("Light intensity exponential increase value")]
        [SerializeField] private float lightPow = 3.0f;
        [Tooltip("How much to smooth out the randomness; lower values = sparks, higher = lantern")]
        [Range(1, 50)]
        [SerializeField] private int lightFlickerSmooth = 7;
        [SerializeField] private float maxFlickerMovement = .1f;
        [Tooltip("Color of the light")]
        [SerializeField] private Color lightColor = Color.yellow;
        private Light light;
        private LightFlickerEffect lightFlickerEffect;
        private GameObject lightGameobject;

        [Header("Private Vars")]
        private bool burning;
        private bool cold;
        private bool disappeared;
        private bool propagationFnished;
        private bool burnedUp;
        private bool particlesOn;
        private bool particlesAshesOn;
        private float flamePropagationPercent;
        private float combustionPercent;
        private float coolingPercent;
        private float disappearPercent;
        private float elapsedSecondsFlamePropagation;
        private float elapsedSecondsCombustionSeconds;
        private float elapsedSecondsColling;
        private float elapsedSecondsDisappear;
        private GameObject igniteGameobject;

        [Header("Editor vars")]
        [HideInInspector] public bool dontAsk;

        #endregion

        #region Unity Methods
        
        void Start() {
            InitMaterial();
            InitParticles();
            InitIgniteArea();
            if (infiniteCombustion) {
                combustionSeconds = Mathf.Infinity;
            }
            if (igniteAtStart) {
                Ignite(transform.position);
            }
        }

        void Update() {
            if (burning || (burnedUp && !cold) || (burnedUp && withAshes && !disappeared)) {
                Burn();
                if (generateLight) {
                    ControlLight();
                }
            } else {
                material.SetVector("_IgnitePosition", transform.position);
            }
            
            
        }
        
        #endregion

        #region Burnable Methods

        private void InitIgniteArea() {
            GameObject igniteArea = new GameObject(gameObject.name + "_IgniteArea");
            igniteArea.transform.parent = transform;
            igniteAreaController = igniteArea.AddComponent<IgniteAreaController>();
            igniteAreaController.igniteOffset = igniteRadiousOffset;
            igniteAreaController.thisBurnableObject = this;
            igniteAreaController.secondsToIgnite = secondsToIgnite;
            igniteAreaController.igniteRadious = igniteRadious;
            SphereCollider collider = igniteArea.AddComponent<SphereCollider>();
            SphereCollider colliderCenter = igniteArea.AddComponent<SphereCollider>();
            collider.radius = igniteRadious;
            collider.isTrigger = true;
            colliderCenter.radius = igniteRadious;
            colliderCenter.isTrigger = true;
            Rigidbody rigidbody = igniteArea.AddComponent<Rigidbody>();
            rigidbody.isKinematic = true;
            rigidbody.useGravity = false;
        }

        public bool IsBurning() {
            return burning;
        }
        
        public bool IsBurnedUp() {
            return burnedUp;
        }

        public void Ignite(Vector3 ignitePosition) {
            if (burning || burnedUp) {
                return;
            }
            igniteGameobject = new GameObject("igniteGameobject");
            igniteGameobject.transform.parent = transform;
            igniteGameobject.transform.position = ignitePosition;
            if (generateLight) {
                GenerateLight();
            }
            burning = true;
            igniteAreaController.OnIgniteCheck();
            OnBurnableIgnited.Invoke();
        }

        private void SetIgnitePosition() {
            material.SetVector("_IgnitePosition", igniteGameobject.transform.position);
        }

        private void GenerateLight() {
            lightGameobject = new GameObject(this.gameObject.name + " - Light");
            lightGameobject.transform.parent = transform;
            lightGameobject.transform.position = transform.position;
            light = lightGameobject.AddComponent<Light>();
            lightFlickerEffect = lightGameobject.AddComponent<LightFlickerEffect>();
            light.intensity = 0;
            light.color = lightColor;
        }

        private void ControlLight() {
            lightFlickerEffect.maxIntensity = Mathf.Pow((flamePropagationPercent - coolingPercent), lightPow) * maxLightIntensity;
            lightFlickerEffect.minIntensity = lightFlickerEffect.maxIntensity / 4;
            lightFlickerEffect.smoothing = lightFlickerSmooth;
            lightFlickerEffect.maxMovement = maxFlickerMovement;
        }

        private void Burn() {
            SetIgnitePosition();
            if (!propagationFnished) {
                elapsedSecondsFlamePropagation += Time.deltaTime;
            }
            if (!burnedUp && !float.IsPositiveInfinity(combustionSeconds)) {
                elapsedSecondsCombustionSeconds += Time.deltaTime;
            }
            if (burnedUp && !cold) {
                elapsedSecondsColling += Time.deltaTime;
            }
            flamePropagationPercent = elapsedSecondsFlamePropagation / flamePropagationSeconds;
            combustionPercent = elapsedSecondsCombustionSeconds / combustionSeconds;
            coolingPercent = elapsedSecondsColling / coolingSeconds;
            SetBurn();
            CheckPercents();
        }

        private void CheckPercents() {
            if (!particlesOn && flamePropagationPercent >= particlesOnFlamePropagationPercent) {
                ParticlesFireOn();
            }
            if (flamePropagationPercent >= 1) {
                propagationFnished = true;
            }
            if (combustionPercent >= 1) {
                burning = false;
                burnedUp = true;
                OnBurnableBurnedUp.Invoke();
            }
            if (particlesOn && combustionPercent >= particlesOffCombustionPercent) {
                ParticlesFireOff();
            }
            
            if (withAshes) {
                if (!particlesAshesOn && coolingPercent >= 1) {
                    ParticlesAshesOn();
                }
                if (!disappeared && particlesAshesOn && disappearPercent < 1) {
                    Disappear();
                }
            }

            if (coolingPercent >= 1) {
                cold = true;
            }
        }

        private void Disappear() {
            elapsedSecondsDisappear += Time.deltaTime;
            disappearPercent = elapsedSecondsDisappear / disappearSeconds;
            if (disappearPercent >= 1) {
                disappearPercent = 1;
                disappeared = true;
                if (destroyAtAshes) {
                    particleAshesGameobject.transform.parent = null;
                    Destroy(gameObject);
                    Destroy(particleAshesGameobject, secondsToDestroyAshes);
                } else {
                    Collider collider = GetComponent<Collider>();
                    if (collider != null) {
                        collider.isTrigger = true;
                    }
                }
            } 
            SetOpacity();
        }

        private void SetOpacity() {
            float opacity = 1 - disappearPercent;
            material.SetFloat("_Opacity", opacity);
        }

        private void SetBurn() {
            float flameValue = Mathf.Clamp(flamePropagationPercent,0,1) /propagationSmooth;
            material.SetFloat("_Burn",flameValue);
            if (combustionPercent >= combustionsSignsAtCombustionPercent) {
                float combustionValue = (combustionPercent - combustionsSignsAtCombustionPercent) * (1.0f/(1.0f-combustionsSignsAtCombustionPercent));
                material.SetFloat("_BurnedValue", Mathf.Clamp(combustionValue, 0, 1));
            }
            material.SetFloat("_BurnedEmissionValue",coolingCurve.Evaluate(1-coolingPercent));
        }

        #endregion

        #region Collision Methods

        // private void OnCollisionEnter(Collision collision) {
        //     BurnableObject otherBurnable = collision.gameObject.GetComponent<BurnableObject>();
        //     if (otherBurnable != null && !burning && !burnedUp && otherBurnable.IsBurning()) {
        //         Ignite(collision.contacts.FirstOrDefault().point);
        //     }
        // }
        //
        // private void OnTriggerEnter(Collider other) {
        //     BurnableObject otherBurnable = other.gameObject.GetComponent<BurnableObject>();
        //     if (otherBurnable != null && !burning && !burnedUp && otherBurnable.IsBurning()) {
        //         Ignite(otherBurnable.gameObject.GetComponent<Collider>().ClosestPointOnBounds(transform.position));
        //     }
        // }

        #endregion

        #region Configuration Methods

        private void InitMaterial() {
            material = GetComponent<MeshRenderer>().material;
            material.SetFloat("_Opacity", 1);
            material.SetColor("_Hot", hot);
            material.SetColor("_Warm", warm);
            material.SetColor("_BurnedEmissiveColor", burnedEmissiveColor);
            material.SetColor("_BorderColor", borderColor);
        }

        private void InitParticles() {
            MeshRenderer meshRenderer = GetComponent<MeshRenderer>();
            if (particlesFirePrefab != null) {
                particleFireGameobject = Instantiate(particlesFirePrefab, transform);
                particleFireGameobject.transform.position = transform.position;
                particleSystems = particleFireGameobject.GetComponentsInChildren<ParticleSystem>().ToList();
                particleSystems.ForEach(particleSystem => {
                    ParticleSystem.ShapeModule shapeModule = particleSystem.shape;
                    shapeModule.shapeType = ParticleSystemShapeType.MeshRenderer;
                    shapeModule.meshRenderer = meshRenderer;
                    shapeModule.meshShapeType = ParticleSystemMeshShapeType.Triangle;
                });
            }
            if (particlesAshesPrefab != null) {
                particleAshesGameobject = Instantiate(particlesAshesPrefab, transform);
                particleAshesGameobject.transform.position = transform.position;
                ashesParticleSystem = particleAshesGameobject.GetComponent<ParticleSystem>();
                ParticleSystem.ShapeModule shapeModule = ashesParticleSystem.shape;
                shapeModule.shapeType = ParticleSystemShapeType.MeshRenderer;
                shapeModule.meshRenderer = meshRenderer;
                shapeModule.meshShapeType = ParticleSystemMeshShapeType.Triangle;
            }
        }

        private void ParticlesFireOn() {
            particleSystems.ForEach(particleSystem => {
                particleSystem.Play();
            });
            particlesOn = true;
        }
        
        private void ParticlesFireOff() {
            particleSystems.ForEach(particleSystem => {
                particleSystem.Stop();
            });
        }
        
        private void ParticlesAshesOn() {
            ashesParticleSystem.Play();
            material.renderQueue = 5000;
            particlesAshesOn = true;
        }
        
        private void ParticlesAshesOff() {
            ashesParticleSystem.Stop();
        }
        
        #endregion

        #region Visuals Methods

        #endregion
        
#if UNITY_EDITOR

        #region Gizmos

        private void OnDrawGizmos() {
            Gizmos.color = Color.red;
            Gizmos.DrawWireSphere(transform.position + igniteRadiousOffset, igniteRadious);
        }

        private void OnDrawGizmosSelected() {
            
        }

        #endregion
        
        #region Editor

        public void SetCorrectShader(Material material, Shader shader) {
            if (material.name.Contains("Default")) {
                return;
            }
            material.shader = shader;
        }

        public void GenerateMaterial(Shader shader) {
            Material newMaterial = new Material(shader);
            gameObject.GetComponent<MeshRenderer>().sharedMaterial = newMaterial;
            string savePath = "Assets/BurnableMaterials/";
            if (!Directory.Exists(savePath)) {
                Directory.CreateDirectory(savePath);
            }
            savePath = savePath.Substring(0, savePath.LastIndexOf('/') + 1);
 
            string newAssetName = savePath + gameObject.name + "_burnableMaterial.mat";
 
            AssetDatabase.CreateAsset(newMaterial, newAssetName);
 
            AssetDatabase.SaveAssets();
            
        }

        #endregion
        
    #endif
    }
    
#if UNITY_EDITOR
    [CustomEditor(typeof(BurnableObject))]
    [CanEditMultipleObjects]
    public class BurnableObjectEditor : Editor {

        private BurnableObject myTarget;
        private Shader burnShader;
        private Shader burnShaderURP;
        private Shader burnShaderHDRP;
        private Material material;
        private bool correctMaterial;
        void OnEnable() {
            myTarget = (BurnableObject)target;
            CheckMaterial();
        }

        public override void OnInspectorGUI() {
            DrawDefaultInspector();

            if (!correctMaterial) {
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField("Material shader incorrect or default material",new GUIStyle(EditorStyles.textField) {normal = new GUIStyleState() {textColor = Color.red}});
                if (GUILayout.Button("Set Correct Shader")) {
                    myTarget.GenerateMaterial(burnShader);
                    CheckMaterial();
                }
                if (GUILayout.Button("Set Correct Shader URP")) {
                    myTarget.GenerateMaterial(burnShaderURP);
                    CheckMaterial();
                }
                if (GUILayout.Button("Set Correct Shader HDRP")) {
                    myTarget.GenerateMaterial(burnShaderHDRP);
                    CheckMaterial();
                }
                EditorGUILayout.EndHorizontal();
            }
            if (GUILayout.Button("Ignite")) {
                myTarget.Ignite(myTarget.transform.position);
                CheckMaterial();
            }
            if (!myTarget.IsBurning()) {
                material.SetVector("_IgnitePosition", myTarget.transform.position);
            }
        }

        private void CheckMaterial() {
            burnShader = Shader.Find("FernandoOleaDev/BurnShader");
            burnShaderURP = Shader.Find("FernandoOleaDev/BurnShaderURP");
            burnShaderHDRP = Shader.Find("FernandoOleaDev/BurnShaderHDRP");
            material = myTarget.GetComponent<MeshRenderer>()?.sharedMaterial;
            correctMaterial = material.shader == burnShader ||  material.shader == burnShaderURP || material.shader == burnShaderHDRP;
            if (!correctMaterial && !myTarget.dontAsk) {
                int option = EditorUtility.DisplayDialogComplex("Incorrect shader",
                    "Do you want to change " + myTarget.name + " material shader?",
                    "Yes",
                    "No",
                    "No & Don't Ask again");
                switch (option) {
                    // Yes.
                    case 0:
                        myTarget.GenerateMaterial(burnShader);
                        CheckMaterial();
                        break;
                    // No.
                    case 1:
                        break;
                    // No & Don't Ask again.
                    case 2:
                        myTarget.dontAsk = true;
                        break;
                    default:
                        break;
                }
            }
        }
    }
#endif
}
