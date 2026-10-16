#if UNITY_EDITOR
using System;
using UnityEngine;
using UnityEngine.UI;
using Kamilunavo.RepairEmpire.Core;
using Kamilunavo.RepairEmpire.Gameplay;
using Kamilunavo.RepairEmpire.UI;
public static class RepairMainMenuValidation
{
 static void Require(bool value,string why){if(!value)throw new InvalidOperationException("Repair mainmenu: "+why);}
 public static void Validate()
 {
  int cases=0;
  foreach(var dimension in new[]{new Vector2(320,650),new Vector2(390,844),new Vector2(768,1024)})foreach(string language in new[]{"de","en"})foreach(bool active in new[]{true,false})
  {
   var host=new GameObject("Actual portrait mainmenu fixture");host.SetActive(false);var canvas=new GameObject("Mainmenu canvas",typeof(Canvas));
   try
   {
    canvas.GetComponent<Canvas>().renderMode=RenderMode.ScreenSpaceOverlay;var region=new GameObject("Mainmenu pane",typeof(RectTransform)).GetComponent<RectTransform>();region.SetParent(canvas.transform,false);region.anchorMin=region.anchorMax=Vector2.one*.5f;region.sizeDelta=dimension;var game=host.AddComponent<RepairGame>();game.Profile=new RepairProfile{Language=language,Level=8,Cash=2345,ToolMask=7,ActiveJob=active?"faucet":"",ActiveTicket=active?1:0};var hud=host.AddComponent<RepairHud>();hud.Build(region,game);hud.ShowDashboard();Canvas.ForceUpdateCanvases();var modal=region.Find("TabletModal");var content=modal.Find("PageBody/ScrollViewport/ScrollContent");var card=content.Find("DashboardCurrentCall");Button action=null;foreach(var b in modal.GetComponentsInChildren<Button>())if(b.name=="DashboardDrive")action=b;
    Require(card!=null&&action!=null&&action.transform.IsChildOf(card),"Actual current-call action must be grouped inside its card "+dimension+" "+language+" active="+active);Require(modal.Find("FixedActionShelf")==null,"Tall mainmenu must not reserve a second detached action shelf");RawImage picture=null;foreach(var image in content.Find("CompanyHero").GetComponentsInChildren<RawImage>())picture=image;Require(picture!=null&&picture.rectTransform.rect.height>=(dimension.y<700?160:dimension.y*.29f),"Portrait workshop scene is large enough to lead composition");Require(((RectTransform)action.transform).rect.height>=48&&((RectTransform)action.transform).rect.width>=48,"Grouped actual call action retains48logicalpoints");Require(game.Profile.ActiveJob==(active?"faucet":"")&&game.Profile.Cash==2345&&game.Profile.CompletedJobs==0,"Preview construction does not dispatch or pay");action.onClick.Invoke();if(active)Require(!hud.ModalOpen&&!game.Paused&&game.Profile.ActiveTicket==1,"Existing active ticket resumes explicitly");else{Require(hud.ModalOpen&&game.Paused&&game.Profile.ActiveJob==""&&game.Profile.ActiveTicket==0,"Unaccepted preview opens paused details without dispatch");hud.Back();Require(region.Find("TabletModal/PageBody/ScrollViewport/ScrollContent/CompanyHero")!=null&&game.Paused,"Details Back restores company without resuming");}Require(game.Profile.Cash==2345&&game.Profile.CompletedJobs==0,"Menu action and Back never grant payment");cases++;
   }
   finally{UnityEngine.Object.DestroyImmediate(canvas);UnityEngine.Object.DestroyImmediate(host);}
  }
  Debug.Log("REPAIR_MAINMENU_PASS actualportrait phone/tablet DE/EN active/unaccepted cases="+cases+" groupedaction largehero statepreserved");
 }
}
#endif
