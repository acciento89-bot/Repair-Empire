using System;
using UnityEngine;
using UnityEngine.UI;
using Kamilunavo.RepairEmpire.Core;
using Kamilunavo.RepairEmpire.Gameplay;

namespace Kamilunavo.RepairEmpire.UI
{
 public sealed partial class RepairHud
 {
  string RequiredTool(JobDefinition job)=>job.ToolTier==0?T("Basis-Schlüssel","Basic Wrench"):job.ToolTier==1?T("Spannungsprüfer","Voltage Tester"):T("Profi-Werkzeug","Professional Kit");
  string RouteDistance(JobDefinition job)
  {
   var from=game.Vehicle!=null?game.Vehicle.transform.position:new Vector3(game.Profile.SavedX,0,game.Profile.SavedZ);
   float metres=Vector2.Distance(new Vector2(from.x,from.z),new Vector2(job.DestinationX,job.DestinationZ));
   return metres>=1000?(metres/1000).ToString("0.0",game.Profile.Language=="de"?System.Globalization.CultureInfo.GetCultureInfo("de-DE"):System.Globalization.CultureInfo.InvariantCulture)+" km":Mathf.RoundToInt(metres)+" m";
  }
  void SelectedContract(RectTransform parent,JobDefinition job,float w)
  {
   bool narrow=w<260;float h=narrow?340:224,photo=narrow?62:88,left=photo+24;
   var card=Button(parent,"SelectedCall","",0,0,w,h,()=>{},true,Color.white);
   ServicePhoto(card.transform,job,8,8,photo,photo);
   Label(card.transform,"SelectedTitle",T(job.TitleDe,job.Title),left,8,w-left-10,narrow?64:50,21,Ink);
   Label(card.transform,"Meta",job.Address+" · "+RouteDistance(job),narrow?10:left,narrow?80:61,narrow?w-20:w-left-10,narrow?35:24,14,Slate,TextAnchor.MiddleLeft,FontStyle.Normal);
   Label(card.transform,"Payout","$"+job.Reward+"  ·  "+job.Xp+" XP",narrow?10:left,narrow?118:88,narrow?w-20:w-left-10,25,18,Ink);
   float requirementsY=narrow?153:121;Panel(card.transform,"RequirementsDivider",10,requirementsY-5,w-20,1,Line);
   ItemGlyph(card.transform,"Tool"+job.ToolTier,10,requirementsY+3,28,30);
   Label(card.transform,"RequiredTool",RequiredTool(job),44,requirementsY,narrow?w-54:w-130,36,14,(game.Profile.ToolMask&(1<<job.ToolTier))!=0?Ink:ActionInk);
   var level=Panel(card.transform,"RequiredLevel",narrow?10:w-80,requirementsY+(narrow?40:3),narrow?w-20:70,30,game.Profile.Level>=job.MinimumLevel?Mist:new Color(.98f,.87f,.80f));Label(level,"Level","Lv "+job.MinimumLevel,3,0,narrow?w-26:64,30,13,Ink,TextAnchor.MiddleCenter);
   float flowY=requirementsY+(narrow?78:46);int columns=narrow?1:3;float cell=w/columns;
   for(int i=0;i<3;i++)
   {
    var stage=job.Presentation.Stages[i];float x=narrow?10:i*cell+8,y=flowY+(narrow?i*32:0);
    var marker=Panel(card.transform,"PreviewStep"+i,x,y+3,20,20,Mist);marker.GetComponent<RoundedPanel>().Radius=10;Label(marker,"Number",(i+1).ToString(),0,0,20,20,12,ActionInk,TextAnchor.MiddleCenter);
    Label(card.transform,"Workflow"+i,T(stage.TitleDe,stage.TitleEn),x+26,y,cell-(narrow?46:36),narrow?28:42,13,Slate,TextAnchor.MiddleLeft,FontStyle.Normal);
   }
  }
  void RenderContractBoard()
  {
   ResolveSelected();float w=body.rect.width;bool wide=w>=650;float detailW=wide?w*.41f:w,detailH=detailW<260?340:224;
   var content=Scroll(Mathf.Max(body.rect.height,detailH+game.Jobs.Count*114+64));
   if(selectedJob!=null)SelectedContract(content,selectedJob,detailW);else EmptyCalls(content,12,12,detailW-24,detailH-12);
   float listX=wide?detailW+16:0,listW=wide?w-listX:w,y=wide?0:detailH+14;
   Label(content,"CallsSection",T("SERVICE-AUFTRÄGE","SERVICE CALLS"),listX+2,y,listW-4,24,15,Ink);
   int open=0;foreach(var job in game.Jobs)if(!RepairRules.IsPaid(game.Profile,job.Id))open++;
   Label(content,"CallBoardStatus",T(open+" offen · "+(game.Jobs.Count-open)+" erledigt",open+" open · "+(game.Jobs.Count-open)+" completed"),listX+2,y+25,listW-4,22,13,Slate,TextAnchor.MiddleLeft,FontStyle.Normal);y+=54;
   foreach(var job in game.Jobs)
   {
    if(selectedJob?.Id==job.Id)continue;var current=job;bool paid=RepairRules.IsPaid(game.Profile,job.Id);
    CallCard(content,job,"Job"+job.Id+"Action",listX,y,listW,106,()=>{selectedJob=current;RenderPage();},paid);y+=114;
   }
   content.sizeDelta=new Vector2(w,Mathf.Max(body.rect.height,Mathf.Max(detailH,y)));
  }
  void WorkflowTimeline(RectTransform parent,JobDefinition job,int phase,float w,float y,float h)
  {
   var panel=Panel(parent,"RepairProcedure",0,y,w,h,Color.white);float cell=w/3;
   for(int i=0;i<3;i++)
   {
    var step=job.Presentation.Stages[i];float centre=cell*(i+.5f);
    if(i<2)Panel(panel,"StageLine"+i,centre+14,22,cell-28,2,i<phase?Orange:Line);
    var marker=Panel(panel,"StageMarker"+i,centre-13,10,26,26,i<=phase?Orange:Mist);marker.GetComponent<RoundedPanel>().Radius=13;
    Label(marker,"Number",i<phase?"✓":(i+1).ToString(),0,0,26,26,14,Ink,TextAnchor.MiddleCenter);
    Label(panel,"ProcedureStep"+i,T(step.TitleDe,step.TitleEn),cell*i+5,41,cell-10,h-46,14,i<=phase?Ink:Slate,TextAnchor.UpperCenter);
   }
  }
  void RenderRepairStudio()
  {
   var job=game.ActiveJob;var interaction=game.Interaction;if(job==null||interaction==null)return;
   float w=body.rect.width;int phase=Mathf.Min(2,game.Profile.RepairPhase);var stage=interaction.Stage??job.Presentation?.Stages[phase];if(stage==null)return;
   bool sequence=interaction.Kind==RepairInputKind.Sequence,wide=w>=600;int count=interaction.ActionCount,rows=sequence?Mathf.CeilToInt(count/2f):1;
   float summaryW=wide?w*.39f-8:w,sceneX=wide?w*.40f:0,sceneW=wide?w*.60f:w,header=summaryW<260?102:82,steps=summaryW<260?110:88;
   float shelfHeight=sequence?rows*(size+6)+34:size+30,shelfY=height-shelfHeight-12;
   float artH=wide?Mathf.Max(150,shelfY-110):Mathf.Clamp(w*.75f,150,340);var content=Scroll(header+steps+artH+140);
   var summary=Panel(content,"RepairServiceSummary",0,0,summaryW,header,Color.white);float thumbnail=summaryW<260?42:62,left=thumbnail+20;
   ServicePhoto(summary,job,8,8,thumbnail,thumbnail);Label(summary,"RepairTitle",T(job.TitleDe,job.Title),left,4,summaryW-left-10,header-38,20,Ink);
   Label(summary,"RepairAddress",job.Address+" · $"+job.Reward+" · "+job.Xp+" XP",left,header-31,summaryW-left-10,27,13,Slate,TextAnchor.MiddleLeft,FontStyle.Normal);
   WorkflowTimeline(content,job,phase,summaryW,header+10,steps);
   float headingY=header+steps+22;
   Label(content,"Stage",T(stage.TitleDe,stage.TitleEn),8,headingY,summaryW-16,34,21,Ink);
   float artY=wide?0:headingY+42;
   if(Application.isPlaying)ScenePhoto(content,"ActualRepairScene",Studio().RepairImage(job.Id,phase,interaction.Taps),sceneX,artY,sceneW,artH);else Symbol(content,job,sceneX,artY,sceneW,artH);
   float instructionsY=wide?headingY+42:artY+artH+10;
   Label(content,"Instructions",T(stage.InstructionDe,stage.InstructionEn),8,instructionsY,summaryW-16,52,16,Slate,TextAnchor.MiddleLeft,FontStyle.Normal);
   var shelf=Panel(modal,"RepairActionShelf",12,shelfY,w,shelfHeight,Paper);Panel(shelf,"ActionDivider",0,0,w,1,Line);
   body.sizeDelta=new Vector2(w,Mathf.Max(size,shelfY-12+body.anchoredPosition.y));var viewport=body.Find("ScrollViewport")as RectTransform;if(viewport!=null)viewport.sizeDelta=body.sizeDelta;
   if(sequence)
   {
    float buttonW=(w-24)/2;
    for(int i=0;i<count;i++)
    {
     int tap=i;var action=stage.Actions[i];var button=Button(shelf,"RepairTap"+i,(i+1)+"  "+T(action.LabelDe,action.LabelEn),8+(i%2)*(buttonW+8),8+(i/2)*(size+6),buttonW,size,()=>{if(game.ApplicationInterrupted){game.Interaction.ResetInput();return;}if(game.Interaction.Tap(tap))game.AdvanceRepair(phase);else RefreshRepairSequence(job,phase,count);},true,i==interaction.Taps?Orange:Mist);
     button.GetComponentInChildren<Text>().fontSize=button.GetComponentInChildren<Text>().resizeTextMaxSize=17;
    }
    Label(shelf,"TapProgress",interaction.Taps+" / "+count,8,8+rows*(size+6),w-16,24,16,Slate);
   }
   else
   {
    repairHold=Hold(shelf,"RepairHold",T(stage.ButtonDe,stage.ButtonEn),8,8,w-16,size);repairHold.GetComponent<Image>().color=Orange;repairHold.GetComponent<Image>().material=null;repairHold.GetComponentInChildren<Text>().color=Ink;
    progress=UiFactory.Progress(shelf,Vector2.zero,Vector2.one,Line,Orange);At((RectTransform)progress.transform.parent,8,size+16,w-16,10);
   }
   content.sizeDelta=new Vector2(w,Mathf.Max(body.rect.height,Mathf.Max(instructionsY+60,artY+artH)));
  }
  void RenderPaymentReceipt()
  {
   var job=game.ResultJob;if(job==null)return;float w=body.rect.width;var content=Scroll(400);
   var receipt=Panel(content,"PaymentReceipt",0,0,w,330,Color.white);
   var badge=Panel(receipt,"PaidBadge",w*.5f-26,18,52,52,new Color(.84f,.91f,.83f));badge.GetComponent<RoundedPanel>().Radius=26;Label(badge,"Check","✓",0,0,52,52,30,new Color(.16f,.37f,.24f),TextAnchor.MiddleCenter);
   Label(receipt,"PaidResultTitle",T("AUFTRAG BEZAHLT","PAYMENT RECEIVED"),12,83,w-24,36,23,Ink,TextAnchor.MiddleCenter);
   Label(receipt,"PaidResultContract",T(job.TitleDe,job.Title),16,127,w-32,50,20,Ink,TextAnchor.MiddleCenter);
   Label(receipt,"PaidResultAddress",job.Address,16,179,w-32,24,14,Slate,TextAnchor.MiddleCenter,FontStyle.Normal);
   Panel(receipt,"ReceiptDivider",18,218,w-36,1,Line);
   Label(receipt,"PaidResultReward","+$"+job.Reward+"  ·  +"+job.Xp+" XP",16,230,w-32,48,26,ActionInk,TextAnchor.MiddleCenter);
   Label(receipt,"PaidResultInfo",T("Dein Lohn ist gesichert.","Your payment is saved."),16,283,w-32,28,15,Slate,TextAnchor.MiddleCenter,FontStyle.Normal);
   float y=height-size*2-24;Button(modal,"ResultResume",T("WEITERFAHREN","RESUME DRIVING"),12,y,w,size,Close,true,Orange);Button(modal,"ResultShop",T("Shop · Werbung entfernen","Shop · Remove Ads"),12,y+size+8,w,size,()=>ShowPage(7),true,Mist);
  }
 }
}
