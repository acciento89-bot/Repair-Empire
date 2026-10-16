#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using UnityEngine;
using Kamilunavo.RepairEmpire.Visuals;

public static class RepairChromeToolsValidation
{
 static void Require(bool valid,string why){if(!valid)throw new InvalidOperationException("REPAIR_CHROME_TOOLS_"+why);}
 static MeshFilter Find(GameObject model,string name){foreach(var filter in model.GetComponentsInChildren<MeshFilter>())if(filter.name==name)return filter;throw new InvalidOperationException("Missing modeled prop "+name);}
 static Vector3 Foot(MeshFilter filter)
 {
  // Average small transformed offsets. Summing hundreds of world positions at
  // studioY=-1000 creates millimetre error in an otherwise correct cloth foot.
  float lowest=float.PositiveInfinity;foreach(var p in filter.sharedMesh.vertices)lowest=Mathf.Min(lowest,filter.transform.TransformVector(p).y);Vector3 sum=Vector3.zero;int count=0;
  foreach(var p in filter.sharedMesh.vertices){var offset=filter.transform.TransformVector(p);if(offset.y<=lowest+.00005f){sum+=offset;count++;}}return filter.transform.position+sum/count;
 }
 static void RestOn(MeshFilter prop,MeshFilter support,List<string> failures,string label)
 {
  var foot=Foot(prop);float gap=RepairVanGlassValidation.Hit(support,new Ray(foot+Vector3.up*.1f,Vector3.down))-.1f;
  if(!float.IsFinite(gap)||gap<-.0005f||gap>.0015f)failures.Add(label+" "+prop.name+" support gap="+gap);
 }
 static (float low,float high) Column(MeshFilter filter,Vector3 position)
 {
  var down=new Ray(new Vector3(position.x,position.y+2,position.z),Vector3.down);var up=new Ray(new Vector3(position.x,position.y-2,position.z),Vector3.up);
  return(position.y-2+RepairVanGlassValidation.Hit(filter,up),position.y+2-RepairVanGlassValidation.Hit(filter,down));
 }
 public static void ValidateContacts()
 {
  var host=new GameObject("Actual counter and repair accessory contacts");var failures=new List<string>();int cases=0,rests=0;
  try
  {
   foreach(var origin in new[]{Vector3.zero,new Vector3(-7.6f,-1000,4)})foreach(var key in new[]{"faucet","kitchen-mixer"})for(int phase=0;phase<3;phase++)
   {
    host.transform.position=origin;host.transform.rotation=Quaternion.Euler(0,origin==Vector3.zero?0:37,0);var model=ServiceSceneArt.BuildFixture(host.transform,key,phase);
    try
    {
     string label=key+" phase="+phase+" origin="+origin;var counter=Find(model,"Cut stone countertop");var tray=Find(model,"Stone soap tray");
     foreach(var name in new[]{"Orange wrench grip","Folded service cloth","Stoneware plant pot","Stone soap tray"}){RestOn(Find(model,name),counter,failures,label);rests++;}
     RestOn(Find(model,"Soap bottle"),tray,failures,label);rests++;
     var bottle=Find(model,"Soap bottle");var head=Find(model,"Soap dispenser");var at=bottle.transform.TransformPoint(Vector3.zero);var body=Column(bottle,at);var pump=Column(head,at);float neckGap=pump.low-body.high;
     MeshFilter collar=null,stem=null;foreach(var filter in model.GetComponentsInChildren<MeshFilter>()){if(filter.name=="Soap pump collar")collar=filter;if(filter.name=="Soap pump stem")stem=filter;}
     if(collar==null||stem==null){if(!float.IsFinite(neckGap)||neckGap>.002f)failures.Add(label+" disconnected soap head gap="+neckGap);}
     else
     {
      var c=Column(collar,at);var s=Column(stem,at);foreach(var pair in new[]{(body.high,c.low),(c.high,s.low),(s.high,pump.low)})if(!float.IsFinite(pair.Item1)||!float.IsFinite(pair.Item2)||pair.Item2-pair.Item1>.0015f||pair.Item2-pair.Item1<-.04f)failures.Add(label+" disconnected pump surfaces "+pair);
     }
     cases++;
    }
    finally{UnityEngine.Object.DestroyImmediate(model);}
   }
  }
  finally{UnityEngine.Object.DestroyImmediate(host);}
  Require(failures.Count==0,string.Join("; ",failures));Debug.Log("REPAIR_PROP_CONTACT_PASS cases="+cases+" actual support rays="+rests+" bath/kitchen/threephases/worldtranslatedandrotated;continuous soap pump");
 }
 public static void ValidateWrench()
 {
  var host=new GameObject("Actual adjustable wrench visible mechanism");var model=ServiceSceneArt.BuildFixture(host.transform,"faucet",1);int rays=0;
  try
  {
   Transform wrench=null;foreach(var node in model.GetComponentsInChildren<Transform>())if(node.name=="Service adjustable wrench")wrench=node;Require(wrench!=null,"WRENCH_MISSING");var parts=model.GetComponentsInChildren<MeshFilter>();
   foreach(var item in new[]{(new Vector2(-.025f,.335f),"Cut stone countertop"),(new Vector2(-.11f,.335f),"Adjustable wrench fixed jaw"),(new Vector2(.065f,.335f),"Sliding adjustable jaw"),(new Vector2(-.025f,.205f),"Knurled adjustment worm")})
   {
    var ray=new Ray(wrench.TransformPoint(new Vector3(item.Item1.x,1,item.Item1.y)),Vector3.down);float nearest=float.PositiveInfinity;MeshFilter first=null;
    foreach(var part in parts){float hit=RepairVanGlassValidation.Hit(part,ray);if(hit<nearest){nearest=hit;first=part;}}
    Require(first!=null&&first.name==item.Item2,"WRENCH_APERTURE_OR_MECHANISM_OCCLUDED expected="+item.Item2+" first="+(first==null?"nothing":first.name));rays++;
   }
  }
  finally{UnityEngine.Object.DestroyImmediate(host);}
  Debug.Log("REPAIR_ADJUSTABLE_WRENCH_PASS real open jaw and independently visible fixed/sliding jaws/adjustment worm;first-hit rays="+rays);
 }
 public static void ValidateReflection()
 {
  var before=Resources.Load<Cubemap>("Art/ServiceRoomReflection-v1");var now=Resources.Load<Cubemap>("Art/ServiceRoomReflection-v2");Require(before!=null&&now!=null&&before!=now,"NEUTRAL_REFLECTION_ASSET_MISSING");
  double Warmth(Cubemap cube){double red=0,blue=0;for(int face=0;face<6;face++)foreach(var p in cube.GetPixels((CubemapFace)face)){red+=p.r;blue+=p.b;}return red/blue;}
  double old=Warmth(before),current=Warmth(now);Require(double.IsFinite(old)&&double.IsFinite(current)&&current<old*.97,"REFLECTION_STILL_GOLDEN old="+old+" current="+current);Debug.Log("REPAIR_NEUTRAL_CHROME_ENVIRONMENT_PASS HDR red/blue warmth "+old+" -> "+current+";actual64pxsource;v1preserved");
 }
 public static void Validate(){ValidateContacts();ValidateWrench();ValidateReflection();}
}
#endif
