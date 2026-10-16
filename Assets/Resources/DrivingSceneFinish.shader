Shader "Repair/DrivingSceneFinish"
{
 Properties { _MainTex("World HDR image",2D)="white"{} _Exposure("Exposure",Float)=.95 _BloomStrength("Highlight glow",Float)=.03 }
 SubShader
 {
  Cull Off ZWrite Off ZTest Always
  Pass
  {
   CGPROGRAM
   #pragma vertex vert_img
   #pragma fragment frag
   #include "UnityCG.cginc"
   sampler2D _MainTex;float4 _MainTex_TexelSize;float _Exposure,_BloomStrength;
   float3 Read(float2 uv){float3 c=max(0,tex2D(_MainTex,uv).rgb);
    #ifdef UNITY_COLORSPACE_GAMMA
    c=GammaToLinearSpace(c);
    #endif
    return c;
   }
   float3 Highlight(float3 c){return max(c-1.2,0)/(1+max(c.r,max(c.g,c.b)));}
   float4 frag(v2f_img i):SV_Target
   {
    float2 step=_MainTex_TexelSize.xy*2;float3 c=Read(i.uv);float3 glow=(Highlight(Read(i.uv+float2(step.x,0)))+Highlight(Read(i.uv-float2(step.x,0)))+Highlight(Read(i.uv+float2(0,step.y)))+Highlight(Read(i.uv-float2(0,step.y))))*.25;
    c=c*_Exposure+glow*_BloomStrength;
    c=saturate((c*(2.51*c+.03))/(c*(2.43*c+.59)+.14));
    #ifdef UNITY_COLORSPACE_GAMMA
    c=LinearToGammaSpace(c);
    #endif
    return float4(c,1);
   }
   ENDCG
  }
 }
 Fallback Off
}
