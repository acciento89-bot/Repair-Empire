#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using UnityEngine;
using Kamilunavo.RepairEmpire.Gameplay;
using Kamilunavo.RepairEmpire.Visuals;

public static class RepairTabletFinishValidation
{
 static void Require(bool value,string message){if(!value)throw new InvalidOperationException("Repair tablet finish: "+message);}
 public static void ValidateThumbnails()
 {
  var host=new GameObject("QA actual thumbnail framing");var failures=new List<string>();var rendered=new HashSet<string>();var previous=RenderTexture.active;int vertices=0;float minimum=1,maximum=0;
  try
  {
   var art=host.AddComponent<ServiceSceneArt>();
   foreach(var job in JobCatalog.All)
   {
    string key=job.Presentation.FixtureKey;if(!rendered.Add(key))continue;var image=art.Thumbnail(job.Id);var camera=host.GetComponentInChildren<Camera>(true);var model=ServiceSceneArt.BuildFixture(camera.transform.parent,key,-1);
    try
    {
     Require(ReferenceEquals(image,art.Thumbnail(key))&&image.width==192&&image.height==192,"Shared immutable192px thumbnail cache "+key);Require(RenderTexture.active==previous&&camera.targetTexture==null,"Thumbnail restores caller render state "+key);
     float minX=1,minY=1,maxX=0,maxY=0;
     foreach(var renderer in RepairSceneFraming.Components(model.transform.Find("Service fixture")))foreach(var vertex in renderer.GetComponent<MeshFilter>().sharedMesh.vertices)
     {
      var point=camera.WorldToViewportPoint(renderer.transform.TransformPoint(vertex));vertices++;minX=Mathf.Min(minX,point.x);maxX=Mathf.Max(maxX,point.x);minY=Mathf.Min(minY,point.y);maxY=Mathf.Max(maxY,point.y);if(point.z<=camera.nearClipPlane||point.x<.05f||point.x>.95f||point.y<.05f||point.y>.95f)failures.Add(key+" clipped "+renderer.name+" "+point);
     }
     float span=Mathf.Max(maxX-minX,maxY-minY);minimum=Mathf.Min(minimum,span);maximum=Mathf.Max(maximum,span);Debug.Log("REPAIR_THUMBNAIL_EXTENT "+key+" "+span+" bounds="+minX+","+minY+","+maxX+","+maxY);if(span<.58f||span>.85f)failures.Add(key+" subject span="+span);
    }
    finally{UnityEngine.Object.DestroyImmediate(model);}
   }
  }
  finally{UnityEngine.Object.DestroyImmediate(host);}
  Require(failures.Count==0,"Actual production-camera subject framing: "+string.Join("; ",failures.GetRange(0,Mathf.Min(12,failures.Count))));Debug.Log("REPAIR_TABLET_THUMBNAIL_PASS keys="+rendered.Count+" actualVertices="+vertices+" span="+minimum+".."+maximum);
 }
 public static void Validate()=>ValidateThumbnails();
}
#endif
