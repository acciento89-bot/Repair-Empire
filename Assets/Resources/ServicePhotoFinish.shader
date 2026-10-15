Shader "Repair/ServicePhotoFinish"
{
 Properties { _MainTex("Captured HDR scene",2D)="white"{} }
 SubShader
 {
  Cull Off ZWrite Off ZTest Always
  Pass
  {
   CGPROGRAM
   #pragma vertex vert_img
   #pragma fragment frag
   #include "UnityCG.cginc"
   sampler2D _MainTex;
   fixed4 frag(v2f_img i):SV_Target
   {
    float3 c=max(0,tex2D(_MainTex,i.uv).rgb);
    #ifdef UNITY_COLORSPACE_GAMMA
    c=GammaToLinearSpace(c);
    #endif
    c*=1.08;
    c=saturate((c*(2.51*c+.03))/(c*(2.43*c+.59)+.14));
    float luminance=dot(c,float3(.2126,.7152,.0722));c=lerp(luminance.xxx,c,1.025);
    #ifdef UNITY_COLORSPACE_GAMMA
    c=LinearToGammaSpace(c);
    #endif
    return fixed4(saturate(c),1);
   }
   ENDCG
  }
 }
 Fallback Off
}
