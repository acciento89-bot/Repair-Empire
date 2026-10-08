using System;
using System.Globalization;
using Kamilunavo.RepairEmpire.Gameplay;
namespace Kamilunavo.RepairEmpire.Core {
public static class RepairRules {
 public static float VehicleSpeed(int vehicle){return vehicle==2?28:vehicle==1?25:22;}
 public static float WorkshopRate(RepairProfile p){return 1+.12f*(Math.Max(1,Math.Min(5,p.Workshop))-1);}
 public static int XpTarget(RepairProfile p){return 99+22*p.Level;}
 public static bool IsArrival(float dx,float dz,float speed){return !float.IsNaN(dx)&&!float.IsNaN(dz)&&!float.IsNaN(speed)&&dx*dx+dz*dz<=36&&Math.Abs(speed)<=1;}
 public static bool CanTake(RepairProfile p,JobDefinition j){return p.Supported&&j!=null&&p.Level>=j.MinimumLevel&&(p.ToolMask&(1<<j.ToolTier))!=0;}
 public static long BeginJob(RepairProfile p,string id){var j=JobCatalog.Find(id);if(!CanTake(p,j)||p.NextTicket>=long.MaxValue-1000)return 0;p.ActiveJob=id;p.ActiveTicket=p.NextTicket++;p.RepairPhase=0;return p.ActiveTicket;}
 public static bool AdvanceRepair(RepairProfile p,long ticket,int phase){if(!p.Supported||ticket!=p.ActiveTicket||ticket<=p.CompletedTicket||phase!=p.RepairPhase||phase<0||phase>=3||JobCatalog.Find(p.ActiveJob)==null)return false;p.RepairPhase++;return true;}
 public static bool Complete(RepairProfile p,long ticket,DateTime utc,Func<RepairProfile,bool> save){var job=JobCatalog.Find(p.ActiveJob);if(!CanTake(p,job)||ticket<=0||ticket!=p.ActiveTicket||ticket<=p.CompletedTicket||p.RepairPhase!=3||save==null||utc.Kind!=DateTimeKind.Utc)return false;var next=p.Clone();Credit(next,job.Reward,job.Xp);next.CompletedJobs++;next.CompletedTicket=ticket;next.ActiveJob="";next.ActiveTicket=0;next.RepairPhase=0;string day=Day(utc);if(string.CompareOrdinal(day,next.JobsDay)>=0){if(next.JobsDay!=day){next.JobsDay=day;next.DailyJobs=0;}next.DailyJobs++;}try{if(!save(next))return false;}catch{return false;}p.CopyFrom(next);return true;}
 public static bool BuyTool(RepairProfile p,int tier){if(!p.Supported||tier<1||tier>2||p.Level<(tier==1?3:4)||(p.ToolMask&(1<<tier))!=0)return false;int cost=tier==1?400:900;if(!Spend(p,cost))return false;p.ToolMask|=1<<tier;return true;}
 public static bool BuyVehicle(RepairProfile p,int v){if(!p.Supported||v<1||v>2||p.Level<(v==1?3:5)||(p.VehicleMask&(1<<v))!=0)return false;if(!Spend(p,v==1?900:2400))return false;p.VehicleMask|=1<<v;return true;}
 public static bool EquipVehicle(RepairProfile p,int v){if(!p.Supported||v<0||v>2||(p.VehicleMask&(1<<v))==0)return false;p.Vehicle=v;return true;}
 public static int WorkshopCost(RepairProfile p){return 400*p.Workshop;}
 public static bool UpgradeWorkshop(RepairProfile p){if(!p.Supported||p.Workshop>=5||!Spend(p,WorkshopCost(p)))return false;p.Workshop++;return true;}
 public static int EmployeeCost(RepairProfile p){return 600+400*p.Employees;}
 public static bool Hire(RepairProfile p,DateTime utc){if(!p.Supported||p.Level<4||p.Employees>=3||utc.Kind!=DateTimeKind.Utc||!Spend(p,EmployeeCost(p)))return false;AccrueOffline(p,utc);p.Employees++;p.OfflineUtc=Math.Max(p.OfflineUtc,Seconds(utc));return true;}
 public static int AccrueOffline(RepairProfile p,DateTime utc){if(!p.Supported||utc.Kind!=DateTimeKind.Utc)return 0;long now=Seconds(utc);if(p.OfflineUtc==0){p.OfflineUtc=now;return 0;}if(now<=p.OfflineUtc)return 0;long elapsed=Math.Min(28800,now-p.OfflineUtc);int reward=(int)(elapsed*p.Employees*30/3600);if(reward==0&&elapsed<28800)return 0;p.OfflineUtc=now;Credit(p,reward,0);return reward;}
 public static int ClaimDaily(RepairProfile p,DateTime utc){if(!p.Supported||utc.Kind!=DateTimeKind.Utc)return 0;string day=Day(utc);if(string.CompareOrdinal(day,p.DailyDay)<=0)return 0;DateTime last;bool yesterday=DateTime.TryParseExact(p.DailyDay,"yyyy-MM-dd",CultureInfo.InvariantCulture,DateTimeStyles.None,out last)&&last.Date==utc.Date.AddDays(-1);p.DailyStreak=yesterday?Math.Min(7,p.DailyStreak+1):1;p.DailyDay=day;int reward=90+p.DailyStreak*10;Credit(p,reward,0);return reward;}
 public static int ClaimDailyJobs(RepairProfile p,DateTime utc){if(!p.Supported||utc.Kind!=DateTimeKind.Utc)return 0;string day=Day(utc);if(p.JobsDay!=day||p.DailyJobs<3||string.CompareOrdinal(day,p.JobsClaimDay)<=0)return 0;p.JobsClaimDay=day;Credit(p,250,150);return 250;}
 public static bool BuyStyle(RepairProfile p,int style){if(!p.Supported||style<1||style>3||p.Styles[style]||!Spend(p,75*style+(style==3?25:0)))return false;p.Styles[style]=true;return true;}
 public static bool EquipStyle(RepairProfile p,int style){if(!p.Supported||style<0||style>=8||!p.Styles[style])return false;p.Style=style;return true;}
 public static void Credit(RepairProfile p,int cash,int xp){if(!p.Supported)return;p.Cash=(int)Math.Min(100000000,(long)p.Cash+Math.Max(0,cash));p.Xp=(int)Math.Min(1000000,(long)p.Xp+Math.Max(0,xp));while(p.Level<100&&p.Xp>=XpTarget(p)){p.Xp-=XpTarget(p);p.Level++;}if(p.Level==100)p.Xp=Math.Min(p.Xp,XpTarget(p)-1);}
 static bool Spend(RepairProfile p,int cost){if(p.Cash<cost)return false;p.Cash-=cost;return true;}static string Day(DateTime utc){return utc.ToString("yyyy-MM-dd",CultureInfo.InvariantCulture);}static long Seconds(DateTime utc){return Math.Max(0,(utc.Ticks-new DateTime(1970,1,1,0,0,0,DateTimeKind.Utc).Ticks)/TimeSpan.TicksPerSecond);}
}}
