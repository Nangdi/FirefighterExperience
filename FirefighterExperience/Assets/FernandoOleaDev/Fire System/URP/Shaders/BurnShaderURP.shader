// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FernandoOleaDev/BurnShaderURP"
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

		//_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		//_TransStrength( "Trans Strength", Range( 0, 50 ) ) = 1
		//_TransNormal( "Trans Normal Distortion", Range( 0, 1 ) ) = 0.5
		//_TransScattering( "Trans Scattering", Range( 1, 50 ) ) = 2
		//_TransDirect( "Trans Direct", Range( 0, 1 ) ) = 0.9
		//_TransAmbient( "Trans Ambient", Range( 0, 1 ) ) = 0.1
		//_TransShadow( "Trans Shadow", Range( 0, 1 ) ) = 0.5
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		

		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
Cull Back
ZWrite On
Blend Off
		
		HLSLINCLUDE
		#pragma target 2.0

		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x 

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}
		
		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS

		ENDHLSL

		
// 		Pass
// 		{
			
// 			Name "Forward"
// 			Tags { "LightMode"="UniversalForward" }
			
// 			  // ZWrite On               // 깊이 버퍼 기록
//     // ZTest LEqual
//     Blend Off               // 블렌딩 끄기 → 불투명
//     Offset 0 , 0
//     ColorMask RGBA
			

// 			HLSLPROGRAM
			
// 			#define _NORMAL_DROPOFF_TS 1
// 			#pragma multi_compile_instancing
// 			#pragma multi_compile _ LOD_FADE_CROSSFADE
// 			#pragma multi_compile_fog
// 			#define ASE_FOG 1
// 			#define _EMISSION
// 			#define _NORMALMAP 1
// 			#define ASE_SRP_VERSION 100700

			
// 			#pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
// 			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
// 			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
// 			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
// 			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
// 			#pragma multi_compile _ _SHADOWS_SOFT
// 			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			
// 			#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
// 			#pragma multi_compile _ SHADOWS_SHADOWMASK

// 			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
// 			#pragma multi_compile _ LIGHTMAP_ON

// 			#pragma vertex vert
// 			#pragma fragment frag

// 			#define SHADERPASS_FORWARD

// 			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
// 			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
// 			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
// 			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
// 			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
// 			#if ASE_SRP_VERSION <= 70108
// 			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
// 			#endif

// 			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
// 			    #define ENABLE_TERRAIN_PERPIXEL_NORMAL
// 			#endif

// 			#define ASE_NEEDS_VERT_POSITION
// 			#define ASE_NEEDS_FRAG_WORLD_POSITION


// 			struct VertexInput
// 			{
// 				float4 vertex : POSITION;
// 				float3 ase_normal : NORMAL;
// 				float4 ase_tangent : TANGENT;
// 				float4 texcoord1 : TEXCOORD1;
// 				float4 texcoord : TEXCOORD0;
				
// 				UNITY_VERTEX_INPUT_INSTANCE_ID
// 			};

// 			struct VertexOutput
// 			{
// 				float4 clipPos : SV_POSITION;
// 				float4 lightmapUVOrVertexSH : TEXCOORD0;
// 				half4 fogFactorAndVertexLight : TEXCOORD1;
// 				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
// 				float4 shadowCoord : TEXCOORD2;
// 				#endif
// 				float4 tSpace0 : TEXCOORD3;
// 				float4 tSpace1 : TEXCOORD4;
// 				float4 tSpace2 : TEXCOORD5;
// 				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
// 				float4 screenPos : TEXCOORD6;
// 				#endif
// 				float4 ase_texcoord7 : TEXCOORD7;
// 				UNITY_VERTEX_INPUT_INSTANCE_ID
// 				UNITY_VERTEX_OUTPUT_STEREO
// 			};

// 			CBUFFER_START(UnityPerMaterial)
// 			float4 _BurnedEmission_ST;
// 			float4 _BorderColor;
// 			float4 _Albedo_ST;
// 			float4 _Burned_ST;
// 			float4 _AlbedoColor;
// 			float4 _Normal_ST;
// 			float4 _BurnedEmissiveColor;
// 			float4 _DistortionMap_ST;
// 			float4 _Warm;
// 			float4 _Hot;
// 			float3 _IgnitePosition;
// 			float _BorderOffset;
// 			float _NoiseValue;
// 			float _Heatwave;
// 			float _Radious;
// 			float _DistortionAmount;
// 			float _BurnedValue;
// 			float _BurnEmissiveValue;
// 			float _BurnedEmissionQuantity;
// 			float _Opacity;
// 			float _WiggleAmount;
// 			float _Burn;
// 			float _BurnComplement;
// 			float _ScrollSpeed;
// 			float _BurnedEmissionValue;
// 			float _Smoothness;
// 			#ifdef _TRANSMISSION_ASE
// 				float _TransmissionShadow;
// 			#endif
// 			#ifdef _TRANSLUCENCY_ASE
// 				float _TransStrength;
// 				float _TransNormal;
// 				float _TransScattering;
// 				float _TransDirect;
// 				float _TransAmbient;
// 				float _TransShadow;
// 			#endif
// 			#ifdef TESSELLATION_ON
// 				float _TessPhongStrength;
// 				float _TessValue;
// 				float _TessMin;
// 				float _TessMax;
// 				float _TessEdgeLength;
// 				float _TessMaxDisp;
// 			#endif
// 			CBUFFER_END
// 			sampler2D _DistortionMap;
// 			sampler2D _Albedo;
// 			sampler2D _Burned;
// 			sampler2D _Normal;
// 			sampler2D _BurnedEmission;
// 			sampler2D _Mask;


			
// 			VertexOutput VertexFunction( VertexInput v  )
// 			{
// 				VertexOutput o = (VertexOutput)0;
// 				UNITY_SETUP_INSTANCE_ID(v);
// 				UNITY_TRANSFER_INSTANCE_ID(v, o);
// 				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

// 				float temp_output_148_0 = ( 1.0 - _BurnedValue );
// 				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
// 				float temp_output_14_0 = ( _TimeParameters.x * _ScrollSpeed );
// 				float2 texCoord38 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
// 				float2 panner37 = ( temp_output_14_0 * float2( 0,-1 ) + texCoord38);
// 				float3 tex2DNode34 = UnpackNormalScale( tex2Dlod( _DistortionMap, float4( panner37, 0, 0.0) ), 1.0f );
// 				float temp_output_243_0 = ( _BurnComplement * _Burn );
				
// 				o.ase_texcoord7.xy = v.texcoord.xy;
				
// 				//setting value to unused interpolator channels and avoid initialization warnings
// 				o.ase_texcoord7.zw = 0;
// 				#ifdef ASE_ABSOLUTE_VERTEX_POS
// 					float3 defaultVertexValue = v.vertex.xyz;
// 				#else
// 					float3 defaultVertexValue = float3(0, 0, 0);
// 				#endif
// 				float3 vertexValue = ( temp_output_148_0 * ( ( ( ase_worldPos * v.vertex.xyz ) * tex2DNode34 * temp_output_243_0 ) * _WiggleAmount ) );
// 				#ifdef ASE_ABSOLUTE_VERTEX_POS
// 					v.vertex.xyz = vertexValue;
// 				#else
// 					v.vertex.xyz += vertexValue;
// 				#endif
// 				v.ase_normal = v.ase_normal;

// 				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
// 				float3 positionVS = TransformWorldToView( positionWS );
// 				float4 positionCS = TransformWorldToHClip( positionWS );

// 				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

// 				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
// 				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
// 				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

// 				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
// 				OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );

// 				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
// 					o.lightmapUVOrVertexSH.zw = v.texcoord;
// 					o.lightmapUVOrVertexSH.xy = v.texcoord * unity_LightmapST.xy + unity_LightmapST.zw;
// 				#endif

// 				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );
// 				#ifdef ASE_FOG
// 					half fogFactor = ComputeFogFactor( positionCS.z );
// 				#else
// 					half fogFactor = 0;
// 				#endif
// 				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
				
// 				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
// 				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
// 				vertexInput.positionWS = positionWS;
// 				vertexInput.positionCS = positionCS;
// 				o.shadowCoord = GetShadowCoord( vertexInput );
// 				#endif
				
// 				o.clipPos = positionCS;
// 				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
// 				o.screenPos = ComputeScreenPos(positionCS);
// 				#endif
// 				return o;
// 			}
			
// 			#if defined(TESSELLATION_ON)
// 			struct VertexControl
// 			{
// 				float4 vertex : INTERNALTESSPOS;
// 				float3 ase_normal : NORMAL;
// 				float4 ase_tangent : TANGENT;
// 				float4 texcoord : TEXCOORD0;
// 				float4 texcoord1 : TEXCOORD1;
				
// 				UNITY_VERTEX_INPUT_INSTANCE_ID
// 			};

// 			struct TessellationFactors
// 			{
// 				float edge[3] : SV_TessFactor;
// 				float inside : SV_InsideTessFactor;
// 			};

// 			VertexControl vert ( VertexInput v )
// 			{
// 				VertexControl o;
// 				UNITY_SETUP_INSTANCE_ID(v);
// 				UNITY_TRANSFER_INSTANCE_ID(v, o);
// 				o.vertex = v.vertex;
// 				o.ase_normal = v.ase_normal;
// 				o.ase_tangent = v.ase_tangent;
// 				o.texcoord = v.texcoord;
// 				o.texcoord1 = v.texcoord1;
				
