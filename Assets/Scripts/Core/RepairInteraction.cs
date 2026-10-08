using System;
namespace Kamilunavo.RepairEmpire.Core {
 // Partial input is intentionally transient; only completed stages enter the saved ticket.
 public sealed class RepairInteraction {
  public int Phase {get;private set;}public int Taps {get;private set;}
  public float Progress {get;private set;}bool held,completed;readonly float rate;
  public RepairInteraction(int phase,float speed=1){rate=float.IsNaN(speed)||float.IsInfinity(speed)?1:Math.Max(1,Math.Min(1.48f,speed));SetPhase(phase);}
  public void SetPhase(int phase){Phase=Math.Max(0,Math.Min(3,phase));Taps=0;Progress=0;held=false;completed=false;}
  public void SetHeld(bool value){held=value;if(!value)Progress=0;}
  public void ResetInput(){held=false;Progress=0;Taps=0;}
  public bool Tick(float dt,bool paused){if(paused){ResetInput();return false;}if(completed||!held||Phase==1||Phase>=3||float.IsNaN(dt)||float.IsInfinity(dt)||dt<=0)return false;Progress=Math.Min(1,Progress+Math.Min(.1f,dt)*rate/(Phase==2?.8f:1f));if(Progress<1)return false;completed=true;held=false;return true;}
  public bool Tap(int index){if(completed||Phase!=1)return false;if(index!=Taps){Taps=0;return false;}Taps++;if(Taps<4)return false;completed=true;return true;}
 }
}
