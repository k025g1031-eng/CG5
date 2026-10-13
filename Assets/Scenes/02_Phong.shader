Shader "Unlit/02_Phong"
{
    Properties
    {
        _Color ("Color", Color) = (1, 0, 0, 1)
        _AmbientStrength ("Ambient Strength", Range(0, 1)) = 0.1
        _Shininess ("Shininess", Range(1, 128)) = 32
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            float _AmbientStrength;
            float _Shininess;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPosition : TEXCOORD1;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 N = normalize(i.worldNormal);
                float3 L = normalize(
                    UnityWorldSpaceLightDir(i.worldPosition));
                float3 V = normalize(
                    UnityWorldSpaceViewDir(i.worldPosition));
                float3 R = reflect(-L, N);

                // 环境光：提供基础亮度
                float3 ambient = _Color.rgb * _AmbientStrength;

                // 漫反射：表面越朝向光源，越亮
                float diffuseFactor = saturate(dot(N, L));
                float3 diffuse =
                    _Color.rgb * _LightColor0.rgb * diffuseFactor;

                // 镜面反射：白色高光
                float specularFactor =
                    pow(saturate(dot(R, V)), _Shininess);

                specularFactor *= step(0.0001, dot(N, L));

                float3 specular =
                    _LightColor0.rgb * specularFactor;

                // 合成三种光照
                return fixed4(ambient + diffuse + specular, 1);
            }
            ENDCG
        }
    }
}