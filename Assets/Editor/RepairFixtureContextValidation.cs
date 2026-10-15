#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Kamilunavo.RepairEmpire.Gameplay;
using Kamilunavo.RepairEmpire.Visuals;

// Actual modeled setting, material and lifetime checks; rendered appearance remains a root gate.
public static class RepairFixtureContextValidation
{
 static void Check(bool value,string message){if(!value)throw new InvalidOperationException("Fixture context: "+message);}
 static bool Has(GameObject root,string name)=>Array.Exists(root.GetComponentsInChildren<Transform>(),t=>t.name==name);
 public static void RunStudio()
 {
  var sky=RenderSettings.skybox;var ambient=RenderSettings.ambientMode;float intensity=RenderSettings.ambientIntensity;var skyColor=RenderSettings.ambientSkyColor;var groundColor=RenderSettings.ambientGroundColor;var equatorColor=RenderSettings.ambientEquatorColor;
  var host=new GameObject("IsolatedFixtureStudioProbe");var owned=new HashSet<UnityEngine.Object>();var activeTarget=RenderTexture.active;
  var finish=Resources.Load<Shader>("ServicePhotoFinish");var existingFinishes=new HashSet<Material>();foreach(var material in Resources.FindObjectsOfTypeAll<Material>())if(material.shader==finish)existingFinishes.Add(material);
  try{
   var art=host.AddComponent<ServiceSceneArt>();owned.Add(art.Thumbnail("faucet"));owned.Add(art.RepairImage("call-2-3",1));
   var probes=host.GetComponentsInChildren<ReflectionProbe>(true);Check(probes.Length==1,"metal uses one isolated local studio reflection environment");
   var probe=probes[0];Check(probe.mode==UnityEngine.Rendering.ReflectionProbeMode.Custom&&probe.customBakedTexture is Cubemap,"actual metallic shader reflection comes from scene-local custom cubemap");
   Check(probe.customBakedTexture.width<=64,"reflection cubemap remains small and bounded");owned.Add(probe.customBakedTexture);
   Check(RenderSettings.skybox==sky&&RenderSettings.ambientMode==ambient&&RenderSettings.ambientIntensity==intensity&&RenderSettings.ambientSkyColor==skyColor&&RenderSettings.ambientGroundColor==groundColor&&RenderSettings.ambientEquatorColor==equatorColor,"isolated photo materials never mutate global render environment");
   var camera=host.GetComponentInChildren<Camera>(true);var pumpPosition=camera.transform.localPosition;art.RepairImage("call-1-1",1);Check((camera.transform.localPosition-pumpPosition).sqrMagnitude>.05f,"camera meaningfully frames a wall outlet differently from a mechanical pump");
   int finishes=0;foreach(var material in Resources.FindObjectsOfTypeAll<Material>())if(material.shader==finish&&!existingFinishes.Contains(material)){owned.Add(material);finishes++;}Check(finish!=null&&finishes==1,"one scene-owned original photographic finish material");
   Check(RenderTexture.active==activeTarget&&camera.targetTexture==null,"HDR photograph restores caller render targets");
   foreach(var f in host.GetComponentsInChildren<MeshFilter>(true))owned.Add(f.sharedMesh);
   foreach(var r in host.GetComponentsInChildren<Renderer>(true))if(r.sharedMaterial.name.StartsWith("FixturePBR")){owned.Add(r.sharedMaterial);if(r.sharedMaterial.mainTexture!=null&&!AssetDatabase.Contains(r.sharedMaterial.mainTexture))owned.Add(r.sharedMaterial.mainTexture);}
  }finally{UnityEngine.Object.DestroyImmediate(host);}
  foreach(var asset in owned)Check(asset==null,"studio render targets/cube/materials/textures and meshes release with owner");
  Check(Resources.Load<Texture2D>("Art/ServiceStone-v1")!=null&&Resources.Load<Texture2D>("Art/ServiceCloth-v1")!=null,"original shared service textures survive studio teardown");
  Debug.Log("REPAIR_FIXTURE_STUDIO_PASS localReflection=true globalEnvironmentUntouched=true");
 }
 public static void Run()
 {
  var signatures=new HashSet<string>();var contexts=new HashSet<string>();var keys=new HashSet<string>();int maxVertices=0;bool allMetal=true;
  foreach(var job in JobCatalog.All){
   var host=new GameObject("FixtureContextProbe");var assets=new HashSet<UnityEngine.Object>();
   try{
    string key=ServiceSceneArt.VisualKey(job.Id);keys.Add(key);var model=ServiceSceneArt.BuildFixture(host.transform,job.Id,1,0);
    if(key=="pipe-leak"||key=="circulation-pump"||key=="service-boiler")Check(!Has(model,"Stone counter")&&!Has(model,"Tiled customer wall")&&!Has(model,"Folded service cloth"),"pipe/pump/boiler use a physical utility setting instead of the bathroom counter: "+key);
    var parts=new List<string>();Transform context=null;foreach(var child in model.GetComponentsInChildren<Transform>())if(child.name.StartsWith("FixtureContext ")){context=child;break;}
    if(context!=null)contexts.Add(context.name);
    int vertices=0;foreach(var f in model.GetComponentsInChildren<MeshFilter>()){
     var mesh=f.sharedMesh;vertices+=mesh.vertexCount;assets.Add(mesh);foreach(var v in mesh.vertices)Check(float.IsFinite(v.x)&&float.IsFinite(v.y)&&float.IsFinite(v.z),"finite context mesh coordinates");
     foreach(var n in mesh.normals)Check(n.sqrMagnitude>.5f,"valid context mesh lighting normals");
     bool belongs=context!=null?f.transform.IsChildOf(context):f.transform.parent==model.transform&&f.name!="Folded service cloth"&&f.name!="Soap bottle"&&f.name!="Soap dispenser";
     if(belongs){long hash=17;foreach(var v in mesh.vertices){var point=model.transform.InverseTransformPoint(f.transform.TransformPoint(v));unchecked{hash=hash*31+Mathf.RoundToInt(point.x*1000);hash=hash*31+Mathf.RoundToInt(point.y*1000);hash=hash*31+Mathf.RoundToInt(point.z*1000);}}parts.Add(mesh.vertexCount+":"+mesh.triangles.Length+":"+hash);}
    }
    parts.Sort(StringComparer.Ordinal);signatures.Add(string.Join("|",parts));maxVertices=Math.Max(maxVertices,vertices);
    Check(vertices>200&&vertices<30000,"context plus task mesh stays below existing 30k fixture ceiling");
    Check(model.GetComponentsInChildren<Collider>().Length==0,"room/detail art never changes gameplay collisions");
    var mats=new HashSet<Material>();var textures=new HashSet<Texture>();bool metal=false;
    foreach(var r in model.GetComponentsInChildren<Renderer>())if(r.sharedMaterial.name.StartsWith("FixturePBR")){
     var mat=r.sharedMaterial;mats.Add(mat);assets.Add(mat);if(mat.mainTexture!=null){textures.Add(mat.mainTexture);if(!AssetDatabase.Contains(mat.mainTexture))assets.Add(mat.mainTexture);}
     if(mat.HasProperty("_Metallic")&&mat.GetFloat("_Metallic")>=.7f)metal=true;
    }
    Check(mats.Count<=20&&textures.Count<=5,"finite shared physical material kit");
    foreach(var texture in textures)Check(texture.width*texture.height<=65536,"original material texture is small and bounded");
    allMetal&=metal;
    MeshArt.Batch(model);foreach(var f in model.GetComponentsInChildren<MeshFilter>())assets.Add(f.sharedMesh);
   }finally{UnityEngine.Object.DestroyImmediate(host);}
   foreach(var asset in assets)Check(asset==null,"context original/batched meshes and generated PBR textures/materials release with owner");
  }
  Check(keys.Count==24,"all twenty-four unique task fixture keys are retained");
  Check(contexts.Count>=6&&contexts.Count<=10&&signatures.Count>=6,"at least six structurally different actual room settings, bounded to ten");
  Check(allMetal,"all tasks include actual metallic materials rather than flat blue toy finish");
  Debug.Log("REPAIR_FIXTURE_CONTEXT_PASS keys="+keys.Count+" contexts="+contexts.Count+" structuralSignatures="+signatures.Count+" maxVertices="+maxVertices);
 }
}
#endif
