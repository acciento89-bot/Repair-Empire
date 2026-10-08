using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.UI;
using Kamilunavo.RepairEmpire.Core;
namespace Kamilunavo.RepairEmpire.Gameplay {
 public sealed class RepairGame:MonoBehaviour {
  public UI.RepairHud Hud;public Monetization.StorePurchases Store;public Monetization.RewardedVideos Videos;public VehicleController Vehicle;public Text CashText,LevelText,ToolText,JobTitle,JobMeta,DistanceText,StatusText;public Button CompleteButton;
  public readonly List<JobDefinition> Jobs=new List<JobDefinition>(JobCatalog.All);
  public RepairProfile Profile=new RepairProfile();public RepairInteraction Interaction;
  public event Action Changed;public event Action<string> Feedback;
  public bool RepairOpen{get;private set;}public bool TabletOpen{get;private set;}
  public Func<bool> NativePresenting;bool focused=true,osPaused;RepairSave storage;float nextSnapshot;
  public bool ApplicationInterrupted=>osPaused||!focused||(NativePresenting!=null&&NativePresenting());
  public bool Paused{get{return RepairOpen||TabletOpen||osPaused||!focused||(NativePresenting!=null&&NativePresenting());}}
  public JobDefinition ActiveJob{get{return JobCatalog.Find(Profile.ActiveJob);}}
  public float Distance{get{var j=ActiveJob;if(j==null||Vehicle==null)return 0;var d=Vehicle.transform.position-new Vector3(j.DestinationX,0,j.DestinationZ);d.y=0;return d.magnitude;}}
  public int Cash{get{return Profile.Cash;}}public int Level{get{return Profile.Level;}}public int Xp{get{return Profile.Xp;}}
  void Awake(){Initialize();}
  public void Initialize(){if(storage!=null)return;string id=Environment.GetEnvironmentVariable("REPAIR_QA_ID")??"";foreach(char c in id)if(!char.IsLetterOrDigit(c)&&c!='-')throw new InvalidOperationException("Invalid isolated profile ID");string path=Path.Combine(Application.persistentDataPath,"repair-company-v1"+(id.Length>0?"-qa-"+id:"")+".json");storage=new RepairSave(path,p=>JsonUtility.ToJson(p),s=>JsonUtility.FromJson<RepairProfile>(s));Profile=storage.Load();RepairPersistence.Configure(storage,()=>Profile.Supported);if(Profile.Supported){var next=Profile.Clone();RepairRules.AccrueOffline(next,DateTime.UtcNow);if(next.CompletedJobs==0&&string.IsNullOrEmpty(next.ActiveJob))RepairRules.BeginJob(next,"faucet");if(storage.Save(next))Profile.CopyFrom(next);}Interaction=new RepairInteraction(Profile.RepairPhase,RepairRules.WorkshopRate(Profile));RefreshProfile();}
  public bool SelectJob(JobDefinition job){if(job==null||RepairOpen||NativePresenting?.Invoke()==true)return false;bool result=Transact(p=>RepairRules.BeginJob(p,job.Id)>0);if(result)Interaction=new RepairInteraction(Profile.RepairPhase,RepairRules.WorkshopRate(Profile));return result;}
  public bool BeginRepair(){var j=ActiveJob;if(j==null||Vehicle==null||Paused||!Profile.Supported||Profile.ActiveTicket<=Profile.CompletedTicket||!RepairRules.IsArrival(Vehicle.transform.position.x-j.DestinationX,Vehicle.transform.position.z-j.DestinationZ,Vehicle.SpeedKmh/3.6f))return false;RepairOpen=true;Interaction=new RepairInteraction(Profile.RepairPhase,RepairRules.WorkshopRate(Profile));SyncPause();RefreshProfile();return true;}
  public bool AdvanceRepair(int phase){if(!RepairOpen||!Profile.Supported||Profile.RepairPhase!=phase||phase<0||phase>2)return false;var next=Profile.Clone();if(!RepairRules.AdvanceRepair(next,next.ActiveTicket,phase))return false;
   if(phase==2){if(storage==null||!RepairRules.Complete(next,next.ActiveTicket,DateTime.UtcNow,storage.Save))return false;Profile.CopyFrom(next);RepairOpen=false;Interaction.SetPhase(3);Feedback?.Invoke(T("Auftrag abgeschlossen!","Service call completed!"));SyncPause();RefreshProfile();return true;}
   if(storage==null||!storage.Save(next))return false;Profile.CopyFrom(next);Interaction.SetPhase(Profile.RepairPhase);Feedback?.Invoke(T("Schritt erledigt","Step completed"));RefreshProfile();return true;
  }
  public void CompleteActiveJob(){if(!RepairOpen||Profile.RepairPhase!=3||storage==null)return;if(RepairRules.Complete(Profile,Profile.ActiveTicket,DateTime.UtcNow,storage.Save)){RepairOpen=false;SyncPause();RefreshProfile();}}
  public void CloseRepair(){if(NativePresenting?.Invoke()==true)return;RepairOpen=false;Interaction?.ResetInput();SyncPause();RefreshProfile();}
  public void SetTabletOpen(bool open){if(NativePresenting?.Invoke()==true)return;TabletOpen=open;Interaction?.ResetInput();SyncPause();RefreshProfile();}
  public bool Transact(Func<RepairProfile,bool> change){if(!Profile.Supported||storage==null)return false;var next=Profile.Clone();if(!change(next)||!storage.Save(next))return false;Profile.CopyFrom(next);RefreshProfile();return true;}
  public string T(string de,string en){return Profile.Language=="en"?en:de;}
  public void RefreshProfile(){if(Vehicle!=null){Vehicle.MaxSpeed=RepairRules.VehicleSpeed(Profile.Vehicle);Vehicle.Acceleration=Profile.Vehicle==2?22:18;}UiFactoryCompatibility();Changed?.Invoke();}
  void UiFactoryCompatibility(){if(CashText!=null)CashText.text="CASH\n$"+Profile.Cash.ToString("N0");if(LevelText!=null)LevelText.text="LEVEL "+Profile.Level+"\n"+Profile.Xp+" / "+RepairRules.XpTarget(Profile)+" XP";if(ToolText!=null)ToolText.text=T("WERKZEUG\n","TOOL\n")+ToolName();var j=ActiveJob;if(JobTitle!=null)JobTitle.text=j==null?T("Nächsten Auftrag wählen","Choose your next call"):T(j.TitleDe,j.Title);if(JobMeta!=null)JobMeta.text=j==null?"":j.Address+"\n$"+j.Reward+" • "+j.Xp+" XP";}
  public string ToolName(){return (Profile.ToolMask&4)!=0?T("Profi-Werkzeug","Professional Kit"):(Profile.ToolMask&2)!=0?T("Spannungsprüfer","Voltage Tester"):T("Basis-Schlüssel","Basic Wrench");}
  void Update(){if(Vehicle==null)return;SyncPause();if(DistanceText!=null)DistanceText.text=Mathf.RoundToInt(Distance)+" m";if(StatusText!=null)StatusText.text=Mathf.RoundToInt(Vehicle.SpeedKmh)+" KM/H";if(CompleteButton!=null){var j=ActiveJob;CompleteButton.gameObject.SetActive(!Paused&&j!=null&&RepairRules.IsArrival(Vehicle.transform.position.x-j.DestinationX,Vehicle.transform.position.z-j.DestinationZ,Vehicle.SpeedKmh/3.6f));}if(!Paused&&(Vehicle.transform.position.y< -3||Mathf.Abs(Vehicle.transform.position.x)>62||Vehicle.transform.position.z< -15||Vehicle.transform.position.z>465))Recover();if(Time.realtimeSinceStartup>=nextSnapshot){nextSnapshot=Time.realtimeSinceStartup+5;Save();}}
  void SyncPause(){if(Vehicle!=null&&Vehicle.InputEnabled==Paused)Vehicle.SetInputEnabled(!Paused);}
  public bool Save(){if(storage==null||!Profile.Supported)return false;if(Vehicle!=null){Profile.SavedX=Vehicle.transform.position.x;Profile.SavedZ=Vehicle.transform.position.z;Profile.SavedHeading=Vehicle.transform.eulerAngles.y;}return storage.Save(Profile);}
  public void RestoreVehicle(){if(Vehicle==null)return;float x=NearestStreet(Profile.SavedX);Vehicle.transform.SetPositionAndRotation(new Vector3(x,.11f,Mathf.Clamp(Profile.SavedZ,0,435)),Quaternion.Euler(0,Profile.SavedHeading,0));Vehicle.ResetMotion();Physics.SyncTransforms();}
  public void Recover(){if(Vehicle==null)return;var pos=Vehicle.transform.position;Vehicle.transform.SetPositionAndRotation(new Vector3(NearestStreet(pos.x),.11f,Mathf.Clamp(pos.z,0,435)),Quaternion.identity);Vehicle.ResetMotion();Physics.SyncTransforms();Save();Feedback?.Invoke(T("Zurück auf der Straße","Back on the road"));}
  public void ReturnToWorkshop(){if(NativePresenting?.Invoke()==true||Vehicle==null)return;Vehicle.transform.SetPositionAndRotation(new Vector3(0,.11f,0),Quaternion.identity);Vehicle.ResetMotion();Physics.SyncTransforms();Save();RefreshProfile();}
  static float NearestStreet(float x){return Mathf.Abs(x)<16?0:x<0?-32:32;}
  void OnApplicationFocus(bool value){focused=value;Interaction?.ResetInput();if(!value)Save();SyncPause();}
  void OnApplicationPause(bool value){osPaused=value;Interaction?.ResetInput();if(value)Save();SyncPause();}
  void OnApplicationQuit(){Save();}
 }
}
