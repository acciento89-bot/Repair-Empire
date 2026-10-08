using System;
using System.Collections.Generic;
using Kamilunavo.RepairEmpire.Core;
namespace Kamilunavo.RepairEmpire.Monetization {
 [Serializable] public sealed class RewardProfile {
  public string Day="";public int Count;public long LastAt;public List<string> Sessions=new List<string>();
  public RewardProfile Clone(){var copy=(RewardProfile)MemberwiseClone();copy.Sessions=Sessions==null?new List<string>():new List<string>(Sessions);return copy;}
 }
 public static class RewardRules {
  public const int Coins=50,DailyLimit=5,CooldownSeconds=60;
  static string Day(DateTime utc){return utc.ToUniversalTime().ToString("yyyy-MM-dd",System.Globalization.CultureInfo.InvariantCulture);}static long Seconds(DateTime utc){return new DateTimeOffset(utc.ToUniversalTime()).ToUnixTimeSeconds();}
  public static int Remaining(RepairProfile p,DateTime utc){if(!p.Supported)return 0;var r=p.Rewards;if(r!=null&&string.CompareOrdinal(r.Day,Day(utc))>0)return 0;return Math.Max(0,5-(r!=null&&r.Day==Day(utc)?r.Count:0));}
  public static int WaitSeconds(RepairProfile p,DateTime utc){if(p.Rewards==null||p.Rewards.LastAt==0)return 0;long last=Math.Max(0,Math.Min(253402300799,p.Rewards.LastAt));return (int)Math.Min(int.MaxValue,Math.Max(0,CooldownSeconds-(Seconds(utc)-last)));}
  public static bool CanClaim(RepairProfile p,DateTime utc){return p.Supported&&Remaining(p,utc)>0&&WaitSeconds(p,utc)==0;}
  public static bool Fulfill(RepairProfile p,string session,DateTime utc,Action<RepairProfile> persist){if(string.IsNullOrWhiteSpace(session)||persist==null||!CanClaim(p,utc))return false;if(p.Rewards==null)p.Rewards=new RewardProfile();if(p.Rewards.Sessions==null)p.Rewards.Sessions=new List<string>();if(p.Rewards.Sessions.Contains(session))return false;var before=p.Clone();if(p.Rewards.Day!=Day(utc)){p.Rewards.Day=Day(utc);p.Rewards.Count=0;p.Rewards.Sessions.Clear();}p.Rewards.Count++;p.Rewards.LastAt=Seconds(utc);p.Rewards.Sessions.Add(session);p.Cash=(int)Math.Min(100000000,(long)p.Cash+50);try{persist(p);return true;}catch{p.CopyFrom(before);throw;}}
 }
}
