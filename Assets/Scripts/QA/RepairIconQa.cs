#if UNITY_EDITOR || DEVELOPMENT_BUILD
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using Kamilunavo.RepairEmpire.Visuals;
namespace Kamilunavo.RepairEmpire.QA
{
 public sealed partial class RepairRuntimeQa
 {
  IEnumerator CaptureRepairIconViews()
  {
   var van=game.Vehicle.GetComponentInChildren<VanArt>();Check(van!=null,"Store icon photographs the actual production driving model");var origin=game.Vehicle.transform.position;var rotation=game.Vehicle.transform.rotation;int cash=game.Profile.Cash;long ticket=game.Profile.ActiveTicket;var host=new GameObject("QA actual Repair store icon camera",typeof(Camera));var camera=host.GetComponent<Camera>();camera.CopyFrom(Camera.main);camera.enabled=false;camera.rect=new Rect(0,0,1,1);camera.aspect=1;camera.fieldOfView=33;host.AddComponent<DrivingSceneFinish>();var target=new RenderTexture(1024,1024,24,RenderTextureFormat.ARGB32){antiAliasing=2};var pixels=new Texture2D(1024,1024,TextureFormat.RGB24,false);var previous=RenderTexture.active;var hashes=new HashSet<int>();
   try
   {
    target.Create();camera.targetTexture=target;var eyes=new[]{new Vector3(3.5f,2.5f,-5.2f),new Vector3(-2.8f,2.3f,-5.1f),new Vector3(.4f,2.8f,-5.7f)};var points=new List<Vector3>();foreach(var filter in van.GetComponentsInChildren<MeshFilter>())if(filter.sharedMesh!=null)foreach(var vertex in filter.sharedMesh.vertices)points.Add(filter.transform.TransformPoint(vertex));Check(points.Count>60000,"Icon framing measures the actual complete commercial van buffers");
    for(int i=0;i<eyes.Length;i++)
    {
     camera.transform.position=van.transform.TransformPoint(eyes[i]);camera.transform.LookAt(van.transform.TransformPoint(new Vector3(0,1.2f,0)));bool fits=false;
     for(int attempt=0;attempt<32;attempt++){fits=true;foreach(var point in points){var p=camera.WorldToViewportPoint(point);if(p.z<=camera.nearClipPlane||p.x<.04f||p.x>.96f||p.y<.04f||p.y>.96f){fits=false;break;}}if(fits)break;camera.transform.position-=camera.transform.forward*.4f;}
     Check(fits,"All actual van vertices fit the native icon with a four-percent margin pose="+i);camera.Render();scenePixels.Remove(target);hashes.Add(RenderedFingerprint(target));RenderTexture.active=target;pixels.ReadPixels(new Rect(0,0,1024,1024),0,0);pixels.Apply();File.WriteAllBytes(Path.Combine(output,"store-icon-native-"+i+".png"),pixels.EncodeToPNG());RenderTexture.active=previous;
    }
    Check(hashes.Count==3,"Three actual1024square opaque native icon photographs");Check(game.Vehicle.transform.position==origin&&game.Vehicle.transform.rotation==rotation&&game.Profile.Cash==cash&&game.Profile.ActiveTicket==ticket,"Icon photography preserves actual van and company authority");
   }
   finally{RenderTexture.active=previous;camera.targetTexture=null;scenePixels.Remove(target);target.Release();Destroy(target);Destroy(pixels);Destroy(host);}
   yield return null;Check(RenderTexture.active==previous&&Camera.main.GetComponent<DrivingSceneFinish>().Ready,"Icon camera teardown restores render context and preserves production finish");
  }
 }
}
#endif
