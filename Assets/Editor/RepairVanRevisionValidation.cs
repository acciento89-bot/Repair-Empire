#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Kamilunavo.RepairEmpire.Core;
using Kamilunavo.RepairEmpire.Gameplay;
using Kamilunavo.RepairEmpire.UI;
using Kamilunavo.RepairEmpire.Visuals;

public static class RepairVanRevisionValidation
{
 static void Require(bool valid,string reason){if(!valid)throw new InvalidOperationException("REPAIR_VAN_REVISION_"+reason);}
 public static void ValidateConceptProportions()
 {
  var root=new GameObject("Concept road van proportions",typeof(VanArt));var failures=new List<string>();int tires=0;
  try
  {
   root.GetComponent<VanArt>().Build();
   foreach(var filter in root.GetComponentsInChildren<MeshFilter>(true))if(filter.name=="Rubber tire")
   {
    float bottom=float.PositiveInfinity,top=float.NegativeInfinity;foreach(var point in filter.sharedMesh.vertices){float y=root.transform.InverseTransformPoint(filter.transform.TransformPoint(point)).y;bottom=Mathf.Min(bottom,y);top=Mathf.Max(top,y);}tires++;
    if(top-bottom>.70f||top-bottom<.60f||Mathf.Abs(bottom-(-.10f))>.012f)failures.Add("road tire height="+(top-bottom)+" collider support plane="+bottom);
   }
   var decal=root.transform.Find("Repair gear and wrench");Require(decal!=null,"REAR_IDENTITY_MISSING");float near=float.PositiveInfinity,far=float.NegativeInfinity;
   foreach(var filter in decal.GetComponentsInChildren<MeshFilter>(true))foreach(var point in filter.sharedMesh.vertices){var p=root.transform.InverseTransformPoint(filter.transform.TransformPoint(point));float gap=VanCoachworkGeometry.RearSkinZ(p.x,p.y)-p.z;near=Mathf.Min(near,gap);far=Mathf.Max(far,gap);}
   if(far>.012f||near<.0005f)failures.Add("rear emblem stand-off="+near+".."+far);
   Require(tires==4&&failures.Count==0,"CONCEPT_PROPORTIONS "+string.Join("; ",failures));Debug.Log("REPAIR_VAN_CONCEPT_PROPORTIONS_PASS four road-sized tires aligned with the existing collider support plane and flush rear livery depth="+(far-near));
  }
  finally{UnityEngine.Object.DestroyImmediate(root);}
 }
 public static void InspectBudget()
 {
  var root=new GameObject("Coachwork buffer inspection",typeof(VanArt));
  try
  {
   root.GetComponent<VanArt>().Build();var seen=new HashSet<Mesh>();var rows=new List<string>();int total=0,active=0;
   foreach(var renderer in root.GetComponentsInChildren<MeshRenderer>(true))if(renderer.enabled)active++;
   foreach(var filter in root.GetComponentsInChildren<MeshFilter>(true))if(seen.Add(filter.sharedMesh)){int n=filter.sharedMesh.vertexCount;total+=n;rows.Add(n.ToString("D6")+" "+filter.name+" triangles="+filter.sharedMesh.triangles.Length/3);}
   var skin=root.transform.Find("Bevelled service body").GetComponent<MeshFilter>().sharedMesh;var points=skin.vertices;var indices=skin.triangles;var edges=new Dictionary<string,(int count,Vector3 a,Vector3 b)>();
   string Key(Vector3 p)=>Mathf.RoundToInt(p.x*100000)+","+Mathf.RoundToInt(p.y*100000)+","+Mathf.RoundToInt(p.z*100000);
   for(int i=0;i<indices.Length;i+=3)for(int e=0;e<3;e++){var a=points[indices[i+e]];var b=points[indices[i+(e+1)%3]];string x=Key(a),y=Key(b),key=string.CompareOrdinal(x,y)<0?x+"/"+y:y+"/"+x;edges.TryGetValue(key,out var edge);edges[key]=(edge.count+1,a,b);}
   int bad=0;var detail=new List<string>();foreach(var e in edges.Values)if(e.count!=2){bad++;if(detail.Count<24)detail.Add(e.count+" "+e.a.ToString("F6")+" -> "+e.b.ToString("F6"));}Debug.Log("REPAIR_VAN_EDGE_INSPECTION bad="+bad+"\n"+string.Join("\n",detail));
   rows.Sort(StringComparer.Ordinal);rows.Reverse();Debug.Log("REPAIR_VAN_BUFFER_INSPECTION total="+total+" active="+active+"\n"+string.Join("\n",rows));
  }
  finally{UnityEngine.Object.DestroyImmediate(root);}
 }
 public static void ValidateCurvedRear()
 {
  var root=new GameObject("Continuous coachwork shape fixture",typeof(VanArt));
  try
  {
   root.GetComponent<VanArt>().Build();var skin=root.transform.Find("Bevelled service body").GetComponent<MeshFilter>().sharedMesh;
   int points=0;float near=float.PositiveInfinity,far=float.NegativeInfinity;
   foreach(var p in skin.vertices)if(p.z< -1.99f&&Mathf.Abs(p.x)>.1f&&Mathf.Abs(p.x)<.75f&&p.y>.8f&&p.y<1.95f){points++;near=Mathf.Min(near,p.z);far=Mathf.Max(far,p.z);}
   Require(points>=50&&far-near>.015f,"REAR_IS_STILL_A_FLAT_CAP points="+points+" depth="+(far-near));
   Require(root.GetComponentsInChildren<Collider>(true).Length==0,"DECORATION_CHANGED_DRIVING_COLLISION");
   Debug.Log("REPAIR_VAN_REVISION_CURVATURE_PASS actual rear skin has continuous compound curvature points="+points+" depth="+(far-near));
  }
  finally{UnityEngine.Object.DestroyImmediate(root);}
 }
 public static void ValidateArtwork()
 {
  foreach(var pane in new[]{new Vector2(393,852),new Vector2(844,390),new Vector2(245,625)})
  {
   var host=new GameObject("Original artwork layout fixture");host.SetActive(false);var canvas=new GameObject("Workshop artwork canvas",typeof(Canvas));
   try
   {
    var region=new GameObject("Workshop artwork region",typeof(RectTransform)).GetComponent<RectTransform>();region.SetParent(canvas.transform,false);region.sizeDelta=pane;
    var game=host.AddComponent<RepairGame>();game.Profile=new RepairProfile();var hud=host.AddComponent<RepairHud>();hud.Build(region,game);hud.ShowDashboard();Canvas.ForceUpdateCanvases();
    RawImage actual=null;foreach(var graphic in region.GetComponentsInChildren<RawImage>())if(graphic.name=="WorkshopHeroArtwork")actual=graphic;
    var expected=Resources.Load<Texture2D>(pane.x-24>=600?"Art/Workshop/ServiceWorkshopHero-wide-v1":"Art/Workshop/ServiceWorkshopHero-v1");Require(actual!=null&&expected!=null&&actual.texture==expected,"ORIGINAL_WORKSHOP_ART_NOT_BOUND "+pane);
    Require(expected.width<=2048&&expected.height<=1024&&!expected.isReadable,"ARTWORK_IMPORT_BUDGET");Require(Mathf.Abs(expected.width/(float)expected.height-(pane.x-24>=600?3f:1.6f))<.01f,"ARTWORK_PROPORTIONS_CHANGED_ON_IMPORT");
    var wallet=region.Find("TabletModal/PageBody/ScrollViewport/ScrollContent/CompanyHero/CompanyWallet")as RectTransform;Require(wallet!=null&&!UiMetrics.ScreenRect(actual.rectTransform).Overlaps(UiMetrics.ScreenRect(wallet)),"BALANCE_HIDES_ORIGINAL_ARTWORK "+pane);
    if(pane.x-24>=600){var viewport=region.Find("TabletModal/PageBody/ScrollViewport")as RectTransform;var view=UiMetrics.ScreenRect(viewport);var image=UiMetrics.ScreenRect(actual.rectTransform);Require(view.yMin<=image.yMin+.5f&&view.yMax>=image.yMax-.5f&&actual.uvRect.width>.999f&&actual.uvRect.height>.999f,"LANDSCAPE_CROPS_WORKSHOP_VAN "+pane);}
   }
   finally{UnityEngine.Object.DestroyImmediate(canvas);UnityEngine.Object.DestroyImmediate(host);}
  }
  Debug.Log("REPAIR_WORKSHOP_ARTWORK_PASS original responsive assets bound, shared non-readable imports and unobscured art");
 }
 public static void ValidateExterior()
 {
  var root=new GameObject("Exterior visibility fixture",typeof(VanArt));var failures=new List<string>();int faces=0,rays=0;
  try
  {
   root.GetComponent<VanArt>().Build();
   foreach(var filter in root.GetComponentsInChildren<MeshFilter>(true))
   {
    if(filter.name!="Cab glass perimeter seal"&&filter.name!="Sculpted cab side glazing")continue;
    var mesh=filter.sharedMesh;var vertices=mesh.vertices;var triangles=mesh.triangles;float side=Mathf.Sign(mesh.bounds.center.x);int inward=0;
    for(int i=0;i<triangles.Length;i+=3){var a=vertices[triangles[i]];var normal=Vector3.Cross(vertices[triangles[i+1]]-a,vertices[triangles[i+2]]-a);faces++;if(normal.x*side<=0)inward++;}
    if(inward>0)failures.Add(filter.name+" side="+side+" inward="+inward);
   }
   foreach(int side in new[]{-1,1})
   {
    MeshFilter navy=null,orange=null;foreach(var filter in root.GetComponentsInChildren<MeshFilter>(true))if(Mathf.Sign(filter.sharedMesh.bounds.center.x)==side){if(filter.name=="Navy lower service wrap")navy=filter;if(filter.name=="Orange service band")orange=filter;}
    Require(navy!=null&&orange!=null,"SIDE_PAINT_MISSING");
    foreach(float z in new[]{-.70f,-.30f,.10f})
    {
     var ray=new Ray(new Vector3(side*5,.37f,z),Vector3.left*side);float lower=RepairVanGlassValidation.Hit(navy,ray),upper=RepairVanGlassValidation.Hit(orange,ray);rays++;
     if(!float.IsFinite(lower)||!float.IsFinite(upper)||lower-upper<.003f)failures.Add("Coplanar side paint side="+side+" z="+z+" separation="+(lower-upper));
    }
   }
   var rearNavy=root.transform.Find("Rear navy service wrap").GetComponent<MeshFilter>();var rearOrange=root.transform.Find("Orange rear livery").GetComponent<MeshFilter>();
   foreach(float x in new[]{-.65f,0,.65f}){var ray=new Ray(new Vector3(x,.37f,-5),Vector3.forward);float lower=RepairVanGlassValidation.Hit(rearNavy,ray),upper=RepairVanGlassValidation.Hit(rearOrange,ray);rays++;if(!float.IsFinite(lower)||!float.IsFinite(upper)||lower-upper<.003f)failures.Add("Coplanar rear paint x="+x+" separation="+(lower-upper));}
   Require(faces>800&&failures.Count==0,"EXTERIOR_VISIBILITY "+string.Join("; ",failures));
   Debug.Log("REPAIR_VAN_EXTERIOR_PASS outward cab faces="+faces+" separated paint rays="+rays);
  }
  finally{UnityEngine.Object.DestroyImmediate(root);}
 }
 public static void ValidateCabin()
 {
  var root=new GameObject("True cabin visibility fixture",typeof(VanArt));int rays=0;
  try
  {
   root.GetComponent<VanArt>().Build();var shell=root.transform.Find("Bevelled service body").GetComponent<MeshFilter>();
   foreach(int side in new[]{-1,1})foreach(float y in new[]{1.30f,1.50f,1.70f})foreach(float z in new[]{.15f,.35f,.55f})
   {
    var ray=new Ray(new Vector3(side*3,y,z),Vector3.left*side);float skin=RepairVanGlassValidation.Hit(shell,ray);rays++;
    Require(!float.IsFinite(skin)||skin>3.60f,"CABIN_BLOCKED_BY_SOLID_DOOR side="+side+" y="+y+" z="+z+" hit="+skin);
    foreach(var filter in root.GetComponentsInChildren<MeshFilter>(true))if(filter.name=="Cab glass perimeter seal")Require(!float.IsFinite(RepairVanGlassValidation.Hit(filter,ray)),"GASKET_BLOCKS_CABIN");
   }
   foreach(int side in new[]{-1,1})foreach(var point in new[]{new Vector2(1.1407f,1.15752f),new Vector2(.015f,1.18f),new Vector2(.015f,1.80f),new Vector2(.69f,1.79f)})
   {
    var ray=new Ray(new Vector3(side*3,point.y,point.x),Vector3.left*side);float skin=RepairVanGlassValidation.Hit(shell,ray);rays++;Require(!float.IsFinite(skin)||skin>3.60f,"CABIN_CORNER_BLOCKED "+point+" hit="+skin);
    foreach(var filter in root.GetComponentsInChildren<MeshFilter>(true))if(filter.name=="Cab glass perimeter seal")Require(!float.IsFinite(RepairVanGlassValidation.Hit(filter,ray)),"GASKET_CORNER_BLOCKED "+point);
   }
   foreach(float x in new[]{-.45f,0,.45f})foreach(float z in new[]{.88f,1.0f,1.18f})
   {
    var ray=new Ray(new Vector3(x,5,z),Vector3.down);float skin=RepairVanGlassValidation.Hit(shell,ray);rays++;
    Require(float.IsFinite(skin)&&skin>4.5f,"CABIN_BLOCKED_BY_SOLID_COWL x="+x+" z="+z+" hit="+skin);
    Require(!float.IsFinite(RepairVanGlassValidation.Hit(root.transform.Find("Windshield perimeter gasket").GetComponent<MeshFilter>(),ray)),"WINDSHIELD_GASKET_BLOCKS_CABIN");
   }
   var prototype=Resources.Load<Material>("Materials/VanCabGlass");Require(prototype!=null&&prototype.IsKeywordEnabled("_ALPHAPREMULTIPLY_ON")&&prototype.renderQueue==3000,"SHIPPED_GLASS_VARIANT_MISSING");
   var glass=root.transform.Find("Swept panoramic windshield").GetComponent<MeshRenderer>().sharedMaterial;
   Require(glass.renderQueue==3000&&glass.color.a>.12f&&glass.color.a<.4f&&glass.GetFloat("_ZWrite")==0&&glass.IsKeywordEnabled("_ALPHAPREMULTIPLY_ON"),"CABIN_GLASS_NOT_TRANSPARENT");
   foreach(var name in new[]{"Cabin dashboard","Driver seat cushion","Passenger seat cushion","Driver seat back","Passenger seat back","Steering column/Steering wheel rim","Cabin bulkhead"})Require(root.transform.Find(name)!=null,"CABIN_PART_MISSING "+name);
   Debug.Log("REPAIR_VAN_CABIN_PASS actual body/gasket aperture rays="+rays+" transparent glass and modeled cabin");
  }
  finally{UnityEngine.Object.DestroyImmediate(root);}
 }
 public static void Validate(){ValidateConceptProportions();ValidateCurvedRear();ValidateExterior();ValidateCabin();ValidateArtwork();}
}
#endif
