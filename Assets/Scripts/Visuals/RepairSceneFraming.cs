using System;
using System.Collections.Generic;
using UnityEngine;

namespace Kamilunavo.RepairEmpire.Visuals
{
 // Fit real service components, not the room, inside the space left by the UI.
 // Called only when a cached repair photograph changes, never every frame.
 public static class RepairSceneFraming
 {
  public static Rect SampleViewport(float displayAspect,float textureAspect)=>displayAspect>=textureAspect?new Rect(0,(1-textureAspect/displayAspect)*.5f,1,textureAspect/displayAspect):new Rect((1-displayAspect/textureAspect)*.5f,0,displayAspect/textureAspect,1);
  public static Rect MapViewport(Rect display,Rect sample)=>new Rect(sample.x+display.x*sample.width,sample.y+display.y*sample.height,display.width*sample.width,display.height*sample.height);
  public static IEnumerable<MeshRenderer> Components(Transform fixture)
  {
   bool faucet=fixture.Find("Curved chrome spout")!=null;
   foreach(var renderer in fixture.GetComponentsInChildren<MeshRenderer>(true))if(renderer.enabled&&!(faucet&&(renderer.name=="Porcelain basin"||renderer.name=="Basin drain")))yield return renderer;
  }
  public static Bounds Fit(Camera camera,Transform fixture,Rect clear)
  {
   if(camera==null||fixture==null||clear.width<.05f||clear.height<.05f||clear.xMin<0||clear.yMin<0||clear.xMax>1||clear.yMax>1)throw new ArgumentException("Invalid repair camera clear viewport");
   bool found=false;var bounds=new Bounds();foreach(var renderer in Components(fixture)){if(!found){bounds=renderer.bounds;found=true;}else bounds.Encapsulate(renderer.bounds);}
   if(!found)throw new InvalidOperationException("Repair fixture has no modeled components");
   var points=new Vector3[8];int index=0;for(int x=-1;x<=1;x+=2)for(int y=-1;y<=1;y+=2)for(int z=-1;z<=1;z+=2)points[index++]=bounds.center+Vector3.Scale(bounds.extents,new Vector3(x,y,z));
   var orientation=camera.transform.rotation;var right=orientation*Vector3.right;var up=orientation*Vector3.up;var forward=orientation*Vector3.forward;float minX=float.PositiveInfinity,minY=minX,maxX=float.NegativeInfinity,maxY=maxX,depth=0;
   foreach(var point in points){var relative=point-bounds.center;float x=Vector3.Dot(relative,right),y=Vector3.Dot(relative,up);minX=Mathf.Min(minX,x);maxX=Mathf.Max(maxX,x);minY=Mathf.Min(minY,y);maxY=Mathf.Max(maxY,y);depth=Mathf.Max(depth,Mathf.Abs(Vector3.Dot(relative,forward)));}
   float tangent=Mathf.Tan(camera.fieldOfView*Mathf.Deg2Rad*.5f),span=Mathf.Max((maxY-minY)/(clear.height*.92f),(maxX-minX)/(camera.aspect*clear.width*.92f)),distance=Mathf.Max(span/(2*tangent)+depth,depth+camera.nearClipPlane+.1f);
   var inset=new Rect(clear.x+clear.width*.02f,clear.y+clear.height*.02f,clear.width*.96f,clear.height*.96f);
   for(int attempt=0;attempt<32;attempt++)
   {
    float viewHeight=2*tangent*distance;var focus=bounds.center-right*((clear.center.x-.5f)*viewHeight*camera.aspect)-up*((clear.center.y-.5f)*viewHeight);camera.transform.SetPositionAndRotation(focus-forward*distance,orientation);bool fits=true;
    foreach(var point in points){var projected=camera.WorldToViewportPoint(point);if(projected.z<=camera.nearClipPlane||!inset.Contains(new Vector2(projected.x,projected.y))){fits=false;break;}}
    if(fits)return bounds;distance*=1.08f;
   }
   throw new InvalidOperationException("Modeled repair components could not fit the actual clear viewport");
  }
 }
}
