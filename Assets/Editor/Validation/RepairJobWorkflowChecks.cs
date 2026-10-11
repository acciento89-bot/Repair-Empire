using System;
using System.Collections.Generic;
using Kamilunavo.RepairEmpire.Core;
using Kamilunavo.RepairEmpire.Gameplay;

namespace Kamilunavo.RepairEmpire.Validation
{
 public static class RepairJobWorkflowChecks
 {
  static int checks;
  static void Check(bool ok,string message){checks++;if(!ok)throw new InvalidOperationException("Job workflow: "+message);}
  public static void Run()
  {
   checks=0;var keys=new HashSet<string>();var patterns=new HashSet<string>();
   foreach(var job in JobCatalog.All){
    var recipe=job.Presentation;Check(recipe!=null&&recipe.Stages.Length==3,"three phases for "+job.Id);Check(keys.Add(recipe.FixtureKey),"unique service fixture key");string pattern="";
    for(int phase=0;phase<3;phase++){
     var stage=recipe.Stages[phase];Check(!string.IsNullOrWhiteSpace(stage.TitleDe)&&!string.IsNullOrWhiteSpace(stage.TitleEn),"localized procedure labels");
     var session=new RepairInteraction(phase,1,recipe);pattern+=stage.Kind+":"+stage.Actions.Length+"/";
     Check(session.Phase==phase&&session.Progress==0&&session.Taps==0,"resume grants no interaction credit");
     if(stage.Kind==RepairInputKind.Sequence){
      Check(stage.Actions.Length>=2&&stage.Actions.Length<=4,"bounded mobile action count");
      session.SetHeld(true);Check(!session.Tick(2,false),"hold cannot skip a sequence");Check(!session.Tap(stage.Actions.Length-1)&&session.Taps==0,"out-of-order action rejected");
      for(int i=0;i<stage.Actions.Length;i++){Check(!string.IsNullOrWhiteSpace(stage.Actions[i].LabelDe)&&!string.IsNullOrWhiteSpace(stage.Actions[i].LabelEn),"localized task actions");Check(session.Tap(i)==(i==stage.Actions.Length-1),"only complete named sequence finishes");}
      Check(!session.Tap(stage.Actions.Length-1),"sequence completion is single-use");
     }else{
      Check(stage.Seconds>=.4f&&stage.Seconds<=2.5f,"bounded hold duration");Check(!session.Tap(0),"tap cannot skip a hold");session.SetHeld(true);Check(!session.Tick(8,false)&&session.Progress<.3f,"long frame stays capped");
      Check(!session.Tick(.1f,true)&&session.Progress==0,"pause cancels partial work");session.SetHeld(true);bool finished=false;for(int tick=0;tick<30;tick++)finished|=session.Tick(.1f,false);Check(finished,"genuine timed hold completes");Check(!session.Tick(.1f,false),"hold completion is single-use");
     }
     session.SetPhase(3);session.SetHeld(true);Check(!session.Tick(10,false)&&!session.Tap(0),"completed phase cannot generate more stages");
    }patterns.Add(pattern);
   }
   Check(keys.Count==24&&patterns.Count>=5,"24fixtures and varied real input workflows");
   Console.WriteLine("REPAIR_JOB_WORKFLOW_PASS checks="+checks+" jobs=24 workflowPatterns="+patterns.Count);
  }
#if REPAIR_JOB_WORKFLOW_EXE
  public static void Main(){Run();}
#endif
 }
}
