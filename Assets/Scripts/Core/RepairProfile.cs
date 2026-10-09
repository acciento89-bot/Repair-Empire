using System;
namespace Kamilunavo.RepairEmpire.Core {
[Serializable] public sealed class RepairProfile {
 public int Schema=1,Cash=1130,Level=2,Xp=124,CompletedJobs,ToolMask=1,VehicleMask=1,Vehicle,Workshop=1,Employees,RepairPhase,DailyStreak,DailyJobs,Style;
 public long NextTicket=1,ActiveTicket,CompletedTicket,OfflineUtc;
 public string ActiveJob="",DailyDay="",JobsDay="",JobsClaimDay="",Language="de";
 public string[] CompletedContracts=new string[0];
 [NonSerialized] public bool RewardInFlight;
 public bool TutorialCompleted;
 public bool Sound=true,Haptics=true,ReducedMotion,HighContrast;
 public bool[] Styles={true,false,false,false,false,false,false,false};
 public float SavedX,SavedZ,SavedHeading;
 public Monetization.CommerceProfile Commerce=new Monetization.CommerceProfile();public Monetization.RewardProfile Rewards=new Monetization.RewardProfile();
 public bool Supported {get{return Schema==1;}}
 public RepairProfile Clone(){var p=(RepairProfile)MemberwiseClone();p.CompletedContracts=CompletedContracts==null?new string[0]:(string[])CompletedContracts.Clone();p.Styles=Styles==null?null:(bool[])Styles.Clone();p.Commerce=Commerce==null?new Monetization.CommerceProfile():Commerce.Clone();p.Rewards=Rewards==null?new Monetization.RewardProfile():Rewards.Clone();return p;}
 public void CopyFrom(RepairProfile other){foreach(var f in typeof(RepairProfile).GetFields())f.SetValue(this,f.GetValue(other));CompletedContracts=other.CompletedContracts==null?new string[0]:(string[])other.CompletedContracts.Clone();Styles=other.Styles==null?null:(bool[])other.Styles.Clone();Commerce=other.Commerce==null?new Monetization.CommerceProfile():other.Commerce.Clone();Rewards=other.Rewards==null?new Monetization.RewardProfile():other.Rewards.Clone();}
 public RepairProfile Presentation(){if(Supported)return this;return new RepairProfile{Schema=Schema,Language=Language=="en"?"en":"de"};}
 public void Normalize(){if(!Supported)return;var paid=new System.Collections.Generic.HashSet<string>();if(CompletedContracts!=null)foreach(var id in CompletedContracts)if(Gameplay.JobCatalog.Find(id)!=null)paid.Add(id);CompletedContracts=new string[paid.Count];paid.CopyTo(CompletedContracts);Cash=Clamp(Cash,0,100000000);Level=Clamp(Level,1,100);Xp=Clamp(Xp,0,999999);CompletedJobs=Clamp(CompletedJobs,0,1000000);ToolMask=(ToolMask&7)|1;VehicleMask=(VehicleMask&7)|1;Vehicle=Clamp(Vehicle,0,2);if((VehicleMask&(1<<Vehicle))==0)Vehicle=0;Workshop=Clamp(Workshop,1,5);Employees=Clamp(Employees,0,3);RepairPhase=Clamp(RepairPhase,0,3);CompletedTicket=Math.Max(0,CompletedTicket);ActiveTicket=Math.Max(0,ActiveTicket);long frontier=Math.Max(ActiveTicket,CompletedTicket);NextTicket=frontier>=long.MaxValue-1000?long.MaxValue:Math.Max(1,Math.Max(frontier+1,NextTicket));DailyStreak=Clamp(DailyStreak,0,7);DailyJobs=Clamp(DailyJobs,0,999);OfflineUtc=Math.Max(0,OfflineUtc);ActiveJob=ActiveJob??"";DailyDay=DailyDay??"";JobsDay=JobsDay??"";JobsClaimDay=JobsClaimDay??"";Language=Language=="en"?"en":"de";if(Styles==null||Styles.Length!=8){var old=Styles;Styles=new bool[8];if(old!=null)Array.Copy(old,Styles,Math.Min(8,old.Length));}Styles[0]=true;Style=Clamp(Style,0,7);if(!Styles[Style])Style=0;SavedX=Finite(SavedX)?Math.Max(-50,Math.Min(50,SavedX)):0;SavedZ=Finite(SavedZ)?Math.Max(0,Math.Min(440,SavedZ)):0;SavedHeading=Finite(SavedHeading)?SavedHeading%360:0;Monetization.CommerceRules.Normalize(this);if(Rewards==null)Rewards=new Monetization.RewardProfile();Rewards.Count=Clamp(Rewards.Count,0,5);Rewards.LastAt=Math.Max(0,Math.Min(253402300799,Rewards.LastAt));Rewards.Day=Rewards.Day??"";if(Rewards.Sessions==null)Rewards.Sessions=new System.Collections.Generic.List<string>();}
 static int Clamp(int v,int a,int b){return Math.Max(a,Math.Min(b,v));}static bool Finite(float v){return !float.IsNaN(v)&&!float.IsInfinity(v);}
}}
