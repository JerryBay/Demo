Shader "Airing/Skin"
{
   Properties
   {
       _Color ("BaseColor(RGB)", Color) = (1, 1, 1, 1)
       _Intensity ("Intensity", Range(0, 2)) = 1 
       _MainTex ("MainTex", 2D) = "white"{}
       _OutlineColor ("OutlineColor", Color) = (0, 0, 0, 1)
       _OutlineWidth ("OutlineWidth", Range(0, 0.01)) = 0.002
       _ShadowRange ("ShadowRange", Range(0, 1)) = 0.5
       _ShadowIntensity ("ShadowIntensity", Range(0, 1)) = 0.5
       _SpecularRange ("SpecularRange", Range(0, 1)) = 0.5
       _SpecularIntensity ("SpecularIntensity", Range(0, 1)) = 0.5
       _FresnelColor ("Fresnel Color(RGB)", Color) = (1, 1, 1, 1)
       _FresnelBias ("Fresnel Bias", float) = 0
       _FresnelScale ("Fresnel Scale", Range(0, 1)) = 1
       _FresnelPower ("Fresnel Power", Range(0, 5)) = 5
   }
   SubShader
   {
       Tags { "Queue"="Geometry" "IgnoreProjector"="True" "RenderType"="Opaque"}
       Pass
       {
           Name "Outline"
           Cull Front
           
           CGPROGRAM
           
           #include "UnityCG.cginc"
           #pragma vertex vert
           #pragma fragment frag
           
           fixed4 _Color;
           sampler2D _MainTex;
           float4 _MainTex_ST;
           fixed4 _OutlineColor;
           float _OutlineWidth;
           
           struct a2v
           {
               float4 vertex: POSITION;
               float3 normal: NORMAL;
           };
           
           struct v2f
           {
               float4 pos: SV_POSITION;
           };
           
           v2f vert(a2v v)
           {
               v2f o;
               
               float4 pos = mul(UNITY_MATRIX_MV, v.vertex);
               float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
               v.normal.z = -0.5;
               pos = pos + float4(normalize(normal), 0) * _OutlineWidth;
               o.pos = mul(UNITY_MATRIX_P, pos);
               
               return o;
           }
           
           fixed4 frag(v2f i): SV_Target
           {
               return _OutlineColor;
           }
           
           ENDCG
       }
       
       Pass
       {
           Name "Forward"
           Tags { "LightMode"="ForwardBase" }
           
           CGPROGRAM
           
           #include "UnityCG.cginc"
           #include "Lighting.cginc"
           #pragma multi_compile_fwdbase
           #pragma vertex vert
           #pragma fragment frag
           
           fixed4 _Color;
           float _Intensity;
           sampler2D _MainTex;
           float4 _MainTex_ST;
           fixed _ShadowRange;
           fixed _ShadowIntensity;
           fixed _SpecularRange;
           fixed _SpecularIntensity;
           fixed4 _FresnelColor;
           float _FresnelBias;
           float _FresnelScale;
           float _FresnelPower;
           
           struct a2v
           {
               float4 vertex: POSITION;
               float3 normal: NORMAL;
               float4 texcoord: TEXCOORD;
           };
           
           struct v2f
           {
               float4 pos: SV_POSITION;
               float2 uv: TEXCOORD0;
               float3 worldNormal: TEXCOORD1;
               float3 worldPos: TEXCOORD2;
           };
           
           v2f vert(a2v v)
           {
               v2f o;
               
               o.pos = UnityObjectToClipPos(v.vertex);
               o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
               o.worldNormal = UnityObjectToWorldNormal(v.normal);
               o.worldPos = mul(unity_ObjectToWorld, v.vertex);
               
               return o;
           }
           
           fixed4 frag(v2f i): SV_Target
           {
               fixed3 worldNormal = normalize(i.worldNormal);
               fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
               
               fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
               
               fixed3 diffuse = albedo * _LightColor0.rgb * _Intensity;
               
               fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
               fixed3 specular = max(0, dot(worldNormal, worldViewDir));
               
               fixed fresnel = max(0, min(1, _FresnelBias + _FresnelScale * pow(1 - dot(worldViewDir, worldNormal), _FresnelPower)));
               fixed3 fresnelColor = fresnel * _FresnelColor.rgb * diffuse;
               fixed oneMinusFresnel = 1 - fresnel;
               fixed3 orignColorWithoutRim = oneMinusFresnel * diffuse;
               return fixed4(fresnelColor + orignColorWithoutRim, 1);
           }
           
           ENDCG
       }
   }
   FallBack "Diffuse"
}
