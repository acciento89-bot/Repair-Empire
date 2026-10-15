Shader "Repair/ResidentialMasonry" {
 Properties {_Color("Warm masonry tint",Color)=(1,1,1,1) _MainTex("Original brick courses",2D)="white"{} _Relief("Mortar edge relief",Range(0,.25))=.13 _Glossiness("Stone polish",Range(0,1))=.12 _Metallic("Metal",Range(0,1))=0}
 SubShader {Tags {"RenderType"="Opaque"} LOD 200
 CGPROGRAM
 #pragma surface surf Standard fullforwardshadows
 #pragma target 3.0
 sampler2D _MainTex;fixed4 _Color;half _Relief,_Glossiness,_Metallic;
 struct Input {float2 uv_MainTex;};
 // Desaturated limestone mortar follows the actual original texture, including
 // its irregular brick edges, instead of a second misaligned procedural grid.
 float HeightFromColor(float3 c){float high=max(c.r,max(c.g,c.b)),low=min(c.r,min(c.g,c.b));return smoothstep(.24,.48,(high-low)/max(high,.001));}
 float BrickHeight(float2 uv){return HeightFromColor(tex2D(_MainTex,uv).rgb);}
 void surf(Input i,inout SurfaceOutputStandard o){float2 uv=i.uv_MainTex;float3 color=tex2D(_MainTex,uv).rgb;float dx=BrickHeight(uv+float2(.002,0))-BrickHeight(uv-float2(.002,0));float dy=BrickHeight(uv+float2(0,.002))-BrickHeight(uv-float2(0,.002));o.Albedo=color*_Color.rgb;o.Normal=normalize(float3(-dx*_Relief*5,-dy*_Relief*5,1));o.Metallic=_Metallic;o.Smoothness=_Glossiness;o.Occlusion=.91+.09*HeightFromColor(color);o.Alpha=1;}
 ENDCG
 } Fallback "Diffuse"
}
