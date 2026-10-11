using System;

namespace Kamilunavo.RepairEmpire.Gameplay
{
 public enum RepairInputKind { Hold, Sequence }
 public sealed class RepairAction
 {
  public readonly string LabelDe,LabelEn;
  public RepairAction(string de,string en){LabelDe=de;LabelEn=en;}
 }
 public sealed class RepairStage
 {
  public readonly string TitleDe,TitleEn,InstructionDe,InstructionEn,ButtonDe,ButtonEn;
  public readonly RepairInputKind Kind;
  public readonly float Seconds;
  public readonly RepairAction[] Actions;
  public RepairStage(string de,string en,string instructionDe,string instructionEn,RepairInputKind kind,float seconds,RepairAction[] actions=null)
  {
   TitleDe=ButtonDe=de;TitleEn=ButtonEn=en;InstructionDe=instructionDe;InstructionEn=instructionEn;Kind=kind;
   Seconds=Math.Max(.4f,Math.Min(2.5f,seconds));Actions=actions??Array.Empty<RepairAction>();
   if(kind==RepairInputKind.Sequence&&(Actions.Length<2||Actions.Length>4))throw new ArgumentException("A repair sequence needs two to four actions.");
  }
 }
 // Catalogue presentation is derived from the saved job ID; no new persisted state/reward authority.
 public sealed class JobPresentation
 {
  public readonly string FixtureKey;
  public readonly RepairStage[] Stages;
  public JobPresentation(string fixture,RepairStage first,RepairStage service,RepairStage test){FixtureKey=fixture;Stages=new[]{first,service,test};}
 }
}
