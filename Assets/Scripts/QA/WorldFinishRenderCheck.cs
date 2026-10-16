#if UNITY_EDITOR || DEVELOPMENT_BUILD
using System;
using UnityEngine;
namespace Kamilunavo.RepairEmpire.QA
{
 public static class WorldFinishRenderCheck
 {
  public static float[] Run(Action<bool,string> check)
  {
   var shader=Resources.Load<Shader>("DrivingSceneFinish");check(shader!=null&&shader.isSupported,"Supported world finish shader");var material=new Material(shader);var source=new Texture2D(32,1,TextureFormat.RGBAFloat,false,true){filterMode=FilterMode.Point,wrapMode=TextureWrapMode.Clamp};var target=new RenderTexture(32,1,0,RenderTextureFormat.ARGBHalf,RenderTextureReadWrite.Linear);var pixels=new Texture2D(32,1,TextureFormat.RGBAFloat,false,true);var previous=RenderTexture.active;bool srgb=GL.sRGBWrite;var output=new float[8];
   try
   {
    float[] levels={0f,.02f,.18f,.5f,1f,2f,4f,8f};var values=new Color[32];for(int i=0;i<32;i++)values[i]=new Color(levels[i/4],levels[i/4],levels[i/4],1);source.SetPixels(values);source.Apply();material.SetFloat("_BloomStrength",0);target.Create();GL.sRGBWrite=false;Graphics.Blit(source,target,material);RenderTexture.active=target;pixels.ReadPixels(new Rect(0,0,32,1),0,0);pixels.Apply();float before=-1;
    for(int i=0;i<8;i++){var c=pixels.GetPixel(i*4+2,0);check(float.IsFinite(c.r)&&c.r>=0&&c.r<=1&&Mathf.Abs(c.r-c.g)<.002f&&Mathf.Abs(c.g-c.b)<.002f&&Mathf.Abs(c.a-1)<.001f,"Finite neutral opaque native HDR level "+i+"="+c);check(c.r>=before,"Monotone native HDR level "+i);before=c.r;output[i]=c.r;}
    check(output[0]<.0005f&&output[6]-output[4]>.04f&&output[6]<.995f,"Exact black and distinct1to4HDRhighlights "+string.Join(",",output));
   }
   finally{GL.sRGBWrite=srgb;RenderTexture.active=previous;target.Release();Dispose(target);Dispose(source);Dispose(pixels);Dispose(material);}
   check(shader!=null,"Shared world shader survives probe disposal");return output;
  }
  static void Dispose(UnityEngine.Object asset){if(Application.isPlaying)UnityEngine.Object.Destroy(asset);else UnityEngine.Object.DestroyImmediate(asset);}
 }
}
#endif
