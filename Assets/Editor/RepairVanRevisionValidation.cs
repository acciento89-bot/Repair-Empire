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
 public static void InspectBudget()
 {
  var root=new GameObject("Coachwork buffer inspection",typeof(VanArt));
  try
  {
   root.GetComponent<VanArt>().Build();var seen=new HashSet<Mesh>();var rows=new List<string>();int total=0,active=0;
   foreach(var renderer in root.GetComponentsInChildren<MeshRenderer>(true))if(renderer.enabled)active++;
   foreach(var filter in root.GetComponentsInChildren<MeshFilter>(true))if(seen.Add(filter.sharedMesh)){int n=filter.sharedMesh.vertexCount;total+=n;rows.Add(n.ToString("D6")+" "+filter.name+" triangles="+filter.sharedMesh.triangles.Length/3);}
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
     var ray=new Ray(new Vector3(side*5,.70f,z),Vector3.left*side);float lower=RepairVanGlassValidation.Hit(navy,ray),upper=RepairVanGlassValidation.Hit(orange,ray);rays++;
     if(!float.IsFinite(lower)||!float.IsFinite(upper)||lower-upper<.003f)failures.Add("Coplanar side paint side="+side+" z="+z+" separation="+(lower-upper));
    }
   }
   var rearNavy=root.transform.Find("Rear navy service wrap").GetComponent<MeshFilter>();var rearOrange=root.transform.Find("Orange rear livery").GetComponent<MeshFilter>();
   foreach(float x in new[]{-.65f,0,.65f}){var ray=new Ray(new Vector3(x,.705f,-5),Vector3.forward);float lower=RepairVanGlassValidation.Hit(rearNavy,ray),upper=RepairVanGlassValidation.Hit(rearOrange,ray);rays++;if(!float.IsFinite(lower)||!float.IsFinite(upper)||lower-upper<.003f)failures.Add("Coplanar rear paint x="+x+" separation="+(lower-upper));}
   Require(faces>1000&&failures.Count==0,"EXTERIOR_VISIBILITY "+string.Join("; ",failures));
   Debug.Log("REPAIR_VAN_EXTERIOR_PASS outward cab faces="+faces+" separated paint rays="+rays);
  }
  finally{UnityEngine.Object.DestroyImmediate(root);}
 }
 public static void Validate(){ValidateCurvedRear();ValidateExterior();ValidateArtwork();}
}
#endif
