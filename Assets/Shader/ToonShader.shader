Shader "Airing/ToonShader"
{
    Properties
    {
        _Color("BaseColor",Color)=(1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor("OutlineColor",Color)=(1,1,1,1)
        _OutlineWidth("OutlineWidth",float)=1
        _ILMTex ("ILM", 2D) = "white"{}
        _SampleDis("SampleDis",Range(0,1)) = 1
        _SensitiveNormal("SensitiveNormal",float) = 1
        _SensitiveDepth("SensitiveDepth",float) = 1
        _EpsNormal("EpsNormal",float) = 0.1
        _EpsDepth("EpsDepth",float) = 0.1      
        _ShadowRange ("ShadowRange", Range(0, 1)) = 0.5
        _ShadowIntensity ("ShadowIntensity", Range(0, 1)) = 0.5
        _SpecularRange ("SpecularRange", Range(0, 1)) = 0.5
        _SpecularIntensity ("SpecularIntensity", Range(0, 1)) = 0.5
        _FresnelColor ("Fresnel Color", Color) = (1, 1, 1, 0)
        _FresnelScale ("Fresnel Scale", Range(0, 1)) = 1
        _FresnelIntensity ("Fresnel Intensity", Range(0, 1)) = 1
        _EmissionTex ("EmissionTex", 2D) = "white" {}
        [HDR]_EmissionColor ("EmissionColor", Color) = (0, 0, 0, 0)
        _EmissionThreshold ("EmissionThreshold", Range(0, 1)) = 0.8  
    }
    SubShader
    {
        Tags { "RenderType"="Opaque""LightMode"="ShadowCaster"}
        LOD 100
        
        Pass
        {
            Name "Outline"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv[5] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _OutlineColor;
            float _OutlineWidth;
            half _SampleDis;
            half _SensitiveNormal;
            half _SensitiveDepth;
            half _EpsNormal;
            half _EpsDepth;
            sampler2D _CameraDepthNormalsTexture;

            v2f vert (a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv[0] =v.uv;
                o.uv[1]=v.uv+_SampleDis*half2(1,1);
                o.uv[2]=v.uv+_SampleDis*half2(1,-1);
                o.uv[3]=v.uv+_SampleDis*half2(-1,-1);
                o.uv[4]=v.uv+_SampleDis*half2(-1,1);
                
                return o;
            }

            half isSame(half4 a,half4 b)
            {
                half2 aNom = a.xy;
                half2 bNom = b.xy;
                half2 subNom = abs(aNom - bNom) * _SensitiveNormal;
                half sameNom = step(subNom.x + subNom.y,_EpsNormal);

                half aDep = DecodeFloatRG(a.zw);
                half bDep = DecodeFloatRG(b.zw);
                half subDep = abs(aDep - bDep) * _SensitiveDepth;
                half sameDep = step(subDep,_EpsDepth);
                return sameNom * sameDep;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half4 sample1=tex2D(_CameraDepthNormalsTexture,i.uv[1]);
                half4 sample2=tex2D(_CameraDepthNormalsTexture,i.uv[3]);
                half4 sample3=tex2D(_CameraDepthNormalsTexture,i.uv[2]);
                half4 sample4=tex2D(_CameraDepthNormalsTexture,i.uv[4]);
                half same=isSame(sample1,sample2)*isSame(sample3,sample4);
                fixed4 res;
                res=lerp(_OutlineColor,tex2D(_MainTex,i.uv[0]),same);
                return res;
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
           sampler2D _MainTex;
           float4 _MainTex_ST;
           sampler2D _ILMTex;
           float4 _ILMTex_ST;
           fixed _ShadowRange;
           fixed _ShadowIntensity;
           fixed _SpecularRange;
           fixed _SpecularIntensity;
           sampler2D _EmissionTex;
           float4 _EmissionTex_ST;
           float4 _EmissionColor;
           float _EmissionThreshold;
           
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
               fixed3 lightMap = tex2D(_ILMTex, i.uv).rgb;
               
               fixed3 diffuse = albedo * _LightColor0.rgb;
               diffuse = diffuse > 0.5 ? lightMap.g + (1 - lightMap.g) * 2 * (diffuse - 0.5) : 2 * diffuse * lightMap.g;
               
               int isShadow = step(max(0, dot(worldLightDir, worldNormal)) - 0.5 + lightMap.g, _ShadowRange);
               diffuse = isShadow ? diffuse * (1 - _ShadowIntensity) : diffuse;
               
               fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
               fixed3 specular = pow(max(0, dot(worldNormal, worldViewDir)), lightMap.r);
               int isSpecular = step(_SpecularRange, specular);
               isSpecular = step(0.1, isSpecular * lightMap.b);
               specular = (1 - isShadow) * isSpecular * _SpecularIntensity * diffuse;
               
               // Emission
               float4 emissionTex = tex2D(_EmissionTex, i.uv);
               float4 emission = float4(_EmissionColor.rgb * emissionTex.r, 1) * step(_EmissionThreshold, emissionTex);
               
               fixed3 result = emission + diffuse + specular;
               return fixed4(result, 1);
           }
           
           ENDCG
       }
    }
}
