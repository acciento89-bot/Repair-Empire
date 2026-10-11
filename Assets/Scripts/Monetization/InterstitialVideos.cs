using System;
using UnityEngine;
using GoogleMobileAds.Api;
using GoogleMobileAds.Common;
using GoogleMobileAds.Ump.Api;
using Kamilunavo.RepairEmpire.Core;
using Kamilunavo.RepairEmpire.Gameplay;
namespace Kamilunavo.RepairEmpire.Monetization {
 public sealed class InterstitialVideos:MonoBehaviour {
  RepairGame game;MonetizationConfig config;InterstitialAd ad;InterstitialPolicy policy;
  readonly AdLoadGeneration loads=new AdLoadGeneration();bool loading;double loadedAt,retryAt;bool opened;
  public bool IsPresenting{get;private set;}
  public string LastDecision{get;private set;}="Not considered";
  public int PaidSinceAd=>policy?.PaidSinceAd??0;
  public event Action Changed;
  public void Initialize(RepairGame owner){game=owner;config=MonetizationConfig.Load();policy=new InterstitialPolicy(Time.realtimeSinceStartupAsDouble);game.Changed+=ProfileChanged;}
  void Main(Action action){MobileAdsEventExecutor.ExecuteInUpdate(()=>{if(this!=null)action();});}
  bool Enabled{get{
#if UNITY_EDITOR || DEVELOPMENT_BUILD
   if(!string.IsNullOrEmpty(RepairPersistence.QaKey))return false;
#endif
   return game!=null&&game.Profile.Supported&&Application.isMobilePlatform&&!CommerceRules.AdsRemoved(game.Profile)&&!string.IsNullOrWhiteSpace(config?.InterstitialId);
  }}
  bool Ready=>ad!=null&&ad.CanShowAd()&&Time.realtimeSinceStartupAsDouble-loadedAt<3500;
  // Only preloading runs here. Presentation has exactly one synchronous call site:
  // the just-persisted paid result. A late load cannot reopen that opportunity.
  void Update(){if(!IsPresenting&&(!Enabled||game.Videos?.AdsReady!=true)){if(loading||ad!=null){loads.Invalidate();loading=false;DropAd();}return;}if(Enabled&&game.Videos?.AdsReady==true&&!IsPresenting&&!game.PresentationGate.Busy)Load();}
  void Load(){if(loading||Ready||Time.realtimeSinceStartupAsDouble<retryAt||!ConsentInformation.CanRequestAds())return;DropAd();loading=true;var generation=loads.Begin();
   try{InterstitialAd.Load(config.InterstitialId,new AdRequest(),(value,error)=>{if(this==null){value?.Destroy();return;}MobileAdsEventExecutor.ExecuteInUpdate(()=>{if(this==null){value?.Destroy();return;}
    if(!loads.IsCurrent(generation)||!Enabled||!ConsentInformation.CanRequestAds()){value?.Destroy();return;}loading=false;
    if(error!=null||value==null){value?.Destroy();retryAt=Time.realtimeSinceStartupAsDouble+60;return;}
    ad=value;loadedAt=Time.realtimeSinceStartupAsDouble;
    value.OnAdFullScreenContentOpened+=()=>Main(()=>{if(ad!=value||!IsPresenting||opened)return;opened=true;policy.MarkOpened(Time.realtimeSinceStartupAsDouble);Changed?.Invoke();});
    value.OnAdFullScreenContentClosed+=()=>Main(()=>Finish(value));value.OnAdFullScreenContentFailed+=failure=>Main(()=>Finish(value));
   });});}catch(Exception){loads.Invalidate();loading=false;retryAt=Time.realtimeSinceStartupAsDouble+60;}
  }
  // Privacy may still allow ad requests while switching personalization. Discard
  // the old consent snapshot and any pending response before the form opens.
  internal void InvalidateConsent(){if(IsPresenting)return;loads.Invalidate();loading=false;retryAt=0;DropAd();}
  public void RewardedOpened(){policy?.DelayAfterRewarded(Time.realtimeSinceStartupAsDouble);}
  public void PaidResult(long ticket,JobDefinition job){if(game==null||policy==null||job==null||game.Profile.CompletedTicket!=ticket||!RepairRules.IsPaid(game.Profile,job.Id)||!policy.RecordPaid(ticket,job.Id))return;
   var b=new InterstitialBoundary{RemoveAds=CommerceRules.AdsRemoved(game.Profile),Tutorial=game.Tutorial.Active,Parked=game.ResultParked,ResultModal=game.ResultOpen&&game.Hud?.ModalOpen==true,RepairOpen=game.RepairOpen,Focused=!game.ApplicationInterrupted,ProviderBusy=game.PresentationGate.Busy||game.Store?.Busy==true,Consent=game.Videos?.AdsReady==true&&ConsentInformation.CanRequestAds(),Ready=Enabled&&Ready};
   PresentAtResult(ticket,Time.realtimeSinceStartupAsDouble,b,()=>ad.Show());
  }
  // Same presentation boundary is exercised with an isolated fake native screen
  // by editor QA; readiness and paid proof are gathered only by PaidResult above.
  internal bool PresentAtResult(long ticket,double now,InterstitialBoundary boundary,Action show){
   if(!policy.TryAtResult(ticket,now,boundary)){LastDecision="Paid result skipped";Changed?.Invoke();return false;}
   if(show==null||!game.Save()||!game.AcquirePresentation(this)){LastDecision="Presentation unavailable";return false;}
   IsPresenting=true;opened=false;LastDecision="Presenting at paid result";Changed?.Invoke();
   try{show();return true;}catch(Exception){Finish(ad);return false;}
  }
  void Finish(InterstitialAd value){if(ad!=value||!IsPresenting)return;IsPresenting=false;game.ReleasePresentation(this);DropAd();retryAt=Time.realtimeSinceStartupAsDouble+2;LastDecision=opened?"Closed at paid result":"Presentation failed; result retained";Changed?.Invoke();game.RefreshProfile();}
  void ProfileChanged(){if(game==null||!CommerceRules.AdsRemoved(game.Profile)||IsPresenting)return;loads.Invalidate();loading=false;DropAd();}
  void DropAd(){ad?.Destroy();ad=null;}
  void OnDestroy(){loads.Invalidate();loading=false;DropAd();if(game!=null){game.Changed-=ProfileChanged;game.ReleasePresentation(this);}IsPresenting=false;}
 }
}
