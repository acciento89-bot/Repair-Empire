Shader "Repair/Foliage" {
 Properties {_MainTex("Canopy cutout",2D)="white"{} _Color("Tint",Color)=(1,1,1,1) _Cutoff("Leaf silhouette",Range(0,1))=.42}
 SubShader {Tags {"Queue"="AlphaTest" "RenderType"="TransparentCutout"} Cull Off AlphaToMask On
 CGPROGRAM
 #pragma surface surf Lambert alphatest:_Cutoff addshadow
 #pragma target 3.0
 sampler2D _MainTex;fixed4 _Color;struct Input{float2 uv_MainTex;};
 void surf(Input i,inout SurfaceOutput o){fixed4 c=tex2D(_MainTex,i.uv_MainTex)*_Color;o.Albedo=c.rgb;o.Alpha=c.a;}
 ENDCG
 } FallBack "Transparent/Cutout/Diffuse"
}
