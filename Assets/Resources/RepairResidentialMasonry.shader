Shader "Repair/ResidentialMasonry" {
 Properties {_Color("Warm masonry tint",Color)=(1,1,1,1) _MainTex("Original brick courses",2D)="white"{} _Relief("Mortar edge relief",Range(0,.25))=.13 _Glossiness("Stone polish",Range(0,1))=.12 _Metallic("Metal",Range(0,1))=0}
 SubShader {Tags {"RenderType"="Opaque"} LOD 200
 CGPROGRAM
 #pragma surface surf Standard fullforwardshadows
 #pragma target 3.0
 sampler2D _MainTex;fixed4 _Color;half _Relief,_Glossiness,_Metallic;
 struct Input {float2 uv_MainTex;};
 float BrickHeight(float2 uv){float row=floor(uv.y*8),x=uv.x*4+fmod(abs(row),2)*.5;float2 f=frac(float2(x,uv.y*8));float edge=min(min(f.x,1-f.x),min(f.y,1-f.y));return smoothstep(.03,.12,edge);}
 void surf(Input i,inout SurfaceOutputStandard o){float2 uv=i.uv_MainTex;float dx=BrickHeight(uv+float2(.002,0))-BrickHeight(uv-float2(.002,0));float dy=BrickHeight(uv+float2(0,.001))-BrickHeight(uv-float2(0,.001));o.Albedo=tex2D(_MainTex,uv).rgb*_Color.rgb;o.Normal=normalize(float3(-dx*_Relief*5,-dy*_Relief*5,1));o.Metallic=_Metallic;o.Smoothness=_Glossiness;o.Occlusion=.91+.09*BrickHeight(uv);o.Alpha=1;}
 ENDCG
 } Fallback "Diffuse"
}
