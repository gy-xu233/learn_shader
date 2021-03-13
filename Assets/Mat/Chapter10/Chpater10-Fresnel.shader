Shader "Unlit/Chpater10-Fresnel"
{
    Properties{
		_Color("Color Tint", Color) = (1,1,1,1)
		_FresnelScale("Fresnel Scale", Range(0,1)) = 0.5
		_Cubemap ("Reflection Cubemap", Cube) = "_Skybox"{}
	}
	SubShader{
		Pass{
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
			fixed _FresnelScale;
			samplerCUBE _Cubemap;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;

			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldNormalDir:TEXCOORD0;
				float3 worldViewDir : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldReflDir : TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormalDir = UnityObjectToWorldNormal(v.normal);
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.worldReflDir = reflect(-o.worldViewDir,o.worldNormalDir);
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				fixed3 worldNormal = normalize(i.worldNormalDir);
				fixed3 worldView = normalize(i.worldViewDir);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
				fixed3 reflection = texCUBE(_Cubemap,i.worldReflDir).rgb;
				fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(worldView,worldNormal),5);
				fixed3 diffuse = _Color.rgb * _LightColor0.rgb * max(0,dot(worldLight,worldNormal));
				fixed3 color = ambient + lerp(diffuse,reflection,saturate(fresnel)) * atten;
				return fixed4(color,1.0);
			}
			ENDCG
		}
	}
}
