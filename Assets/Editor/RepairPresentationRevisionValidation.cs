#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEngine.UI;
using Kamilunavo.RepairEmpire.Core;
using Kamilunavo.RepairEmpire.Gameplay;
using Kamilunavo.RepairEmpire.UI;

// Observable information and control identity, independent of the presenter's layout.
public static class RepairPresentationRevisionValidation
{
 static readonly BindingFlags Private=BindingFlags.NonPublic|BindingFlags.Instance;
 static void Require(bool valid,string reason){if(!valid)throw new InvalidOperationException("REPAIR_PRESENTATION_"+reason);}
 static string Signature(string symbol)
 {
  var go=new GameObject("Pedal identity fixture",typeof(RectTransform),typeof(CanvasRenderer),typeof(ServiceUiIcon));
  var mesh=new Mesh();
  try
  {
   ((RectTransform)go.transform).sizeDelta=new Vector2(64,64);var graphic=go.GetComponent<ServiceUiIcon>();graphic.Symbol=symbol;
   using(var vertices=new VertexHelper())
   {
    typeof(ServiceUiIcon).GetMethod("OnPopulateMesh",Private,null,new[]{typeof(VertexHelper)},null).Invoke(graphic,new object[]{vertices});vertices.FillMesh(mesh);
    var result=new System.Text.StringBuilder();foreach(var point in mesh.vertices)result.Append(point.ToString("R"));foreach(var tint in mesh.colors32)result.Append(tint.ToString());return result.ToString();
   }
  }
  finally{UnityEngine.Object.DestroyImmediate(mesh);UnityEngine.Object.DestroyImmediate(go);}
 }
 public static void ValidatePedals(){Require(Signature("Brake")!=Signature("Gas"),"PEDALS_LOOK_IDENTICAL");Debug.Log("REPAIR_PRESENTATION_PEDALS_PASS brake and accelerator have different actual meshes");}
 static string RequiredTool(RepairGame game,int tier)=>tier==0?game.T("Basis-Schlüssel","Basic Wrench"):tier==1?game.T("Spannungsprüfer","Voltage Tester"):game.T("Profi-Werkzeug","Professional Kit");
 public static void ValidateCallInformation()
 {
  foreach(string language in new[]{"de","en"})
  {
   var host=new GameObject("Call information fixture");host.SetActive(false);var canvas=new GameObject("Call information canvas",typeof(Canvas));
   try
   {
    var region=new GameObject("Call information region",typeof(RectTransform)).GetComponent<RectTransform>();region.SetParent(canvas.transform,false);region.sizeDelta=new Vector2(375,720);
    var game=host.AddComponent<RepairGame>();game.Profile=new RepairProfile{Language=language,Level=8,ToolMask=7};var hud=host.AddComponent<RepairHud>();hud.Build(region,game);hud.ShowPage(0);
    foreach(var job in new[]{JobCatalog.Find("call-0-0"),JobCatalog.Find("call-1-1"),JobCatalog.Find("call-2-3")})
    {
     Require(job!=null,"FIXTURE_JOB_MISSING");var modal=region.Find("TabletModal");var content=modal.Find("PageBody/ScrollViewport/ScrollContent");
     var row=content.Find("Job"+job.Id+"Action");if(row!=null)row.GetComponent<Button>().onClick.Invoke();
     var selected=region.Find("TabletModal/PageBody/ScrollViewport/ScrollContent/SelectedCall");Require(selected!=null,"SELECTED_CALL_MISSING");
     var text=new System.Text.StringBuilder();foreach(var label in selected.GetComponentsInChildren<Text>())text.AppendLine(label.text);string information=text.ToString();
     Require(information.Contains(RequiredTool(game,job.ToolTier)),"REQUIRED_TOOL_NOT_VISIBLE "+job.Id+" "+language);
     Require(information.Contains(job.Address)&&information.Contains("$"+job.Reward),"CUSTOMER_OR_PAY_NOT_VISIBLE "+job.Id);
     foreach(var stage in job.Presentation.Stages)Require(information.Contains(game.T(stage.TitleDe,stage.TitleEn)),"JOB_SPECIFIC_WORKFLOW_NOT_VISIBLE "+job.Id+" "+language);
     Require(game.Profile.ActiveJob==""&&game.Profile.Cash==1130,"PREVIEW_CHANGED_COMPANY_AUTHORITY");
    }
   }
   finally{UnityEngine.Object.DestroyImmediate(canvas);UnityEngine.Object.DestroyImmediate(host);}
  }
  Debug.Log("REPAIR_PRESENTATION_CALL_INFO_PASS localized tools, customer/pay and three job-specific steps; preview never accepts a job");
 }
 public static void ValidateGuidedArrival()
 {
  foreach(var pane in new[]{new Vector2(393,852),new Vector2(844,390),new Vector2(375,627)})
  {
   var host=new GameObject("Guided control overlap fixture");host.SetActive(false);var canvas=new GameObject("Guided control canvas",typeof(Canvas));
   try
   {
    var region=new GameObject("Guided control region",typeof(RectTransform)).GetComponent<RectTransform>();region.SetParent(canvas.transform,false);region.sizeDelta=pane;
    var game=host.AddComponent<RepairGame>();game.Profile=new RepairProfile{ActiveJob=JobCatalog.All[0].Id};game.Tutorial.Start(game.Profile,284);
    var hud=host.AddComponent<RepairHud>();hud.Build(region,game);hud.RefreshProfile();Canvas.ForceUpdateCanvases();
    var arrival=region.Find("DrivingHud/ServiceCall/RepairArrival")as RectTransform;var skip=region.Find("DrivingHud/SkipTutorial")as RectTransform;
    Require(arrival!=null&&skip!=null&&skip.gameObject.activeSelf,"GUIDED_CONTROLS_MISSING");
    Require(!UiMetrics.ScreenRect(arrival).Overlaps(UiMetrics.ScreenRect(skip)),"GUIDED_ARRIVAL_COVERED_BY_SKIP "+pane);
   }
   finally{UnityEngine.Object.DestroyImmediate(canvas);UnityEngine.Object.DestroyImmediate(host);}
  }
  Debug.Log("REPAIR_PRESENTATION_GUIDED_ARRIVAL_PASS actual Route/Start and Later targets remain separate");
 }
 public static void ValidateCustomerSign()
 {
  var environment=new RepairStreetCompositionValidation.EnvironmentState();var root=new GameObject("Customer sign containment fixture",typeof(CityBuilder));
  try
  {
   root.GetComponent<CityBuilder>().Build();var sign=root.GetComponent<CityBuilder>().Destination.Find("Customer address board");Require(sign!=null,"CUSTOMER_SIGN_MISSING");
   var plate=sign.Find("Modeled customer sign").GetComponent<MeshFilter>();var plateBounds=plate.sharedMesh.bounds;
   var label=sign.GetComponentInChildren<TextMesh>();var renderer=label.GetComponent<MeshRenderer>();var bounds=renderer.localBounds;
   Require(bounds.size.x>0&&bounds.size.y>0,"CUSTOMER_SIGN_TEXT_HAS_NO_GEOMETRY");
   for(int x=-1;x<=1;x+=2)for(int y=-1;y<=1;y+=2)
   {
    var point=sign.InverseTransformPoint(label.transform.TransformPoint(bounds.center+Vector3.Scale(bounds.extents,new Vector3(x,y,0))));
    Require(point.x>=plateBounds.min.x+.06f&&point.x<=plateBounds.max.x-.06f&&point.y>=plateBounds.min.y+.06f&&point.y<=plateBounds.max.y-.06f,"CUSTOMER_SIGN_TEXT_OUTSIDE_PLATE "+point);
   }
  }
  finally{environment.Restore();UnityEngine.Object.DestroyImmediate(root);}
  Debug.Log("REPAIR_PRESENTATION_CUSTOMER_SIGN_PASS actual TextMesh glyph bounds remain inside the modeled plate");
 }
 public static void Validate(){ValidatePedals();ValidateCallInformation();ValidateGuidedArrival();ValidateCustomerSign();}
 public static void CaptureBaseline()
 {
  var failures=new List<string>();foreach(Action check in new Action[]{ValidatePedals,ValidateCallInformation})try{check();}catch(Exception error){failures.Add(error.Message);Debug.Log("REPAIR_PRESENTATION_BASELINE_RED "+error.Message);}
  if(failures.Count>0)throw new InvalidOperationException(string.Join(" | ",failures));
 }
}
#endif
