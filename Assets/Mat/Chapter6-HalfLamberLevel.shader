﻿Shader "Unity Shaders Book/Chapter 6/Chapter6-HalfLamberLevel"
{
    Properties
    {
        _Diffuse("Diffuse",Color) = (1,1,1,1)
    }
    SubShader
    {

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			fixed4 _Diffuse;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = normalize(mul(v.normal,(float3x3)unity_ObjectToWorld));
				return o;
			}

			fixed4 frag(v2f i) :SV_Target{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (0.5 * dot(i.worldNormal,worldLight) + 0.5);
				fixed3 color = diffuse + ambient;
				return fixed4(color,1.0);
			}
			ENDCG

        }

    }
	FallBack "Diffuse"
}
