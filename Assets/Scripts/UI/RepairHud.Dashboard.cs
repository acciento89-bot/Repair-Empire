using System;
using UnityEngine;
using UnityEngine.UI;
using Kamilunavo.RepairEmpire.Core;
using Kamilunavo.RepairEmpire.Gameplay;
using Kamilunavo.RepairEmpire.Visuals;
namespace Kamilunavo.RepairEmpire.UI {
 public sealed partial class RepairHud {
  static readonly Color Paper=new(.975f,.96f,.93f,1),Ink=new(.025f,.065f,.11f),Slate=new(.27f,.33f,.39f),Mist=new(.91f,.89f,.84f),ActionInk=new(.66f,.25f,.04f),Line=new(.86f,.83f,.77f);
  ServiceSceneArt serviceArt;
  float RowHeight=>body!=null&&body.rect.width<300?Mathf.Max(size+94,148):Mathf.Max(size+30,90);
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
  void UiIcon(Transform parent,string symbol,float x,float y,float w,float h,Color tint){var go=new GameObject("Icon"+symbol,typeof(RectTransform),typeof(CanvasRenderer),typeof(ServiceUiIcon));go.transform.SetParent(parent,false);At((RectTransform)go.transform,x,y,w,h);var icon=go.GetComponent<ServiceUiIcon>();icon.Symbol=symbol;icon.color=tint;icon.raycastTarget=false;}
  void ScenePhoto(Transform parent,string name,Texture texture,float x,float y,float w,float h)
  {
   Transform host=parent;
   if(name!="ActualRepairScene")
   {
    var frame=Panel(parent,name+"Frame",x,y,w,h,Color.white);frame.GetComponent<Image>().raycastTarget=false;frame.gameObject.AddComponent<Mask>().showMaskGraphic=false;host=frame;x=y=0;
   }
   var go=new GameObject(name,typeof(RectTransform),typeof(CanvasRenderer),typeof(RawImage));go.transform.SetParent(host,false);At((RectTransform)go.transform,x,y,w,h);var graphic=go.GetComponent<RawImage>();graphic.texture=texture;graphic.raycastTarget=false;
   if(texture!=null){float ratio=w/h,original=(float)texture.width/texture.height;graphic.uvRect=ratio>=original?new Rect(0,(1-original/ratio)*.5f,1,original/ratio):new Rect((1-ratio/original)*.5f,0,ratio/original,1);}
  }
  void ServicePhoto(Transform parent,JobDefinition job,float x,float y,float w,float h){if(Application.isPlaying)ScenePhoto(parent,"ModeledServicePhoto"+job.Id,Studio().Thumbnail(job.Id),x,y,w,h);else Symbol(parent,job,x,y,w,h);}
  void ItemGlyph(Transform parent,string item,float x,float y,float w,float h){var go=new GameObject("ServiceItemGlyph",typeof(RectTransform),typeof(CanvasRenderer),typeof(ServiceItemGlyph));go.transform.SetParent(parent,false);At((RectTransform)go.transform,x,y,w,h);var glyph=go.GetComponent<ServiceItemGlyph>();glyph.Item=item;glyph.raycastTarget=false;}
  void RenderPage(){if(rendering||modal==null)return;rendering=true;try{
   Clear(modal);repairHold=null;progress=null;ResolveSelected();float pad=12;bool repair=game.RepairOpen,result=game.ResultOpen;var names=PageNames();modal.GetComponent<Image>().color=Paper;modal.GetComponent<Image>().material=null;
   Panel(modal,"ServiceHeader",0,0,width,size+pad*2,Paper);Panel(modal,"BrandStripe",pad,pad,4,size,Orange);Label(modal,"TabletTitle",result?T("AUFTRAG BEZAHLT","ORDER PAID"):repair?T("REPARATUR","REPAIR"):"REPAIR EMPIRE",pad+14,pad,width-(width<300?size:size*2)-48,size*.55f,22,Ink);
   Label(modal,"TabletSubtitle",repair?T("SERVICE AM KUNDEN","CUSTOMER SERVICE"):page==9?T("WERKSTATT-TABLET","WORKSHOP TABLET"):T("DEINE FIRMA","YOUR COMPANY")+" · $"+game.Cash.ToString("N0"),pad+14,pad+size*.55f,width-(width<300?size:size*2)-48,size*.4f,13,Slate);
   if(!repair&&!result&&width>=300){var shop=Button(modal,"DashboardShop","Shop",width-size*2-pad-6,pad,size,size,()=>ShowPage(7),true,Color.white);At((RectTransform)shop.GetComponentInChildren<Text>().transform,0,size-20,size,18);shop.GetComponentInChildren<Text>().fontSize=shop.GetComponentInChildren<Text>().resizeTextMaxSize=12;UiIcon(shop.transform,"Shop",(size-23)/2,4,23,23,Ink);}
   Button(modal,"Close","×",width-size-pad,pad,size,size,Close,true,Color.white);
   Panel(modal,"HeaderDivider",pad,size+pad*2-1,width-pad*2,1,Line);
   float top=size+pad*2+10,bodyW=width-pad*2,bottom=pad;
   if(!repair){bottom=size*2+pad*3+12;if(page!=9&&!result){Label(modal,"SectionTitle",names[page],pad,top,bodyW,28,22,Ink);top+=36;}}
   body=Panel(modal,"PageBody",pad,top,bodyW,Mathf.Max(size,height-top-bottom),Color.clear);
   if(result)RenderPaidResult();else if(repair)RenderRepair();else{RenderTablet();RenderDriveFooter(pad,bodyW);RenderNavigation(pad,bodyW);}
  }finally{rendering=false;}}
  bool NarrowNavigation(float w)=>(w-12)/4<size;
  float NavigationHeight(float w)=>NarrowNavigation(w)?size*2+8:Mathf.Max(size+8,72);
  void RenderNavigation(float pad,float w)
  {
   bool narrow=NarrowNavigation(w);float navH=NavigationHeight(w),y=height-navH;var nav=Panel(modal,"DashboardNavigation",0,y,width,navH,Paper);Panel(nav,"NavigationDivider",pad,0,w,1,Line);
   int[] destinations={0,1,3,9};string[] symbols={"Calls","Equipment","Workshop","Company"};string[] labels={T("Aufträge","Calls"),T("Ausrüstung","Equipment"),T("Werkstatt","Workshop"),T("Firma","Company")};float bw=narrow?(w-4)/2:(w-12)/4;
   for(int i=0;i<4;i++)
   {
    int target=destinations[i];bool active=page==target||(target==1&&page==2)||(target==9&&(page==4||page==5||page==6||page==7));float x=pad+(narrow?i%2:i)*(bw+4),row=narrow?i/2:0,h=narrow?size:navH-8;
    var button=Button(nav,"DashboardNav"+target,labels[i],x,4+row*size,bw,h,()=>ShowPage(target),true,Paper);var label=button.GetComponentInChildren<Text>();label.color=active?ActionInk:Ink;label.fontSize=label.resizeTextMaxSize=14;
    float iconSize=narrow?18:27;At((RectTransform)label.transform,0,narrow?h-20:h-24,bw,narrow?17:20);if(narrow)label.fontSize=label.resizeTextMaxSize=12;UiIcon(button.transform,symbols[i],(bw-iconSize)/2,narrow?4:7,iconSize,iconSize,active?ActionInk:Ink);
    if(active)Panel((RectTransform)button.transform,"ActiveUnderline",bw*.19f,h-3,bw*.62f,3,Orange).GetComponent<Image>().raycastTarget=false;
   }
  }
  void RenderDriveFooter(float pad,float w){float y=height-NavigationHeight(w)-size-pad-12;Panel(modal,"FixedActionShelf",0,y-8,width,size+16,Paper);
   JobDefinition call=page==0?selectedJob:game.ActiveJob;bool accept=page==0&&call!=null;string caption=accept?(game.ActiveJob?.Id==call.Id?T("ZUM KUNDEN","TO CUSTOMER"):T("ANNEHMEN","ACCEPT CALL")):call!=null?T("ROUTE FORTSETZEN","CONTINUE ROUTE"):page==9?T("AUFTRAG WÄHLEN","CHOOSE CALL"):T("WEITERFAHREN","RESUME DRIVING");
   bool eligible=!accept||RepairRules.CanTake(game.Profile,call);if(accept&&!eligible)caption=game.Profile.Level<call.MinimumLevel?T("LEVEL "+call.MinimumLevel+" ERREICHEN","REACH LEVEL "+call.MinimumLevel):T("WERKZEUG BENÖTIGT","TOOL REQUIRED");
   float backW=page==9?0:Mathf.Min(96,Mathf.Max(size,w*.25f)),actionX=pad+(backW>0?backW+8:0),actionW=w-(actionX-pad);
   if(backW>0){var back=Button(modal,"MenuBack",T("‹ Zurück","‹ Back"),pad,y,backW,size,Back,true,Mist);back.GetComponentInChildren<Text>().fontSize=back.GetComponentInChildren<Text>().resizeTextMaxSize=16;}
   var drive=Button(modal,accept?"AcceptSelected":page==9?"DashboardDrive":"ReturnDrive",caption,actionX,y,actionW,size,()=>{if(accept){if(game.SelectJob(call))Close();else ShowNotice(T("Auftrag nicht verfügbar oder noch beim Kunden","Call unavailable or still at the customer"));}else if(page==9&&call==null)ShowPage(0);else Close();},eligible,eligible?Orange:Mist);drive.GetComponentInChildren<Text>().fontSize=drive.GetComponentInChildren<Text>().resizeTextMaxSize=16;
   float bodyTop=-body.anchoredPosition.y;body.sizeDelta=new Vector2(w,Mathf.Max(size,y-12-bodyTop));var viewport=body.Find("ScrollViewport") as RectTransform;if(viewport!=null)viewport.sizeDelta=body.sizeDelta;
  }
  void RenderDashboard()
  {
   float w=body.rect.width;bool wide=w>=600;float imageH=wide?Mathf.Clamp(body.rect.height-24,92,Mathf.Min(210,w*.22f)):Mathf.Clamp(w*.625f,150,300),imageW=wide?imageH*3:w,heroH=wide?imageH:imageH+44;var c=Scroll(heroH+600);var hero=Panel(c,"CompanyHero",0,0,w,heroH,Paper);
   var artwork=Resources.Load<Texture2D>(wide?"Art/Workshop/ServiceWorkshopHero-wide-v1":"Art/Workshop/ServiceWorkshopHero-v1");
   if(artwork!=null)ScenePhoto(hero,"WorkshopHeroArtwork",artwork,0,0,imageW,imageH);else if(Application.isPlaying)ScenePhoto(hero,"ModeledWorkshopPhoto",Studio().WorkshopImage(),0,0,imageW,imageH);else Illustration(hero,3,0,0,imageW,imageH);
   float walletW=Mathf.Min(114,w*.40f),walletX=wide?imageW+16:w-walletW-8,walletY=wide?imageH-38:imageH+6;var wallet=Panel(hero,"CompanyWallet",walletX,walletY,walletW,32,Navy);UiIcon(wallet,"Cash",7,6,22,20,new Color(.43f,.83f,.46f));Label(wallet,"DashboardBalance","$"+game.Cash.ToString("N0"),34,0,walletW-40,32,18,White);
   Label(hero,"WorkshopCaption",T("KLEINE REPARATUREN. GROSSE WIRKUNG.","SMALL REPAIRS. REAL IMPACT."),wide?imageW+16:8,wide?8:imageH+2,wide?w-imageW-24:Mathf.Max(48,w-walletW-24),40,12,Ink);
   float y=heroH+10;Label(c,"CurrentCallHeading",game.ActiveJob!=null?T("AKTUELLER AUFTRAG","CURRENT SERVICE CALL"):T("DEIN NÄCHSTER AUFTRAG","YOUR NEXT SERVICE CALL"),4,y,w-8,23,15,Ink);y+=29;
   var call=NextCall();if(call!=null){float cardH=Mathf.Max(132,size+64);CallCard(c,call,"DashboardCurrentCall",0,y,w,cardH,()=>{selectedJob=call;ShowPage(0);},false);y+=cardH+10;}else{EmptyCalls(c,8,y,w-16,Mathf.Max(110,size*2));y+=Mathf.Max(110,size*2)+10;}
   bool columns=w>=320;int shown=0;
   foreach(var job in game.Jobs)
   {
    if(job.Id==call?.Id||RepairRules.IsPaid(game.Profile,job.Id))continue;var next=job;
    if(columns){float cardW=(w-10)/2;CompactCall(c,next,"DashboardNext"+job.Id,(shown%2)*(cardW+10),y,cardW,124,()=>{selectedJob=next;ShowPage(0);});}
    else{CallCard(c,next,"DashboardNext"+job.Id,0,y,w,106,()=>{selectedJob=next;ShowPage(0);},false);y+=116;}
    if(++shown==2)break;
   }
   if(columns&&shown>0)y+=134;
   Label(c,"CompanySections",T("DEINE FIRMA","YOUR COMPANY"),4,y+4,w-8,25,15,Slate);y+=36;
   int[] sections={4,5,7,6};string[] labels={T("Team & Einnahmen","Team & earnings"),T("Tägliche Ziele","Daily goals"),T("Designs & Shop","Designs & shop"),T("Optionen & Hilfe","Options & help")};string[] symbols={"Company","Calls","Shop","Equipment"};
   for(int i=0;i<4;i++){int section=sections[i];var button=Button(c,"DashboardSection"+section,labels[i]+"  ›",0,y,w,size+4,()=>ShowPage(section),true,Color.white);var text=button.GetComponentInChildren<Text>();At((RectTransform)text.transform,48,0,w-60,size+4);text.color=Ink;text.fontSize=text.resizeTextMaxSize=18;text.alignment=TextAnchor.MiddleLeft;UiIcon(button.transform,symbols[i],12,(size-24)/2,28,28,ActionInk);y+=size+12;}
   c.sizeDelta=new Vector2(w,Mathf.Max(body.rect.height,y));
  }
  void CompactCall(RectTransform parent,JobDefinition job,string name,float x,float y,float w,float h,Action action)
  {
   var card=Button(parent,name,"",x,y,w,h,action,true,Color.white);ServicePhoto(card.transform,job,9,10,47,47);Label(card.transform,"Title",T(job.TitleDe,job.Title),64,6,w-72,54,16,Ink);Label(card.transform,"Meta",job.Address,10,66,w-20,28,13,Slate,TextAnchor.MiddleLeft,FontStyle.Normal);Label(card.transform,"Payout","$"+job.Reward+" · "+job.Xp+" XP",10,h-27,w-20,22,14,Ink);
  }
  void CallCard(RectTransform parent,JobDefinition job,string name,float x,float y,float w,float h,Action action,bool paid){var card=Button(parent,name,"",x,y,w,h,action,!paid,paid?Mist:Color.white);float art=Mathf.Min(h-16,w<280?62:100);ServicePhoto(card.transform,job,8,8,art,art);float left=art+20,remaining=w-left-12;Label(card.transform,"Title",T(job.TitleDe,job.Title),left,6,remaining,h>=120?51:43,21,Ink);Label(card.transform,"Meta",paid?T("Erledigt · bezahlt","Completed · paid"):job.Address+" · Lv "+job.MinimumLevel,left,h>=120?59:49,remaining,23,14,Slate,TextAnchor.MiddleLeft,FontStyle.Normal);Label(card.transform,"Payout",paid?"✓ "+T("Bezahlt","Paid"):"$"+job.Reward+" · "+job.Xp+" XP",left,h-32,remaining,25,16,paid?Slate:Ink);}
  void Row(RectTransform p,string name,string title,string description,float y,Action action,string actionText,bool enabled=true,Color? color=null){float w=p.rect.width,h=RowHeight;var card=Panel(p,name,0,y,w,h,Color.white);bool narrow=w<300;float icon=narrow?38:58;ItemGlyph(card,name,8,8,icon,narrow?42:Mathf.Min(66,h-16));float left=icon+16;float actionW=narrow?w-16:Mathf.Min(112,Mathf.Max(size,w*.27f));Label(card,"Title",title,left,7,narrow?w-left-8:w-left-actionW-16,32,19,Ink);Label(card,"Description",description,narrow?8:left,narrow?44:39,narrow?w-16:w-left-actionW-16,narrow?h-size-56:h-43,14,Slate,TextAnchor.MiddleLeft,FontStyle.Normal);var button=Button(card,name+"Action",actionText,narrow?8:w-actionW-8,narrow?h-size-8:(h-size)/2,actionW,size,action,enabled,color??Mist);var text=button.GetComponentInChildren<Text>();text.fontSize=text.resizeTextMaxSize=15;}
  void RenderJobs(float row)=>RenderContractBoard();

 }
}
