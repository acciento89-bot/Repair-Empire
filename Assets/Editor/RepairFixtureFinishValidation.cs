#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using UnityEngine;
using Kamilunavo.RepairEmpire.Gameplay;
using Kamilunavo.RepairEmpire.Visuals;

public static class RepairFixtureFinishValidation
{
 static void Require(bool value,string why){if(!value)throw new InvalidOperationException("REPAIR_FIXTURE_FINISH_"+why);}
 public static void ValidateCartridge()
 {
  var host=new GameObject("Actual closed and exposed cartridge fixture");FixtureMaterials.Kit(host.transform);var failures=new List<string>();
  try
  {
   foreach(int phase in new[]{-1,0,1,2})
   {
    var model=ServiceSceneArt.BuildFixture(host.transform,"faucet",phase);
    try
    {
     var parts=model.transform.Find("Service fixture");var cartridge=parts.Find("Visible valve cartridge").GetComponent<MeshRenderer>();var cap=parts.Find("Mixer control cap").GetComponent<MeshRenderer>();
     if(phase==1)Require(cartridge.enabled&&cartridge.bounds.max.y<cap.bounds.min.y&&cartridge.bounds.max.y>.5f,"OPEN_CARTRIDGE_NO_LONGER_EXPOSED");
     else if(cartridge.bounds.max.y>cap.bounds.max.y)failures.Add("phase="+phase+" cartridgeTop="+cartridge.bounds.max.y+" capTop="+cap.bounds.max.y);
    }
    finally{UnityEngine.Object.DestroyImmediate(model);}
   }
  }
  finally{UnityEngine.Object.DestroyImmediate(host);}
  Require(failures.Count==0,"BRASS_PROTRUDES_FROM_CLOSED_CAP "+string.Join("; ",failures));Debug.Log("REPAIR_FIXTURE_CARTRIDGE_PASS closed photos/inspect/test covered; replacement cartridge exposed below removed cap");
 }
 static bool TriangleHit(Ray ray,Vector3 a,Vector3 b,Vector3 c,out float distance)
 {
  distance=0;var e1=b-a;var e2=c-a;var cross=Vector3.Cross(ray.direction,e2);float determinant=Vector3.Dot(e1,cross);if(Mathf.Abs(determinant)<.000001f)return false;float inverse=1/determinant;var offset=ray.origin-a;float u=Vector3.Dot(offset,cross)*inverse;if(u<0||u>1)return false;var q=Vector3.Cross(offset,e1);float v=Vector3.Dot(ray.direction,q)*inverse;if(v<0||u+v>1)return false;distance=Vector3.Dot(e2,q)*inverse;return distance>=0;
 }
 static bool Covered(Camera camera,Ray ray,MeshRenderer[] surfaces)
 {
  foreach(var renderer in surfaces)
  {
   if(!renderer.enabled||!renderer.bounds.IntersectRay(ray))continue;var mesh=renderer.GetComponent<MeshFilter>().sharedMesh;var vertices=mesh.vertices;var indices=mesh.triangles;
   for(int i=0;i<indices.Length;i+=3)if(TriangleHit(ray,renderer.transform.TransformPoint(vertices[indices[i]]),renderer.transform.TransformPoint(vertices[indices[i+1]]),renderer.transform.TransformPoint(vertices[indices[i+2]]),out float hit)&&hit>=camera.nearClipPlane&&hit<=camera.farClipPlane)return true;
  }
  return false;
 }
 public static void ValidateRooms()
 {
  var host=new GameObject("Real room coverage fixture");FixtureMaterials.Kit(host.transform);var cameraHost=new GameObject("Real room coverage camera",typeof(Camera));var camera=cameraHost.GetComponent<Camera>();camera.enabled=false;camera.nearClipPlane=.05f;camera.farClipPlane=40;int cases=0,misses=0;var examples=new List<string>();
  try
  {
   foreach(var job in JobCatalog.All)foreach(int phase in new[]{-1,0,1,2})
   {
    var model=ServiceSceneArt.BuildFixture(host.transform,job.Id,phase);
    try
    {
     Transform room=null;foreach(Transform child in model.transform)if(child.name.StartsWith("FixtureContext "))room=child;Require(room!=null,"ACTUAL_ROOM_MISSING "+job.Id);
     var surfaces=room.GetComponentsInChildren<MeshRenderer>();var pose=model.GetComponent<FixturePhotoPose>();
     foreach(float aspect in new[]{1,393f/852,805f/150,280f/1100})
     {
      camera.aspect=aspect;camera.transform.position=pose.Eye;camera.transform.LookAt(pose.Target);camera.fieldOfView=pose.FieldOfView;
      if(aspect!=1)RepairSceneFraming.Fit(camera,model.transform.Find("Service fixture"),aspect<.5f?new Rect(.031f,.254f,.938f,.411f):new Rect(.05f,.05f,.9f,.9f));
      for(int x=0;x<5;x++)for(int y=0;y<5;y++)if(!Covered(camera,camera.ViewportPointToRay(new Vector3(.01f+x*.245f,.01f+y*.245f,0)),surfaces)){misses++;if(examples.Count<4)examples.Add(job.Id+":"+phase+" aspect="+aspect+" sample="+x+","+y);}
      cases++;
     }
    }
    finally{UnityEngine.Object.DestroyImmediate(model);}
   }
  }
  finally{UnityEngine.Object.DestroyImmediate(cameraHost);UnityEngine.Object.DestroyImmediate(host);}
  Require(misses==0,"ROOM_BACKGROUND_VOIDS cases="+cases+" misses="+misses+" "+string.Join("; ",examples));Debug.Log("REPAIR_FIXTURE_ROOM_PASS actual geometry covers "+cases+" camera cases/"+(cases*25)+" rays; no painted background");
 }
 public static void CaptureBaseline()
 {
  var failures=new List<string>();foreach(Action check in new Action[]{ValidateCartridge,ValidateRooms})try{check();}catch(Exception e){failures.Add(e.Message);}Require(failures.Count==0,string.Join("\n",failures));
 }
 public static void ConfigureWater()
 {
  const string path="Assets/Resources/Materials/ServiceWater-v1.mat";Require(UnityEditor.AssetDatabase.LoadAssetAtPath<Material>(path)==null,"WATER_ALREADY_AUTHORED");
  var material=new Material(Resources.Load<Material>("Materials/VanCabGlass")){name="Original service water",color=new Color(.72f,.87f,.92f,.22f)};material.SetFloat("_Metallic",.02f);material.SetFloat("_Glossiness",.96f);UnityEditor.AssetDatabase.CreateAsset(material,path);UnityEditor.AssetDatabase.SaveAssets();Validate();
 }
 static float FirstMeshHit(MeshRenderer renderer,Ray ray)
 {
  if(!renderer.enabled||!renderer.bounds.IntersectRay(ray))return float.PositiveInfinity;var mesh=renderer.GetComponent<MeshFilter>().sharedMesh;var points=mesh.vertices;var triangles=mesh.triangles;float nearest=float.PositiveInfinity;
  for(int i=0;i<triangles.Length;i+=3)if(TriangleHit(ray,renderer.transform.TransformPoint(points[triangles[i]]),renderer.transform.TransformPoint(points[triangles[i+1]]),renderer.transform.TransformPoint(points[triangles[i+2]]),out float hit))nearest=Mathf.Min(nearest,hit);return nearest;
 }
 public static void ValidateBasinAssembly()
 {
  var host=new GameObject("Actual basin cabinet drain assembly fixture");FixtureMaterials.Kit(host.transform);var failures=new List<string>();
  try
  {
   foreach(string key in new[]{"faucet","kitchen-mixer"})
   {
    var model=ServiceSceneArt.BuildFixture(host.transform,key,0);
    try
    {
     var parts=model.transform.Find("Service fixture");var basin=parts.Find(key=="faucet"?"Porcelain basin":"Kitchen sink recess").GetComponent<MeshRenderer>();var drain=parts.Find(key=="faucet"?"Basin drain":"Kitchen basket drain").GetComponent<MeshRenderer>();var renderers=model.GetComponentsInChildren<MeshRenderer>();
     float center=key=="faucet"?-.19f:-.05f;
     for(int x=-1;x<=1;x++)for(int z=-1;z<=1;z++)
     {
      var ray=new Ray(new Vector3(x*.10f+.001f,.10f,center+z*.06f+.001f),Vector3.down);float nearest=float.PositiveInfinity;MeshRenderer first=null;
      foreach(var renderer in renderers){float hit=FirstMeshHit(renderer,ray);if(hit<nearest){nearest=hit;first=renderer;}}
      if(first!=basin&&first!=drain&&first?.name!="Basket drain slot")failures.Add(key+" basin obscured by "+(first==null?"nothing":first.name));
     }
     // Avoid the lathe fan's exactly shared radial vertex/edge in ray arithmetic.
     var sample=new Ray(new Vector3(drain.bounds.center.x+.001f,.10f,drain.bounds.center.z+.001f),Vector3.down);float floor=sample.origin.y-FirstMeshHit(basin,sample);
     Require(float.IsFinite(floor),"BASIN_DRAIN_SURFACE_RAY_MISSING "+key+" sample="+sample.origin+" bounds="+basin.bounds);
     if(drain.bounds.min.y<floor-.001f||drain.bounds.min.y>floor+.0031f||drain.bounds.max.y>floor+.008f)failures.Add(key+" drain floats above basin floor="+floor+" drain="+drain.bounds.min.y+".."+drain.bounds.max.y);
    }
    finally{UnityEngine.Object.DestroyImmediate(model);}
   }
  }
  finally{UnityEngine.Object.DestroyImmediate(host);}
  Require(failures.Count==0,"BASIN_ASSEMBLY "+string.Join("; ",failures));Debug.Log("REPAIR_BASIN_ASSEMBLY_PASS actual bath/kitchen basin visible above open cabinet carcasses;drains seat flush to real basin triangles");
 }
 public static void ValidateWaterContact()
 {
  var host=new GameObject("Actual water and basin intersection fixture");FixtureMaterials.Kit(host.transform);float maximumGap=0;int samples=0;
  try
  {
   foreach(int phase in new[]{-1,2})
   {
    var model=ServiceSceneArt.BuildFixture(host.transform,"faucet",phase);
    try
    {
     var parts=model.transform.Find("Service fixture");var basin=parts.Find("Porcelain basin").GetComponent<MeshFilter>();var ripple=parts.Find("Water impact ripple").GetComponent<MeshFilter>();var points=basin.sharedMesh.vertices;var indices=basin.sharedMesh.triangles;
     foreach(var point in ripple.sharedMesh.vertices)
     {
      var world=ripple.transform.TransformPoint(point);var ray=new Ray(world+Vector3.up*.15f,Vector3.down);float nearest=float.PositiveInfinity;
      for(int i=0;i<indices.Length;i+=3)if(TriangleHit(ray,basin.transform.TransformPoint(points[indices[i]]),basin.transform.TransformPoint(points[indices[i+1]]),basin.transform.TransformPoint(points[indices[i+2]]),out float hit))nearest=Mathf.Min(nearest,hit);
      Require(float.IsFinite(nearest),"WATER_IMPACT_OUTSIDE_BASIN");float gap=nearest-.15f;maximumGap=Mathf.Max(maximumGap,gap);Require(gap>.0001f&&gap<.002f,"WATER_IMPACT_FLOATING gap="+gap);samples++;
     }
     var stream=parts.Find("Water test stream").GetComponent<MeshRenderer>();Require(Mathf.Abs(stream.bounds.min.y-(ripple.GetComponent<MeshRenderer>().bounds.min.y))<.002f,"WATER_STREAM_DETACHED_FROM_IMPACT");
    }
    finally{UnityEngine.Object.DestroyImmediate(model);}
   }
  }
  finally{UnityEngine.Object.DestroyImmediate(host);}
  Debug.Log("REPAIR_WATER_CONTACT_PASS actual basin triangles;impact samples="+samples+" maximumGap="+maximumGap);
 }
 public static void ValidateWater()
 {
  var prototype=Resources.Load<Material>("Materials/ServiceWater-v1");Require(prototype!=null&&prototype.renderQueue==3000&&prototype.IsKeywordEnabled("_ALPHAPREMULTIPLY_ON"),"NATIVE_WATER_PROTOTYPE_MISSING");
  var host=new GameObject("Actual water phase fixture");FixtureMaterials.Kit(host.transform);Material owned=null;
  try
  {
   foreach(int phase in new[]{-1,0,1,2})
   {
    var model=ServiceSceneArt.BuildFixture(host.transform,"faucet",phase);try{var stream=model.transform.Find("Service fixture/Water test stream");Require((stream!=null)==(phase<0||phase==2),"WATER_PHASE_SEMANTICS_CHANGED");if(stream!=null){var renderer=stream.GetComponent<MeshRenderer>();owned=renderer.sharedMaterial;Require(owned!=prototype&&owned.renderQueue==3000&&renderer.shadowCastingMode==UnityEngine.Rendering.ShadowCastingMode.Off,"WATER_CLONE_TRANSPARENCY_OR_OPAQUE_SHADOW");}}finally{UnityEngine.Object.DestroyImmediate(model);}
   }
  }
  finally{UnityEngine.Object.DestroyImmediate(host);}
  Require(owned==null&&prototype!=null,"WATER_OWNERSHIP");Debug.Log("REPAIR_SERVICE_WATER_PASS serialized transparency, phase semantics and owned material cleanup");
 }
 public static void Validate(){ValidateCartridge();ValidateRooms();ValidateWater();ValidateWaterContact();ValidateBasinAssembly();}
}
#endif
