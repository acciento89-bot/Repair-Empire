using System.Collections.Generic;
using UnityEngine;
namespace Kamilunavo.RepairEmpire.Visuals
{
 // Original compact commercial coachwork. These owned visual meshes never carry
 // colliders; the vehicle root retains driving, wheel pivots and paint authority.
 public static class VanCoachworkGeometry
 {
  static readonly float[] Stations={-2.18f,-2.08f,-1.72f,.28f,.58f,.95f,1.28f,1.63f,1.92f,2.11f};
  static readonly float[] Widths={.89f,1.00f,1.055f,1.055f,1.03f,1.01f,.99f,.965f,.94f,.86f};
  static readonly float[] Roof={2.18f,2.37f,2.40f,2.39f,2.31f,2.12f,1.77f,1.31f,1.20f,1.06f};
  static float Arch(float z)
  {
   float height=.42f;foreach(float axle in new[]{-1.42f,1.38f}){float distance=Mathf.Abs(z-axle);if(distance<.59f)height=Mathf.Max(height,.40f+Mathf.Sqrt(.59f*.59f-distance*distance));}return height;
  }
  static float Sample(float[] z,float[] values,float at)
  {for(int i=1;i<z.Length;i++)if(at<=z[i])return Mathf.Lerp(values[i-1],values[i],Mathf.SmoothStep(0,1,(at-z[i-1])/(z[i]-z[i-1])));return values[values.Length-1];}
  static List<float> BodyRings()
  {
   var rings=new List<float>(Stations);rings.Add(-1.42f);rings.Add(1.38f);
   for(int i=0;i<=60;i++){float z=Mathf.Lerp(Stations[0],Stations[Stations.Length-1],i/60f);bool near=false;foreach(float existing in rings)if(Mathf.Abs(existing-z)<.002f){near=true;break;}if(!near)rings.Add(z);}rings.Sort();return rings;
  }
  public static GameObject Windshield(Transform parent,Material material)
  {
   var v=new List<Vector3>();var uv=new List<Vector2>();var triangles=new List<int>();
   // The old four-point pane cut through the curved roof. Follow the identical
   // body stations with a small physical stand-off for the glazing/seal.
   foreach(float z in BodyRings())
   {
    if(z<.95f||z>1.63f)continue;float t=(z-.95f)/.68f,w=Mathf.Lerp(.74f,.75f,t),y=Sample(Stations,Roof,z)+.018f;int n=v.Count;
    v.Add(new(-w,y,z));v.Add(new(w,y,z));uv.Add(new(0,t));uv.Add(new(1,t));
    if(n>0)triangles.AddRange(new[]{n-2,n,n-1,n-1,n,n+1});
   }
   return MeshArt.Mesh(parent,"Swept panoramic windshield",v.ToArray(),triangles.ToArray(),uv.ToArray(),material);
  }
  public static void Wiper(Transform parent,int side,Material material)
  {
   var path=new Vector3[5];for(int i=0;i<path.Length;i++){float t=i/4f,z=Mathf.Lerp(1.59f,1.35f,t);path[i]=new(side*Mathf.Lerp(.40f,.57f,t),Sample(Stations,Roof,z)+.037f,z);}
   MeshArt.Tube(parent,"Windshield wiper",path,.012f,material,8);
  }
  public static GameObject Body(Transform parent,Material material)
  {
   var rings=BodyRings();
   const int corners=12,sides=4*corners;var v=new List<Vector3>();var uv=new List<Vector2>();var t=new List<int>();
   foreach(float z in rings){float width=Sample(Stations,Widths,z),top=Sample(Stations,Roof,z);
    for(int corner=0;corner<4;corner++)for(int n=0;n<corners;n++){
     float a=(corner+n/(float)corners)*Mathf.PI*.5f;bool upper=corner<2;float rx=upper?.20f:.09f,ry=upper?.23f:.09f;
     float cx=(corner==0||corner==3?1:-1)*(width-rx),cy=upper?top-ry:.42f+ry;
     float x=cx+Mathf.Cos(a)*rx,y=cy+Mathf.Sin(a)*ry;
     // The pressed side return rises over real wheel positions. Lower paint
     // follows this opening instead of bridging it with a floating rectangle.
     float side=Mathf.SmoothStep(0,1,(Mathf.Abs(x)/width-.72f)/.20f);
     if(y<1.06f)y=Mathf.Max(y,Mathf.Lerp(.42f,Arch(z),side));
     v.Add(new Vector3(x,y,z));uv.Add(new Vector2((corner*corners+n)/(float)sides,(z+2.18f)/4.29f));
    }
   }
   for(int ring=1;ring<rings.Count;ring++)for(int i=0;i<sides;i++){int a=(ring-1)*sides+i,b=ring*sides+i,next=(i+1)%sides;t.AddRange(new[]{a,(ring-1)*sides+next,b,(ring-1)*sides+next,ring*sides+next,b});}
   foreach(int end in new[]{0,rings.Count-1}){int center=v.Count;v.Add(new Vector3(0,(Sample(Stations,Roof,rings[end])+.42f)*.5f,rings[end]));uv.Add(new Vector2(.5f,.5f));for(int i=0;i<sides;i++){int a=end*sides+i,b=end*sides+(i+1)%sides;t.AddRange(end==0?new[]{center,b,a}:new[]{center,a,b});}}
   return MeshArt.Mesh(parent,"Bevelled service body",v.ToArray(),t.ToArray(),uv.ToArray(),material);
  }
  public static GameObject SideBand(Transform parent,string name,int side,float bottom,float top,Material material)
  {
   const int samples=70;var v=new List<Vector3>();var t=new List<int>();var uv=new List<Vector2>();
   for(int i=0;i<samples;i++){
    float z0=Mathf.Lerp(-2.0f,1.28f,i/(float)samples),z1=Mathf.Lerp(-2.0f,1.28f,(i+1)/(float)samples);
    float lower0=Mathf.Max(bottom,Arch(z0)+.017f),lower1=Mathf.Max(bottom,Arch(z1)+.017f);if(lower0>=top&&lower1>=top)continue;
    lower0=Mathf.Min(lower0,top);lower1=Mathf.Min(lower1,top);int k=v.Count;float x=side*(name=="Orange service band"?1.087f:1.074f);
    v.AddRange(new[]{new Vector3(x,lower0,z0),new Vector3(x,top,z0),new Vector3(x,top,z1),new Vector3(x,lower1,z1)});
    uv.AddRange(new[]{new Vector2(0,0),new Vector2(0,1),new Vector2(1,1),new Vector2(1,0)});t.AddRange(side>0?new[]{k,k+1,k+2,k,k+2,k+3}:new[]{k,k+2,k+1,k,k+3,k+2});
   }
   return MeshArt.Mesh(parent,name,v.ToArray(),t.ToArray(),uv.ToArray(),material);
  }
  public static GameObject RearPanel(Transform parent,string name,Vector3 at,Vector3 size,float radius,Material material)
  {
   const int corners=10,sides=corners*4;var v=new List<Vector3>();var uv=new List<Vector2>();var t=new List<int>();
   for(int ring=0;ring<3;ring++)for(int corner=0;corner<4;corner++)for(int n=0;n<corners;n++){
    float bevel=ring==1?0:.008f,a=(corner+n/(float)corners)*Mathf.PI*.5f,rx=size.x*.5f-bevel,ry=size.y*.5f-bevel;
    float cx=(corner==0||corner==3?1:-1)*(rx-radius),cy=(corner<2?1:-1)*(ry-radius);
    float x=cx+Mathf.Cos(a)*radius,y=cy+Mathf.Sin(a)*radius,z=ring==0?size.z*.5f:ring==1?0:-size.z*.5f;
    v.Add(new Vector3(x,y,z));uv.Add(new Vector2(x/size.x+.5f,y/size.y+.5f));
   }
   for(int ring=1;ring<3;ring++)for(int i=0;i<sides;i++){int a=(ring-1)*sides+i,b=(ring-1)*sides+(i+1)%sides,c=ring*sides+i,d=ring*sides+(i+1)%sides;t.AddRange(new[]{a,c,b,b,c,d});}
   foreach(int end in new[]{0,2}){int center=v.Count;v.Add(new Vector3(0,0,end==0?size.z*.5f:-size.z*.5f));uv.Add(new Vector2(.5f,.5f));for(int i=0;i<sides;i++){int a=end*sides+i,b=end*sides+(i+1)%sides;t.AddRange(end==0?new[]{center,a,b}:new[]{center,b,a});}}
   var go=MeshArt.Mesh(parent,name,v.ToArray(),t.ToArray(),uv.ToArray(),material);go.transform.localPosition=at;return go;
  }
  public static GameObject Bumper(Transform parent,string name,Vector3 at,Material material)
  {
   float[] x={-1.085f,-1.07f,-1.03f,-.96f,-.72f,0,.72f,.96f,1.03f,1.07f,1.085f};
   float depth=name=="Front bumper"?.09f:.12f;
   const int sides=20;var v=new List<Vector3>();var uv=new List<Vector2>();var t=new List<int>();
   for(int ring=0;ring<x.Length;ring++)for(int i=0;i<sides;i++){
    float a=i*Mathf.PI*2/sides,c=Mathf.Cos(a),s=Mathf.Sin(a),roll=Mathf.SmoothStep(0,1,(1.085f-Mathf.Abs(x[ring]))/.125f);
    v.Add(new Vector3(x[ring],Mathf.Sign(c)*Mathf.Pow(Mathf.Abs(c),.55f)*Mathf.Lerp(.043f,.11f,roll),Mathf.Sign(s)*Mathf.Pow(Mathf.Abs(s),.55f)*Mathf.Lerp(depth*.29f,depth,roll)));uv.Add(new Vector2(ring/(float)(x.Length-1),i/(float)sides));
   }
   for(int ring=1;ring<x.Length;ring++)for(int i=0;i<sides;i++){int a=(ring-1)*sides+i,b=ring*sides+i,next=(i+1)%sides;t.AddRange(new[]{a,(ring-1)*sides+next,b,(ring-1)*sides+next,ring*sides+next,b});}
   foreach(int end in new[]{0,x.Length-1}){int center=v.Count;v.Add(new Vector3(x[end],0,0));uv.Add(new(.5f,.5f));for(int i=0;i<sides;i++){int a=end*sides+i,b=end*sides+(i+1)%sides;t.AddRange(end==0?new[]{center,b,a}:new[]{center,a,b});}}
   var go=MeshArt.Mesh(parent,name,v.ToArray(),t.ToArray(),uv.ToArray(),material);go.transform.localPosition=at;return go;
  }
  public static GameObject WheelArch(Transform parent,int side,float axle,Material material)
  {
   const int segments=28;var v=new List<Vector3>();var t=new List<int>();
   for(int ring=0;ring<=segments;ring++){float a=ring*Mathf.PI/segments;foreach(var section in new[]{new Vector2(1.073f,.540f),new Vector2(1.132f,.540f),new Vector2(1.132f,.595f),new Vector2(1.073f,.595f)})v.Add(new Vector3(side*section.x,.40f+Mathf.Sin(a)*section.y,axle+Mathf.Cos(a)*section.y));}
   for(int ring=0;ring<segments;ring++)for(int p=0;p<4;p++){int a=ring*4+p,b=(ring+1)*4+p,c=ring*4+(p+1)%4,d=(ring+1)*4+(p+1)%4;t.AddRange(new[]{a,b,c,c,b,d});}
   foreach(int end in new[]{0,segments}){int center=v.Count;Vector3 point=Vector3.zero;for(int p=0;p<4;p++)point+=v[end*4+p];v.Add(point*.25f);for(int p=0;p<4;p++){int a=end*4+p,b=end*4+(p+1)%4;t.AddRange(end==0?new[]{center,a,b}:new[]{center,b,a});}}
   if(side<0)for(int i=0;i<t.Count;i+=3){int swap=t[i+1];t[i+1]=t[i+2];t[i+2]=swap;}
   return MeshArt.Mesh(parent,"Raised wheel arch trim",v.ToArray(),t.ToArray(),null,material);
  }
 }
}
