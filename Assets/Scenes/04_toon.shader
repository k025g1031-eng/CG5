Shader "Unlit/04_Toon"
{
    Properties
    {
        _Color ("Bright Color", Color) = (0, 0.7, 0, 1)
        _ShadowColor ("Shadow Color", Color) = (0, 0.35, 0, 1)
        _Threshold ("Threshold", Range(-1, 1)) = 0.3
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
            fixed4 _ShadowColor;
            float _Threshold;

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

                // 表面朝向光源的程度
                float brightness = dot(N, L);

                // 达到阈值时为 1，否则为 0
                float toon = step(_Threshold, brightness);

                // 0 使用暗色，1 使用亮色
                float3 color = lerp(
                    _ShadowColor.rgb, _Color.rgb, toon);

                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}