#if UNITY_EDITOR
using System;
using UnityEngine;
using Kamilunavo.RepairEmpire.Visuals;

public static class RepairVanGlassValidation
{
 static float Hit(MeshFilter filter,Ray ray)
 {
  var vertices=filter.sharedMesh.vertices;var triangles=filter.sharedMesh.triangles;float nearest=float.PositiveInfinity;
  for(int i=0;i<triangles.Length;i+=3)
  {
   var a=filter.transform.TransformPoint(vertices[triangles[i]]);var b=filter.transform.TransformPoint(vertices[triangles[i+1]]);var c=filter.transform.TransformPoint(vertices[triangles[i+2]]);
   var edge=b-a;var other=c-a;var h=Vector3.Cross(ray.direction,other);float det=Vector3.Dot(edge,h);if(Mathf.Abs(det)<1e-8f)continue;
   float inv=1/det;var s=ray.origin-a;float u=Vector3.Dot(s,h)*inv;if(u<0||u>1)continue;var q=Vector3.Cross(s,edge);float v=Vector3.Dot(ray.direction,q)*inv;if(v<0||u+v>1)continue;float t=Vector3.Dot(other,q)*inv;if(t>=0)nearest=Mathf.Min(nearest,t);
  }
  return nearest;
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
   if(host.GetComponentsInChildren<Collider>(true).Length!=0)throw new InvalidOperationException("Glazing must not change driving collision");
   Debug.Log("REPAIR_VAN_GLASS_PASS actual mesh rays="+checks+" shell never obscures glazing");
  }
  finally{UnityEngine.Object.DestroyImmediate(host);}
 }
}
#endif
