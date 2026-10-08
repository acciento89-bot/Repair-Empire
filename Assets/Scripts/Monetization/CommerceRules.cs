using System;
using System.Collections.Generic;
using Kamilunavo.RepairEmpire.Core;
namespace Kamilunavo.RepairEmpire.Monetization {
 [Serializable] public sealed class CommerceProfile {
  public int Entitlements;public bool StarterCreditClaimed;public List<string> FulfilledTransactions=new List<string>();
  public CommerceProfile Clone(){var copy=(CommerceProfile)MemberwiseClone();copy.FulfilledTransactions=FulfilledTransactions==null?new List<string>():new List<string>(FulfilledTransactions);return copy;}
 }
 public static class CommerceRules {
  public const string Starter="com.kamilunavo.repairempire.starter",Collection="com.kamilunavo.repairempire.vancollection";
  public static bool KnownProduct(string id){return id==Starter||id==Collection;}
  public static int PremiumStyles(int rights){return ((rights&1)!=0?16:0)|((rights&2)!=0?224:0);}
  public static void Normalize(RepairProfile p){if(!p.Supported)return;if(p.Commerce==null)p.Commerce=new CommerceProfile();p.Commerce.Entitlements&=3;if(p.Commerce.FulfilledTransactions==null)p.Commerce.FulfilledTransactions=new List<string>();if(p.Styles==null||p.Styles.Length!=8){var old=p.Styles;p.Styles=new bool[8];if(old!=null)Array.Copy(old,p.Styles,Math.Min(8,old.Length));}p.Styles[0]=true;int mask=PremiumStyles(p.Commerce.Entitlements);for(int i=4;i<8;i++)p.Styles[i]=(mask&(1<<i))!=0;p.Style=Math.Max(0,Math.Min(7,p.Style));if(!p.Styles[p.Style])p.Style=0;}
  public static bool ApplyPending(RepairProfile p,string product,string transaction){if(!p.Supported||!KnownProduct(product)||string.IsNullOrWhiteSpace(transaction))return false;Normalize(p);string marker=product+":"+transaction;if(p.Commerce.FulfilledTransactions.Contains(marker))return false;if(product==Starter){p.Commerce.Entitlements|=1;if(!p.Commerce.StarterCreditClaimed){p.Cash=(int)Math.Min(100000000,(long)p.Cash+500);p.Commerce.StarterCreditClaimed=true;}}else p.Commerce.Entitlements|=2;p.Commerce.FulfilledTransactions.Add(marker);Normalize(p);return true;}
  public static bool FulfillPending(RepairProfile p,string product,string transaction,Action<RepairProfile> persist){if(!p.Supported||!KnownProduct(product)||string.IsNullOrWhiteSpace(transaction)||persist==null)return false;var before=p.Clone();ApplyPending(p,product,transaction);try{persist(p);return true;}catch{p.CopyFrom(before);throw;}}
  public static bool RestoreEntitlement(RepairProfile p,string product){if(!p.Supported||!KnownProduct(product))return false;Normalize(p);int before=p.Commerce.Entitlements;p.Commerce.Entitlements|=product==Starter?1:2;if(product==Starter)p.Commerce.StarterCreditClaimed=true;Normalize(p);return before!=p.Commerce.Entitlements;}
  public static void ReconcileEntitlements(RepairProfile p,IEnumerable<string> active){if(!p.Supported)return;Normalize(p);int mask=0;foreach(string id in active)mask|=id==Starter?1:id==Collection?2:0;p.Commerce.Entitlements=mask;if((mask&1)!=0)p.Commerce.StarterCreditClaimed=true;Normalize(p);}
 }
}
