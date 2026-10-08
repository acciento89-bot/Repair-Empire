using System;
namespace Kamilunavo.RepairEmpire.Core {
 public static class RepairPersistence {
  #if DEVELOPMENT_BUILD || UNITY_EDITOR
  public static string QaKey=>Environment.GetEnvironmentVariable("REPAIR_QA_ID");
#endif
  static RepairSave storage;static Func<bool> supported;
  public static bool Writable{get{return storage!=null&&supported!=null&&supported();}}
  public static void Configure(RepairSave target,Func<bool> writable){storage=target;supported=writable;}
  public static void Save(RepairProfile p){if(!Writable||!p.Supported)throw new InvalidOperationException("Saved profile is preserved and unavailable for transactions.");p.Normalize();if(!storage.Save(p))throw new InvalidOperationException("Profile could not be persisted.");}
 }
}
