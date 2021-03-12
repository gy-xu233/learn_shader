Shader "Unity Shaders Book/Chapter10/Reflection"
{
    Properties{
		_Color("Color Tint",Color) = (1,1,1,1)
		_ReflectColor("Refraction Color", Color) = (1,1,1,1)
		_ReflectAmount("Refraction Amount",Range(0,1)) = 1
		_Cubemap("Refaction Cubemap",Cube) = "_Skybox"{}
	}
	SubShader{
		Pass{
		Tags{"LightMode" = "ForwardBase"}
			
			CGPROGRAM
			fixed4 _Color;
			fixed4 _ReflectColor;
			fixed _ReflectAmount;
			samplerCUBE _Cubemap;

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldView : TEXCOORD2;
				float3 worldRef : TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldView = WorldSpaceViewDir(v.vertex);
				o.worldRef = reflect(-o.worldView,o.worldNormal);
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				fixed3 worldNormalDir = normalize(i.worldNormal);
				fixed3 worldViewDir = normalize(i.worldView);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0,dot(worldNormalDir,worldLight));

				fixed3 reflection = texCUBE(_Cubemap,i.worldRef).rgb * _ReflectColor.rgb;
				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

				fixed3 color = ambient + lerp(diffuse,reflection,_ReflectAmount) * atten;
				return fixed4(color,1.0);
			}
			ENDCG
		}
	}

}
