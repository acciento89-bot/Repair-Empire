using System;
using UnityEngine;
using UnityEngine.UI;
using Kamilunavo.RepairEmpire.Core;
using Kamilunavo.RepairEmpire.Gameplay;
namespace Kamilunavo.RepairEmpire.UI {
 public sealed partial class RepairHud {
  static readonly Color Paper=new(.97f,.955f,.91f,1),Ink=new(.075f,.16f,.20f),Slate=new(.31f,.40f,.43f),Mist=new(.86f,.92f,.90f),ActionInk=new(.66f,.25f,.04f),Line=new(.86f,.85f,.79f);
  float RowHeight=>body!=null&&body.rect.width<300?Mathf.Max(size+110,166):Mathf.Max(size+34,94);
  string[] PageNames()=>new[]{T("Aufträge","Service calls"),T("Werkzeug","Tools"),T("Fahrzeuge","Vehicles"),T("Werkstatt","Workshop"),T("Einnahmen","Earnings"),T("Täglich","Daily"),T("Optionen","Options"),"Shop"};
  public void ShowDashboard()=>ShowPage(9);
  JobDefinition NextCall(){if(game.ActiveJob!=null)return game.ActiveJob;foreach(var j in game.Jobs)if(RepairRules.CanTake(game.Profile,j)&&!RepairRules.IsPaid(game.Profile,j.Id))return j;return null;}
  void ResolveSelected(){if(selectedJob!=null&&!RepairRules.IsPaid(game.Profile,selectedJob.Id))return;selectedJob=NextCall();}
  void Illustration(Transform parent,int scene,float x,float y,float w,float h){var go=new GameObject("ServiceIllustration",typeof(RectTransform),typeof(CanvasRenderer),typeof(ServiceIllustrationGraphic));go.transform.SetParent(parent,false);At((RectTransform)go.transform,x,y,w,h);var graphic=go.GetComponent<ServiceIllustrationGraphic>();graphic.Scene=scene;graphic.raycastTarget=false;}
  void RenderPage(){if(rendering||modal==null)return;rendering=true;try{
   Clear(modal);repairHold=null;progress=null;ResolveSelected();float pad=12;bool repair=game.RepairOpen;var names=PageNames();modal.GetComponent<Image>().color=Paper;
   Panel(modal,"BrandStripe",pad,pad,4,size,Orange);Label(modal,"TabletTitle",repair?T("REPARATUR","REPAIR"):"REPAIR EMPIRE",pad+14,pad,width-(width<300?size:size*2)-48,size*.55f,24,Ink);
   Label(modal,"TabletSubtitle",repair?T("SERVICE AM KUNDEN","CUSTOMER SERVICE"):T("Deine Servicefirma","Your service company")+" · $"+game.Cash.ToString("N0"),pad+14,pad+size*.55f,width-(width<300?size:size*2)-48,size*.4f,14,Slate);
   if(!repair&&width>=300)Button(modal,"DashboardOptions","•••",width-size*2-pad-6,pad,size,size,()=>ShowPage(6),true,Mist);
   Button(modal,"Close","×",width-size-pad,pad,size,size,Close,true,Mist);
   float top=size+pad*2,bodyX=pad,bodyW=width-pad*2,bottom=pad;
   if(!repair){
    // Four permanent destinations; every specialist section is visible on Home.
    int[] destinations={9,0,3,7};string[] labels={T("Zentrale","Home"),T("Aufträge","Calls"),T("Werkstatt","Workshop"),"Shop"};
    float navW=Mathf.Max(size,(bodyW-12)/4);var navView=Panel(modal,"DashboardNavigation",pad,top,bodyW,size,Paper);navView.gameObject.AddComponent<RectMask2D>();var navScroll=navView.gameObject.AddComponent<ScrollRect>();navScroll.horizontal=true;navScroll.vertical=false;navScroll.viewport=navView;navScroll.movementType=ScrollRect.MovementType.Clamped;var navContent=Panel(navView,"NavigationContent",0,0,4*(navW+4),size,Color.clear);navScroll.content=navContent;for(int i=0;i<4;i++){int destination=destinations[i];var b=Button(navContent,"DashboardNav"+destination,labels[i],i*(navW+4),0,navW,size,()=>ShowPage(destination),true,page==destination?Mist:Paper);var text=b.GetComponentInChildren<Text>();text.fontSize=text.resizeTextMaxSize=16;text.color=Ink;if(page==destination)Panel((RectTransform)b.transform,"ActiveUnderline",8,size-4,navW-16,3,Orange).GetComponent<Image>().raycastTarget=false;}
    top+=size+12;bottom=size+pad*2+18;
    if(page!=9){Label(modal,"SectionTitle",names[page],pad,top,bodyW,28,22,Ink);top+=36;}
   }
   body=Panel(modal,"PageBody",bodyX,top,bodyW,Mathf.Max(size,height-top-bottom),Color.clear);
   if(repair)RenderRepair();else{RenderTablet();RenderDriveFooter(pad,bodyW);}
  }finally{rendering=false;}}
  void RenderDriveFooter(float pad,float w){float y=height-size-pad;Panel(modal,"FixedActionShelf",0,y-18,width,size+pad+18,Paper);Panel(modal,"FooterDivider",pad,y-14,w,1,Line);
   JobDefinition call=page==0?selectedJob:game.ActiveJob;bool accept=page==0&&call!=null;string caption=accept?(game.ActiveJob?.Id==call.Id?T("WEITER ZUM KUNDEN","CONTINUE TO CUSTOMER"):T("ANNEHMEN & LOSFAHREN","ACCEPT & DRIVE")):call!=null?T("WEITER ZUR ROUTE","CONTINUE ROUTE"):page==9?T("NÄCHSTEN AUFTRAG WÄHLEN","CHOOSE NEXT SERVICE CALL"):T("ZURÜCK AUF DIE STRASSE","BACK TO THE STREET");
   Button(modal,accept?"AcceptSelected":page==9?"DashboardDrive":"ReturnDrive",caption,pad,y,w,size,()=>{if(accept){if(game.SelectJob(call))Close();else ShowNotice(T("Auftrag nicht verfügbar oder noch beim Kunden","Call unavailable or still at the customer"));}else if(page==9&&call==null)ShowPage(0);else Close();},!accept||RepairRules.CanTake(game.Profile,call));
  }
  void RenderDashboard(){float w=body.rect.width;bool wide=w>=600;float heroH=wide?180:178,sectionY=heroH+20,tileH=108;int cols=wide?3:w<280?1:2;float gap=10,tileW=(w-(cols-1)*gap)/cols;var c=Scroll(sectionY+36+Mathf.Ceil(8f/cols)*(tileH+gap)+56);
   var hero=Panel(c,"CompanyHero",0,0,w,heroH,Mist);float artW=w<300?w*.30f:w*.42f;Illustration(hero,9,w-artW-8,8,artW,heroH-16);float textW=w-artW-24;
   Label(hero,"HeroEyebrow",game.ActiveJob!=null?T("DEINE AKTUELLE ROUTE","YOUR CURRENT ROUTE"):T("GUTEN TAG, SERVICE-TEAM","HELLO, SERVICE TEAM"),14,10,textW,27,13,Ink);
   Label(hero,"HeroStory",game.ActiveJob!=null?T(game.ActiveJob.TitleDe,game.ActiveJob.Title):T("Deine Stadt.\nDein Handwerk.","Your city.\nYour craft."),14,41,textW,73,27,Ink);
   Label(hero,"HeroProgress",game.ActiveJob!=null?game.ActiveJob.Address+"\n$"+game.ActiveJob.Reward+" · "+Mathf.RoundToInt(game.Distance)+" m":T("Level ","Level ")+game.Profile.Level+" · "+game.Profile.CompletedJobs+" / 24 "+T("erledigt","completed"),14,120,textW,47,16,Slate);
   Label(c,"CompanySections",T("DEINE FIRMA","YOUR COMPANY"),0,sectionY,w,26,15,Slate);string[] names=PageNames();string[] de={"Kunden & nächste Route","Für jeden Service bereit","Dein Van, deine Flotte","Ausbauen & lackieren","Team & Firmenertrag","Belohnungen & Ziele","Sprache, Ton & Hilfe","Designs & Extras"};string[] en={"Customers & next route","Ready for every repair","Your van, your fleet","Expand & paint","Team & company income","Rewards & goals","Language, sound & help","Designs & extras"};
   for(int i=0;i<8;i++){int section=i;float x=(i%cols)*(tileW+gap),y=sectionY+36+(i/cols)*(tileH+gap);var tile=Button(c,"DashboardSection"+i,"",x,y,tileW,tileH,()=>ShowPage(section),true,Color.white);Illustration(tile.transform,i,tileW-68,7,62,49);Label(tile.transform,"SectionName",names[i],12,12,tileW-78,33,21,Ink);Label(tile.transform,"SectionDetail",T(de[i],en[i]),12,56,tileW-24,40,14,Slate);}
   Label(c,"CompanyMotto",T("Ein Auftrag. Gute Arbeit. Eine stärkere Firma.","One service call. Great work. A stronger company."),0,c.rect.height-46,w,38,15,Slate);
  }
  void Row(RectTransform p,string name,string title,string description,float y,Action action,string actionText,bool enabled=true,Color? color=null){float w=p.rect.width,h=RowHeight;var card=Panel(p,name,0,y,w,h,Color.white);bool narrow=w<300;float icon=w>=310?66:0;if(icon>0)Illustration(card,page,8,13,52,Mathf.Min(66,h-26));float left=icon+12;float actionW=narrow?w-24:Mathf.Min(112,Mathf.Max(size,w*.27f));Label(card,"Title",title,left,8,narrow?w-24:w-left-actionW-18,31,20,Ink);Label(card,"Description",description,left,40,narrow?w-24:w-left-actionW-18,narrow?h-size-58:h-46,14,Slate);var button=Button(card,name+"Action",actionText,narrow?12:w-actionW-8,narrow?h-size-10:(h-size)/2,actionW,size,action,enabled,color??Mist);var text=button.GetComponentInChildren<Text>();text.fontSize=text.resizeTextMaxSize=16;}
  void RenderJobs(float row){ResolveSelected();float w=body.rect.width,heroH=154;var c=Scroll(heroH+46+game.Jobs.Count*(Mathf.Max(size+26,82)+10));
   if(selectedJob!=null){var detail=Panel(c,"SelectedCall",0,0,w,heroH,Mist);float artW=w<260?0:Mathf.Clamp(w*.32f,76,152);if(artW>0)Illustration(detail,0,w-artW-8,8,artW,heroH-16);Label(detail,"SelectedEyebrow",game.ActiveJob?.Id==selectedJob.Id?T("AKTIVER AUFTRAG","ACTIVE SERVICE CALL"):T("DEINE NÄCHSTE ROUTE","YOUR NEXT ROUTE"),12,8,w-artW-30,25,13,Slate);Label(detail,"SelectedTitle",T(selectedJob.TitleDe,selectedJob.Title),12,38,w-artW-30,53,24,Ink);Label(detail,"SelectedNotes",selectedJob.Address+"\n$"+selectedJob.Reward+" · "+selectedJob.Xp+" XP · Lv "+selectedJob.MinimumLevel,12,97,w-artW-30,48,16,Slate);}
   else Label(c,"AllCallsPaid",T("Alle 24 Aufträge erledigt. Gut gemacht!","All 24 contracts completed. Well done!"),12,12,w-24,80,22,Ink);
   Label(c,"CallsSection",T("KUNDEN IN DEINER STADT","CUSTOMERS IN YOUR CITY"),0,heroH+12,w,26,15,Slate);
   int index=0;bool narrow=w<300;float callH=Mathf.Max(size+26,narrow?108:82);foreach(var j in game.Jobs){if(selectedJob!=null&&selectedJob.Id==j.Id)continue;bool paid=RepairRules.IsPaid(game.Profile,j.Id);float y=heroH+46+index++*(callH+10);var b=Button(c,"Job"+j.Id+"Action","",0,y,w,callH,()=>{selectedJob=j;RenderPage();},!paid,paid?new Color(.93f,.93f,.89f):Color.white);float iconW=narrow?40:64;var icon=Panel((RectTransform)b.transform,"ServiceIconTile",8,8,iconW,narrow?42:callH-16,paid?Line:new Color(.96f,.89f,.77f));icon.GetComponent<Image>().raycastTarget=false;Symbol(icon,j,5,5,iconW-10,narrow?32:callH-26);Label(b.transform,"Title",T(j.TitleDe,j.Title),iconW+20,7,narrow?w-iconW-28:w-149,narrow?44:32,21,Ink);Label(b.transform,"Meta",paid?T("Erledigt · bezahlt","Completed · paid"):j.Address+" · Lv "+j.MinimumLevel,narrow?12:84,narrow?56:40,narrow?w-24:w-149,narrow?23:callH-45,14,Slate);Label(b.transform,"Payout",paid?"✓":"$"+j.Reward,narrow?12:w-65,narrow?82:8,narrow?w-24:57,narrow?22:callH-16,18,paid?Slate:ActionInk,narrow?TextAnchor.MiddleLeft:TextAnchor.MiddleCenter);}
   c.sizeDelta=new Vector2(w,Mathf.Max(body.rect.height,heroH+46+index*(callH+10)));

  }
 }
}