// 				return o;
// 			}

// 			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
// 			{
// 				TessellationFactors o;
// 				float4 tf = 1;
// 				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
// 				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
// 				#if defined(ASE_FIXED_TESSELLATION)
// 				tf = FixedTess( tessValue );
// 				#elif defined(ASE_DISTANCE_TESSELLATION)
// 				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
// 				#elif defined(ASE_LENGTH_TESSELLATION)
// 				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
// 				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
// 				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
// 				#endif
// 				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
// 				return o;
// 			}

// 			[domain("tri")]
// 			[partitioning("fractional_odd")]
// 			[outputtopology("triangle_cw")]
// 			[patchconstantfunc("TessellationFunction")]
// 			[outputcontrolpoints(3)]
// 			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
// 			{
// 			   return patch[id];
// 			}

// 			[domain("tri")]
// 			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
// 			{
// 				VertexInput o = (VertexInput) 0;
// 				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
// 				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
// 				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
// 				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
// 				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				
// 				#if defined(ASE_PHONG_TESSELLATION)
// 				float3 pp[3];
// 				for (int i = 0; i < 3; ++i)
// 					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
// 				float phongStrength = _TessPhongStrength;
// 				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
// 				#endif
// 				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
// 				return VertexFunction(o);
// 			}
// 			#else
// 			VertexOutput vert ( VertexInput v )
// 			{
// 				return VertexFunction( v );
// 			}
// 			#endif

// 			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
// 				#define ASE_SV_DEPTH SV_DepthLessEqual  
// 			#else
// 				#define ASE_SV_DEPTH SV_Depth
// 			#endif

// 			half4 frag ( VertexOutput IN 
// 						#ifdef ASE_DEPTH_WRITE_ON
// 						,out float outputDepth : ASE_SV_DEPTH
// 						#endif
// 						 ) : SV_Target
// 			{
// 				UNITY_SETUP_INSTANCE_ID(IN);
// 				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

// 				#ifdef LOD_FADE_CROSSFADE
// 					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
// 				#endif

// 				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
// 					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
// 					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
// 					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
// 					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
// 				#else
// 					float3 WorldNormal = normalize( IN.tSpace0.xyz );
// 					float3 WorldTangent = IN.tSpace1.xyz;
// 					float3 WorldBiTangent = IN.tSpace2.xyz;
// 				#endif
// 				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
// 				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
// 				float4 ShadowCoords = float4( 0, 0, 0, 0 );
// 				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
// 				float4 ScreenPos = IN.screenPos;
// 				#endif

// 				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
// 					ShadowCoords = IN.shadowCoord;
// 				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
// 					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
// 				#endif
	
// 				WorldViewDirection = SafeNormalize( WorldViewDirection );

// 				float2 uv_Albedo = IN.ase_texcoord7.xy * _Albedo_ST.xy + _Albedo_ST.zw;
// 				float2 uv_Burned = IN.ase_texcoord7.xy * _Burned_ST.xy + _Burned_ST.zw;
// 				float4 lerpResult142 = lerp( tex2D( _Albedo, uv_Albedo ) , tex2D( _Burned, uv_Burned ) , _BurnedValue);
				
// 				float2 uv_Normal = IN.ase_texcoord7.xy * _Normal_ST.xy + _Normal_ST.zw;
				
// 				float2 uv_BurnedEmission = IN.ase_texcoord7.xy * _BurnedEmission_ST.xy + _BurnedEmission_ST.zw;
// 				float temp_output_148_0 = ( 1.0 - _BurnedValue );
// 				float2 uv_DistortionMap = IN.ase_texcoord7.xy * _DistortionMap_ST.xy + _DistortionMap_ST.zw;
// 				float temp_output_14_0 = ( _TimeParameters.x * _ScrollSpeed );
// 				float2 panner12 = ( temp_output_14_0 * float2( 0,-1 ) + float2( 0,0 ));
// 				float2 texCoord10 = IN.ase_texcoord7.xy * float2( 1,1 ) + panner12;
// 				float4 lerpResult18 = lerp( _Warm , _Hot , tex2D( _Mask, ( ( (UnpackNormalScale( tex2D( _DistortionMap, uv_DistortionMap ), 1.0f )).xy * _DistortionAmount ) + texCoord10 ) ).r);
// 				float4 temp_cast_1 = (1.5).xxxx;
// 				float4 color122 = IsGammaSpace() ? float4(1,0.5641353,0,1) : float4(1,0.2782784,0,1);
// 				float temp_output_83_0 = distance( WorldPosition , _IgnitePosition );
// 				float3 temp_cast_3 = (temp_output_83_0).xxx;
// 				float temp_output_243_0 = ( _BurnComplement * _Burn );
// 				float2 texCoord38 = IN.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
// 				float2 panner37 = ( temp_output_14_0 * float2( 0,-1 ) + texCoord38);
// 				float3 tex2DNode34 = UnpackNormalScale( tex2D( _DistortionMap, panner37 ), 1.0f );
// 				float2 texCoord42 = IN.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
// 				float4 tex2DNode23 = tex2D( _Mask, ( float2( 0,0 ) + ( ( (tex2DNode34).xy * _Heatwave ) + texCoord42 ) ) );
// 				float4 color261 = IsGammaSpace() ? float4(0.5803922,0.5803922,0.5803922,1) : float4(0.2961383,0.2961383,0.2961383,1);
// 				float lerpResult257 = lerp( tex2DNode23.r , color261.r , ( 1.0 - _NoiseValue ));
// 				float clampResult104 = clamp( ( ( temp_output_83_0 / ( _Radious * temp_output_243_0 ) ) * lerpResult257 ) , 0.0 , 1.0 );
// 				float temp_output_120_0 = ( saturate( ( 1.0 - ( ( distance( color122.rgb , temp_cast_3 ) - 4.26 ) / max( 3.08 , 1E-05 ) ) ) ) * clampResult104 );
// 				float4 lerpResult99 = lerp( ( pow( lerpResult18 , temp_cast_1 ) * 1.5 ) , float4( 0,0,0,0 ) , temp_output_120_0);
// 				float lerpResult221 = lerp( temp_output_120_0 , ( 1.0 - _BorderOffset ) , 7.47);
// 				float lerpResult237 = lerp( ( 1.0 - temp_output_120_0 ) , 0.0 , lerpResult221);
// 				float4 lerpResult240 = lerp( ( lerpResult99 - float4( 0,0,0,0 ) ) , float4( 0,0,0,0 ) , lerpResult237);
// 				float4 lerpResult156 = lerp( _BorderColor , _Warm , tex2DNode23.r);
// 				float4 lerpResult181 = lerp( lerpResult156 , float4( 0,0,0,0 ) , ( 1.0 - lerpResult237 ));
// 				float4 clampResult254 = clamp( lerpResult181 , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
				
// 				// float3 Albedo = ( ( lerpResult142 * _AlbedoColor ) * _Opacity ).rgb;
// 				float3 Albedo = tex2D(_Albedo, uv_Albedo).rgb * _AlbedoColor.rgb;

// // 추가: 밝기 보정 (Standard Lit 처럼)
// // Albedo = GammaToLinearSpace(Albedo); // Linear 공간 보정
// 				float3 Normal = UnpackNormalScale( tex2D( _Normal, uv_Normal ), 1.0f );
// 				float3 Emission = ( ( _BurnedEmissionQuantity * ( ( _BurnedValue * ( _BurnedEmissiveColor * tex2D( _BurnedEmission, uv_BurnedEmission ) ) ) * _BurnedEmissionValue ) ) + ( temp_output_148_0 * ( ( lerpResult240 + clampResult254 ) * _BurnEmissiveValue ) ) ).rgb;
// 				float3 Specular = 0.5;
// 				float Metallic = 0;
// 				float Smoothness = _Smoothness;
// 				float Occlusion = 1;
// 				float Alpha = _Opacity;
// 				float AlphaClipThreshold = 0.5;
// 				float AlphaClipThresholdShadow = 0.5;
// 				float3 BakedGI = 0;
// 				float3 RefractionColor = 1;
// 				float RefractionIndex = 1;
// 				float3 Transmission = 1;
// 				float3 Translucency = 1;
// 				#ifdef ASE_DEPTH_WRITE_ON
// 				float DepthValue = 0;
// 				#endif

// 				#ifdef _ALPHATEST_ON
// 					clip(Alpha - AlphaClipThreshold);
// 				#endif

// 				InputData inputData;
// 				inputData.positionWS = WorldPosition;
// 				inputData.viewDirectionWS = WorldViewDirection;
// 				inputData.shadowCoord = ShadowCoords;

// 				#ifdef _NORMALMAP
// 					#if _NORMAL_DROPOFF_TS
// 					inputData.normalWS = TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
// 					#elif _NORMAL_DROPOFF_OS
// 					inputData.normalWS = TransformObjectToWorldNormal(Normal);
// 					#elif _NORMAL_DROPOFF_WS
// 					inputData.normalWS = Normal;
// 					#endif
// 					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
// 				#else
// 					inputData.normalWS = WorldNormal;
// 				#endif

