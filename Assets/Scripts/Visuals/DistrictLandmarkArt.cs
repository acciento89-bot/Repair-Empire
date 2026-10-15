using System.Collections.Generic;
using UnityEngine;

namespace Kamilunavo.RepairEmpire.Visuals
{
 // Original architectural geometry uses the district's existing owned material kit.
 // It does not add physics or consume the building-height random sequence.
 public static class DistrictLandmarkArt
 {
  static GameObject Box(Transform p,string name,Vector3 at,Vector3 size,Material material,float bevel=.035f)=>MeshArt.BevelBox(p,name,at,size,bevel,material);
  public static void ClockTower(Transform parent,UrbanArtKit kit,Vector3 position,float baseHeight)
  {
   var root=new GameObject("Original Riverside clock tower").transform;root.SetParent(parent,false);root.localPosition=position;
   Box(root,"Clock tower roof plinth",new(0,baseHeight,0),new(7.2f,.60f,7.2f),kit.Trim);
   Box(root,"Clock tower upper masonry",new(0,baseHeight+3.2f,0),new(5.6f,6.1f,5.6f),kit.Plaster);
   foreach(int x in new[]{-1,1})foreach(int z in new[]{-1,1})Box(root,"Clock tower carved corner",new(x*2.85f,baseHeight+3.2f,z*2.85f),new(.34f,6.4f,.34f),kit.Trim);
   foreach(float y in new[]{.7f,1.0f,6.3f,6.7f})Box(root,"Clock tower cornice",new(0,baseHeight+y,0),new(6.1f,.20f,6.1f),kit.Trim);
   for(int side=0;side<4;side++)
   {
    var face=new GameObject("Clock dial elevation").transform;face.SetParent(root,false);face.localPosition=new(0,baseHeight+3.7f,0);face.localRotation=Quaternion.Euler(0,side*90,0);
    var rim=MeshArt.Lathe(face,"Clock carved stone surround",new[]{0f,.10f,.16f,.20f},new[]{0f,1.37f,1.37f,0f},48,kit.Trim,Vector3.one);rim.transform.localRotation=Quaternion.Euler(90,0,0);rim.transform.localPosition=new(0,0,2.85f);
    var dial=MeshArt.Lathe(face,"Dark clock dial",new[]{0f,.025f,.035f,.035f},new[]{0f,1.16f,1.16f,0f},48,kit.Roof,Vector3.one);dial.transform.localRotation=Quaternion.Euler(90,0,0);dial.transform.localPosition=new(0,0,3.06f);
    for(int tick=0;tick<12;tick++){float a=tick*Mathf.PI/6;var mark=Box(face,"Clock hour mark",new(Mathf.Sin(a)*.94f,Mathf.Cos(a)*.94f,3.12f),new(.055f,.18f,.025f),kit.Trim,.01f);mark.transform.localRotation=Quaternion.Euler(0,0,-tick*30);}
    var hour=Box(face,"Clock hour hand",new(.20f,.14f,3.15f),new(.09f,.62f,.035f),kit.Trim,.015f);hour.transform.localRotation=Quaternion.Euler(0,0,-55);
    var minute=Box(face,"Clock minute hand",new(-.12f,.36f,3.17f),new(.055f,.91f,.035f),kit.Trim,.01f);minute.transform.localRotation=Quaternion.Euler(0,0,18);
   }
   var roof=MeshArt.Lathe(root,"Clock tower slate cupola",new[]{0f,.18f,1.35f,2.40f,2.7f},new[]{4.5f,4.5f,3.15f,1.2f,0f},4,kit.Roof,Vector3.one);roof.transform.localPosition=new(0,baseHeight+6.9f,0);roof.transform.localRotation=Quaternion.Euler(0,45,0);
   MeshArt.Tube(root,"Clock tower finial",new[]{new Vector3(0,baseHeight+9.3f,0),new Vector3(0,baseHeight+11.8f,0)},.055f,kit.Metal,12);
   MeshArt.Oval(root,"Clock tower finial globe",new(0,baseHeight+10.1f,0),new(.32f,.32f,.32f),kit.Trim,16);
  }
  public static void AvenueBridge(Transform parent,UrbanArtKit kit)
  {
   var root=new GameObject("Original Riverside stone arch bridge").transform;root.SetParent(parent,false);root.localPosition=new(0,0,310);
   const int segments=32;var vertices=new List<Vector3>();var triangles=new List<int>();var uv=new List<Vector2>();
   for(int i=0;i<=segments;i++)
   {
    float x=-18+36f*i/segments,under=8+4*Mathf.Sqrt(Mathf.Max(0,1-(x/18)*(x/18)));
    vertices.AddRange(new[]{new Vector3(x,under,-1.8f),new Vector3(x,14,-1.8f),new Vector3(x,under,1.8f),new Vector3(x,14,1.8f)});uv.AddRange(new[]{new Vector2(x*.25f,under*.25f),new Vector2(x*.25f,3.5f),new Vector2(x*.25f,under*.25f),new Vector2(x*.25f,3.5f)});
    if(i>0){int a=(i-1)*4,b=i*4;triangles.AddRange(new[]{a,a+1,b,a+1,b+1,b,a+2,b+2,a+3,a+3,b+2,b+3,a,b,a+2,a+2,b,b+2,a+1,a+3,b+1,a+3,b+3,b+1});}
   }
   triangles.AddRange(new[]{0,2,1,1,2,3,segments*4,segments*4+1,segments*4+2,segments*4+1,segments*4+3,segments*4+2});
   MeshArt.Mesh(root,"Continuous stone arch span",vertices.ToArray(),triangles.ToArray(),uv.ToArray(),kit.Trim);
   foreach(int side in new[]{-1,1})
   {
    Box(root,"Bridge upper stone coping",new(0,14.12f,side*1.88f),new(37,.24f,.30f),kit.Trim);
    Box(root,"Bridge metal top rail",new(0,15.10f,side*1.88f),new(36,.07f,.07f),kit.Metal);
    for(int post=0;post<=30;post++)Box(root,"Bridge slender baluster",new(-18+post*1.2f,14.60f,side*1.88f),new(.055f,1.03f,.055f),kit.Metal,.01f);
    Box(root,"Bridge masonry pier",new(side*17.6f,4,0),new(1.5f,8,3.6f),kit.Plaster);
   }
  }
 }
}
