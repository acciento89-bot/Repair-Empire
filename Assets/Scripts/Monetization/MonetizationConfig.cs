using System;
using UnityEngine;
namespace Kamilunavo.RepairEmpire.Monetization
{
    [Serializable] public sealed class MonetizationConfig
    {
        public bool InternalTestAds=true;
        public string IosRewarded="",AndroidRewarded="",IosInterstitial="",AndroidInterstitial="";
        public static string InterstitialUnit(bool ios,bool internalTest,string production)=>internalTest?(ios?"ca-app-pub-3940256099942544/4411468910":"ca-app-pub-3940256099942544/1033173712"):(string.IsNullOrWhiteSpace(production)?"":production);
        public string InterstitialId=>InterstitialUnit(Application.platform==RuntimePlatform.IPhonePlayer,InternalTestAds,Application.platform==RuntimePlatform.IPhonePlayer?IosInterstitial:AndroidInterstitial);
        public static MonetizationConfig Load()
        {
            var text=Resources.Load<TextAsset>("Monetization");
            return text==null?new MonetizationConfig():JsonUtility.FromJson<MonetizationConfig>(text.text);
        }
        public string RewardedId=>InternalTestAds?
            (Application.platform==RuntimePlatform.IPhonePlayer?"ca-app-pub-3940256099942544/1712485313":"ca-app-pub-3940256099942544/5224354917"):
            (Application.platform==RuntimePlatform.IPhonePlayer?IosRewarded:AndroidRewarded);
    }
}
