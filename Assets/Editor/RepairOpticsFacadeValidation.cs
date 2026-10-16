#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using UnityEngine;
using Kamilunavo.RepairEmpire.Visuals;

public static class RepairOpticsFacadeValidation
{
 static void Require(bool valid,string why){if(!valid)throw new InvalidOperationException("REPAIR_OPTICS_FACADE_"+why);}
 static float Hit(MeshRenderer renderer,Ray ray)
 {
  if(!renderer.enabled||renderer.GetComponent<MeshFilter>()==null||!renderer.bounds.IntersectRay(ray))return float.PositiveInfinity;var mesh=renderer.GetComponent<MeshFilter>().sharedMesh;var points=mesh.vertices;var triangles=mesh.triangles;float nearest=float.PositiveInfinity;
  for(int i=0;i<triangles.Length;i+=3)
  {
   var a=renderer.transform.TransformPoint(points[triangles[i]]);var b=renderer.transform.TransformPoint(points[triangles[i+1]]);var c=renderer.transform.TransformPoint(points[triangles[i+2]]);var e1=b-a;var e2=c-a;var cross=Vector3.Cross(ray.direction,e2);float determinant=Vector3.Dot(e1,cross);if(Mathf.Abs(determinant)<.000001f)continue;float inverse=1/determinant;var offset=ray.origin-a;float u=Vector3.Dot(offset,cross)*inverse;if(u<0||u>1)continue;var q=Vector3.Cross(offset,e1);float v=Vector3.Dot(ray.direction,q)*inverse;if(v<0||u+v>1)continue;float distance=Vector3.Dot(e2,q)*inverse;if(distance>=0)nearest=Mathf.Min(nearest,distance);
  }
  return nearest;
 }
 static MeshRenderer First(MeshRenderer[] renderers,Ray ray,bool ignoreLens=false)
 {
  float nearest=float.PositiveInfinity;MeshRenderer first=null;
  foreach(var renderer in renderers){if(ignoreLens&&renderer.name=="Swept optical headlamp")continue;float hit=Hit(renderer,ray);if(hit<nearest){nearest=hit;first=renderer;}}return first;
 }
 static void ValidateClosedHousing(Mesh mesh)
 {
  var points=mesh.vertices;var indices=mesh.triangles;var welded=new Dictionary<Vector3Int,int>();var map=new int[points.Length];var edges=new Dictionary<(int,int),(int count,int winding)>();double volume=0;
  for(int i=0;i<points.Length;i++){var p=points[i];var key=new Vector3Int(Mathf.RoundToInt(p.x*100000),Mathf.RoundToInt(p.y*100000),Mathf.RoundToInt(p.z*100000));if(!welded.TryGetValue(key,out int id)){id=welded.Count;welded.Add(key,id);}map[i]=id;}
  for(int i=0;i<indices.Length;i+=3)
  {
   int a=indices[i],b=indices[i+1],c=indices[i+2];volume+=Vector3.Dot(points[a],Vector3.Cross(points[b],points[c]))/6.0;
   foreach(var pair in new[]{(map[a],map[b]),(map[b],map[c]),(map[c],map[a])}){var key=pair.Item1<pair.Item2?pair:(pair.Item2,pair.Item1);edges.TryGetValue(key,out var old);edges[key]=(old.count+1,old.winding+(pair.Item1<pair.Item2?1:-1));}
  }
  foreach(var edge in edges)Require(edge.Value.count==2&&edge.Value.winding==0,"OPEN_OR_INCONSISTENT_HOUSING "+mesh.name+" edge="+edge.Key);
  Require(volume>.0000001,"INVERTED_HOUSING "+mesh.name+" volume="+volume);
 }
 public static void ValidateOptics()
 {
  var host=new GameObject("Authored vehicle optics fixture");var meshes=new HashSet<Mesh>();var material=new Material(Resources.Load<Material>("Materials/Surface"));ArtLifetime.Own(host,material);var failures=new List<string>();
  try
  {
   VanProductionDetails.Build(host.transform,material,material,material,material,material,material,material);var renderers=host.GetComponentsInChildren<MeshRenderer>();int lenses=0,backings=0,closed=0,separation=0;
   foreach(var renderer in renderers)
   {
    meshes.Add(renderer.GetComponent<MeshFilter>().sharedMesh);
    if(renderer.name=="Swept optical headlamp"){lenses++;if(renderer.bounds.size.x<.35f||renderer.bounds.size.y<.21f)failures.Add("headlamp too small "+renderer.bounds.size);}
    if(renderer.name=="Formed headlamp reflector backing")backings++;
    if(renderer.name=="Swept headlamp gasket"||renderer.name=="Hollow projector retaining cup"){ValidateClosedHousing(renderer.GetComponent<MeshFilter>().sharedMesh);closed++;}
   }
   if(lenses!=2||backings!=2)failures.Add("two real optical backings required lenses="+lenses+" backings="+backings);
   foreach(int side in new[]{-1,1})
   {
    var between=new Vector3(side*.62f,.985f,3.5f);var hit=First(renderers,new Ray(between,Vector3.back),true);
    if(hit==null||hit.name!="Formed headlamp reflector backing")failures.Add("module gap sees "+(hit==null?"nothing":hit.name));
    foreach(float x in new[]{.505f,.700f})
    {
     hit=First(renderers,new Ray(new Vector3(side*x,1.020f,3.5f),Vector3.back),true);
     if(hit==null||hit.name!="Concave optical reflector")failures.Add("projector rim hidden side="+side+" x="+x+" first="+(hit==null?"nothing":hit.name));
    }
   }
   foreach(var reflector in renderers)if(reflector.name=="Concave optical reflector")
   {
    int side=reflector.bounds.center.x>0?1:-1;MeshRenderer lens=null,backing=null;foreach(var renderer in renderers)if(Mathf.Sign(renderer.bounds.center.x)==side){if(renderer.name=="Swept optical headlamp")lens=renderer;if(renderer.name=="Formed headlamp reflector backing")backing=renderer;}
    Require(lens!=null&&backing!=null,"PROJECTOR_SURFACES_MISSING");
    foreach(var point in reflector.GetComponent<MeshFilter>().sharedMesh.vertices)
    {
     var p=reflector.transform.TransformPoint(point);var ray=new Ray(new Vector3(p.x,p.y,3.5f),Vector3.back);float front=Hit(lens,ray),rear=Hit(backing,ray),depth=3.5f-p.z;
     Require(float.IsFinite(front)&&float.IsFinite(rear)&&depth-front>=.001f&&rear-depth>=.001f,"REFLECTOR_INTERSECTS_COVER_OR_BACKING p="+p+" frontGap="+(depth-front)+" rearGap="+(rear-depth));separation++;
    }
   }
   Require(closed==6&&separation>=300,"PHYSICAL_OPTIC_GEOMETRY_MISSING closed="+closed+" separation="+separation);
  }
  finally{UnityEngine.Object.DestroyImmediate(host);}
  Require(material==null,"OPTIC_MATERIAL_LEAK");foreach(var mesh in meshes)Require(mesh==null,"OPTIC_MESH_LEAK");Require(failures.Count==0,string.Join("; ",failures));Debug.Log("REPAIR_VEHICLE_OPTICS_PASS two larger formed lamps;real opaque backing/concave projector first hits;owned cleanup");
 }
 public static void ValidateReturns()
 {
  var host=new GameObject("Authored return sash fixture");var material=new Material(Resources.Load<Material>("Materials/Surface"));ArtLifetime.Own(host,material);var meshes=new HashSet<Mesh>();var failures=new List<string>();int panes=0,frames=0;
  try
  {
   var kit=new UrbanArtKit(host.transform,material,material,material);kit.Facade(0,0,15,10,17,-1,0);kit.Facade(40,0,24,10,17,1,3);
   foreach(Transform facade in host.transform)
   {
    var renderers=facade.GetComponentsInChildren<MeshRenderer>();foreach(var renderer in renderers)
    {
     var filter=renderer.GetComponent<MeshFilter>();if(filter==null)continue;meshes.Add(filter.sharedMesh);if(renderer.name=="Return elevation sash surrounds")frames++;
     if(renderer.name!="Return elevation window")continue;panes++;var at=renderer.transform.localPosition;var bounds=renderer.GetComponent<MeshFilter>().sharedMesh.bounds;
     if(bounds.size.z>1.5f)failures.Add("overbroad return window "+bounds.size.z);
     int side=at.x>0?1:-1;var normal=facade.TransformDirection(Vector3.right*side);var center=facade.TransformPoint(at);var first=First(renderers,new Ray(center+normal*3,-normal));
     if(first==null||first.name!="Return elevation sash surrounds")failures.Add("center lacks modeled sash "+(first==null?"nothing":first.name));
     var clear=facade.TransformPoint(at+new Vector3(0,.34f,.21f));first=First(renderers,new Ray(clear+normal*3,-normal));if(first!=renderer)failures.Add("window opening blocked by "+(first==null?"nothing":first.name));
    }
   }
   Require(host.GetComponentsInChildren<Collider>().Length==0,"RETURN_DETAILS_ADD_COLLISION");
  }
  finally{UnityEngine.Object.DestroyImmediate(host);}
  foreach(var mesh in meshes)Require(mesh==null,"RETURN_MESH_LEAK");Require(panes==36&&frames==2&&failures.Count==0,"RETURN_SASH panes="+panes+" combinedFrames="+frames+" "+string.Join("; ",failures));Debug.Log("REPAIR_RETURN_SASH_PASS36narrowpanes/twoownedcombinedsurroundmeshes;actualframeandclearpanerays");
 }
 public static void ValidateAssembly()
 {
  var host=new GameObject("Actual complete headlamp grille assembly",typeof(VanArt));var failures=new List<string>();int samples=0;
  try
  {
   host.GetComponent<VanArt>().Build();var renderers=host.GetComponentsInChildren<MeshRenderer>();
   foreach(int side in new[]{-1,1})foreach(var point in new[]{new Vector2(.62f,.985f),new Vector2(.505f,1.020f),new Vector2(.700f,1.020f),new Vector2(.505f,.945f),new Vector2(.535f,.945f),new Vector2(.555f,.945f)})
   {
    var ray=new Ray(new Vector3(side*point.x,point.y,3.5f),Vector3.back);float opaque=float.PositiveInfinity,lens=float.PositiveInfinity;MeshRenderer first=null;
    foreach(var renderer in renderers)
    {
     var material=renderer.sharedMaterial;if(material==null)continue;float distance=Hit(renderer,ray);
     if(material.name=="VanHeadlamp")lens=Mathf.Min(lens,distance);
     else if(material.renderQueue<=2500&&distance<opaque){opaque=distance;first=renderer;}
    }
    samples++;if(!float.IsFinite(lens)||!float.IsFinite(opaque)||opaque-lens<.001f)failures.Add("cover penetrated at "+side*point.x+","+point.y+" gap="+(opaque-lens));
    if(point.y>.98f&&(first==null||first.sharedMaterial.name!="VanChrome"))failures.Add("physical silver optics occluded at "+side*point.x+","+point.y+" by "+(first==null?"nothing":first.sharedMaterial.name));
   }
  }
  finally{UnityEngine.Object.DestroyImmediate(host);}
  Require(failures.Count==0,"ASSEMBLED_GRILLE_OPTICS "+string.Join("; ",failures));Debug.Log("REPAIR_ASSEMBLED_OPTICS_PASS real final batched vehicle first-visible metal and clear cover; rays="+samples);
 }
 public static void CaptureBaseline(){var failures=new List<string>();foreach(Action check in new Action[]{ValidateOptics,ValidateReturns,ValidateAssembly})try{check();}catch(Exception e){failures.Add(e.Message);}Require(failures.Count==0,string.Join("\n",failures));}
 public static void Validate(){ValidateOptics();ValidateReturns();ValidateAssembly();}
}
#endif