// 				#ifdef ASE_FOG
// 					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
// 				#endif

// 				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
// 				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
// 					float3 SH = SampleSH(inputData.normalWS.xyz);
// 				#else
// 					float3 SH = IN.lightmapUVOrVertexSH.xyz;
// 				#endif

// 				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );
// 				#ifdef _ASE_BAKEDGI
// 					inputData.bakedGI = BakedGI;
// 				#endif
				
// 				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(IN.clipPos);
// 				inputData.shadowMask = SAMPLE_SHADOWMASK(IN.lightmapUVOrVertexSH.xy);

// 				half4 color = UniversalFragmentPBR(
// 					inputData, 
// 					Albedo, 
// 					Metallic, 
// 					Specular, 
// 					Smoothness, 
// 					Occlusion, 
// 					Emission, 
// 					Alpha);

// 				#ifdef _TRANSMISSION_ASE
// 				{
// 					float shadow = _TransmissionShadow;

// 					Light mainLight = GetMainLight( inputData.shadowCoord );
// 					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
// 					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );
// 					half3 mainTransmission = max(0 , -dot(inputData.normalWS, mainLight.direction)) * mainAtten * Transmission;
// 					color.rgb += Albedo * mainTransmission;

// 					#ifdef _ADDITIONAL_LIGHTS
// 						int transPixelLightCount = GetAdditionalLightsCount();
// 						for (int i = 0; i < transPixelLightCount; ++i)
// 						{
// 							Light light = GetAdditionalLight(i, inputData.positionWS);
// 							float3 atten = light.color * light.distanceAttenuation;
// 							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

// 							half3 transmission = max(0 , -dot(inputData.normalWS, light.direction)) * atten * Transmission;
// 							color.rgb += Albedo * transmission;
// 						}
// 					#endif
// 				}
// 				#endif

// 				#ifdef _TRANSLUCENCY_ASE
// 				{
// 					float shadow = _TransShadow;
// 					float normal = _TransNormal;
// 					float scattering = _TransScattering;
// 					float direct = _TransDirect;
// 					float ambient = _TransAmbient;
// 					float strength = _TransStrength;

// 					Light mainLight = GetMainLight( inputData.shadowCoord );
// 					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
// 					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );

// 					half3 mainLightDir = mainLight.direction + inputData.normalWS * normal;
// 					half mainVdotL = pow( saturate( dot( inputData.viewDirectionWS, -mainLightDir ) ), scattering );
// 					half3 mainTranslucency = mainAtten * ( mainVdotL * direct + inputData.bakedGI * ambient ) * Translucency;
// 					color.rgb += Albedo * mainTranslucency * strength;

// 					#ifdef _ADDITIONAL_LIGHTS
// 						int transPixelLightCount = GetAdditionalLightsCount();
// 						for (int i = 0; i < transPixelLightCount; ++i)
// 						{
// 							Light light = GetAdditionalLight(i, inputData.positionWS);
// 							float3 atten = light.color * light.distanceAttenuation;
// 							atten = lerp( atten, atten * light.shadowAttenuation, shadow );

// 							half3 lightDir = light.direction + inputData.normalWS * normal;
// 							half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );
// 							half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;
// 							color.rgb += Albedo * translucency * strength;
// 						}
// 					#endif
// 				}
// 				#endif

// 				#ifdef _REFRACTION_ASE
// 					float4 projScreenPos = ScreenPos / ScreenPos.w;
// 					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, float4( WorldNormal,0 ) ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
// 					projScreenPos.xy += refractionOffset.xy;
// 					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos.xy ) * RefractionColor;
// 					color.rgb = lerp( refraction, color.rgb, color.a );
// 					color.a = 1;
// 				#endif

// 				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
// 					color.rgb *= color.a;
// 				#endif

// 				#ifdef ASE_FOG
// 					#ifdef TERRAIN_SPLAT_ADDPASS
// 						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
// 					#else
// 						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
// 					#endif
// 				#endif

// 				#ifdef ASE_DEPTH_WRITE_ON
// 					outputDepth = DepthValue;
// 				#endif

// 				return color;
// 			}

// 			ENDHLSL
// 		}
// Pass           mmmmmmmmmmmmmmmmmmmmmmmmmmmmmㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
// {
//     Name "ForwardLit"
//     Tags { "LightMode"="UniversalForward" }

//     HLSLPROGRAM
//     #pragma vertex vert
//     #pragma fragment frag
//     #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
//     #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

//     struct Attributes {
//         float4 positionOS : POSITION;
//         float3 normalOS   : NORMAL;
//         float2 uv         : TEXCOORD0;
//     };

//     struct Varyings {
//         float4 positionCS : SV_POSITION;
//         float3 positionWS : TEXCOORD0;
//         float3 normalWS   : TEXCOORD1;
//         float2 uv         : TEXCOORD2;
//     };

//     Varyings vert (Attributes IN) {
//         Varyings OUT;
//         OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
//         OUT.positionCS = TransformWorldToHClip(OUT.positionWS);
//         OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
//         OUT.uv = IN.uv;
//         return OUT;
//     }

//     // === BurnableObject 가 제어하는 머티리얼 변수들 ===
//     CBUFFER_START(UnityPerMaterial)
//         float4 _AlbedoColor;
//         float  _BurnedValue;
//         float  _Burn;
//         float  _BurnedEmissionValue;
//         float  _BurnedEmissionQuantity;
//         float  _Opacity;
//         float4 _Hot;
//         float4 _Warm;
//         float4 _BurnedEmissiveColor;
//         float4 _BorderColor;
//         float3 _IgnitePosition;
//     CBUFFER_END

//     TEXTURE2D(_Albedo);        SAMPLER(sampler_Albedo);
//     TEXTURE2D(_Burned);        SAMPLER(sampler_Burned);
//     TEXTURE2D(_BurnedEmission);SAMPLER(sampler_BurnedEmission);

//    half4 frag (Varyings IN) : SV_Target
// {
//     // 기본 알베도
//     float3 texAlbedo = SAMPLE_TEXTURE2D(_Albedo, sampler_Albedo, IN.uv).rgb;
//     float3 texBurned = SAMPLE_TEXTURE2D(_Burned, sampler_Burned, IN.uv).rgb;
//     float3 albedoMix = lerp(texAlbedo, texBurned, _BurnedValue);

//     half3 albedo = albedoMix * _AlbedoColor.rgb * _Opacity;

