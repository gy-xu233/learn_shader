Shader "Unity Shaders Book/Chapter 10/GlassRefraction"
{
    Properties{
		_MainTex("Main Tex", 2D) = "white"{}
		_BumpMap("Normal Map", 2D) = "bump"{}
		_Cubemap("Environment Cubemap", Cube) = "_Skybox"{}
		_Distortion("Distortion", Range(0,100)) = 10
		_RefractAmount("Refract Amount",Range(0.0,1.0)) = 1.0
	}
	SubShader{
		Tags { "Queue" = "Transparent" "RenderType" = "Opaque"}
		GrabPass{"_RefractionTex"}
		Pass{
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			samplerCUBE _Cubemap;
			float _Distortion;
			fixed _RefractAmount;
			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;

			struct a2v{
				float4 vertex : POSITION;
				float3 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float4 srcPos : TEXCOORD0;
				float4 uv : TEXCOORD1;
				float4 TtoW0 : TEXCOORD2;
				float4 TtoW1 : TEXCOORD3;
				float4 TtoW2 : TEXCOORD4;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.srcPos = ComputeGrabScreenPos(o.pos);
				o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord,_BumpMap);

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;

				o.TtoW0 = float4(worldTangent.xyz,worldPos.x);
				o.TtoW1 = float4(worldBinormal.xyz,worldPos.y);
				o.TtoW2 = float4(worldNormal.xyz,worldPos.z);
				return o;
			}

			fixed4 frag(v2f i): SV_Target
			{
				float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 bump = UnpackNormal(tex2D(_BumpMap,i.uv.zw));

				float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;
				i.srcPos.xy = offset + i.srcPos.xy;
				fixed3 refrCol = tex2D(_RefractionTex,(i.srcPos.xy/i.srcPos.w)).rgb;
				bump = normalize(half3(bump.x * i.TtoW0.xyz + bump.y * i.TtoW1.xyz + bump.z * i.TtoW2.xyz));
				fixed3 reflDir = reflect(-viewDir,bump);
				fixed4 texColor = tex2D(_MainTex,i.uv.xy);
				fixed3 reflcol = texCUBE(_Cubemap,reflDir).rgb * texColor.rgb;
				fixed3 finalColor = reflcol * (1 - _RefractAmount) + refrCol * _RefractAmount;
				return fixed4(finalColor,1);
			}
			ENDCG
		}
	}
}
