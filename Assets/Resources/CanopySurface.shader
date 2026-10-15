Shader "Repair/CanopySurface" {
 Properties {_MainTex("Original dense foliage",2D)="white"{} _Color("Natural variation",Color)=(1,1,1,1)}
 SubShader {Tags {"RenderType"="Opaque"} LOD 200
 CGPROGRAM
 #pragma surface surf Standard fullforwardshadows
 #pragma target 3.0
 sampler2D _MainTex;fixed4 _Color;
 struct Input {float2 uv_MainTex;fixed4 color:COLOR;};
 void surf(Input i,inout SurfaceOutputStandard o){fixed3 leaf=tex2D(_MainTex,i.uv_MainTex).rgb*_Color.rgb;o.Albedo=leaf;o.Metallic=0;o.Smoothness=.08;o.Occlusion=i.color.a;o.Alpha=1;}
 ENDCG
 } Fallback "Diffuse"
}
