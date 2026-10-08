using System;
using Kamilunavo.RepairEmpire.Core;
namespace Kamilunavo.RepairEmpire.Validation {
 public static class RepairInteractionChecks {
  public static int Run(){int n=0;Action<bool,string> check=(ok,name)=>{n++;if(!ok)throw new Exception("REPAIR_INTERACTION_FAIL "+name);};var session=new RepairInteraction(0);
  session.SetHeld(true);check(!session.Tick(.5f,false),"single long frame cannot instantly finish");for(int i=0;i<4;i++)check(!session.Tick(.1f,false),"first hold requires time");check(!session.Tick(.1f,true)&&session.Progress==0,"pause cancels partial hold");session.SetHeld(true);bool finished=false;for(int i=0;i<12;i++)finished|=session.Tick(.1f,false);check(finished,"continuous actual hold completes first stage");check(!session.Tick(.1f,false),"completion cannot repeat");session.SetPhase(1);check(!session.Tap(2)&&session.Taps==0,"wrong order does not advance");check(!session.Tap(0)&&!session.Tap(1)&&!session.Tap(2),"ordered first three fasteners");check(!session.Tap(0)&&session.Taps==0,"wrong later tap resets sequence");for(int i=0;i<3;i++)session.Tap(i);check(session.Tap(3),"four ordered taps finish stage");check(!session.Tap(3),"tap completion cannot repeat");session.SetPhase(2);session.SetHeld(true);for(int i=0;i<4;i++)session.Tick(.1f,false);session.SetHeld(false);check(session.Progress==0,"release resets verification hold");session.SetHeld(true);finished=false;for(int i=0;i<12;i++)finished|=session.Tick(.1f,false);check(finished,"final verification hold completes");session.SetPhase(3);session.SetHeld(true);check(!session.Tick(2,false)&&!session.Tap(0),"finished repair cannot mint stages");var resumed=new RepairInteraction(1);check(resumed.Taps==0&&!resumed.Tick(1,false),"resume restores saved stage without interaction credit");Console.WriteLine("REPAIR_INTERACTION_PASS "+n);return n;}
#if REPAIR_INTERACTION_EXE
  public static void Main(){Run();}
#endif
 }
}
