Shader "Unlit/02_Phong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            fixed4 _Color;
            float _AmbientStrength;
            float _Shininess;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPosition : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;

                // 传递 UV，并应用材质的 Tiling、Offset
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // 读取贴图颜色，乘以材质颜色
                float3 baseColor = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

                float3 N = normalize(i.worldNormal);
                float3 L = normalize(
                    UnityWorldSpaceLightDir(i.worldPosition));
                float3 V = normalize(
                    UnityWorldSpaceViewDir(i.worldPosition));
                float3 R = reflect(-L, N);

                // 环境光
                float3 ambient = baseColor * _AmbientStrength;

                // 漫反射
                float diffuseFactor = saturate(dot(N, L));
                float3 diffuse =
                    baseColor * _LightColor0.rgb * diffuseFactor;

                // 镜面反射：保留独立的高光颜色
                float specularFactor =
                    pow(saturate(dot(R, V)), _Shininess);

                specularFactor *= step(0.0001, dot(N, L));

                float3 specular =
                    _LightColor0.rgb * specularFactor;

                return fixed4(ambient + diffuse + specular, 1);
            }
            ENDCG
        }
    }
}