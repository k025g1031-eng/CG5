Shader "Unlit/05_RimLight"
{
    Properties
    {
        _Color ("Base Color", Color) = (0.2, 0.2, 0.2, 1)
        _AmbientStrength ("Ambient Strength", Range(0, 1)) = 0.1
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimPower ("Rim Power", Range(0.5, 10)) = 3
        _RimStrength ("Rim Strength", Range(0, 3)) = 1
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
            fixed4 _RimColor;
            float _RimPower;
            float _RimStrength;

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

                // 基础明暗
                float3 ambient = _Color.rgb * _AmbientStrength;

                float diffuseFactor = saturate(dot(N, L));
                float3 diffuse =
                    _Color.rgb * _LightColor0.rgb * diffuseFactor;

                // 越靠近视觉边缘，数值越大
                float rim = 1.0 - saturate(dot(N, V));

                // 用 pow 收窄边缘光的范围
                rim = pow(rim, _RimPower);

                float3 rimLight =
                    _RimColor.rgb * rim * _RimStrength;

                return fixed4(ambient + diffuse + rimLight, 1);
            }
            ENDCG
        }
    }
}