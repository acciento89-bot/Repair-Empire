#if UNITY_EDITOR
using System;
using UnityEngine;
using Kamilunavo.RepairEmpire.Visuals;

public static class RepairVanGlassValidation
{
 internal static float Hit(MeshFilter filter,Ray ray)=>Hit(filter,ray,out _);
 internal static float Hit(MeshFilter filter,Ray ray,out Vector3 surfaceNormal)
 {
  var vertices=filter.sharedMesh.vertices;var triangles=filter.sharedMesh.triangles;var normals=filter.sharedMesh.normals;float nearest=float.PositiveInfinity;surfaceNormal=Vector3.zero;
  for(int i=0;i<triangles.Length;i+=3)
  {
   var a=filter.transform.TransformPoint(vertices[triangles[i]]);var b=filter.transform.TransformPoint(vertices[triangles[i+1]]);var c=filter.transform.TransformPoint(vertices[triangles[i+2]]);
   var edge=b-a;var other=c-a;var h=Vector3.Cross(ray.direction,other);float det=Vector3.Dot(edge,h);if(Mathf.Abs(det)<1e-8f)continue;
   float inv=1/det;var s=ray.origin-a;float u=Vector3.Dot(s,h)*inv;if(u<0||u>1)continue;var q=Vector3.Cross(s,edge);float v=Vector3.Dot(ray.direction,q)*inv;if(v<0||u+v>1)continue;float t=Vector3.Dot(other,q)*inv;if(t>=0&&t<nearest){nearest=t;surfaceNormal=filter.transform.TransformDirection(normals[triangles[i]]*(1-u-v)+normals[triangles[i+1]]*u+normals[triangles[i+2]]*v).normalized;}
  }
  return nearest;
 }
 public static int ValidateCargoSkin(GameObject host)
 {
  var body=host.transform.Find("Bevelled service body").GetComponent<MeshFilter>();int checks=0;
  foreach(var filter in host.GetComponentsInChildren<MeshFilter>(true))if(filter.name.StartsWith("Rear window"))throw new InvalidOperationException("VAN_CONCEPT_REQUIRES_CLOSED_CARGO_DOORS");
  foreach(int side in new[]{-1,1})
  {
   foreach(float dx in new[]{-.20f,0,.20f})foreach(float dy in new[]{-.10f,0,.10f})
   {
    float x=side*.47f+dx,y=1.99f+dy;var ray=new Ray(new Vector3(x,y,-5),Vector3.forward);float skin=Hit(body,ray);checks++;
    if(!float.IsFinite(skin)||Mathf.Abs(skin-(VanCoachworkGeometry.RearSkinZ(x,y)+5))>.02f)throw new InvalidOperationException("VAN_CONTINUOUS_CARGO_SKIN side="+side+" body="+skin);
   }
  }
  return checks;
 }
 public static void Validate()
 {
  var host=new GameObject("ActualVanGlassOcclusionProbe",typeof(VanArt));int checks=0;
  try
  {
   host.GetComponent<VanArt>().Build();var body=host.transform.Find("Bevelled service body").GetComponent<MeshFilter>();var glass=host.transform.Find("Swept panoramic windshield").GetComponent<MeshFilter>();
   for(int row=0;row<=18;row++)foreach(float x in new[]{-.60f,0,.60f})
   {
    float z=Mathf.Lerp(.965f,1.59f,row/18f);var ray=new Ray(new Vector3(x,5,z),Vector3.down);float skin=Hit(body,ray),pane=Hit(glass,ray);checks++;
    if(!float.IsFinite(skin)||!float.IsFinite(pane)||pane>=skin-.007f)throw new InvalidOperationException("VAN_GLASS_OCCLUDED x="+x+" z="+z+" bodyDistance="+skin+" glassDistance="+pane);
   }
   int cargoChecks=ValidateCargoSkin(host);
   if(host.GetComponentsInChildren<Collider>(true).Length!=0)throw new InvalidOperationException("Glazing must not change driving collision");
   Debug.Log("REPAIR_VAN_GLASS_PASS actual windshield mesh rays="+checks+" shell never obscures glazing; closed cargo skin rays="+cargoChecks);
  }
  finally{UnityEngine.Object.DestroyImmediate(host);}
 }
}
#endif
