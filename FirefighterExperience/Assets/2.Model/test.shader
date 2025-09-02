Shader "Custom/test"
{
    Properties
    {
        [HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_AlbedoColor("Albedo Color", Color) = (1,1,1,1)
		_baseMap_BaseMap ("Base Map", 2D) = "white" {}
		_Albedo("Albedo", 2D) = "white" {}
		_Normal("Normal", 2D) = "white" {}
		_BurnedEmission("Burned Emission", 2D) = "white" {}
		_Burned("Burned", 2D) = "white" {}
		_BurnComplement("Burn Complement", Float) = 0.5
		_Mask("Mask", 2D) = "white" {}
		_DistortionMap("Distortion Map", 2D) = "white" {}
		_IgnitePosition("Ignite Position", Vector) = (0,0,0,0)
		_DistortionAmount("Distortion Amount", Range( 0 , 1)) = 0.5
		_Burn("Burn", Range( 0 , 1)) = 0
		_ScrollSpeed("Scroll Speed", Range( 0 , 1)) = 0.5
		_Hot("Hot ", Color) = (0.9887359,1,0,0)
		_Warm("Warm", Color) = (1,0.3847524,0,0)
		_Heatwave("Heat wave", Range( 0 , 1)) = 0.1
		_WiggleAmount("Wiggle Amount", Float) = 0.05
		_Radious("Radious", Range( 0 , 2)) = 0.1828547
		[HDR]_BurnedEmissiveColor("Burned Emissive Color", Color) = (2,0.9960784,0,1)
		_BurnedValue("Burned Value", Range( 0 , 1)) = 0
		_BurnedEmissionValue("Burned Emission Value", Range( 0 , 1)) = 0.716
		_BurnedEmissionQuantity("Burned Emission Quantity", Range( 0 , 1)) = 0.5
		[HDR]_BorderColor("Border Color", Color) = (0,0.2140574,1,0)
		_BorderOffset("Border Offset", Range( 0 , 1)) = 0.066
		_BurnEmissiveValue("Burn Emissive Value", Range( 0 , 1)) = 0.5
		_NoiseValue("Noise Value", Range( 0 , 1)) = 0.15
		_Opacity("Opacity", Range( 0 , 1)) = 1
		[ASEEnd]_Smoothness("Smoothness", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
