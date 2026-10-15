using System.Collections.Generic;
using UnityEngine;

namespace Kamilunavo.RepairEmpire.Visuals
{
 // Original solid civic architecture, beyond the legal driving envelope.
 // All meshes/materials belong to the existing district; no physics or RNG.
 public static class DistrictCivicHall
 {
  static GameObject Box(Transform p,string name,Vector3 at,Vector3 size,Material mat,bool rounded=false)=>rounded?MeshArt.BevelBox(p,name,at,size,.045f,mat):MeshArt.Box(p,name,at,size,mat);
  static Vector2[] Outline(float width,float height,int segments)
  {
   float r=width*.5f,arc=height*.5f-r;var v=new List<Vector2>{new(r,-height*.5f)};
   for(int i=0;i<=segments;i++){float a=i*Mathf.PI/segments;v.Add(new Vector2(Mathf.Cos(a)*r,arc+Mathf.Sin(a)*r));}v.Add(new Vector2(-r,-height*.5f));return v.ToArray();
  }
  static void ArchedWindow(Transform p,Vector3 at,float width,float height,UrbanArtKit kit)
  {
   const int segments=16;const float rim=.14f,depth=.22f;var outer=Outline(width,height,segments);var inner=Outline(width-rim*2,height-rim*2,segments);int n=outer.Length;var v=new List<Vector3>();var uv=new List<Vector2>();var t=new List<int>();
   for(int ring=0;ring<4;ring++)for(int i=0;i<n;i++){var point=ring%2==0?outer[i]:inner[i];v.Add(new Vector3(point.x,point.y,ring<2?-depth*.5f:depth*.5f));uv.Add(new Vector2(point.x,point.y));}
   for(int i=0;i<n;i++)
   {
    int next=(i+1)%n,o=i,on=next,inside=n+i,insideNext=n+next,back=2*n+i,backNext=2*n+next,backInside=3*n+i,backInsideNext=3*n+next;
    t.AddRange(new[]{o,inside,on,on,inside,insideNext,back,backNext,backInside,backNext,backInsideNext,backInside,o,on,back,on,backNext,back,inside,backInside,insideNext,insideNext,backInside,backInsideNext});
   }
   var border=MeshArt.Mesh(p,"Carved civic arch",v.ToArray(),t.ToArray(),uv.ToArray(),kit.Trim);border.transform.localPosition=at;
   var outline=Outline(width-rim*2,height-rim*2,segments);v.Clear();uv.Clear();t.Clear();
   for(int side=0;side<2;side++)foreach(var point in outline){v.Add(new Vector3(point.x,point.y,side==0?-.035f:.035f));uv.Add(new Vector2(point.x/width+.5f,point.y/height+.5f));}
   int front=v.Count;v.Add(new Vector3(0,0,-.035f));uv.Add(Vector2.one*.5f);int rear=v.Count;v.Add(new Vector3(0,0,.035f));uv.Add(Vector2.one*.5f);
   for(int i=0;i<n;i++){int next=(i+1)%n;t.AddRange(new[]{front,next,i,rear,n+i,n+next,i,next,n+i,next,n+next,n+i});}
   var glazing=MeshArt.Mesh(p,"Arched civic glazing",v.ToArray(),t.ToArray(),uv.ToArray(),kit.Glass);glazing.transform.localPosition=at+Vector3.forward*.14f;
   Box(p,"Civic vertical window mullion",at+new Vector3(0,-rim*.3f,-.012f),new(.045f,height-rim*2,.05f),kit.Metal);
   Box(p,"Civic window transom",at+new Vector3(0,-height*.12f,-.016f),new(width-rim*2,.045f,.055f),kit.Metal);
   Box(p,"Civic projecting stone sill",at+new Vector3(0,-height*.5f-.06f,-.09f),new(width+.26f,.16f,.46f),kit.Trim,true);
  }
  static void Mansard(Transform p,Vector3 at,float width,float depth,UrbanArtKit kit)
  {
   float[] y={0,.25f,2.15f,2.9f,3.02f},scale={1,1,.70f,.58f,.58f};var v=new List<Vector3>();var t=new List<int>();var uv=new List<Vector2>();
   for(int ring=0;ring<y.Length;ring++)foreach(var corner in new[]{new Vector2(-1,-1),new Vector2(-1,1),new Vector2(1,1),new Vector2(1,-1)}){v.Add(new Vector3(corner.x*width*.5f*scale[ring],y[ring],corner.y*depth*.5f*scale[ring]));uv.Add(new Vector2(corner.x,corner.y));}
   for(int ring=1;ring<y.Length;ring++)for(int i=0;i<4;i++){int next=(i+1)%4,a=(ring-1)*4+i,b=(ring-1)*4+next,c=ring*4+i,d=ring*4+next;t.AddRange(new[]{a,b,c,b,d,c});}t.AddRange(new[]{0,2,1,0,3,2,16,17,18,16,18,19});
   var roof=MeshArt.Mesh(p,"Civic sculpted mansard roof",v.ToArray(),t.ToArray(),uv.ToArray(),kit.Roof);roof.transform.localPosition=at;
   Box(p,"Mansard stone eave",at,new(width+.36f,.24f,depth+.36f),kit.Trim);
  }
  public static Transform Build(Transform parent,UrbanArtKit kit)
  {
   var root=new GameObject("Original Riverside civic hall").transform;root.SetParent(parent,false);root.localPosition=new Vector3(0,-.05f,480);
   // Ground continues from the existing475m edge, without coplanar overlap.
   // The hall remains beyond the465m recovery boundary; decorative only.
   Box(root,"Civic distant paved square",new(0,-.12f,10),new(64,.24f,30),kit.Trim);
   Box(root,"Civic broad stone plinth",new(0,.32f,-.1f),new(31.8f,.64f,12),kit.Trim,true);
   Box(root,"Civic central clock shaft",new(0,13.5f,0),new(8.8f,27,10.4f),kit.Plaster,true);
   foreach(int side in new[]{-1,1})
   {
    float x=side*9.4f;Box(root,"Civic symmetrical masonry wing",new(x,8.4f,.1f),new(10.8f,16.8f,9.6f),kit.Plaster,true);
    foreach(float y in new[]{.8f,5.8f,10.5f,15.8f,16.4f})Box(root,"Civic continuous stone cornice",new(x,y,.1f),new(11.1f,.22f,9.9f),kit.Trim);
    foreach(int edge in new[]{-1,1})
    {
     float column=x+edge*5.06f;Box(root,"Civic carved wing pilaster",new(column,8.6f,-4.83f),new(.36f,15.8f,.30f),kit.Trim);
     foreach(float y in new[]{1f,15.8f})Box(root,"Civic pilaster capital",new(column,y,-4.88f),new(.62f,.33f,.48f),kit.Trim,true);
    }
    for(int floor=0;floor<3;floor++)for(int column=0;column<3;column++)ArchedWindow(root,new(x+(column-1)*2.65f,3.1f+floor*4.6f,-4.84f),1.55f,2.25f,kit);
    Mansard(root,new(x,16.85f,.1f),11.25f,10.05f,kit);
    foreach(int dormer in new[]{-1,1})
    {
     float xx=x+dormer*2.65f;Box(root,"Civic stone dormer",new(xx,18.12f,-4.23f),new(1.85f,1.85f,.70f),kit.Trim,true);ArchedWindow(root,new(xx,18.13f,-4.72f),1.32f,1.54f,kit);Box(root,"Dormer slate hood",new(xx,19.12f,-4.20f),new(2.05f,.18f,.95f),kit.Roof,true);
    }
   }
   foreach(int side in new[]{-1,1})
   {
    Box(root,"Civic tower buttress",new(side*4.15f,13.45f,-5.18f),new(.50f,26.0f,.48f),kit.Trim);
    for(int block=0;block<8;block++)Box(root,"Civic tower carved block",new(side*4.15f,1.5f+block*3.35f,-5.24f),new(.65f,.23f,.62f),kit.Trim);
   }
   foreach(float y in new[]{7.4f,18.3f,26.35f})Box(root,"Civic tower string course",new(0,y,0),new(9.25f,.25f,10.8f),kit.Trim);
   ArchedWindow(root,new(0,3.6f,-5.35f),4.3f,5.4f,kit);foreach(float y in new[]{12.1f,21.7f})ArchedWindow(root,new(0,y,-5.34f),2.55f,4.35f,kit);
   foreach(int step in new[]{0,1,2})Box(root,"Civic entrance stone step",new(0,.14f+step*.17f,-6.9f+step*.38f),new(6.6f-step*.3f,.28f,1.40f),kit.Trim,true);
   DistrictLandmarkArt.ClockTower(root,kit,Vector3.zero,26.5f,true);
   return root;
  }
 }
}
