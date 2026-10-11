#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using Kamilunavo.RepairEmpire.Gameplay;
using Kamilunavo.RepairEmpire.Visuals;

public static class RepairJobPresentationValidation
{
 static void Check(bool value,string message){if(!value)throw new InvalidOperationException("Job presentation: "+message);}
 public static void Run()
 {
  var keys=new HashSet<string>();
  foreach(var job in JobCatalog.All)keys.Add(ServiceSceneArt.VisualKey(job.Id));
  Debug.Log("REPAIR_JOB_PRESENTATION_BASELINE calls="+JobCatalog.All.Length+" distinctFixtureKeys="+keys.Count);
  Check(JobCatalog.All.Length==24,"the existing24paid contract identities remain available");
  Check(keys.Count==24,"each of the24contracts has its own fixture instead of category-level fallback images");
  var presentation=typeof(JobDefinition).GetField("Presentation",BindingFlags.Public|BindingFlags.Instance);
  Check(presentation!=null,"each job carries an explicit localized repair presentation");
  var signatures=new HashSet<string>();var workflows=new HashSet<string>();
  foreach(var job in JobCatalog.All){
   var definition=presentation.GetValue(job);Check(definition!=null,"presentation exists for "+job.Id);
   var stages=definition.GetType().GetField("Stages").GetValue(definition) as Array;
   Check(stages!=null&&stages.Length==3,"exactly three persisted phases remain for "+job.Id);
   string workflow="";foreach(var stage in stages){
    var type=stage.GetType();Check(!string.IsNullOrWhiteSpace(type.GetField("TitleDe").GetValue(stage) as string)&&!string.IsNullOrWhiteSpace(type.GetField("TitleEn").GetValue(stage) as string),"DE/EN stage labels for "+job.Id);
    var actions=type.GetField("Actions").GetValue(stage) as Array;workflow+=type.GetField("Kind").GetValue(stage)+":"+(actions?.Length??0)+"/";
   }
   workflows.Add(workflow);
   var root=new GameObject("JobFixtureProbe");
   try{
    var fixture=ServiceSceneArt.BuildFixture(root.transform,job.Id,1);
    Check(fixture.GetComponentsInChildren<Collider>().Length==0,"service preview never changes collision");
    int vertices=0;var geometry=new List<string>();foreach(var f in fixture.GetComponentsInChildren<MeshFilter>()){
     vertices+=f.sharedMesh.vertexCount;long hash=17;foreach(var vertex in f.sharedMesh.vertices){var p=fixture.transform.InverseTransformPoint(f.transform.TransformPoint(vertex));unchecked{hash=hash*31+Mathf.RoundToInt(p.x*1000);hash=hash*31+Mathf.RoundToInt(p.y*1000);hash=hash*31+Mathf.RoundToInt(p.z*1000);}}
     geometry.Add(f.sharedMesh.vertexCount+":"+f.sharedMesh.triangles.Length+":"+hash);
    }
    geometry.Sort(StringComparer.Ordinal);Check(vertices>200&&vertices<30000,"bounded real fixture geometry for "+job.Id);
    Check(signatures.Add(string.Join("|",geometry)),"each authored job changes real fixture geometry instead of only model names: "+job.Id);
   }finally{UnityEngine.Object.DestroyImmediate(root);}
  }
  Check(workflows.Count>=5,"service calls vary actual hold/sequence modes and counts");
  Debug.Log("REPAIR_JOB_PRESENTATION_PASS calls=24 fixtures=24 phases=3 workflowPatterns="+workflows.Count);
 }
}
#endif
