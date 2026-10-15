#if UNITY_EDITOR
using System;
using System.Reflection;
using UnityEngine;
using UnityEngine.UI;
using Kamilunavo.RepairEmpire.Core;
using Kamilunavo.RepairEmpire.Gameplay;
using Kamilunavo.RepairEmpire.UI;

public static class RepairConceptUiValidation
{
 // Test the actual graphic triangle coverage, not a requested radius property.
 static bool Covers(Graphic graphic,Vector2 point)
 {
  using(var helper=new VertexHelper())
  {
   graphic.GetType().GetMethod("OnPopulateMesh",BindingFlags.NonPublic|BindingFlags.Instance,null,new[]{typeof(VertexHelper)},null).Invoke(graphic,new object[]{helper});
   var mesh=new Mesh();try{helper.FillMesh(mesh);var v=mesh.vertices;var t=mesh.triangles;
    for(int i=0;i<t.Length;i+=3){Vector2 a=v[t[i]],b=v[t[i+1]],c=v[t[i+2]];float Cross(Vector2 u,Vector2 w)=>u.x*w.y-u.y*w.x;float area=Cross(b-a,c-a);if(Mathf.Abs(area)<.0001f)continue;float u=Cross(b-point,c-point)/area,w=Cross(c-point,a-point)/area;float z=1-u-w;if(u>=0&&w>=0&&z>=0)return true;}
    return false;
   }finally{UnityEngine.Object.DestroyImmediate(mesh);}
  }
 }
 public static void Validate()
 {
  ValidateDensity(new Vector2(750,1334),2);
  ValidateDensity(new Vector2(1136,640),2);
  var root=new GameObject("ConceptUiFixture");root.SetActive(false);var canvas=new GameObject("ConceptUiCanvas",typeof(Canvas));
  try
  {
   canvas.GetComponent<Canvas>().renderMode=RenderMode.ScreenSpaceOverlay;
   var region=new GameObject("ConceptUiPane",typeof(RectTransform)).GetComponent<RectTransform>();region.SetParent(canvas.transform,false);region.anchorMin=region.anchorMax=Vector2.one*.5f;region.sizeDelta=new(393,852);
   var game=root.AddComponent<RepairGame>();game.Profile=new RepairProfile{Language="de",Level=8,Cash=2345,ToolMask=7};var hud=root.AddComponent<RepairHud>();hud.Build(region,game);hud.ShowDashboard();Canvas.ForceUpdateCanvases();
   var card=region.Find("TabletModal/PageBody/ScrollViewport/ScrollContent/DashboardCurrentCall").GetComponent<Image>();var bounds=card.rectTransform.rect;
   if(Covers(card,bounds.min+Vector2.one))throw new InvalidOperationException("CONCEPT_CARD_CORNER_OPAQUE: the actual call card is still a square");
   if(!Covers(card,bounds.center))throw new InvalidOperationException("CONCEPT_CARD_CENTRE_EMPTY");
   Debug.Log("REPAIR_CONCEPT_UI_PASS rounded actual card geometry preserves solid centre and transparent corners");
  }
  finally{UnityEngine.Object.DestroyImmediate(canvas);UnityEngine.Object.DestroyImmediate(root);}
 }
 static void ValidateDensity(Vector2 pixels,float pointScale)
 {
  var root=new GameObject("DensityUiFixture");root.SetActive(false);var canvas=new GameObject("DensityUiCanvas",typeof(Canvas));
  try
  {
   var reference=pixels.x>pixels.y?new Vector2(844,390):new Vector2(390,844);float factor=Mathf.Sqrt((pixels.x/reference.x)*(pixels.y/reference.y));canvas.GetComponent<Canvas>().renderMode=RenderMode.ScreenSpaceOverlay;canvas.GetComponent<Canvas>().scaleFactor=factor;UiMetrics.QaPointScale=pointScale;
   var region=new GameObject("DensityUiPane",typeof(RectTransform)).GetComponent<RectTransform>();region.SetParent(canvas.transform,false);region.anchorMin=region.anchorMax=Vector2.one*.5f;region.sizeDelta=pixels/factor;
   var game=root.AddComponent<RepairGame>();game.Profile=new RepairProfile{Language="de",Level=8,Cash=2345,ToolMask=7};var hud=root.AddComponent<RepairHud>();hud.Build(region,game);Canvas.ForceUpdateCanvases();
   var mission=region.Find("DrivingHud/ServiceCall");var metadata=UiMetrics.ScreenRect((RectTransform)mission.Find("JobMeta"));var action=UiMetrics.ScreenRect((RectTransform)mission.Find("RepairArrival"));
   if(metadata.Overlaps(action))throw new InvalidOperationException("DENSE_DRIVING_TEXT_OVERLAP "+pixels+" rewards intersect actual Navigate target");
   Debug.Log("REPAIR_DRIVING_DENSITY_PASS "+pixels+" pointScale="+pointScale+" information and action separated");
  }
  finally{UiMetrics.QaPointScale=null;UnityEngine.Object.DestroyImmediate(canvas);UnityEngine.Object.DestroyImmediate(root);}
 }
}
#endif
