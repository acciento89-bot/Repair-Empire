Shader "Repair/WorldText"
{
 Properties
 {
  _MainTex ("Font atlas", 2D) = "white" {}
  _Color ("Tint", Color) = (1,1,1,1)
  [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("Depth test", Float) = 4
  [Toggle] _ZWrite ("Depth write", Float) = 0
 }
 SubShader
 {
  Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector"="True" }
  Cull Off
  ZTest [_ZTest]
  ZWrite [_ZWrite]
  Blend SrcAlpha OneMinusSrcAlpha
  Pass
  {
   CGPROGRAM
   #pragma vertex vert
   #pragma fragment frag
   #include "UnityCG.cginc"
   sampler2D _MainTex;
   fixed4 _Color;
   struct Input { float4 vertex:POSITION; float2 uv:TEXCOORD0; fixed4 color:COLOR; };
   struct Output { float4 vertex:SV_POSITION; float2 uv:TEXCOORD0; fixed4 color:COLOR; };
   Output vert(Input input)
   {
    Output output; output.vertex=UnityObjectToClipPos(input.vertex); output.uv=input.uv; output.color=input.color*_Color; return output;
   }
   fixed4 frag(Output input):SV_Target
   {
    fixed4 color=input.color; color.a*=tex2D(_MainTex,input.uv).a; return color;
   }
   ENDCG
  }
 }
}
