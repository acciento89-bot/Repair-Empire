namespace Kamilunavo.RepairEmpire.Core {
 // Observes the real company loop; it never grants rewards, moves the van or resets tickets.
 public sealed class RepairTutorial {
  public bool Active {get;private set;}public int Step {get;private set;}
  int completedAtStart;float distanceAtStart;
  public void Start(RepairProfile p,float distance){Active=p.Supported;Step=0;completedAtStart=p.CompletedJobs;distanceAtStart=distance;}
  public void Stop(){Active=false;}
  public void Observe(RepairProfile p,float distance,bool steered,bool accelerated,bool arrived,bool repairOpen,bool interrupted){
   if(!Active||interrupted)return;
   if(p.CompletedJobs>completedAtStart&&Step<6)Step=6;
   switch(Step){case 0:if(steered)Step=1;break;case 1:if(accelerated)Step=2;break;case 2:if(distanceAtStart-distance>=12||arrived)Step=3;break;case 3:if(arrived)Step=4;break;case 4:if(repairOpen)Step=5;break;case 5:break;case 6:if((p.ToolMask&2)!=0){Step=7;Active=false;}break;}
  }
 }
}
