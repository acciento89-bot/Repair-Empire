#if UNITY_EDITOR || DEVELOPMENT_BUILD
using System.Collections;
using System.IO;
using UnityEngine;
using Kamilunavo.RepairEmpire.UI;
using Kamilunavo.RepairEmpire.Visuals;
namespace Kamilunavo.RepairEmpire.QA
{
 public sealed partial class RepairRuntimeQa
 {
  IEnumerator CaptureWorldFinishControl()
  {
   yield return CheckWorldFinishLifetime();
   var camera=Camera.main;var finish=camera.GetComponent<DrivingSceneFinish>();Check(finish!=null&&finish.Ready,"Production world camera owns supported finish");var canvas=game.Hud.GetComponentInParent<Canvas>();Check(canvas.renderMode==RenderMode.ScreenSpaceOverlay,"UI stays outside world tone and glow");var ramp=WorldFinishRenderCheck.Run(Check);File.WriteAllText(Path.Combine(output,"world-hdr-ramp.txt"),string.Join(",",ramp));bool enabled=finish.enabled;int cash=game.Profile.Cash;long ticket=game.Profile.ActiveTicket;var vehicle=game.Vehicle.transform.position;var rectangle=camera.rect;
   Texture2D before=null,after=null;
   try
   {
    finish.enabled=false;yield return null;yield return Capture("world-finish-off");finish.enabled=true;yield return null;yield return Capture("world-finish-on");Check(finish.CompletedRenders>0,"Actual production OnRenderImage callback renders the world");
    Check(finish.InputWasHdr,"Production finish receives actual floating-point HDR scene input");before=new Texture2D(2,2,TextureFormat.RGB24,false);after=new Texture2D(2,2,TextureFormat.RGB24,false);ImageConversion.LoadImage(before,File.ReadAllBytes(Path.Combine(output,"world-finish-off.png")));ImageConversion.LoadImage(after,File.ReadAllBytes(Path.Combine(output,"world-finish-on.png")));Check(before.width==after.width&&before.height==after.height,"Matched world finish frames have same dimensions");var a=before.GetPixels32();var b=after.GetPixels32();int changed=0,glyphs=0;var label=UiMetrics.ScreenRect((RectTransform)game.CashText.transform);
    for(int y=0;y<before.height;y++)for(int x=0;x<before.width;x++)
    {
     int i=y*before.width+x;int difference=Mathf.Abs(a[i].r-b[i].r)+Mathf.Abs(a[i].g-b[i].g)+Mathf.Abs(a[i].b-b[i].b);var uv=new Vector2((x+.5f)/before.width,(y+.5f)/before.height);if(rectangle.Contains(uv)&&uv.y>.16f&&uv.y<.70f&&difference>6)changed++;
     if(label.Contains(new Vector2(x+.5f,y+.5f))&&a[i].r>235&&a[i].g>235&&a[i].b>225){Check(difference<=3,"Overlay cash glyph avoids world grading");glyphs++;}
    }
    Check(changed>1000&&glyphs>16,"Native world finish visibly changes scene and preserves overlay glyphs changed="+changed+" glyphs="+glyphs);Check(camera.rect==rectangle&&game.Profile.Cash==cash&&game.Profile.ActiveTicket==ticket&&Vector3.Distance(vehicle,game.Vehicle.transform.position)<.01f,"World finish comparison preserves viewport/company/vehicle");
   }
   finally{finish.enabled=enabled;if(before!=null)Destroy(before);if(after!=null)Destroy(after);}
   yield return null;
  }
  IEnumerator CheckWorldFinishLifetime()
  {
   int Owned(){int count=0;foreach(var material in Resources.FindObjectsOfTypeAll<Material>())if(material.name=="Owned driving scene finish")count++;return count;}
   int baseline=Owned();var shader=Resources.Load<Shader>("DrivingSceneFinish");
   foreach(bool initialHdr in new[]{false,true})
   {
    var host=new GameObject("QA finish lifetime");host.SetActive(false);var camera=host.AddComponent<Camera>();camera.enabled=false;camera.allowHDR=initialHdr;var finish=host.AddComponent<DrivingSceneFinish>();
    try
    {
     host.SetActive(true);Check(finish.Ready&&camera.allowHDR&&Owned()==baseline+1,"World finish owns exactly one material on enable, original HDR="+initialHdr);
     for(int cycle=0;cycle<3;cycle++)
     {
      finish.enabled=false;Check(!finish.Ready&&camera.allowHDR==initialHdr,"World finish restores original HDR on disable cycle="+cycle+" original="+initialHdr);yield return null;Check(Owned()==baseline,"World finish releases its material after disable cycle="+cycle+" original="+initialHdr);finish.enabled=true;Check(finish.Ready&&camera.allowHDR&&Owned()==baseline+1,"World finish re-enables with one owned material cycle="+cycle+" original="+initialHdr);
     }
    }
    finally{Destroy(host);}
    yield return null;Check(Owned()==baseline&&shader!=null&&shader.isSupported,"Destroying finish owner releases material and preserves imported shader, original HDR="+initialHdr);
   }
  }
  void CheckRenderedCameraMargins()
  {
   var image=new Texture2D(2,2,TextureFormat.RGB24,false);int count=0;var rectangle=Camera.main.rect;
   try
   {
    ImageConversion.LoadImage(image,File.ReadAllBytes(Path.Combine(output,"reserved-pane.png")));
    for(int y=1;y<10;y++)for(int x=1;x<20;x++){var uv=new Vector2(x/20f,y/10f);if(rectangle.Contains(uv))continue;var c=image.GetPixel(Mathf.RoundToInt(uv.x*(image.width-1)),Mathf.RoundToInt(uv.y*(image.height-1)));Check(Mathf.Max(c.r,c.g,c.b)<.02f,"Actual world finish leaves unused camera region black "+uv);count++;}
    Check(count>=50,"Actual unused viewport pixel coverage "+count);
   }
   finally{Destroy(image);}
  }
 }
}
#endif
