Shader "Unlit/03_Specular"
{
    Properties
    {
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
                // N：表面法线
                float3 N = normalize(i.worldNormal);

                // L：表面指向光源
                float3 L = normalize(
                    UnityWorldSpaceLightDir(i.worldPosition));

                // V：表面指向摄像机
                float3 V = normalize(
                    UnityWorldSpaceViewDir(i.worldPosition));

                // R：光线的反射方向
                float3 R = reflect(-L, N);

                // 反射方向越接近摄像机方向，高光越亮
                float specular = pow(saturate(dot(R, V)), _Shininess);

                // 背对光源的表面不显示高光
                specular *= step(0.0001, dot(N, L));

                return fixed4(_LightColor0.rgb * specular, 1);
            }
            ENDCG
        }
    }
}