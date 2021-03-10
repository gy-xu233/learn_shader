Shader "Unity Shaders Book/Chapter8/AlphaTest"
{
    Properties{
		_Color("Main Tint", Color) = (1,1,1,1)
		_MainTex("Main Tex", 2D) = "white"{}
		_Cutoff("Alpha Cutoff", Range(0,1)) = 0.5
	}
	SubShader{
		Tags{"Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout"}
		Pass{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragmae fragment frag
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _Cutoff;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float4 worldPos : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(Unity_ObjToWorld,v.vertex);
				o.worldNormal = normalize(ObjToWorldSpaceNormal(v.normal));
				o.uv = TRANSFORM_TEX(v.texcoord.xy,_MainTex);
				return o;
			}
			
			fixed4 frag(v2f i):SV_Target{
				fixed4 texColor = tex2D(_MainTex,i.uv);
				clip(texColor.a - _Cutoff);
				fixed3 albedo = texColor.rgb * _Color.rgb;
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = albedo * _LightColor0.rgb * max(0,dot(i.worldNormal,lightDir));

				return fixed4(diffuse + ambient,1.0);

			}
			ENDCG
		}
	
	}
	FallBack "Transparent/Cutout/VertexLit"
}
