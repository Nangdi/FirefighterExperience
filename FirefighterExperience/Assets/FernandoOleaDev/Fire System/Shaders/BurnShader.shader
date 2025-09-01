// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FernandoOleaDev/BurnShader"
{
	Properties
	{
		_AlbedoColor("Albedo Color", Color) = (1,1,1,1)
		_Albedo("Albedo", 2D) = "white" {}
		_Normal("Normal", 2D) = "white" {}
		_BurnedEmission("Burned Emission", 2D) = "white" {}
		_Burned("Burned", 2D) = "white" {}
		_BurnComplement("Burn Complement", Float) = 0.5
		_Cutoff( "Mask Clip Value", Float ) = 0.5
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
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		BlendOp Add , Add
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float _BurnedValue;
		uniform sampler2D _DistortionMap;
		uniform float _ScrollSpeed;
		uniform float _BurnComplement;
		uniform float _Burn;
		uniform float _WiggleAmount;
		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform sampler2D _Burned;
		uniform float4 _Burned_ST;
		uniform float4 _AlbedoColor;
		uniform float _Opacity;
		uniform float _BurnedEmissionQuantity;
		uniform float4 _BurnedEmissiveColor;
		uniform sampler2D _BurnedEmission;
		uniform float4 _BurnedEmission_ST;
		uniform float _BurnedEmissionValue;
		uniform float4 _Warm;
		uniform float4 _Hot;
		uniform sampler2D _Mask;
		uniform float4 _DistortionMap_ST;
		uniform float _DistortionAmount;
		uniform float3 _IgnitePosition;
		uniform float _Radious;
		uniform float _Heatwave;
		uniform float _NoiseValue;
		uniform float _BorderOffset;
		uniform float4 _BorderColor;
		uniform float _BurnEmissiveValue;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float temp_output_148_0 = ( 1.0 - _BurnedValue );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float temp_output_14_0 = ( _Time.y * _ScrollSpeed );
			float2 panner37 = ( temp_output_14_0 * float2( 0,-1 ) + v.texcoord.xy);
			float3 tex2DNode34 = UnpackNormal( tex2Dlod( _DistortionMap, float4( panner37, 0, 0.0) ) );
			float temp_output_243_0 = ( _BurnComplement * _Burn );
			v.vertex.xyz += ( temp_output_148_0 * ( ( ( ase_worldPos * ase_vertex3Pos ) * tex2DNode34 * temp_output_243_0 ) * _WiggleAmount ) );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float2 uv_Burned = i.uv_texcoord * _Burned_ST.xy + _Burned_ST.zw;
			float4 lerpResult142 = lerp( tex2D( _Albedo, uv_Albedo ) , tex2D( _Burned, uv_Burned ) , _BurnedValue);
			o.Albedo = ( ( lerpResult142 * _AlbedoColor ) * _Opacity ).rgb;
			float2 uv_BurnedEmission = i.uv_texcoord * _BurnedEmission_ST.xy + _BurnedEmission_ST.zw;
			float temp_output_148_0 = ( 1.0 - _BurnedValue );
			float2 uv_DistortionMap = i.uv_texcoord * _DistortionMap_ST.xy + _DistortionMap_ST.zw;
			float temp_output_14_0 = ( _Time.y * _ScrollSpeed );
			float2 panner12 = ( temp_output_14_0 * float2( 0,-1 ) + float2( 0,0 ));
			float2 uv_TexCoord10 = i.uv_texcoord + panner12;
			float4 lerpResult18 = lerp( _Warm , _Hot , tex2D( _Mask, ( ( (UnpackNormal( tex2D( _DistortionMap, uv_DistortionMap ) )).xy * _DistortionAmount ) + uv_TexCoord10 ) ).r);
			float4 temp_cast_1 = (1.5).xxxx;
			float4 color122 = IsGammaSpace() ? float4(1,0.5641353,0,1) : float4(1,0.2782784,0,1);
			float3 ase_worldPos = i.worldPos;
			float temp_output_83_0 = distance( ase_worldPos , _IgnitePosition );
			float3 temp_cast_3 = (temp_output_83_0).xxx;
			float temp_output_243_0 = ( _BurnComplement * _Burn );
			float2 panner37 = ( temp_output_14_0 * float2( 0,-1 ) + i.uv_texcoord);
			float3 tex2DNode34 = UnpackNormal( tex2D( _DistortionMap, panner37 ) );
			float4 tex2DNode23 = tex2D( _Mask, ( float2( 0,0 ) + ( ( (tex2DNode34).xy * _Heatwave ) + i.uv_texcoord ) ) );
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
			o.Emission = ( ( _BurnedEmissionQuantity * ( ( _BurnedValue * ( _BurnedEmissiveColor * tex2D( _BurnedEmission, uv_BurnedEmission ) ) ) * _BurnedEmissionValue ) ) + ( temp_output_148_0 * ( ( lerpResult240 + clampResult254 ) * _BurnEmissiveValue ) ) ).rgb;
			float temp_output_269_0 = _Opacity;
			o.Alpha = temp_output_269_0;
			float ifLocalVar272 = 0;
			if( _Opacity == 0.0 )
				ifLocalVar272 = 1.0;
			clip( ( 1.0 - ifLocalVar272 ) - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
-1280;0;1280;963;-3343.737;1203.341;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;15;-2532.471,598.0767;Inherit;False;Property;_ScrollSpeed;Scroll Speed;12;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;13;-2427.44,431.6177;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-2250.714,491.9632;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;38;-2565.275,861.6467;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;5;-1859.134,48.60458;Inherit;True;Property;_DistortionMap;Distortion Map;8;0;Create;True;0;0;0;False;0;False;2b1a8f21a03ceac458be942cf1d2c3bb;2b1a8f21a03ceac458be942cf1d2c3bb;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.PannerNode;37;-2150.289,921.0687;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;34;-1669.145,850.3341;Inherit;True;Property;_TextureSample3;Texture Sample 3;10;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;39;-1296.816,879.1255;Inherit;True;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-1360.5,1123.853;Inherit;False;Property;_Heatwave;Heat wave;15;0;Create;True;0;0;0;False;0;False;0.1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-987.1444,888.1452;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;42;-1000.479,1134.975;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;540.4363,437.8204;Inherit;True;Property;_Burn;Burn;11;0;Create;True;0;0;0;False;0;False;0;0.3696827;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;241;659.9708,282.5988;Inherit;False;Property;_BurnComplement;Burn Complement;5;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-705.4518,988.9401;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector3Node;81;1474.985,-614.0461;Inherit;False;Property;_IgnitePosition;Ignite Position;9;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;82;1478.119,-763.3414;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;6;-1520.415,54.965;Inherit;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;259;-291.2563,1021.983;Inherit;False;Property;_NoiseValue;Noise Value;25;0;Create;True;0;0;0;False;0;False;0.15;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;2;-939.3911,-141.3561;Inherit;True;Property;_Mask;Mask;7;0;Create;True;0;0;0;False;0;False;4b2ba27a6a753a94a8128faebf2f85a0;21a28dc0208659849a8ce5aac732704a;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;107;1603.575,-392.3406;Inherit;False;Property;_Radious;Radious;17;0;Create;True;0;0;0;False;0;False;0.1828547;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;72;-509.9009,615.5985;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;243;878.9641,299.5897;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;23;-295.7572,421.5832;Inherit;True;Property;_TextureSample2;Texture Sample 2;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;9;-1147.336,322.2137;Inherit;False;Property;_DistortionAmount;Distortion Amount;10;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
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
Node;AmplifyShaderEditor.ClampOpNode;104;2401.482,-237.0999;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-414.9413,-158.4928;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;174;2469.679,-53.90163;Inherit;False;Property;_BorderOffset;Border Offset;23;0;Create;True;0;0;0;False;0;False;0.066;0.35;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;16;-418.8863,-686.412;Inherit;False;Property;_Warm;Warm;14;0;Create;True;0;0;0;False;0;False;1,0.3847524,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;121;2367.819,-545.3472;Inherit;False;Color Mask;-1;;3;eec747d987850564c95bde0e5a6d1867;0;4;1;FLOAT3;0,0,0;False;3;FLOAT3;256,256,256;False;4;FLOAT;4.26;False;5;FLOAT;3.08;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;17;-404.1541,-451.4974;Inherit;False;Property;_Hot;Hot ;13;0;Create;True;0;0;0;False;0;False;0.9887359,1,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;2541.652,-318.6801;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;18;59.56415,-533.3942;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;239;2764.273,95.9801;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;221.2018,-119.5995;Inherit;False;Constant;_Float0;Float 0;7;0;Create;True;0;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;20;380.6855,-533.395;Inherit;True;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;221;2902.894,-254.0226;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0.68;False;2;FLOAT;7.47;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;222;2948.315,-494.7758;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;688.8762,-533.3945;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;237;3170.644,-407.6335;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;166;-315.2205,99.24629;Inherit;False;Property;_BorderColor;Border Color;22;1;[HDR];Create;True;0;0;0;False;0;False;0,0.2140574,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;99;3158.123,94.83076;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;238;3396.901,-286.7773;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;156;92.12936,12.30105;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;144;3891.846,-583.3491;Inherit;True;Property;_BurnedEmission;Burned Emission;3;0;Create;True;0;0;0;False;0;False;-1;c2a51129c261b2448875f79ed40b9322;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;177;3450.239,137.0309;Inherit;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;134;3631.052,-447.5884;Inherit;False;Property;_BurnedEmissiveColor;Burned Emissive Color;18;1;[HDR];Create;True;0;0;0;False;0;False;2,0.9960784,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;181;3622.717,352.1974;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;4219.051,-500.6572;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;53;1159.098,-205.5029;Inherit;True;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;143;3933.304,-352.317;Inherit;False;Property;_BurnedValue;Burned Value;19;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;55;1002.388,-451.3068;Inherit;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClampOpNode;254;3910.245,343.3853;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;240;3690.044,-56.46889;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;140;3943.143,-1086.648;Inherit;True;Property;_Burned;Burned;4;0;Create;True;0;0;0;False;0;False;-1;a95f52500bf6e5244baaa814c3589ca8;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;150;3840.611,-167.6197;Inherit;False;Property;_BurnedEmissionValue;Burned Emission Value;20;0;Create;True;0;0;0;False;0;False;0.716;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;4220.376,-265.6968;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;167;3952.262,98.92515;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;28;935.4064,-793.4656;Inherit;True;Property;_Albedo;Albedo;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;255;4092.245,389.3853;Inherit;False;Property;_BurnEmissiveValue;Burn Emissive Value;24;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;1435.055,-321.585;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;58;1673.644,252.4638;Inherit;False;Property;_WiggleAmount;Wiggle Amount;16;0;Create;True;0;0;0;False;0;False;0.05;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;153;4455.373,-368.7309;Inherit;False;Property;_BurnedEmissionQuantity;Burned Emission Quantity;21;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;273;4814.154,490.0592;Inherit;False;Constant;_Float2;Float 2;28;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;269;4834.643,332.614;Inherit;False;Property;_Opacity;Opacity;26;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;266;4845.319,-592.8013;Inherit;False;Property;_AlbedoColor;Albedo Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;142;4417.281,-848.1109;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;1700.643,-107.0391;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;4413.062,-231.5433;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;256;4381.245,356.3853;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;148;4133.675,-113.5824;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;1967.737,267.7921;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ConditionalIfNode;272;5060.154,430.0592;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;154;4621.999,-263.1327;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;149;4477.874,20.048;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;267;5090.515,-694.4405;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;97;-643.2159,-272.3637;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;270;5071.072,-312.1632;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;139;3951.772,-869.7904;Inherit;True;Property;_Normal;Normal;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;4266.561,159.0264;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;145;4713.042,8.702801;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;274;5216.154,424.0592;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;5141.9,-129.9364;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;FernandoOleaDev/BurnShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;AlphaTest;ForwardOnly;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;0;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;6;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
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
WireConnection;104;0;116;0
WireConnection;3;0;2;0
WireConnection;3;1;11;0
WireConnection;121;1;83;0
WireConnection;121;3;122;0
WireConnection;120;0;121;0
WireConnection;120;1;104;0
WireConnection;18;0;16;0
WireConnection;18;1;17;0
WireConnection;18;2;3;1
WireConnection;239;0;174;0
WireConnection;20;0;18;0
WireConnection;20;1;22;0
WireConnection;221;0;120;0
WireConnection;221;1;239;0
WireConnection;222;0;120;0
WireConnection;21;0;20;0
WireConnection;21;1;22;0
WireConnection;237;0;222;0
WireConnection;237;2;221;0
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
WireConnection;254;0;181;0
WireConnection;240;0;177;0
WireConnection;240;2;237;0
WireConnection;146;0;143;0
WireConnection;146;1;147;0
WireConnection;167;0;240;0
WireConnection;167;1;254;0
WireConnection;56;0;55;0
WireConnection;56;1;53;0
WireConnection;142;0;28;0
WireConnection;142;1;140;0
WireConnection;142;2;143;0
WireConnection;54;0;56;0
WireConnection;54;1;34;0
WireConnection;54;2;243;0
WireConnection;151;0;146;0
WireConnection;151;1;150;0
WireConnection;256;0;167;0
WireConnection;256;1;255;0
WireConnection;148;0;143;0
WireConnection;57;0;54;0
WireConnection;57;1;58;0
WireConnection;272;0;269;0
WireConnection;272;3;273;0
WireConnection;154;0;153;0
WireConnection;154;1;151;0
WireConnection;149;0;148;0
WireConnection;149;1;256;0
WireConnection;267;0;142;0
WireConnection;267;1;266;0
WireConnection;270;0;267;0
WireConnection;270;1;269;0
WireConnection;152;0;148;0
WireConnection;152;1;57;0
WireConnection;145;0;154;0
WireConnection;145;1;149;0
WireConnection;274;0;272;0
WireConnection;0;0;270;0
WireConnection;0;1;139;0
WireConnection;0;2;145;0
WireConnection;0;9;269;0
WireConnection;0;10;274;0
WireConnection;0;11;152;0
ASEEND*/
//CHKSM=13A6906C570AD02BA62CDB4C36DDAEDA6A88462B