//     // 단순 색상 출력 (씬 전체 조명/그림자만 영향받음)
//     return half4(albedo, 1.0);
// }
//     ENDHLSL
// }
Pass
{
    Name "ForwardLit"
    Tags { "LightMode"="UniversalForward" }

    HLSLPROGRAM
    #pragma vertex vert
    #pragma fragment frag
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
    #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
    #pragma multi_compile_fragment _ _SHADOWS_SOFT
    #pragma multi_compile_fog

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

    struct Attributes {
        float4 positionOS : POSITION;
        float3 normalOS   : NORMAL;
        float2 uv         : TEXCOORD0;
    };

    struct Varyings {
        float4 positionCS : SV_POSITION;
        float3 positionWS : TEXCOORD0;
        float3 normalWS   : TEXCOORD1;
        float2 uv         : TEXCOORD2;
        float4 shadowCoord : TEXCOORD3;
    };

    Varyings vert (Attributes IN) {
        Varyings OUT;
        OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
        OUT.positionCS = TransformWorldToHClip(OUT.positionWS);
        OUT.normalWS   = TransformObjectToWorldNormal(IN.normalOS);
        OUT.uv         = IN.uv;
        OUT.shadowCoord = TransformWorldToShadowCoord(OUT.positionWS);
        return OUT;
    }

    // BurnableObject 변수들 유지
    CBUFFER_START(UnityPerMaterial)
        float4 _AlbedoColor;
        float  _BurnedValue;
        float  _Opacity;
    CBUFFER_END

    TEXTURE2D(_Albedo); SAMPLER(sampler_Albedo);
    TEXTURE2D(_Burned); SAMPLER(sampler_Burned);

    half4 frag (Varyings IN) : SV_Target
    {
        // 원본 / 불탄 텍스처 섞기
        float3 texAlbedo = SAMPLE_TEXTURE2D(_Albedo, sampler_Albedo, IN.uv).rgb;
        float3 texBurned = SAMPLE_TEXTURE2D(_Burned, sampler_Burned, IN.uv).rgb;
        float3 albedoMix = lerp(texAlbedo, texBurned, _BurnedValue);

        // 최종 색상
        half3 albedo = albedoMix * _AlbedoColor.rgb * _Opacity;

       // 표준 Unity 조명 입력
InputData lightingInput = (InputData)0;
lightingInput.positionWS      = IN.positionWS;
lightingInput.normalWS        = normalize(IN.normalWS);
lightingInput.viewDirectionWS = GetWorldSpaceViewDir(IN.positionWS);
lightingInput.shadowCoord     = IN.shadowCoord;

// ✅ 추가: GI / Ambient / Fog
lightingInput.bakedGI         = SAMPLE_GI(IN.uv, IN.positionWS, lightingInput.normalWS);
lightingInput.vertexLighting  = 0;
lightingInput.fogCoord        = ComputeFogFactor(IN.positionCS.z);
        // PBR SurfaceData
        SurfaceData surface = (SurfaceData)0;
        surface.albedo = albedo;
        surface.metallic = 0.0;
        surface.specular = 0.5;
        surface.smoothness = 0.5;
        surface.occlusion = 1.0;
        surface.emission = 0;

        return UniversalFragmentPBR(lightingInput, surface);
    }
    ENDHLSL
}



		
		Pass
		{
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off
			ColorMask 0

			HLSLPROGRAM
			
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 100700

			
			#pragma vertex vert
			#pragma fragment frag
#if ASE_SRP_VERSION >= 110000
			#pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
#endif
			#define SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BurnedEmission_ST;
			float4 _BorderColor;
			float4 _Albedo_ST;
			float4 _Burned_ST;
			float4 _AlbedoColor;
			float4 _Normal_ST;
			float4 _BurnedEmissiveColor;
			float4 _DistortionMap_ST;
			float4 _Warm;
			float4 _Hot;
			float3 _IgnitePosition;
			float _BorderOffset;
			float _NoiseValue;
			float _Heatwave;
			float _Radious;
			float _DistortionAmount;
			float _BurnedValue;
			float _BurnEmissiveValue;
			float _BurnedEmissionQuantity;
			float _Opacity;
			float _WiggleAmount;
			float _Burn;
			float _BurnComplement;
			float _ScrollSpeed;
			float _BurnedEmissionValue;
			float _Smoothness;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _DistortionMap;


			
			float3 _LightDirection;
#if ASE_SRP_VERSION >= 110000 
			float3 _LightPosition;
#endif
			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float temp_output_148_0 = ( 1.0 - _BurnedValue );
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float temp_output_14_0 = ( _TimeParameters.x * _ScrollSpeed );
				float2 texCoord38 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner37 = ( temp_output_14_0 * float2( 0,-1 ) + texCoord38);
				float3 tex2DNode34 = UnpackNormalScale( tex2Dlod( _DistortionMap, float4( panner37, 0, 0.0) ), 1.0f );
				float temp_output_243_0 = ( _BurnComplement * _Burn );
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( temp_output_148_0 * ( ( ( ase_worldPos * v.vertex.xyz ) * tex2DNode34 * temp_output_243_0 ) * _WiggleAmount ) );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				float3 normalWS = TransformObjectToWorldDir(v.ase_normal);

		#if ASE_SRP_VERSION >= 110000 
			#if _CASTING_PUNCTUAL_LIGHT_SHADOW
				float3 lightDirectionWS = normalize(_LightPosition - positionWS);
			#else
				float3 lightDirectionWS = _LightDirection;
			#endif
				float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
			#if UNITY_REVERSED_Z
				clipPos.z = min(clipPos.z, UNITY_NEAR_CLIP_VALUE);
			#else
				clipPos.z = max(clipPos.z, UNITY_NEAR_CLIP_VALUE);
			#endif
		#else
				float4 clipPos = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));
			#if UNITY_REVERSED_Z
				clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
			#else
				clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
			#endif
		#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual  
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif

			half4 frag(	VertexOutput IN 
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );
				
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				
				float Alpha = _Opacity;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				#ifdef ASE_DEPTH_WRITE_ON
				float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif
				return 0;
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 100700

			
			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BurnedEmission_ST;
			float4 _BorderColor;
			float4 _Albedo_ST;
			float4 _Burned_ST;
			float4 _AlbedoColor;
			float4 _Normal_ST;
			float4 _BurnedEmissiveColor;
			float4 _DistortionMap_ST;
			float4 _Warm;
			float4 _Hot;
			float3 _IgnitePosition;
			float _BorderOffset;
			float _NoiseValue;
			float _Heatwave;
			float _Radious;
			float _DistortionAmount;
			float _BurnedValue;
			float _BurnEmissiveValue;
			float _BurnedEmissionQuantity;
			float _Opacity;
			float _WiggleAmount;
			float _Burn;
			float _BurnComplement;
			float _ScrollSpeed;
			float _BurnedEmissionValue;
			float _Smoothness;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _DistortionMap;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float temp_output_148_0 = ( 1.0 - _BurnedValue );
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float temp_output_14_0 = ( _TimeParameters.x * _ScrollSpeed );
				float2 texCoord38 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner37 = ( temp_output_14_0 * float2( 0,-1 ) + texCoord38);
				float3 tex2DNode34 = UnpackNormalScale( tex2Dlod( _DistortionMap, float4( panner37, 0, 0.0) ), 1.0f );
				float temp_output_243_0 = ( _BurnComplement * _Burn );
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( temp_output_148_0 * ( ( ( ase_worldPos * v.vertex.xyz ) * tex2DNode34 * temp_output_243_0 ) * _WiggleAmount ) );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;
				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual  
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif
			half4 frag(	VertexOutput IN 
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				
				float Alpha = _Opacity;
				float AlphaClipThreshold = 0.5;
				#ifdef ASE_DEPTH_WRITE_ON
				float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				#ifdef ASE_DEPTH_WRITE_ON
				outputDepth = DepthValue;
				#endif

				return 0;
			}
			ENDHLSL
		}
		
		
		Pass
		{
			
			Name "Meta"
			Tags { "LightMode"="Meta" }

			Cull Off

			HLSLPROGRAM
			
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 100700

			
			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_META

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BurnedEmission_ST;
			float4 _BorderColor;
			float4 _Albedo_ST;
			float4 _Burned_ST;
			float4 _AlbedoColor;
			float4 _Normal_ST;
			float4 _BurnedEmissiveColor;
			float4 _DistortionMap_ST;
			float4 _Warm;
			float4 _Hot;
			float3 _IgnitePosition;
			float _BorderOffset;
			float _NoiseValue;
			float _Heatwave;
			float _Radious;
			float _DistortionAmount;
			float _BurnedValue;
			float _BurnEmissiveValue;
			float _BurnedEmissionQuantity;
			float _Opacity;
			float _WiggleAmount;
			float _Burn;
			float _BurnComplement;
			float _ScrollSpeed;
			float _BurnedEmissionValue;
			float _Smoothness;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _DistortionMap;
			sampler2D _Albedo;
			sampler2D _Burned;
			sampler2D _BurnedEmission;
			sampler2D _Mask;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float temp_output_148_0 = ( 1.0 - _BurnedValue );
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float temp_output_14_0 = ( _TimeParameters.x * _ScrollSpeed );
				float2 texCoord38 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner37 = ( temp_output_14_0 * float2( 0,-1 ) + texCoord38);
				float3 tex2DNode34 = UnpackNormalScale( tex2Dlod( _DistortionMap, float4( panner37, 0, 0.0) ), 1.0f );
				float temp_output_243_0 = ( _BurnComplement * _Burn );
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( temp_output_148_0 * ( ( ( ase_worldPos * v.vertex.xyz ) * tex2DNode34 * temp_output_243_0 ) * _WiggleAmount ) );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = MetaVertexPosition( v.vertex, v.texcoord1.xy, v.texcoord1.xy, unity_LightmapST, unity_DynamicLightmapST );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.texcoord1 = v.texcoord1;
				o.texcoord2 = v.texcoord2;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_Albedo = IN.ase_texcoord2.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				float2 uv_Burned = IN.ase_texcoord2.xy * _Burned_ST.xy + _Burned_ST.zw;
				float4 lerpResult142 = lerp( tex2D( _Albedo, uv_Albedo ) , tex2D( _Burned, uv_Burned ) , _BurnedValue);
				
				float2 uv_BurnedEmission = IN.ase_texcoord2.xy * _BurnedEmission_ST.xy + _BurnedEmission_ST.zw;
				float temp_output_148_0 = ( 1.0 - _BurnedValue );
				float2 uv_DistortionMap = IN.ase_texcoord2.xy * _DistortionMap_ST.xy + _DistortionMap_ST.zw;
				float temp_output_14_0 = ( _TimeParameters.x * _ScrollSpeed );
				float2 panner12 = ( temp_output_14_0 * float2( 0,-1 ) + float2( 0,0 ));
				float2 texCoord10 = IN.ase_texcoord2.xy * float2( 1,1 ) + panner12;
				float4 lerpResult18 = lerp( _Warm , _Hot , tex2D( _Mask, ( ( (UnpackNormalScale( tex2D( _DistortionMap, uv_DistortionMap ), 1.0f )).xy * _DistortionAmount ) + texCoord10 ) ).r);
				float4 temp_cast_1 = (1.5).xxxx;
				float4 color122 = IsGammaSpace() ? float4(1,0.5641353,0,1) : float4(1,0.2782784,0,1);
				float temp_output_83_0 = distance( WorldPosition , _IgnitePosition );
				float3 temp_cast_3 = (temp_output_83_0).xxx;
				float temp_output_243_0 = ( _BurnComplement * _Burn );
				float2 texCoord38 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner37 = ( temp_output_14_0 * float2( 0,-1 ) + texCoord38);
				float3 tex2DNode34 = UnpackNormalScale( tex2D( _DistortionMap, panner37 ), 1.0f );
				float2 texCoord42 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode23 = tex2D( _Mask, ( float2( 0,0 ) + ( ( (tex2DNode34).xy * _Heatwave ) + texCoord42 ) ) );
				float4 color261 = IsGammaSpace() ? float4(0.5803922,0.5803922,0.5803922,1) : float4(0.2961383,0.2961383,0.2961383,1);
				float lerpResult257 = lerp( tex2DNode23.r , color261.r , ( 1.0 - _NoiseValue ));
				float clampResult104 = clamp( ( ( temp_output_83_0 / ( _Radious * temp_output_243_0 ) ) * lerpResult257 ) , 0.0 , 1.0 );
				float temp_output_120_0 = ( saturate( ( 1.0 - ( ( distance( color122.rgb , temp_cast_3 ) - 4.26 ) / max( 3.08 , 1E-05 ) ) ) ) * clampResult104 );
				float4 lerpResult99 = lerp( ( pow( lerpResult18 , temp_cast_1 ) * 1.5 ) , float4( 0,0,0,0 ) , temp_output_120_0);
				float lerpResult221 = lerp( temp_output_120_0 , ( 1.0 - _BorderOffset ) , 7.47);
				float lerpResult237 = lerp( ( 1.0 - temp_output_120_0 ) , 0.0 , lerpResult221);
				float4 lerpResult240 = lerp( ( lerpResult99 - float4( 0,0,0,0 ) ) , float4( 0,0,0,0 ) , lerpResult237);
				float4 lerpResult156 = lerp( _BorderColor , _Warm , tex2DNode23.r);
				float4 lerpResult181 = lerp( lerpResult156 , float4( 0,0,0,0 ) , ( 1.0 - lerpResult237 ));
				float4 clampResult254 = clamp( lerpResult181 , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
				
				
				float3 Albedo = ( ( lerpResult142 * _AlbedoColor ) * _Opacity ).rgb;
				float3 Emission = ( ( _BurnedEmissionQuantity * ( ( _BurnedValue * ( _BurnedEmissiveColor * tex2D( _BurnedEmission, uv_BurnedEmission ) ) ) * _BurnedEmissionValue ) ) + ( temp_output_148_0 * ( ( lerpResult240 + clampResult254 ) * _BurnEmissiveValue ) ) ).rgb;
				float Alpha = _Opacity;
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				MetaInput metaInput = (MetaInput)0;
				metaInput.Albedo = Albedo;
				metaInput.Emission = Emission;
				
				return MetaFragment(metaInput);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }

			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA

			HLSLPROGRAM
			
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 100700

			
			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_2D

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			
			#define ASE_NEEDS_VERT_POSITION


			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BurnedEmission_ST;
			float4 _BorderColor;
			float4 _Albedo_ST;
			float4 _Burned_ST;
			float4 _AlbedoColor;
			float4 _Normal_ST;
			float4 _BurnedEmissiveColor;
			float4 _DistortionMap_ST;
			float4 _Warm;
			float4 _Hot;
			float3 _IgnitePosition;
			float _BorderOffset;
			float _NoiseValue;
			float _Heatwave;
			float _Radious;
			float _DistortionAmount;
			float _BurnedValue;
			float _BurnEmissiveValue;
			float _BurnedEmissionQuantity;
			float _Opacity;
			float _WiggleAmount;
			float _Burn;
			float _BurnComplement;
			float _ScrollSpeed;
			float _BurnedEmissionValue;
			float _Smoothness;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _DistortionMap;
			sampler2D _Albedo;
			sampler2D _Burned;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float temp_output_148_0 = ( 1.0 - _BurnedValue );
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float temp_output_14_0 = ( _TimeParameters.x * _ScrollSpeed );
				float2 texCoord38 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner37 = ( temp_output_14_0 * float2( 0,-1 ) + texCoord38);
				float3 tex2DNode34 = UnpackNormalScale( tex2Dlod( _DistortionMap, float4( panner37, 0, 0.0) ), 1.0f );
				float temp_output_243_0 = ( _BurnComplement * _Burn );
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( temp_output_148_0 * ( ( ( ase_worldPos * v.vertex.xyz ) * tex2DNode34 * temp_output_243_0 ) * _WiggleAmount ) );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif

				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_Albedo = IN.ase_texcoord2.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				float2 uv_Burned = IN.ase_texcoord2.xy * _Burned_ST.xy + _Burned_ST.zw;
				float4 lerpResult142 = lerp( tex2D( _Albedo, uv_Albedo ) , tex2D( _Burned, uv_Burned ) , _BurnedValue);
				
				
				float3 Albedo = ( ( lerpResult142 * _AlbedoColor ) * _Opacity ).rgb;
				float Alpha = _Opacity;
				float AlphaClipThreshold = 0.5;

				half4 color = half4( Albedo, Alpha );

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				return color;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthNormals"
			Tags { "LightMode"="DepthNormals" }

			ZWrite On
			Blend One Zero
            ZTest LEqual
            ZWrite On

			HLSLPROGRAM
			
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 100700

			
			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float3 worldNormal : TEXCOORD2;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BurnedEmission_ST;
			float4 _BorderColor;
			float4 _Albedo_ST;
			float4 _Burned_ST;
			float4 _AlbedoColor;
			float4 _Normal_ST;
			float4 _BurnedEmissiveColor;
			float4 _DistortionMap_ST;
			float4 _Warm;
			float4 _Hot;
			float3 _IgnitePosition;
			float _BorderOffset;
			float _NoiseValue;
			float _Heatwave;
			float _Radious;
			float _DistortionAmount;
			float _BurnedValue;
			float _BurnEmissiveValue;
			float _BurnedEmissionQuantity;
			float _Opacity;
			float _WiggleAmount;
			float _Burn;
			float _BurnComplement;
			float _ScrollSpeed;
			float _BurnedEmissionValue;
			float _Smoothness;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _DistortionMap;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float temp_output_148_0 = ( 1.0 - _BurnedValue );
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float temp_output_14_0 = ( _TimeParameters.x * _ScrollSpeed );
				float2 texCoord38 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner37 = ( temp_output_14_0 * float2( 0,-1 ) + texCoord38);
				float3 tex2DNode34 = UnpackNormalScale( tex2Dlod( _DistortionMap, float4( panner37, 0, 0.0) ), 1.0f );
				float temp_output_243_0 = ( _BurnComplement * _Burn );
				
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( temp_output_148_0 * ( ( ( ase_worldPos * v.vertex.xyz ) * tex2DNode34 * temp_output_243_0 ) * _WiggleAmount ) );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;
				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal( v.ase_normal );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.worldNormal = normalWS;

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = positionCS;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual  
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif
			half4 frag(	VertexOutput IN 
						#ifdef ASE_DEPTH_WRITE_ON
						,out float outputDepth : ASE_SV_DEPTH
						#endif
						 ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				
				float Alpha = _Opacity;
				float AlphaClipThreshold = 0.5;
				#ifdef ASE_DEPTH_WRITE_ON
				float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				
				#ifdef ASE_DEPTH_WRITE_ON
				outputDepth = DepthValue;
				#endif
				
				return float4(PackNormalOctRectEncode(TransformWorldToViewDir(IN.worldNormal, true)), 0.0, 0.0);
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "GBuffer"
			Tags { "LightMode"="UniversalGBuffer" }
			
			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#define _NORMAL_DROPOFF_TS 1
			#pragma multi_compile_instancing
			#pragma multi_compile _ LOD_FADE_CROSSFADE
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _EMISSION
			#define _NORMALMAP 1
			#define ASE_SRP_VERSION 100700

			
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
			#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
			#pragma multi_compile _ _SHADOWS_SOFT
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			#pragma multi_compile _ _GBUFFER_NORMALS_OCT
			
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON

			#pragma vertex vert
			#pragma fragment frag

			#define SHADERPASS SHADERPASS_GBUFFER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#if defined(UNITY_INSTANCING_ENABLED) && defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL)
			    #define ENABLE_TERRAIN_PERPIXEL_NORMAL
			#endif

			#define ASE_NEEDS_VERT_POSITION
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord1 : TEXCOORD1;
				float4 texcoord : TEXCOORD0;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 lightmapUVOrVertexSH : TEXCOORD0;
				half4 fogFactorAndVertexLight : TEXCOORD1;
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord : TEXCOORD2;
				#endif
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 screenPos : TEXCOORD6;
				#endif
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BurnedEmission_ST;
			float4 _BorderColor;
			float4 _Albedo_ST;
			float4 _Burned_ST;
			float4 _AlbedoColor;
			float4 _Normal_ST;
			float4 _BurnedEmissiveColor;
			float4 _DistortionMap_ST;
			float4 _Warm;
			float4 _Hot;
			float3 _IgnitePosition;
			float _BorderOffset;
			float _NoiseValue;
			float _Heatwave;
			float _Radious;
			float _DistortionAmount;
			float _BurnedValue;
			float _BurnEmissiveValue;
			float _BurnedEmissionQuantity;
			float _Opacity;
			float _WiggleAmount;
			float _Burn;
			float _BurnComplement;
			float _ScrollSpeed;
			float _BurnedEmissionValue;
			float _Smoothness;
			#ifdef _TRANSMISSION_ASE
				float _TransmissionShadow;
			#endif
			#ifdef _TRANSLUCENCY_ASE
				float _TransStrength;
				float _TransNormal;
				float _TransScattering;
				float _TransDirect;
				float _TransAmbient;
				float _TransShadow;
			#endif
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _DistortionMap;
			sampler2D _Albedo;
			sampler2D _Burned;
			sampler2D _Normal;
			sampler2D _BurnedEmission;
			sampler2D _Mask;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float temp_output_148_0 = ( 1.0 - _BurnedValue );
				float3 ase_worldPos = mul(GetObjectToWorldMatrix(), v.vertex).xyz;
				float temp_output_14_0 = ( _TimeParameters.x * _ScrollSpeed );
				float2 texCoord38 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner37 = ( temp_output_14_0 * float2( 0,-1 ) + texCoord38);
				float3 tex2DNode34 = UnpackNormalScale( tex2Dlod( _DistortionMap, float4( panner37, 0, 0.0) ), 1.0f );
				float temp_output_243_0 = ( _BurnComplement * _Burn );
				
				o.ase_texcoord7.xy = v.texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord7.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = ( temp_output_148_0 * ( ( ( ase_worldPos * v.vertex.xyz ) * tex2DNode34 * temp_output_243_0 ) * _WiggleAmount ) );
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 positionVS = TransformWorldToView( positionWS );
				float4 positionCS = TransformWorldToHClip( positionWS );

				VertexNormalInputs normalInput = GetVertexNormalInputs( v.ase_normal, v.ase_tangent );

				o.tSpace0 = float4( normalInput.normalWS, positionWS.x);
				o.tSpace1 = float4( normalInput.tangentWS, positionWS.y);
				o.tSpace2 = float4( normalInput.bitangentWS, positionWS.z);

				OUTPUT_LIGHTMAP_UV( v.texcoord1, unity_LightmapST, o.lightmapUVOrVertexSH.xy );
				OUTPUT_SH( normalInput.normalWS.xyz, o.lightmapUVOrVertexSH.xyz );

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					o.lightmapUVOrVertexSH.zw = v.texcoord;
					o.lightmapUVOrVertexSH.xy = v.texcoord * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif

				half3 vertexLight = VertexLighting( positionWS, normalInput.normalWS );
				#ifdef ASE_FOG
					half fogFactor = ComputeFogFactor( positionCS.z );
				#else
					half fogFactor = 0;
				#endif
				o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
				
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				
				o.clipPos = positionCS;
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				o.screenPos = ComputeScreenPos(positionCS);
				#endif
				return o;
			}
			
			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
				float4 texcoord1 : TEXCOORD1;
				
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.texcoord = v.texcoord;
				o.texcoord1 = v.texcoord1;
				
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
				o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
				
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			#if defined(ASE_EARLY_Z_DEPTH_OPTIMIZE)
				#define ASE_SV_DEPTH SV_DepthLessEqual  
			#else
				#define ASE_SV_DEPTH SV_Depth
			#endif
			FragmentOutput frag ( VertexOutput IN 
								#ifdef ASE_DEPTH_WRITE_ON
								,out float outputDepth : ASE_SV_DEPTH
								#endif
								 )
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float2 sampleCoords = (IN.lightmapUVOrVertexSH.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
					float3 WorldNormal = TransformObjectToWorldNormal(normalize(SAMPLE_TEXTURE2D(_TerrainNormalmapTexture, sampler_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
					float3 WorldTangent = -cross(GetObjectToWorldMatrix()._13_23_33, WorldNormal);
					float3 WorldBiTangent = cross(WorldNormal, -WorldTangent);
				#else
					float3 WorldNormal = normalize( IN.tSpace0.xyz );
					float3 WorldTangent = IN.tSpace1.xyz;
					float3 WorldBiTangent = IN.tSpace2.xyz;
				#endif
				float3 WorldPosition = float3(IN.tSpace0.w,IN.tSpace1.w,IN.tSpace2.w);
				float3 WorldViewDirection = _WorldSpaceCameraPos.xyz  - WorldPosition;
				float4 ShadowCoords = float4( 0, 0, 0, 0 );
				#if defined(ASE_NEEDS_FRAG_SCREEN_POSITION)
				float4 ScreenPos = IN.screenPos;
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					ShadowCoords = IN.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
				#endif
	
				WorldViewDirection = SafeNormalize( WorldViewDirection );

				float2 uv_Albedo = IN.ase_texcoord7.xy * _Albedo_ST.xy + _Albedo_ST.zw;
				float2 uv_Burned = IN.ase_texcoord7.xy * _Burned_ST.xy + _Burned_ST.zw;
				float4 lerpResult142 = lerp( tex2D( _Albedo, uv_Albedo ) , tex2D( _Burned, uv_Burned ) , _BurnedValue);
				
				float2 uv_Normal = IN.ase_texcoord7.xy * _Normal_ST.xy + _Normal_ST.zw;
				
				float2 uv_BurnedEmission = IN.ase_texcoord7.xy * _BurnedEmission_ST.xy + _BurnedEmission_ST.zw;
				float temp_output_148_0 = ( 1.0 - _BurnedValue );
				float2 uv_DistortionMap = IN.ase_texcoord7.xy * _DistortionMap_ST.xy + _DistortionMap_ST.zw;
				float temp_output_14_0 = ( _TimeParameters.x * _ScrollSpeed );
				float2 panner12 = ( temp_output_14_0 * float2( 0,-1 ) + float2( 0,0 ));
				float2 texCoord10 = IN.ase_texcoord7.xy * float2( 1,1 ) + panner12;
				float4 lerpResult18 = lerp( _Warm , _Hot , tex2D( _Mask, ( ( (UnpackNormalScale( tex2D( _DistortionMap, uv_DistortionMap ), 1.0f )).xy * _DistortionAmount ) + texCoord10 ) ).r);
				float4 temp_cast_1 = (1.5).xxxx;
				float4 color122 = IsGammaSpace() ? float4(1,0.5641353,0,1) : float4(1,0.2782784,0,1);
				float temp_output_83_0 = distance( WorldPosition , _IgnitePosition );
				float3 temp_cast_3 = (temp_output_83_0).xxx;
				float temp_output_243_0 = ( _BurnComplement * _Burn );
				float2 texCoord38 = IN.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner37 = ( temp_output_14_0 * float2( 0,-1 ) + texCoord38);
				float3 tex2DNode34 = UnpackNormalScale( tex2D( _DistortionMap, panner37 ), 1.0f );
				float2 texCoord42 = IN.ase_texcoord7.xy * float2( 1,1 ) + float2( 0,0 );
				float4 tex2DNode23 = tex2D( _Mask, ( float2( 0,0 ) + ( ( (tex2DNode34).xy * _Heatwave ) + texCoord42 ) ) );
				float4 color261 = IsGammaSpace() ? float4(0.5803922,0.5803922,0.5803922,1) : float4(0.2961383,0.2961383,0.2961383,1);
				float lerpResult257 = lerp( tex2DNode23.r , color261.r , ( 1.0 - _NoiseValue ));
				float clampResult104 = clamp( ( ( temp_output_83_0 / ( _Radious * temp_output_243_0 ) ) * lerpResult257 ) , 0.0 , 1.0 );
				float temp_output_120_0 = ( saturate( ( 1.0 - ( ( distance( color122.rgb , temp_cast_3 ) - 4.26 ) / max( 3.08 , 1E-05 ) ) ) ) * clampResult104 );
				float4 lerpResult99 = lerp( ( pow( lerpResult18 , temp_cast_1 ) * 1.5 ) , float4( 0,0,0,0 ) , temp_output_120_0);
				float lerpResult221 = lerp( temp_output_120_0 , ( 1.0 - _BorderOffset ) , 7.47);
				float lerpResult237 = lerp( ( 1.0 - temp_output_120_0 ) , 0.0 , lerpResult221);
				float4 lerpResult240 = lerp( ( lerpResult99 - float4( 0,0,0,0 ) ) , float4( 0,0,0,0 ) , lerpResult237);
				float4 lerpResult156 = lerp( _BorderColor , _Warm , tex2DNode23.r);
				float4 lerpResult181 = lerp( lerpResult156 , float4( 0,0,0,0 ) , ( 1.0 - lerpResult237 ));
				float4 clampResult254 = clamp( lerpResult181 , float4( 0,0,0,0 ) , float4( 1,1,1,0 ) );
				
				float3 Albedo = ( ( lerpResult142 * _AlbedoColor ) * _Opacity ).rgb;
				float3 Normal = UnpackNormalScale( tex2D( _Normal, uv_Normal ), 1.0f );
				float3 Emission = ( ( _BurnedEmissionQuantity * ( ( _BurnedValue * ( _BurnedEmissiveColor * tex2D( _BurnedEmission, uv_BurnedEmission ) ) ) * _BurnedEmissionValue ) ) + ( temp_output_148_0 * ( ( lerpResult240 + clampResult254 ) * _BurnEmissiveValue ) ) ).rgb;
				float3 Specular = 0.5;
				float Metallic = 0;
				float Smoothness = _Smoothness;
				float Occlusion = 1;
				float Alpha = _Opacity;
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;
				float3 BakedGI = 0;
				float3 RefractionColor = 1;
				float RefractionIndex = 1;
				float3 Transmission = 1;
				float3 Translucency = 1;
				#ifdef ASE_DEPTH_WRITE_ON
				float DepthValue = 0;
				#endif

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				InputData inputData;
				inputData.positionWS = WorldPosition;
				inputData.viewDirectionWS = WorldViewDirection;
				inputData.shadowCoord = ShadowCoords;

				#ifdef _NORMALMAP
					#if _NORMAL_DROPOFF_TS
					inputData.normalWS = TransformTangentToWorld(Normal, half3x3( WorldTangent, WorldBiTangent, WorldNormal ));
					#elif _NORMAL_DROPOFF_OS
					inputData.normalWS = TransformObjectToWorldNormal(Normal);
					#elif _NORMAL_DROPOFF_WS
					inputData.normalWS = Normal;
					#endif
					inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				#else
					inputData.normalWS = WorldNormal;
				#endif

				#ifdef ASE_FOG
					inputData.fogCoord = IN.fogFactorAndVertexLight.x;
				#endif

				inputData.vertexLighting = IN.fogFactorAndVertexLight.yzw;
				#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
					float3 SH = SampleSH(inputData.normalWS.xyz);
				#else
					float3 SH = IN.lightmapUVOrVertexSH.xyz;
				#endif

				inputData.bakedGI = SAMPLE_GI( IN.lightmapUVOrVertexSH.xy, SH, inputData.normalWS );
				#ifdef _ASE_BAKEDGI
					inputData.bakedGI = BakedGI;
				#endif

				BRDFData brdfData;
				InitializeBRDFData( Albedo, Metallic, Specular, Smoothness, Alpha, brdfData);
				half4 color;
				color.rgb = GlobalIllumination( brdfData, inputData.bakedGI, Occlusion, inputData.normalWS, inputData.viewDirectionWS);
				color.a = Alpha;

				#ifdef _TRANSMISSION_ASE
				{
					float shadow = _TransmissionShadow;
				
					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );
					half3 mainTransmission = max(0 , -dot(inputData.normalWS, mainLight.direction)) * mainAtten * Transmission;
					color.rgb += Albedo * mainTransmission;
				
					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );
				
							half3 transmission = max(0 , -dot(inputData.normalWS, light.direction)) * atten * Transmission;
							color.rgb += Albedo * transmission;
						}
					#endif
				}
				#endif
				
				#ifdef _TRANSLUCENCY_ASE
				{
					float shadow = _TransShadow;
					float normal = _TransNormal;
					float scattering = _TransScattering;
					float direct = _TransDirect;
					float ambient = _TransAmbient;
					float strength = _TransStrength;
				
					Light mainLight = GetMainLight( inputData.shadowCoord );
					float3 mainAtten = mainLight.color * mainLight.distanceAttenuation;
					mainAtten = lerp( mainAtten, mainAtten * mainLight.shadowAttenuation, shadow );
				
					half3 mainLightDir = mainLight.direction + inputData.normalWS * normal;
					half mainVdotL = pow( saturate( dot( inputData.viewDirectionWS, -mainLightDir ) ), scattering );
					half3 mainTranslucency = mainAtten * ( mainVdotL * direct + inputData.bakedGI * ambient ) * Translucency;
					color.rgb += Albedo * mainTranslucency * strength;
				
					#ifdef _ADDITIONAL_LIGHTS
						int transPixelLightCount = GetAdditionalLightsCount();
						for (int i = 0; i < transPixelLightCount; ++i)
						{
							Light light = GetAdditionalLight(i, inputData.positionWS);
							float3 atten = light.color * light.distanceAttenuation;
							atten = lerp( atten, atten * light.shadowAttenuation, shadow );
				
							half3 lightDir = light.direction + inputData.normalWS * normal;
							half VdotL = pow( saturate( dot( inputData.viewDirectionWS, -lightDir ) ), scattering );
							half3 translucency = atten * ( VdotL * direct + inputData.bakedGI * ambient ) * Translucency;
							color.rgb += Albedo * translucency * strength;
						}
					#endif
				}
				#endif
				
				#ifdef _REFRACTION_ASE
					float4 projScreenPos = ScreenPos / ScreenPos.w;
					float3 refractionOffset = ( RefractionIndex - 1.0 ) * mul( UNITY_MATRIX_V, float4( WorldNormal, 0 ) ).xyz * ( 1.0 - dot( WorldNormal, WorldViewDirection ) );
					projScreenPos.xy += refractionOffset.xy;
					float3 refraction = SHADERGRAPH_SAMPLE_SCENE_COLOR( projScreenPos.xy ) * RefractionColor;
					color.rgb = lerp( refraction, color.rgb, color.a );
					color.a = 1;
				#endif
				
				#ifdef ASE_FINAL_COLOR_ALPHA_MULTIPLY
					color.rgb *= color.a;
				#endif
				
				#ifdef ASE_FOG
					#ifdef TERRAIN_SPLAT_ADDPASS
						color.rgb = MixFogColor(color.rgb, half3( 0, 0, 0 ), IN.fogFactorAndVertexLight.x );
					#else
						color.rgb = MixFog(color.rgb, IN.fogFactorAndVertexLight.x);
					#endif
				#endif
				
				#ifdef ASE_DEPTH_WRITE_ON
					outputDepth = DepthValue;
				#endif
				
				return BRDFDataToGbuffer(brdfData, inputData, Smoothness, Emission + color.rgb);
			}

			ENDHLSL
		}
		
	}
	
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18935
-1262;6;1280;963;-4117.503;432.8496;1.3;True;True
Node;AmplifyShaderEditor.RangedFloatNode;15;-2532.471,598.0767;Inherit;False;Property;_ScrollSpeed;Scroll Speed;11;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;13;-2427.44,431.6177;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-2250.714,491.9632;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;38;-2565.275,861.6467;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;5;-1859.134,48.60458;Inherit;True;Property;_DistortionMap;Distortion Map;7;0;Create;True;0;0;0;False;0;False;2b1a8f21a03ceac458be942cf1d2c3bb;2b1a8f21a03ceac458be942cf1d2c3bb;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.PannerNode;37;-2150.289,921.0687;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;34;-1669.145,850.3341;Inherit;True;Property;_TextureSample3;Texture Sample 3;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;39;-1296.816,879.1255;Inherit;True;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-1360.5,1123.853;Inherit;False;Property;_Heatwave;Heat wave;14;0;Create;True;0;0;0;False;0;False;0.1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-987.1444,888.1452;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;42;-1000.479,1134.975;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;540.4363,437.8204;Inherit;True;Property;_Burn;Burn;10;0;Create;True;0;0;0;False;0;False;0;0.3696827;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;241;659.9708,282.5988;Inherit;False;Property;_BurnComplement;Burn Complement;5;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-705.4518,988.9401;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;81;1474.985,-614.0461;Inherit;False;Property;_IgnitePosition;Ignite Position;8;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;82;1478.119,-763.3414;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;6;-1520.415,54.965;Inherit;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;259;-291.2563,1021.983;Inherit;False;Property;_NoiseValue;Noise Value;24;0;Create;True;0;0;0;False;0;False;0.15;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;2;-939.3911,-141.3561;Inherit;True;Property;_Mask;Mask;6;0;Create;True;0;0;0;False;0;False;4b2ba27a6a753a94a8128faebf2f85a0;21a28dc0208659849a8ce5aac732704a;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;107;1603.575,-392.3406;Inherit;False;Property;_Radious;Radious;16;0;Create;True;0;0;0;False;0;False;0.1828547;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;72;-509.9009,615.5985;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;243;878.9641,299.5897;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;23;-295.7572,421.5832;Inherit;True;Property;_TextureSample2;Texture Sample 2;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;9;-1147.336,322.2137;Inherit;False;Property;_DistortionAmount;Distortion Amount;9;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;1909.204,-288.6359;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;260;3.043607,1011.397;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;12;-1431.823,492.4725;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;261;-55.63222,782.0242;Inherit;False;Constant;_Color1;Color 1;27;0;Create;True;0;0;0;False;0;False;0.5803922,0.5803922,0.5803922,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;83;1753.754,-700.6537;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;7;-1093.456,121.781;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;10;-1132.252,488.1626;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-834.8355,188.5918;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;257;208.4192,744.6213;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;108;2047.49,-515.5246;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;122;2209.219,-745.5472;Inherit;False;Constant;_Color0;Color 0;15;0;Create;True;0;0;0;False;0;False;1,0.5641353,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-667.7291,279.3643;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;2240.289,-304.0139;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-414.9413,-158.4928;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;174;2469.679,-53.90163;Inherit;False;Property;_BorderOffset;Border Offset;22;0;Create;True;0;0;0;False;0;False;0.066;0.35;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;104;2401.482,-237.0999;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;17;-404.1541,-451.4974;Inherit;False;Property;_Hot;Hot ;12;0;Create;True;0;0;0;False;0;False;0.9887359,1,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;16;-418.8863,-686.412;Inherit;False;Property;_Warm;Warm;13;0;Create;True;0;0;0;False;0;False;1,0.3847524,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;121;2367.819,-545.3472;Inherit;False;Color Mask;-1;;3;eec747d987850564c95bde0e5a6d1867;0;4;1;FLOAT3;0,0,0;False;3;FLOAT3;256,256,256;False;4;FLOAT;4.26;False;5;FLOAT;3.08;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;2541.652,-318.6801;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;18;59.56415,-533.3942;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;239;2764.273,95.9801;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;221.2018,-119.5995;Inherit;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;222;2948.315,-494.7758;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;20;380.6855,-533.395;Inherit;True;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;221;2902.894,-254.0226;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.68;False;2;FLOAT;7.47;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;166;-315.2205,99.24629;Inherit;False;Property;_BorderColor;Border Color;21;1;[HDR];Create;True;0;0;0;False;0;False;0,0.2140574,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;237;3170.644,-407.6335;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;688.8762,-533.3945;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;99;3158.123,94.83076;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;238;3396.901,-286.7773;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;156;92.12936,12.30105;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;144;3891.846,-583.3491;Inherit;True;Property;_BurnedEmission;Burned Emission;3;0;Create;True;0;0;0;False;0;False;-1;c2a51129c261b2448875f79ed40b9322;c2a51129c261b2448875f79ed40b9322;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;177;3450.239,137.0309;Inherit;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;134;3631.052,-447.5884;Inherit;False;Property;_BurnedEmissiveColor;Burned Emissive Color;17;1;[HDR];Create;True;0;0;0;False;0;False;2,0.9960784,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;181;3622.717,352.1974;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;4219.051,-500.6572;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;53;1159.098,-205.5029;Inherit;True;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;55;1002.388,-451.3068;Inherit;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;240;3690.044,-56.46889;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;254;3910.245,343.3853;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;143;3933.304,-352.317;Inherit;False;Property;_BurnedValue;Burned Value;18;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;140;3943.143,-1086.648;Inherit;True;Property;_Burned;Burned;4;0;Create;True;0;0;0;False;0;False;-1;a95f52500bf6e5244baaa814c3589ca8;a95f52500bf6e5244baaa814c3589ca8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;28;935.4064,-793.4656;Inherit;True;Property;_Albedo;Albedo;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;167;3952.262,98.92515;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;255;4092.245,389.3853;Inherit;False;Property;_BurnEmissiveValue;Burn Emissive Value;23;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;150;3840.611,-167.6197;Inherit;False;Property;_BurnedEmissionValue;Burned Emission Value;19;0;Create;True;0;0;0;False;0;False;0.716;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;1435.055,-321.585;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;4220.376,-265.6968;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;1700.643,-107.0391;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;58;1673.644,252.4638;Inherit;False;Property;_WiggleAmount;Wiggle Amount;15;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;4413.062,-231.5433;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;153;4455.373,-368.7309;Inherit;False;Property;_BurnedEmissionQuantity;Burned Emission Quantity;20;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;142;4417.281,-848.1109;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;266;4845.319,-592.8013;Inherit;False;Property;_AlbedoColor;Albedo Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;148;4133.675,-113.5824;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;256;4381.245,356.3853;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;269;4834.643,332.614;Inherit;False;Property;_Opacity;Opacity;25;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;4477.874,20.048;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;154;4621.999,-263.1327;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;1967.737,267.7921;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;267;5090.515,-694.4405;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;283;4775.304,-140.3496;Inherit;False;Property;_Metallic;Metallic;26;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;145;4713.042,8.702801;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;139;3951.772,-869.7904;Inherit;True;Property;_Normal;Normal;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;284;4767.504,-64.94963;Inherit;False;Property;_Smoothness;Smoothness;27;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;273;4814.154,490.0592;Inherit;False;Constant;_Float2;Float 2;28;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;4266.561,159.0264;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;274;5216.154,424.0592;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;270;5071.072,-312.1632;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ConditionalIfNode;272;5060.154,430.0592;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;97;-643.2159,-272.3637;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;279;5141.9,-129.9364;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;281;5141.9,-129.9364;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthNormals;0;6;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthNormals;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;280;5141.9,-129.9364;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;278;5141.9,-129.9364;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;282;5141.9,-129.9364;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;GBuffer;0;7;GBuffer;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalGBuffer;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;277;5141.9,-129.9364;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;275;5141.9,-129.9364;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;New Amplify Shader;94348b07e5e8bab40bd6c8a1e3df54cd;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;276;5219.895,-124.7364;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;2;FernandoOleaDev/BurnShaderURP;94348b07e5e8bab40bd6c8a1e3df54cd;True;Forward;0;1;Forward;18;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;38;Workflow;1;637833861258641071;Surface;1;637833861029900438;  Refraction Model;0;637833862945979364;  Blend;0;637833862173733737;Two Sided;1;0;Fragment Normal Space,InvertActionOnDeselection;0;0;Transmission;0;0;  Transmission Shadow;0.5,False,-1;0;Translucency;0;0;  Translucency Strength;1,False,-1;0;  Normal Distortion;0.5,False,-1;0;  Scattering;2,False,-1;0;  Direct;0.9,False,-1;0;  Ambient;0.1,False,-1;0;  Shadow;0.5,False,-1;0;Cast Shadows;1;0;  Use Shadow Threshold;0;0;Receive Shadows;1;0;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;1;0;_FinalColorxAlpha;0;0;Meta Pass;1;0;Override Baked GI;0;0;Extra Pre Pass;0;0;DOTS Instancing;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,-1;0;  Type;0;0;  Tess;16,False,-1;0;  Min;10,False,-1;0;  Max;25,False,-1;0;  Edge Length;16,False,-1;0;  Max Displacement;25,False,-1;0;Write Depth;0;0;  Early Z;0;0;Vertex Position,InvertActionOnDeselection;1;0;0;8;False;True;True;True;True;True;True;True;False;;False;0
WireConnection;14;0;13;0
WireConnection;14;1;15;0
WireConnection;37;0;38;0
WireConnection;37;1;14;0
WireConnection;34;0;5;0
WireConnection;34;1;37;0
WireConnection;39;0;34;0
WireConnection;40;0;39;0
WireConnection;40;1;41;0
WireConnection;43;0;40;0
WireConnection;43;1;42;0
WireConnection;6;0;5;0
WireConnection;72;1;43;0
WireConnection;243;0;241;0
WireConnection;243;1;25;0
WireConnection;23;0;2;0
WireConnection;23;1;72;0
WireConnection;109;0;107;0
WireConnection;109;1;243;0
WireConnection;260;0;259;0
WireConnection;12;1;14;0
WireConnection;83;0;82;0
WireConnection;83;1;81;0
WireConnection;7;0;6;0
WireConnection;10;1;12;0
WireConnection;8;0;7;0
WireConnection;8;1;9;0
WireConnection;257;0;23;1
WireConnection;257;1;261;1
WireConnection;257;2;260;0
WireConnection;108;0;83;0
WireConnection;108;1;109;0
WireConnection;11;0;8;0
WireConnection;11;1;10;0
WireConnection;116;0;108;0
WireConnection;116;1;257;0
WireConnection;3;0;2;0
WireConnection;3;1;11;0
WireConnection;104;0;116;0
WireConnection;121;1;83;0
WireConnection;121;3;122;0
WireConnection;120;0;121;0
WireConnection;120;1;104;0
WireConnection;18;0;16;0
WireConnection;18;1;17;0
WireConnection;18;2;3;1
WireConnection;239;0;174;0
WireConnection;222;0;120;0
WireConnection;20;0;18;0
WireConnection;20;1;22;0
WireConnection;221;0;120;0
WireConnection;221;1;239;0
WireConnection;237;0;222;0
WireConnection;237;2;221;0
WireConnection;21;0;20;0
WireConnection;21;1;22;0
WireConnection;99;0;21;0
WireConnection;99;2;120;0
WireConnection;238;0;237;0
WireConnection;156;0;166;0
WireConnection;156;1;16;0
WireConnection;156;2;23;1
WireConnection;177;0;99;0
WireConnection;181;0;156;0
WireConnection;181;2;238;0
WireConnection;147;0;134;0
WireConnection;147;1;144;0
WireConnection;240;0;177;0
WireConnection;240;2;237;0
WireConnection;254;0;181;0
WireConnection;167;0;240;0
WireConnection;167;1;254;0
WireConnection;56;0;55;0
WireConnection;56;1;53;0
WireConnection;146;0;143;0
WireConnection;146;1;147;0
WireConnection;54;0;56;0
WireConnection;54;1;34;0
WireConnection;54;2;243;0
WireConnection;151;0;146;0
WireConnection;151;1;150;0
WireConnection;142;0;28;0
WireConnection;142;1;140;0
WireConnection;142;2;143;0
WireConnection;148;0;143;0
WireConnection;256;0;167;0
WireConnection;256;1;255;0
WireConnection;149;0;148;0
WireConnection;149;1;256;0
WireConnection;154;0;153;0
WireConnection;154;1;151;0
WireConnection;57;0;54;0
WireConnection;57;1;58;0
WireConnection;267;0;142;0
WireConnection;267;1;266;0
WireConnection;145;0;154;0
WireConnection;145;1;149;0
WireConnection;152;0;148;0
WireConnection;152;1;57;0
WireConnection;274;0;272;0
WireConnection;270;0;267;0
WireConnection;270;1;269;0
WireConnection;272;0;269;0
WireConnection;272;3;273;0
WireConnection;276;0;270;0
WireConnection;276;1;139;0
WireConnection;276;2;145;0
WireConnection;276;4;284;0
WireConnection;276;6;269;0
WireConnection;276;8;152;0
ASEEND*/
//CHKSM=778CEFBCF0A0DD67B43FC11BD634B030A56C9332