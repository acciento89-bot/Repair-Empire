Shader "Repair/CitySurface" {
 Properties {
  _CityTiles("City material layers",2DArray)="white"{}
  _RoadAlbedo("Original asphalt albedo",2D)="gray"{}
  _Color("Tint",Color)=(1,1,1,1)
  _AtlasTile("Atlas tile",Float)=0
  _MetersPerTile("World metres per tile",Float)=2
  _Metallic("Metallic",Range(0,1))=0
  _Glossiness("Smoothness",Range(0,1))=.2
 }
 SubShader {
  Tags {"RenderType"="Opaque"}
  LOD 200
  CGPROGRAM
  #pragma surface surf Standard fullforwardshadows
  #pragma target 3.5
  #pragma require 2darray
  #include "UnityCG.cginc"
  UNITY_DECLARE_TEX2DARRAY(_CityTiles);
  sampler2D _RoadAlbedo;
  fixed4 _Color;
  half _AtlasTile,_MetersPerTile,_Metallic,_Glossiness;
  struct Input {float3 worldPos;float3 worldNormal;};
  fixed3 sampleSurface(float2 position) {
   float2 uv=position/max(.1,_MetersPerTile);
   if(_AtlasTile<.5)return tex2D(_RoadAlbedo,uv).rgb;
   return UNITY_SAMPLE_TEX2DARRAY(_CityTiles,float3(uv,_AtlasTile)).rgb;
  }
  void surf(Input i,inout SurfaceOutputStandard o) {
   float3 weights=pow(abs(normalize(i.worldNormal)),4);
   weights/=max(.0001,weights.x+weights.y+weights.z);
   o.Albedo=(sampleSurface(i.worldPos.zy)*weights.x+sampleSurface(i.worldPos.xz)*weights.y+sampleSurface(i.worldPos.xy)*weights.z)*_Color.rgb;
   // Restrained baked appearance: small-scale surface variation and warm ground bounce.
   float grain=sin(i.worldPos.x*29.7+i.worldPos.z*17.1)*sin(i.worldPos.y*23.3+i.worldPos.z*11.8);
   o.Albedo*=.97+grain*(_AtlasTile<.5?0:.025);
   o.Occlusion=.93;
   o.Metallic=_Metallic;o.Smoothness=_Glossiness;o.Alpha=1;
  }
  ENDCG
 }
 FallBack "Diffuse"
}
