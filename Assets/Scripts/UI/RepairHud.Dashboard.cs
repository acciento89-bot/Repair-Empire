using System;
using UnityEngine;
using UnityEngine.UI;
using Kamilunavo.RepairEmpire.Core;
using Kamilunavo.RepairEmpire.Gameplay;
using Kamilunavo.RepairEmpire.Visuals;
namespace Kamilunavo.RepairEmpire.UI {
 public sealed partial class RepairHud {
  static readonly Color Paper=new(.965f,.95f,.915f,1),Ink=new(.025f,.065f,.11f),Slate=new(.29f,.34f,.39f),Mist=new(.89f,.88f,.84f),ActionInk=new(.66f,.25f,.04f),Line=new(.82f,.80f,.75f);
  ServiceSceneArt serviceArt;
  float RowHeight=>body!=null&&body.rect.width<300?Mathf.Max(size+110,166):Mathf.Max(size+34,94);
  string[] PageNames()=>new[]{T("Aufträge","Service calls"),T("Ausrüstung","Equipment"),T("Fahrzeuge","Vehicles"),T("Werkstatt","Workshop"),T("Team & Einnahmen","Team & earnings"),T("Täglich","Daily"),T("Optionen","Options"),"Shop"};
  public void ShowDashboard()=>ShowPage(9);
  JobDefinition NextCall(){if(game.ActiveJob!=null)return game.ActiveJob;foreach(var j in game.Jobs)if(RepairRules.CanTake(game.Profile,j)&&!RepairRules.IsPaid(game.Profile,j.Id))return j;return null;}
  void EmptyCalls(Transform parent,float x,float y,float width,float height){
   string name,message;
   if(!game.Profile.Supported){name="SavePreserved";message=T("Dieser Speicherstand stammt aus einer neueren Version. Deine Firma bleibt erhalten; Aufträge sind hier nicht verfügbar.","This save comes from a newer version. Your company is preserved; contracts are unavailable here.");}
   else{bool paid=game.Jobs.Count>0;foreach(var job in game.Jobs)paid&=RepairRules.IsPaid(game.Profile,job.Id);
    if(paid){name="AllCallsPaid";message=T("Alle "+game.Jobs.Count+" Aufträge erledigt. Gut gemacht!","All "+game.Jobs.Count+" contracts completed. Well done!");}
    else{name="NoEligibleCalls";message=T("Aktuell kein passender Auftrag. Prüfe Level und Ausrüstung in der Auftragsliste.","No eligible call right now. Check level and equipment requirements in the call list.");}
   }
   Label(parent,name,message,x,y,width,height,20,Ink);
  }
  void ResolveSelected(){if(!game.Profile.Supported){selectedJob=null;return;}if(selectedJob!=null&&!RepairRules.IsPaid(game.Profile,selectedJob.Id))return;selectedJob=NextCall();}
  void Illustration(Transform parent,int scene,float x,float y,float w,float h){var go=new GameObject("ServiceIllustration",typeof(RectTransform),typeof(CanvasRenderer),typeof(ServiceIllustrationGraphic));go.transform.SetParent(parent,false);At((RectTransform)go.transform,x,y,w,h);var graphic=go.GetComponent<ServiceIllustrationGraphic>();graphic.Scene=scene;graphic.raycastTarget=false;}
  ServiceSceneArt Studio(){if(serviceArt==null){var root=new GameObject("Company service photography");root.transform.SetParent(game.transform,false);serviceArt=root.AddComponent<ServiceSceneArt>();}return serviceArt;}
  void ScenePhoto(Transform parent,string name,Texture texture,float x,float y,float w,float h){var go=new GameObject(name,typeof(RectTransform),typeof(CanvasRenderer),typeof(RawImage));go.transform.SetParent(parent,false);At((RectTransform)go.transform,x,y,w,h);var graphic=go.GetComponent<RawImage>();graphic.texture=texture;graphic.raycastTarget=false;float ratio=w/h,original=(float)texture.width/texture.height;graphic.uvRect=ratio>=original?new Rect(0,(1-original/ratio)*.5f,1,original/ratio):new Rect((1-ratio/original)*.5f,0,ratio/original,1);}
  void ServicePhoto(Transform parent,JobDefinition job,float x,float y,float w,float h){if(Application.isPlaying)ScenePhoto(parent,"ModeledServicePhoto"+job.Id,Studio().Thumbnail(job.Id),x,y,w,h);else Symbol(parent,job,x,y,w,h);}
  void RenderPage(){if(rendering||modal==null)return;rendering=true;try{
   Clear(modal);repairHold=null;progress=null;ResolveSelected();float pad=12;bool repair=game.RepairOpen;var names=PageNames();modal.GetComponent<Image>().color=Paper;
   Panel(modal,"BrandStripe",pad,pad,4,size,Orange);Label(modal,"TabletTitle",repair?T("REPARATUR","REPAIR"):"REPAIR EMPIRE",pad+14,pad,width-(width<300?size:size*2)-48,size*.55f,24,Ink);
   Label(modal,"TabletSubtitle",repair?T("SERVICE AM KUNDEN","CUSTOMER SERVICE"):T("WERKSTATT-TABLET","WORKSHOP TABLET")+" · $"+game.Cash.ToString("N0"),pad+14,pad+size*.55f,width-(width<300?size:size*2)-48,size*.4f,14,Slate);
   if(!repair&&width>=300)Button(modal,"DashboardOptions","•••",width-size*2-pad-6,pad,size,size,()=>ShowPage(6),true,Mist);
   Button(modal,"Close","×",width-size-pad,pad,size,size,Close,true,Mist);
   float top=size+pad*2,bodyW=width-pad*2,bottom=pad;
   if(!repair){bottom=size*2+pad*3+12;if(page!=9){Label(modal,"SectionTitle",names[page],pad,top,bodyW,28,22,Ink);top+=36;}}
   body=Panel(modal,"PageBody",pad,top,bodyW,Mathf.Max(size,height-top-bottom),Color.clear);
   if(repair)RenderRepair();else{RenderTablet();RenderDriveFooter(pad,bodyW);RenderNavigation(pad,bodyW);}
  }finally{rendering=false;}}
  void RenderNavigation(float pad,float w){float y=height-size-pad;var nav=Panel(modal,"DashboardNavigation",0,y-8,width,size+pad+8,Paper);Panel(nav,"NavigationDivider",pad,0,w,1,Line);int[] destinations={0,1,3,9};string[] labels={T("Aufträge","Calls"),T("Ausrüstung","Equipment"),T("Werkstatt","Workshop"),T("Firma","Company")};float bw=(w-12)/4;
   // On the narrowest reserved pane, two rows preserve full-size logical targets.
   bool narrow=bw<size;if(narrow){nav.anchoredPosition=new Vector2(0,-(height-size*2-pad));nav.sizeDelta=new Vector2(width,size*2+pad+8);bw=(w-4)/2;}
   for(int i=0;i<4;i++){int target=destinations[i];bool active=page==target||(target==1&&page==2)||(target==9&&(page==4||page==5||page==6||page==7));float x=pad+(narrow?i%2:i)*(bw+4),row=narrow?i/2:0;var b=Button(nav,"DashboardNav"+target,labels[i],x,8+row*size,bw,size,()=>ShowPage(target),true,Paper);var text=b.GetComponentInChildren<Text>();text.fontSize=text.resizeTextMaxSize=15;text.color=active?ActionInk:Ink;if(active)Panel((RectTransform)b.transform,"ActiveUnderline",8,size-4,bw-16,3,Orange).GetComponent<Image>().raycastTarget=false;}
  }
  void RenderDriveFooter(float pad,float w){bool narrow=(w-12)/4<size;float y=height-size*(narrow?3:2)-pad*2-8;Panel(modal,"FixedActionShelf",0,y-8,width,size+16,Paper);
   JobDefinition call=page==0?selectedJob:game.ActiveJob;bool accept=page==0&&call!=null;string caption=accept?(game.ActiveJob?.Id==call.Id?T("WEITER ZUM KUNDEN","CONTINUE TO CUSTOMER"):T("AUFTRAG ANNEHMEN","ACCEPT SERVICE CALL")):call!=null?T("WEITER ZUR ROUTE","CONTINUE ROUTE"):page==9?T("NÄCHSTEN AUFTRAG WÄHLEN","CHOOSE NEXT SERVICE CALL"):T("ZURÜCK AUF DIE STRASSE","BACK TO THE STREET");
   Button(modal,accept?"AcceptSelected":page==9?"DashboardDrive":"ReturnDrive",caption,pad,y,w,size,()=>{if(accept){if(game.SelectJob(call))Close();else ShowNotice(T("Auftrag nicht verfügbar oder noch beim Kunden","Call unavailable or still at the customer"));}else if(page==9&&call==null)ShowPage(0);else Close();},!accept||RepairRules.CanTake(game.Profile,call));
   // Content stops above both permanent shelves, including the narrow two-row fallback.
   float bodyTop=-body.anchoredPosition.y;body.sizeDelta=new Vector2(w,Mathf.Max(size,y-12-bodyTop));var viewport=body.Find("ScrollViewport") as RectTransform;if(viewport!=null)viewport.sizeDelta=body.sizeDelta;
  }
  void RenderDashboard(){float w=body.rect.width;bool wide=w>=600;float heroH=wide?210:Mathf.Clamp(w*.64f,170,260);var c=Scroll(heroH+560);var hero=Panel(c,"CompanyHero",0,0,w,heroH,Navy);
   if(Application.isPlaying)ScenePhoto(hero,"ModeledWorkshopPhoto",Studio().WorkshopImage(),0,0,w,heroH);else Illustration(hero,3,0,0,w,heroH);
   Panel(hero,"WorkshopCaptionSurface",0,heroH-44,w,44,Navy);Label(hero,"WorkshopCaption",T("KLEINE REPARATUREN. GROSSE WIRKUNG.","SMALL REPAIRS. REAL IMPACT."),14,heroH-42,w-28,40,15,White);
   float y=heroH+12;Label(c,"CurrentCallHeading",game.ActiveJob!=null?T("AKTUELLER AUFTRAG","CURRENT SERVICE CALL"):T("DEIN NÄCHSTER AUFTRAG","YOUR NEXT SERVICE CALL"),0,y,w,27,15,Ink);y+=32;var call=NextCall();if(call!=null){CallCard(c,call,"DashboardCurrentCall",0,y,w,Mathf.Max(126,size+60),()=>{selectedJob=call;ShowPage(0);},false);y+=Mathf.Max(126,size+60)+10;}
   else{EmptyCalls(c,8,y,w-16,Mathf.Max(110,size*2));y+=Mathf.Max(110,size*2)+10;}
   int shown=0;foreach(var job in game.Jobs){if(job.Id==call?.Id||RepairRules.IsPaid(game.Profile,job.Id))continue;float h=Mathf.Max(size+38,96);CallCard(c,job,"DashboardNext"+job.Id,0,y,w,h,()=>{selectedJob=job;ShowPage(0);},false);y+=h+8;if(++shown==2)break;}
   Label(c,"CompanySections",T("DEINE FIRMA","YOUR COMPANY"),0,y+6,w,28,15,Slate);y+=42;int[] sections={4,5,7,6};string[] labels={T("Team & Einnahmen","Team & earnings"),T("Tägliche Ziele","Daily goals"),T("Designs & Shop","Designs & shop"),T("Optionen & Hilfe","Options & help")};foreach(int i in new[]{0,1,2,3}){int section=sections[i];var b=Button(c,"DashboardSection"+section,labels[i]+"  ›",0,y,w,size,()=>ShowPage(section),true,Color.white);b.GetComponentInChildren<Text>().color=Ink;y+=size+8;}c.sizeDelta=new Vector2(w,Mathf.Max(body.rect.height,y));
  }
  void CallCard(RectTransform parent,JobDefinition job,string name,float x,float y,float w,float h,Action action,bool paid){var card=Button(parent,name,"",x,y,w,h,action,!paid,paid?Mist:Color.white);float art=Mathf.Min(h-16,w<280?62:100);ServicePhoto(card.transform,job,8,8,art,art);float left=art+20,remaining=w-left-12;Label(card.transform,"Title",T(job.TitleDe,job.Title),left,6,remaining,h>=120?51:43,21,Ink);Label(card.transform,"Meta",paid?T("Erledigt · bezahlt","Completed · paid"):job.Address+" · Lv "+job.MinimumLevel,left,h>=120?59:49,remaining,23,14,Slate);Label(card.transform,"Payout",paid?"✓ "+T("Bezahlt","Paid"):"$"+job.Reward+" · "+job.Xp+" XP",left,h-32,remaining,25,16,paid?Slate:Ink);}
  void Row(RectTransform p,string name,string title,string description,float y,Action action,string actionText,bool enabled=true,Color? color=null){float w=p.rect.width,h=RowHeight;var card=Panel(p,name,0,y,w,h,Color.white);bool narrow=w<300;float icon=w>=310?66:0;if(icon>0)Illustration(card,page,8,13,52,Mathf.Min(66,h-26));float left=icon+12;float actionW=narrow?w-24:Mathf.Min(112,Mathf.Max(size,w*.27f));Label(card,"Title",title,left,8,narrow?w-24:w-left-actionW-18,31,20,Ink);Label(card,"Description",description,left,40,narrow?w-24:w-left-actionW-18,narrow?h-size-58:h-46,14,Slate);var button=Button(card,name+"Action",actionText,narrow?12:w-actionW-8,narrow?h-size-10:(h-size)/2,actionW,size,action,enabled,color??Mist);var text=button.GetComponentInChildren<Text>();text.fontSize=text.resizeTextMaxSize=16;}
  void RenderJobs(float row){ResolveSelected();float w=body.rect.width,h=Mathf.Max(126,size+60),callH=Mathf.Max(size+40,106);var c=Scroll(h+50+game.Jobs.Count*(callH+8));if(selectedJob!=null){CallCard(c,selectedJob,"SelectedCall",0,0,w,h,()=>{},false);var title=c.Find("SelectedCall/Title");if(title!=null)title.name="SelectedTitle";}
   else EmptyCalls(c,12,12,w-24,h-12);
   Label(c,"CallsSection",T("KUNDEN IN DEINER STADT","CUSTOMERS IN YOUR CITY"),0,h+8,w,28,15,Slate);int index=0;foreach(var job in game.Jobs){if(selectedJob?.Id==job.Id)continue;var current=job;bool paid=RepairRules.IsPaid(game.Profile,job.Id);CallCard(c,job,"Job"+job.Id+"Action",0,h+44+index++*(callH+8),w,callH,()=>{selectedJob=current;RenderPage();},paid);}c.sizeDelta=new Vector2(w,Mathf.Max(body.rect.height,h+44+index*(callH+8)));
  }
 }
}
