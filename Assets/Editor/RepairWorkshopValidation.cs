#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using UnityEngine;
using Kamilunavo.RepairEmpire.Visuals;

public static class RepairWorkshopValidation
{
 static void Check(bool value,string message){if(!value)throw new InvalidOperationException("Workshop: "+message);}
 public static void Validate()
 {
  var host=new GameObject("OriginalWorkshopBudgetProbe");var owned=new HashSet<UnityEngine.Object>();var imported=new HashSet<Texture>();
  int vertices=0,active=0;var meshes=new HashSet<Mesh>();var materials=new HashSet<Material>();
  try
  {
   var model=WorkshopArt.Build(host.transform);
   Check(model.GetComponentsInChildren<Collider>(true).Length==0&&model.GetComponentsInChildren<Rigidbody>(true).Length==0,"cached workshop art adds no driving collision or simulation");
   foreach(var f in model.GetComponentsInChildren<MeshFilter>(true))if(meshes.Add(f.sharedMesh)){vertices+=f.sharedMesh.vertexCount;owned.Add(f.sharedMesh);}
   foreach(var renderer in model.GetComponentsInChildren<MeshRenderer>(true))
   {
    if(renderer.enabled)active++;
    var m=renderer.sharedMaterial;if(m==null)continue;
    if(m.name.StartsWith("WorkshopOriginal ")||m.name.StartsWith("Van")){materials.Add(m);owned.Add(m);}
    if(m.name=="WorkshopOriginal Plaster"||m.name=="WorkshopOriginal Oak")
    {
     var texture=m.mainTexture;Check(texture!=null&&texture.width<=1024&&texture.height<=1024,"real imported original plaster/oak maps are bound and mobile sized");imported.Add(texture);
    }
   }
   Check(imported.Count==2,"plaster and wood use separate original surfaces");
   Check(vertices>20000&&vertices<180000&&active<=32&&materials.Count<=24,"bounded complete workshop/van buffers, draw groups and materials: "+vertices+" / "+active+" / "+materials.Count);
   var lights=model.GetComponentsInChildren<Light>();Check(lights.Length==2,"two bounded local work lights");
   foreach(var light in lights)Check(light.cullingMask==(1<<ServiceSceneArt.PreviewLayer)&&light.type==LightType.Point&&light.shadows==LightShadows.None&&light.range<=9,"photo lights cannot affect the city or add live shadow maps");
  }
  finally{UnityEngine.Object.DestroyImmediate(host);}
  foreach(var asset in owned)Check(asset==null,"authored buffers and instance materials release with scene owner");
  foreach(var texture in imported)Check(texture!=null,"imported production textures are borrowed, not destroyed");
  host=new GameObject("WorkshopPhotoCacheProbe");var previous=RenderTexture.active;var sky=RenderSettings.skybox;var intensity=RenderSettings.ambientIntensity;RenderTexture target=null;
  try
  {
   var studio=host.AddComponent<ServiceSceneArt>();target=studio.WorkshopImage() as RenderTexture;
   Check(target!=null&&target.IsCreated()&&target.width==960&&target.height==600&&target.depth>=24,"real bounded workshop photograph");
   Check(ReferenceEquals(target,studio.WorkshopImage()),"menu refresh reuses the same photograph instead of rendering or allocating each time");
   var camera=host.GetComponentInChildren<Camera>(true);Check(camera!=null&&!camera.enabled&&camera.targetTexture==null,"studio remains disabled with restored render target");
   Check(RenderTexture.active==previous&&RenderSettings.skybox==sky&&RenderSettings.ambientIntensity==intensity,"photo leaves active target and global environment intact");
  }
  finally{UnityEngine.Object.DestroyImmediate(host);}
  Check(target==null,"cached photograph releases with studio");
  Debug.Log("REPAIR_WORKSHOP_PASS vertices="+vertices+" activeRenderers="+active+" materials="+materials.Count+" actualVisualReview=PENDING");
 }
}
#endif
