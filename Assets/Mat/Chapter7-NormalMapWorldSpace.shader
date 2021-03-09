Shader "Unity Shaders Book/Chapter 7/Chapter7-NormalMapWorldSpace"
{
   Properties{
		_Color("Color Tint", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump"{}
		_BumpScale("Bump Scale", Float) = 1.0
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0, 256)) = 20
	}

	SubShader{
		Pass{
			Tags{ "LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				float3 binormal = normalize(cross(v.normal,v.tangent.xyz) * v.tangent.w);
				o.TtoW0 = float4(normalize(UnityObjectToWorldNormal(v.tangent.xyz)),v.vertex.x);
				o.TtoW1 = float4(normalize(UnityObjectToWorldNormal(binormal)),v.vertex.y);
				o.TtoW2 = float4(normalize(UnityObjectToWorldNormal(v.normal)),v.vertex.z);

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET0{
				float4 vertex = float4(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w,1);
				float3 worldLightDir = normalize(WorldSpaceLightDir(vertex));
				float3 worldViewDir = normalize(WorldSpaceViewDir(vertex));

				fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);
				fixed3 tangentNormal;
				//tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
				//tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				float3 worldNormal =  tangentNormal.x * i.TtoW0.xyz + tangentNormal.y * i.TtoW1.xyz + tangentNormal.z * i.TtoW2.xyz;

				fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 halfDir = normalize(worldLightDir + worldViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular * pow(max(0,dot(worldNormal,halfDir)),_Gloss);
				fixed3 diffuse = albedo * _LightColor0.rgb * max(0,dot(worldNormal, worldLightDir));

				return fixed4(diffuse + specular + ambient,1.0);
			}
			ENDCG

		}
	}
	FallBack "Specular"
}
