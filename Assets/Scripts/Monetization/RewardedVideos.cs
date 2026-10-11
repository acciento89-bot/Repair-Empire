using System;
using UnityEngine;
using GoogleMobileAds.Api;
using GoogleMobileAds.Common;
using GoogleMobileAds.Ump.Api;
using Kamilunavo.RepairEmpire.Gameplay;
using Kamilunavo.RepairEmpire.Core;
namespace Kamilunavo.RepairEmpire.Monetization
{
    public sealed class RewardedVideos:MonoBehaviour
    {
        private RepairGame _game;
        private MonetizationConfig _config;
        private RewardedAd _ad;
        private bool _prepared,_initialized,_loading,_consentUpdated,_consentUpdating,_initializing;
        public bool AdsReady=>_consentUpdated&&_initialized&&ConsentInformation.CanRequestAds();
        private readonly AdLoadGeneration _loads=new();
        private double _loadedAt,_retryAt,_nextPrepareAt;
        private string _session="";
        private bool _rewarded,_rewardOpened;
        public bool IsPresenting {get;private set;}
        public bool PrivacyRequired=>_consentUpdated && ConsentInformation.PrivacyOptionsRequirementStatus==PrivacyOptionsRequirementStatus.Required;
        public event Action Changed;
        public string Status {get;private set;}="";
        public bool CanWatch=>RepairPersistence.Writable && Application.isMobilePlatform && !IsPresenting && !_game.PresentationGate.Busy && _ad!=null && _ad.CanShowAd() && Time.realtimeSinceStartupAsDouble-_loadedAt<3500 && ConsentInformation.CanRequestAds() && RewardRules.CanClaim(_game.Profile,DateTime.UtcNow);
        private string T(string de,string en)=>_game.Hud.T(de,en);
        private void Main(Action action)=>MobileAdsEventExecutor.ExecuteInUpdate(()=>{if(this!=null)action();});
        public void Initialize(RepairGame game)
        {
            _game=game;_config=MonetizationConfig.Load();
            Status=T("Video gerade nicht verfügbar","Video currently unavailable");
            BeginConsentUpdate();
        }
        private void Update(){TickPreparation(Time.realtimeSinceStartupAsDouble,Prepare);}
        private void TickPreparation(double now,Action prepare){if(_game==null||!_game.Profile.Supported||!_game.SafeAdContext||IsPresenting||_game.Store?.IsPresenting==true||now<_retryAt||now<_nextPrepareAt)return;_nextPrepareAt=now+1;prepare();}
        public void Prepare()
        {
            if(!_game.Profile.Supported || !Application.isMobilePlatform || !_game.SafeAdContext || IsPresenting || Time.realtimeSinceStartupAsDouble<_retryAt)return;
#if UNITY_EDITOR || DEVELOPMENT_BUILD
            if(!string.IsNullOrEmpty(RepairPersistence.QaKey))return;
#endif
            if(!_consentUpdated){BeginConsentUpdate();return;}
            if(_prepared){if(_initialized)Load();return;}
            _prepared=true;SetStatus(T("Video wird vorbereitet …","Preparing video …"));
            if(!TryPresentConsent(()=>ConsentForm.LoadAndShowConsentFormIfRequired(formError=>Main(()=>{IsPresenting=false;_game.ReleasePresentation(this);AfterConsent();})))){_prepared=false;AfterConsent();}
        }
        private void BeginConsentUpdate()
        {
            if(_consentUpdating||_consentUpdated||_game==null||!_game.Profile.Supported||!Application.isMobilePlatform)return;
#if UNITY_EDITOR || DEVELOPMENT_BUILD
            if(!string.IsNullOrEmpty(RepairPersistence.QaKey))return;
#endif
            _consentUpdating=true;
            try{ConsentInformation.Update(new ConsentRequestParameters(),error=>Main(()=>
            {
                _consentUpdating=false;_consentUpdated=true;
                if(error!=null)_retryAt=Time.realtimeSinceStartupAsDouble+60;
                if(_game.SafeAdContext)Prepare();else if(ConsentInformation.CanRequestAds())AfterConsent();else Changed?.Invoke();
            }));}catch(Exception){_consentUpdating=false;_retryAt=Time.realtimeSinceStartupAsDouble+60;SetStatus(T("Datenschutz gerade nicht verfügbar","Privacy unavailable"));}
        }
        private bool TryPresentConsent(Action show)
        {
            // Recheck the actual parked modal after the asynchronous consent update.
            if(_game==null || !_game.SafeAdContext || _game.Store?.IsPresenting==true)return false;
            if(!_game.Save()||!_game.AcquirePresentation(this))return false;IsPresenting=true;Changed?.Invoke();
            try{show();return true;}catch(Exception){IsPresenting=false;_game.ReleasePresentation(this);_prepared=false;Changed?.Invoke();return false;}
        }
        private void AfterConsent()
        {
            Changed?.Invoke();
            if(!ConsentInformation.CanRequestAds()){SetStatus(T("Video nicht verfügbar – Datenschutzeinstellungen prüfen","Video unavailable – check privacy settings"));return;}
            if(_initialized){Load();return;}
            if(_initializing)return;_initializing=true;
            try{MobileAds.Initialize(status=>Main(()=>
            {
                _initializing=false;
                if(status==null){SetStatus(T("Video gerade nicht verfügbar","Video currently unavailable"));return;}
                _initialized=true;Load();
            }));}catch(Exception){_initializing=false;_retryAt=Time.realtimeSinceStartupAsDouble+60;SetStatus(T("Video gerade nicht verfügbar","Video currently unavailable"));}
        }
        private void Load()
        {
            if(!_initialized || _loading || IsPresenting || !ConsentInformation.CanRequestAds() || Time.realtimeSinceStartupAsDouble<_retryAt)return;
            if(_ad!=null && _ad.CanShowAd() && Time.realtimeSinceStartupAsDouble-_loadedAt<3500)return;
            _ad?.Destroy();_ad=null;
            var id=_config.RewardedId;
            if(string.IsNullOrWhiteSpace(id)){SetStatus(T("Video gerade nicht verfügbar","Video currently unavailable"));return;}
            _loading=true;var generation=_loads.Begin();
            try{RewardedAd.Load(id,new AdRequest(),(ad,error)=>
            {
                if(this==null){ad?.Destroy();return;}
                Main(()=>
                {
                    if(!_loads.IsCurrent(generation)){ad?.Destroy();return;}
                    if(!ConsentInformation.CanRequestAds()){_loading=false;ad?.Destroy();return;}
                    _loading=false;
                    if(error!=null || ad==null){ad?.Destroy();_retryAt=Time.realtimeSinceStartupAsDouble+60;SetStatus(T("Kein Video verfügbar – später erneut versuchen","No video available – try later"));return;}
                    _ad=ad;_loadedAt=Time.realtimeSinceStartupAsDouble;
                    ad.OnAdFullScreenContentOpened+=()=>Main(()=>{if(_ad!=ad||!IsPresenting||_rewardOpened)return;_rewardOpened=true;_game.Interstitials?.RewardedOpened();});
                    ad.OnAdFullScreenContentClosed+=()=>Main(()=>Finish(ad,false));
                    ad.OnAdFullScreenContentFailed+=failure=>Main(()=>Finish(ad,true));
                    SetStatus(T("Freiwilliges Video: +50 Spielgeld","Optional video: +50 cash"));
                });
            });}catch(Exception){_loads.Invalidate();_loading=false;_retryAt=Time.realtimeSinceStartupAsDouble+60;SetStatus(T("Video gerade nicht verfügbar","Video currently unavailable"));}
        }
        public void Watch()
        {
            if(!CanWatch || !_game.Hud.ShopOpen)return;
            if(!_game.Save()||!_game.AcquirePresentation(this))return;IsPresenting=true;_session=Guid.NewGuid().ToString("N");_rewarded=false;_rewardOpened=false;
            var session=_session;var ad=_ad;Changed?.Invoke();
            try{ad.Show(reward=>Main(()=>
            {
                // Only this specific SDK completion callback can award this view, once.
                if(_session!=session || _rewarded)return;
                try
                {
                    if(RewardRules.Fulfill(_game.Profile,session,DateTime.UtcNow,RepairPersistence.Save))
                    {_rewarded=true;SetStatus(T("+50 Spielgeld erhalten","Received +50 cash"));_game.RefreshProfile();}
                }
                catch(Exception){SetStatus(T("Belohnung konnte nicht gespeichert werden","Reward could not be saved"));}
            }));}
            catch(Exception){Finish(ad,true);}
        }
        private void Finish(RewardedAd ad,bool failed)
        {
            if(_ad!=ad)return;
            IsPresenting=false;_game.ReleasePresentation(this);
            SetStatus(failed?T("Video konnte nicht geöffnet werden","Video could not open"):_rewarded?T("+50 Spielgeld erhalten","Received +50 cash"):T("Video beendet – keine Prämie erhalten","Video ended – no reward received"));
            // Keep the session until the next Watch; delayed SDK reward callbacks remain valid.
            _ad=null;ad.Destroy();_retryAt=Time.realtimeSinceStartupAsDouble+2;
        }
        public void ShowPrivacy()
        {
            if(!PrivacyRequired || IsPresenting||!_game.Hud.ShopOpen||_game.ApplicationInterrupted)return;
            if(!_game.Save()||!_game.AcquirePresentation(this))return;IsPresenting=true;_game.Interstitials?.InvalidateConsent();_loads.Invalidate();_loading=false;_retryAt=0;_ad?.Destroy();_ad=null;Changed?.Invoke();
            try{ConsentForm.ShowPrivacyOptionsForm(error=>Main(()=>{IsPresenting=false;_game.ReleasePresentation(this);AfterConsent();}));}
            catch(Exception){IsPresenting=false;_game.ReleasePresentation(this);SetStatus(T("Datenschutz gerade nicht verfügbar","Privacy options unavailable"));}
        }
        private void SetStatus(string status){Status=status;Changed?.Invoke();}
        private void OnDestroy(){_loads.Invalidate();_ad?.Destroy();_ad=null;_game?.ReleasePresentation(this);}
    }
}
