#if UNITY_EDITOR || DEVELOPMENT_BUILD
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using UnityEngine;
using Kamilunavo.RepairEmpire.Visuals;
namespace Kamilunavo.RepairEmpire.QA
{
 public sealed partial class RepairRuntimeQa
 {
  IEnumerator CaptureRepairAccessories()
  {
   var original=game.GetComponentInChildren<ServiceSceneArt>();var originalRoom=original.GetComponentInChildren<Camera>(true).transform.parent.gameObject;bool active=originalRoom.activeSelf;var host=new GameObject("QA actual repair accessory photographs");var previous=RenderTexture.active;var target=new RenderTexture(768,512,24,RenderTextureFormat.ARGB32){antiAliasing=2};var pixels=new Texture2D(768,512,TextureFormat.RGB24,false);int cash=game.Profile.Cash;long ticket=game.Profile.ActiveTicket;
   try
   {
    originalRoom.SetActive(false);yield return null;yield return new WaitForEndOfFrame();var studio=host.AddComponent<ServiceSceneArt>();studio.Thumbnail("faucet");var room=studio.GetComponentInChildren<Camera>(true).transform.parent;target.Create();
    foreach(var name in new[]{"bathroom-wrench","bathroom-soap-pump","kitchen-accessories"})
    {
     string key=name=="kitchen-accessories"?"kitchen-mixer":"faucet";var model=ServiceSceneArt.BuildFixture(room,key,-1);
     try
     {
      var pose=model.GetComponent<FixturePhotoPose>();float top=FixtureContextArt.TabletopHeight(key);pose.Eye=name=="bathroom-wrench"?new Vector3(1.08f,.98f,-1.06f):name=="bathroom-soap-pump"?new Vector3(1.25f,.65f,-.65f):new Vector3(1.58f,1.52f,-1.72f);pose.Target=name=="bathroom-wrench"?new Vector3(.83f,top+.03f,-.30f):name=="bathroom-soap-pump"?new Vector3(.83f,top+.21f,.31f):new Vector3(.66f,top+.04f,.06f);pose.FieldOfView=name=="bathroom-soap-pump"?30:33;
      typeof(ServiceSceneArt).GetMethod("Photograph",BindingFlags.Instance|BindingFlags.NonPublic).Invoke(studio,new object[]{model,target,false,null});scenePixels.Remove(target);RenderedFingerprint(target);var old=RenderTexture.active;
      try{RenderTexture.active=target;pixels.ReadPixels(new Rect(0,0,768,512),0,0);pixels.Apply();File.WriteAllBytes(Path.Combine(output,name+".png"),pixels.EncodeToPNG());}
      finally{RenderTexture.active=old;}
      Check(RenderTexture.active==previous,"Accessory photograph restores caller target "+name);
     }
     finally{model.SetActive(false);Destroy(model);}
     yield return null;
    }
    Check(game.Profile.Cash==cash&&game.Profile.ActiveTicket==ticket,"Accessory photographs never mutate company or active ticket");
   }
   finally{RenderTexture.active=previous;scenePixels.Remove(target);target.Release();Destroy(target);Destroy(pixels);host.SetActive(false);Destroy(host);originalRoom.SetActive(active);}
   yield return null;yield return new WaitForEndOfFrame();Check(RenderTexture.active==previous&&originalRoom.activeSelf==active,"Accessory inspection restores original studio and target");
  }
  void CheckNativeServiceWater()
  {
   var studio=game.GetComponentInChildren<ServiceSceneArt>();var material=FixtureMaterials.Get(studio.transform,FixtureFinish.Glass);
   Check(material.renderQueue==3000&&material.IsKeywordEnabled("_ALPHAPREMULTIPLY_ON"),"Actual service water uses serialized native transparency variant");
   var host=new GameObject("QA actual service water");host.transform.position=new Vector3(0,-260,0);var cameraHost=new GameObject("QA water transmission camera",typeof(Camera));var camera=cameraHost.GetComponent<Camera>();camera.enabled=false;camera.cullingMask=1<<ServiceSceneArt.PreviewLayer;camera.clearFlags=CameraClearFlags.SolidColor;camera.orthographic=true;camera.orthographicSize=.4f;camera.nearClipPlane=.1f;camera.farClipPlane=4;camera.transform.position=host.transform.position+Vector3.back*2;
   var target=new RenderTexture(32,32,0,RenderTextureFormat.ARGB32);var pixels=new Texture2D(1,1,TextureFormat.RGB24,false);var previous=RenderTexture.active;
   try
   {
    var pane=MeshArt.Mesh(host.transform,"Actual water material transmission patch",new[]{new Vector3(-1,-1,0),new Vector3(-1,1,0),new Vector3(1,1,0),new Vector3(1,-1,0)},new[]{0,1,2,0,2,3},null,material);pane.layer=ServiceSceneArt.PreviewLayer;target.Create();camera.targetTexture=target;
    Color Read(Color background){camera.backgroundColor=background;camera.Render();RenderTexture.active=target;pixels.ReadPixels(new Rect(16,16,1,1),0,0);pixels.Apply();return pixels.GetPixel(0,0);}
    var surface=pane.GetComponent<MeshRenderer>();surface.enabled=false;var emptyRed=Read(Color.red);var emptyBlue=Read(Color.blue);surface.enabled=true;var red=Read(Color.red);var blue=Read(Color.blue);
    File.WriteAllText(Path.Combine(output,"water-presence-control.txt"),"emptyRed="+emptyRed+" emptyBlue="+emptyBlue+" waterRed="+red+" waterBlue="+blue);
    float Contribution(Color a,Color b)=>Mathf.Abs(a.r-b.r)+Mathf.Abs(a.g-b.g)+Mathf.Abs(a.b-b.b);
    Check(Contribution(red,emptyRed)>.03f&&Contribution(blue,emptyBlue)>.03f,"Native water contributes visible pixels compared with disabled surface");
    Check(red.r-blue.r>.20f&&blue.b-red.b>.20f,"Native water transmits both red and blue control backgrounds");
   }
   finally{RenderTexture.active=previous;camera.targetTexture=null;target.Release();Destroy(target);Destroy(pixels);Destroy(cameraHost);Destroy(host);}
  }
  IEnumerator DiagnoseColdPhoto()
  {
   // Isolate the real production factory. Duplicate studio lights/probes would
   // invalidate a cold-start experiment, so park and restore the existing room.
   var original=game.GetComponentInChildren<ServiceSceneArt>();var originalRoom=original.GetComponentInChildren<Camera>(true).transform.parent.gameObject;bool active=originalRoom.activeSelf;var host=new GameObject("QA isolated cold photograph");var previous=RenderTexture.active;
   var records=new System.Text.StringBuilder();var buffers=new Dictionary<string,Color32[]>();var textures=new List<Texture2D>();
   try
   {
    originalRoom.SetActive(false);yield return null;yield return new WaitForEndOfFrame();
    var studio=host.AddComponent<ServiceSceneArt>();var image=(RenderTexture)studio.Thumbnail("faucet");var camera=studio.GetComponentInChildren<Camera>(true);var room=camera.transform.parent;var probe=studio.GetComponentInChildren<ReflectionProbe>(true);
    Color32[] Read(string name)
    {
     var old=RenderTexture.active;var pixels=new Texture2D(image.width,image.height,TextureFormat.RGB24,false);textures.Add(pixels);
     try{RenderTexture.active=image;pixels.ReadPixels(new Rect(0,0,image.width,image.height),0,0);pixels.Apply();File.WriteAllBytes(Path.Combine(output,name+".png"),pixels.EncodeToPNG());return pixels.GetPixels32();}
     finally{RenderTexture.active=old;}
    }
    void Membership(string name,MeshRenderer renderer)
    {
     var probes=new List<UnityEngine.Rendering.ReflectionProbeBlendInfo>();renderer.GetClosestReflectionProbes(probes);records.Append(name+" ");foreach(var entry in probes)records.Append(entry.probe.name+":"+entry.weight+" ");records.AppendLine();
    }
    void Retake(string name)
    {
     var model=ServiceSceneArt.BuildFixture(room,"faucet",-1);var chrome=model.transform.Find("Service fixture/Curved chrome spout").GetComponent<MeshRenderer>();Membership(name+" before",chrome);
     try{typeof(ServiceSceneArt).GetMethod("Photograph",BindingFlags.Instance|BindingFlags.NonPublic).Invoke(studio,new object[]{model,image,false,null});Membership(name+" after",chrome);buffers.Add(name,Read(name));}
     finally{model.SetActive(false);Destroy(model);}
    }
    buffers.Add("photo-cold",Read("photo-cold"));yield return null;yield return new WaitForEndOfFrame();Retake("photo-settled");
    probe.enabled=false;yield return null;yield return new WaitForEndOfFrame();Retake("photo-probe-off");
    probe.enabled=true;yield return null;yield return new WaitForEndOfFrame();Retake("photo-probe-on");
    long Difference(string a,string b){long sum=0;var x=buffers[a];var y=buffers[b];for(int i=0;i<x.Length;i++)sum+=Math.Abs(x[i].r-y[i].r)+Math.Abs(x[i].g-y[i].g)+Math.Abs(x[i].b-y[i].b);return sum;}
    long coldSettled=Difference("photo-cold","photo-settled"),coldOff=Difference("photo-cold","photo-probe-off"),coldOn=Difference("photo-cold","photo-probe-on"),settledOn=Difference("photo-settled","photo-probe-on"),offOn=Difference("photo-probe-off","photo-probe-on");
    records.AppendLine("coldSettled="+coldSettled+" coldOff="+coldOff+" coldOn="+coldOn+" settledOn="+settledOn+" offOn="+offOn);File.WriteAllText(Path.Combine(output,"photo-probe-diagnostic.txt"),records.ToString());Debug.Log("REPAIR_PHOTO_PROBE "+records);
    Check(offOn>1000,"Actual same-phase faucet responds to isolated reflection probe control");
    if(mode!="photo-probe")Check(coldOn<offOn*.02&&settledOn<offOn*.02,"First cached photo agrees with settled same-phase studio reflection");
   }
   finally
   {
    RenderTexture.active=previous;foreach(var texture in textures)Destroy(texture);host.SetActive(false);Destroy(host);originalRoom.SetActive(active);
   }
   yield return null;yield return new WaitForEndOfFrame();Check(RenderTexture.active==previous&&originalRoom.activeSelf==active,"Cold photo inspection restores render target and original studio state");
  }
 }
}
#endif
