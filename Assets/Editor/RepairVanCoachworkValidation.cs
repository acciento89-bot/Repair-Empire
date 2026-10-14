#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using UnityEngine;
using Kamilunavo.RepairEmpire.Visuals;

// Actual mesh/livery/lifetime contracts; the parent task still reviews real photographs.
public static class RepairVanCoachworkValidation
{
 static int checks;
 static void Check(bool value,string label){checks++;if(!value)throw new InvalidOperationException("VAN_COACHWORK: "+label);}
 static string Key(Vector3 p)=>Mathf.RoundToInt(p.x*100000)+","+Mathf.RoundToInt(p.y*100000)+","+Mathf.RoundToInt(p.z*100000);
 static void Solid(Mesh mesh)
 {
  var points=mesh.vertices;var indices=mesh.triangles;var edges=new Dictionary<string,int>();double volume=0;
  for(int i=0;i<indices.Length;i+=3){var a=points[indices[i]];var b=points[indices[i+1]];var c=points[indices[i+2]];
   Check(Vector3.Cross(b-a,c-a).sqrMagnitude>1e-12f,"nondegenerate coachwork face");volume+=Vector3.Dot(a,Vector3.Cross(b,c))/6d;
   for(int e=0;e<3;e++){string x=Key(points[indices[i+e]]),y=Key(points[indices[i+(e+1)%3]]);string key=string.CompareOrdinal(x,y)<0?x+"/"+y:y+"/"+x;edges.TryGetValue(key,out int n);edges[key]=n+1;}
  }
  foreach(var count in edges.Values)Check(count==2,"closed original coachwork skin");Check(volume>0,"outward coachwork winding");
 }
 public static void Validate()
 {
  checks=0;var host=new GameObject("OriginalCompactVanFixture",typeof(VanArt));var assets=new HashSet<UnityEngine.Object>();var errors=new List<string>();
  Application.LogCallback capture=(m,s,t)=>{if(t==LogType.Error||t==LogType.Assert||t==LogType.Exception)errors.Add(m);};Application.logMessageReceived+=capture;
  try{
   var art=host.GetComponent<VanArt>();art.Build();var shell=host.transform.Find("Bevelled service body").GetComponent<MeshFilter>().sharedMesh;
   int shoulder=0,axle=0;foreach(var p in shell.vertices){
    if(Mathf.Abs(p.z+1.72f)<.001f&&Mathf.Abs(p.x)>.85f&&Mathf.Abs(p.x)<1.055f&&p.y>2.20f&&p.y<2.395f)shoulder++;
    if(Mathf.Abs(p.z+1.42f)<.001f&&Mathf.Abs(p.x)>.94f){axle++;Check(p.y>=.90f,"side skin actually rises around the rear wheel opening");}
   }
   Check(shoulder>=12,"continuous rolled cargo shoulders have intermediate surface curvature");Check(axle>0,"rear wheel opening belongs to the body mesh");Solid(shell);
   Check(shell.bounds.min.y>=.419f&&shell.bounds.max.y<=2.401f&&shell.bounds.size.x<=2.111f&&shell.bounds.min.z>=-2.181f&&shell.bounds.max.z<=2.111f,"original body/camera envelope retained");
   foreach(var name in new[]{"Rear bumper","Front bumper","Rear window left","Rear window right"}){var mesh=host.transform.Find(name).GetComponent<MeshFilter>().sharedMesh;Solid(mesh);Check(mesh.vertexCount>=80,"molded coachwork replaces a square slab: "+name);}
   foreach(var filter in host.GetComponentsInChildren<MeshFilter>())if(filter.name=="Raised wheel arch trim")Solid(filter.sharedMesh);
   var livery=new HashSet<Material>();int active=0,vertices=0;var meshes=new HashSet<Mesh>();
   foreach(var filter in host.GetComponentsInChildren<MeshFilter>(true)){var mesh=filter.sharedMesh;assets.Add(mesh);if(meshes.Add(mesh))vertices+=mesh.vertexCount;foreach(var n in mesh.normals)Check(float.IsFinite(n.x)&&float.IsFinite(n.y)&&float.IsFinite(n.z)&&n.sqrMagnitude>.5f,"finite lit coachwork normals");}
   var materials=new HashSet<Material>();foreach(var renderer in host.GetComponentsInChildren<MeshRenderer>(true)){if(renderer.enabled)active++;var material=renderer.sharedMaterial;if(material!=null&&material.name.StartsWith("Van",StringComparison.Ordinal)){materials.Add(material);assets.Add(material);if(material.name=="VanStyleLivery")livery.Add(material);}}
   Check(active<=32&&vertices<70000&&materials.Count==9,"existing moving model buffer/draw/material ceilings retained");
   Check(livery.Count==1,"one owned actual paint material drives all coachwork bands");var paint=new List<Material>(livery)[0];var colors=new[]{new Color(1,.32f,.045f),new Color(.08f,.64f,.82f),new Color(.24f,.75f,.38f),new Color(.66f,.3f,.94f),new Color(1,.73f,.1f),new Color(.16f,.77f,1),new Color(.35f,.95f,.64f),new Color(.89f,.30f,.67f)};
   for(int style=0;style<8;style++){art.Apply(style,0);Check(paint.color==colors[style],"actual livery variant "+style);}
   art.Apply(0,1);Check(host.transform.localScale==new Vector3(1,1.10f,1.06f),"upgrade visual scale remains exact");art.Apply(0,0);
   int wheels=0;foreach(var t in host.GetComponentsInChildren<Transform>())if(t.name=="Wheel"){wheels++;Check(Mathf.Abs(t.localPosition.x)==1.035f&&t.localPosition.y==.38f&&(t.localPosition.z==-1.42f||t.localPosition.z==1.38f),"existing wheel animation origin");}Check(wheels==4&&host.GetComponentsInChildren<Collider>(true).Length==0,"four original pivots and no decorative collision");
   foreach(var probe in host.GetComponentsInChildren<ReflectionProbe>()){assets.Add(probe.customBakedTexture);Check(probe.customBakedTexture.width==32&&probe.mode==UnityEngine.Rendering.ReflectionProbeMode.Custom,"existing finite owned vehicle reflection");}
   int filters=host.GetComponentsInChildren<MeshFilter>(true).Length;art.Build();Check(filters==host.GetComponentsInChildren<MeshFilter>(true).Length,"idempotent model creation");
   UnityEngine.Object.DestroyImmediate(host);foreach(var asset in assets)Check(asset==null,"coachwork/material/reflection buffer disposed with model");Check(errors.Count==0,"zero generation/disposal errors: "+string.Join(" | ",errors));
   Debug.Log("REPAIR_VAN_COACHWORK_PASS checks="+checks+" uniqueVertices="+vertices+" renderers="+active+" materials="+materials.Count+" actualConceptReview=PENDING");
  }finally{Application.logMessageReceived-=capture;if(host!=null)UnityEngine.Object.DestroyImmediate(host);}
 }
}
#endif
