using UnityEngine;

namespace Kamilunavo.RepairEmpire.Visuals
{
 // One owned scene capture, never a camera or reflection update loop.
 public sealed class CitySceneReflections:MonoBehaviour
 {
  public bool Captured {get;private set;}
  public int CaptureCount {get;private set;}
  public Cubemap Reflection {get;private set;}
  public ReflectionProbe Probe {get;private set;}
  public static CitySceneReflections Capture(Transform district)
  {
   var owner=district.GetComponent<CitySceneReflections>()??district.gameObject.AddComponent<CitySceneReflections>();
   if(owner.CaptureCount==0)owner.CaptureStreet();return owner;
  }
  void CaptureStreet()
  {
   CaptureCount++;
   Reflection=new Cubemap(64,TextureFormat.RGB24,true){name="Original district reflection",filterMode=FilterMode.Trilinear,wrapMode=TextureWrapMode.Clamp};ArtLifetime.Own(gameObject,Reflection);
   var host=new GameObject("One-time district reflection capture",typeof(Camera));host.transform.SetParent(transform,false);host.transform.localPosition=new Vector3(0,3.6f,58);
   var camera=host.GetComponent<Camera>();camera.enabled=false;camera.clearFlags=CameraClearFlags.Skybox;camera.nearClipPlane=.2f;camera.farClipPlane=560;camera.allowHDR=false;camera.allowMSAA=false;camera.cullingMask=~((1<<ServiceSceneArt.PreviewLayer)|(1<<5));var previous=RenderTexture.active;
   try{Captured=camera.RenderToCubemap(Reflection);}
   finally{RenderTexture.active=previous;camera.targetTexture=null;if(Application.isPlaying)Destroy(host);else DestroyImmediate(host);}
   // A failed platform capture keeps the normal environment fallback. The owned
   // small texture is still cleaned up with this district, and is never retried.
   if(!Captured)return;
   var node=new GameObject("Captured street environment",typeof(ReflectionProbe));node.transform.SetParent(transform,false);node.transform.localPosition=new Vector3(0,3.6f,220);
   Probe=node.GetComponent<ReflectionProbe>();Probe.mode=UnityEngine.Rendering.ReflectionProbeMode.Custom;Probe.customBakedTexture=Reflection;Probe.size=new Vector3(140,70,520);Probe.boxProjection=false;Probe.blendDistance=0;Probe.intensity=.85f;Probe.importance=10;Probe.cullingMask=0;
  }
 }
}
