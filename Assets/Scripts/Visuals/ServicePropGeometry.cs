using System.Collections.Generic;
using UnityEngine;

namespace Kamilunavo.RepairEmpire.Visuals
{
 public static class ServicePropGeometry
 {
  // A closed, softly folded original cloth mesh; the weave is an imported albedo.
  public static void Cloth(Transform parent,Vector3 position)
  {
   const int columns=16,rows=12;var vertices=new List<Vector3>();var triangles=new List<int>();var uv=new List<Vector2>();
   int stride=columns+1,layer=(columns+1)*(rows+1);
   for(int side=0;side<2;side++)for(int row=0;row<=rows;row++)for(int col=0;col<=columns;col++)
   {
    float u=col/(float)columns,v=row/(float)rows;float envelope=Mathf.Sin(u*Mathf.PI)*Mathf.Sin(v*Mathf.PI);
    float y=side==0?.038f+.009f*Mathf.Sin(v*12+u*3)*envelope+.009f*envelope:.006f;
    vertices.Add(new Vector3((u-.5f)*.33f,y,(v-.5f)*.30f));uv.Add(new Vector2(u,v));
    if(row<rows&&col<columns){int a=side*layer+row*stride+col;if(side==0)triangles.AddRange(new[]{a,a+stride,a+1,a+1,a+stride,a+stride+1});else triangles.AddRange(new[]{a,a+1,a+stride,a+1,a+stride+1,a+stride});}
   }
   for(int col=0;col<columns;col++){int a=col,b=rows*stride+col;triangles.AddRange(new[]{a,a+1,a+layer,a+1,a+layer+1,a+layer,b,b+layer,b+1,b+1,b+layer,b+layer+1});}
   for(int row=0;row<rows;row++){int a=row*stride,b=a+columns;triangles.AddRange(new[]{a,a+layer,a+stride,a+stride,a+layer,a+stride+layer,b,b+stride,b+layer,b+stride,b+stride+layer,b+layer});}
   var cloth=MeshArt.Mesh(parent,"Folded service cloth",vertices.ToArray(),triangles.ToArray(),uv.ToArray(),FixtureMaterials.Get(parent,FixtureFinish.Cloth));cloth.transform.localPosition=position;cloth.transform.localRotation=Quaternion.Euler(0,-12,0);
  }
  public static void VanityAccents(Transform parent,float counterY)
  {
   var stone=FixtureMaterials.Get(parent,FixtureFinish.Stone);var green=FixtureMaterials.Get(parent,FixtureFinish.Green);var ceramic=FixtureMaterials.Get(parent,FixtureFinish.Ceramic);
   var plant=new GameObject("Original vanity plant").transform;plant.SetParent(parent,false);plant.localPosition=new Vector3(-.86f,counterY+.0005f,.34f);
   MeshArt.Lathe(plant,"Stoneware plant pot",new[]{0f,0f,.015f,.15f,.17f,.17f,.04f,.04f},new[]{0f,.075f,.08f,.095f,.098f,.086f,.065f,0f},24,ceramic,Vector3.one);
   MeshArt.Lathe(plant,"Houseplant soil",new[]{.145f,.145f},new[]{.081f,0f},24,FixtureMaterials.Get(parent,FixtureFinish.Dirt),Vector3.one);
   for(int leaf=0;leaf<7;leaf++)
   {
    float angle=leaf*2.39996f;var tip=new Vector3(Mathf.Cos(angle)*.14f,.24f+(leaf%3)*.045f,Mathf.Sin(angle)*.14f);var side=new Vector3(-Mathf.Sin(angle),0,Mathf.Cos(angle))*.042f;var stem=new Vector3(0,.13f,0);var middle=Vector3.Lerp(stem,tip,.58f);
    var v=new[]{stem,middle-side,tip,middle+side,middle+Vector3.up*.018f};MeshArt.Mesh(plant,"Modeled houseplant leaf",v,new[]{0,1,4,1,2,4,2,3,4,3,0,4,0,4,1,1,4,2,2,4,3,3,4,0},null,green);
   }
   // The tray sits on the counter, clear of the physical basin opening.
   MeshArt.BevelBox(parent,"Stone soap tray",new Vector3(.83f,counterY+.0125f+.0005f,.34f),new Vector3(.24f,.025f,.24f),.018f,stone);
  }
  public static void SoapPump(Transform parent,float counterY)
  {
   var ceramic=FixtureMaterials.Get(parent,FixtureFinish.Ceramic);var metal=FixtureMaterials.Get(parent,FixtureFinish.Chrome);var dark=FixtureMaterials.Get(parent,FixtureFinish.Navy);float bottom=counterY+.026f;
   MeshArt.Lathe(parent,"Soap bottle",new[]{0f,0f,.018f,.20f,.27f,.30f,.32f,.32f},new[]{0f,.056f,.067f,.067f,.052f,.027f,.027f,0f},24,ceramic,Vector3.one).transform.localPosition=new Vector3(.83f,bottom,.34f);
   MeshArt.Lathe(parent,"Soap pump collar",new[]{0f,0f,.026f,.026f},new[]{0f,.035f,.035f,0f},24,metal,Vector3.one).transform.localPosition=new Vector3(.83f,bottom+.317f,.34f);
   MeshArt.Lathe(parent,"Soap pump stem",new[]{0f,0f,.041f,.041f},new[]{0f,.010f,.010f,0f},16,dark,Vector3.one).transform.localPosition=new Vector3(.83f,bottom+.342f,.34f);
   MeshArt.BevelBox(parent,"Soap dispenser",new Vector3(.83f,bottom+.384f,.30f),new Vector3(.12f,.025f,.12f),.009f,metal);
   MeshArt.Tube(parent,"Soap pump nozzle",new[]{new Vector3(.83f,bottom+.382f,.29f),new Vector3(.83f,bottom+.382f,.21f),new Vector3(.83f,bottom+.373f,.205f)},.009f,metal,12);
   MeshArt.BevelBox(parent,"Soap bottle embossed label",new Vector3(.83f,bottom+.145f,.2735f),new Vector3(.044f,.052f,.003f),.001f,dark);
  }
  // Four chamfered rings and closed caps form each original convex forging.
  static void Forging(Transform parent,string name,Vector2[] outline,Material metal,bool openSlot=false)
  {
   var vertices=new List<Vector3>();var triangles=new List<int>();var uv=new List<Vector2>();Vector2 center=Vector2.zero;foreach(var p in outline)center+=p;center/=outline.Length;int count=outline.Length;
   float[] y={0f,.006f,.059f,.065f},scale={.92f,1f,1f,.92f};
   if(openSlot)
   {
    // A real through-slot exposes the thumb worm. A filled forging would
    // bury the mechanism even though the screw existed in the hierarchy.
    center=new Vector2(-.01f,.205f);var half=new Vector2(.06f,.0325f);var angles=new List<float>();foreach(var p in outline)angles.Add(Mathf.Atan2(p.y-center.y,p.x-center.x));foreach(int x in new[]{-1,1})foreach(int z in new[]{-1,1})angles.Add(Mathf.Atan2(z*half.y,x*half.x));angles.Sort();count=angles.Count;
    float Cross(Vector2 a,Vector2 b)=>a.x*b.y-a.y*b.x;
    foreach(int ring in new[]{0,1,2,3,4,5,6,7})foreach(float angle in angles)
    {
     var direction=new Vector2(Mathf.Cos(angle),Mathf.Sin(angle));float outer=float.PositiveInfinity;
     for(int i=0;i<outline.Length;i++){var a=outline[i]-center;var edge=outline[(i+1)%outline.Length]-outline[i];float den=Cross(direction,edge);if(Mathf.Abs(den)<.000001f)continue;float distance=Cross(a,edge)/den,u=Cross(a,direction)/den;if(distance>0&&u>=-.00001f&&u<=1.00001f)outer=Mathf.Min(outer,distance);}
     var h=half+Vector2.one*(ring==4||ring==7?.004f:0);float inner=Mathf.Min(h.x/Mathf.Max(.00001f,Mathf.Abs(direction.x)),h.y/Mathf.Max(.00001f,Mathf.Abs(direction.y)));
     float distanceFromCenter=ring<4?outer*scale[ring]:inner;var at=center+direction*distanceFromCenter;float height=ring<4?y[ring]:y[7-ring];vertices.Add(new Vector3(at.x,height,at.y));uv.Add(at);
    }
    for(int ring=0;ring<8;ring++)for(int i=0;i<count;i++){int a=ring*count+i,b=ring*count+(i+1)%count,c=((ring+1)%8)*count+i,d=((ring+1)%8)*count+(i+1)%count;triangles.AddRange(new[]{a,b,c,b,d,c});}
   }
   else
   {
    for(int ring=0;ring<4;ring++)foreach(var p in outline){var at=Vector2.Lerp(center,p,scale[ring]);vertices.Add(new Vector3(at.x,y[ring],at.y));uv.Add(at);}
    for(int ring=0;ring<3;ring++)for(int i=0;i<count;i++){int a=ring*count+i,b=ring*count+(i+1)%count,c=a+count,d=b+count;triangles.AddRange(new[]{a,b,c,b,d,c});}
    int bottom=vertices.Count;vertices.Add(new Vector3(center.x,0,center.y));uv.Add(center);int top=vertices.Count;vertices.Add(new Vector3(center.x,.065f,center.y));uv.Add(center);
    for(int i=0;i<count;i++)triangles.AddRange(new[]{bottom,(i+1)%count,i,top,3*count+i,3*count+(i+1)%count});
   }
   double volume=0;for(int i=0;i<triangles.Count;i+=3)volume+=Vector3.Dot(vertices[triangles[i]],Vector3.Cross(vertices[triangles[i+1]],vertices[triangles[i+2]]))/6d;
   if(volume<0)for(int i=0;i<triangles.Count;i+=3){int swap=triangles[i+1];triangles[i+1]=triangles[i+2];triangles[i+2]=swap;}
   MeshArt.Mesh(parent,name,vertices.ToArray(),triangles.ToArray(),uv.ToArray(),metal);
  }
  public static void AdjustableWrench(Transform parent,Vector3 position)
  {
   var metal=FixtureMaterials.Get(parent,FixtureFinish.Chrome);var dark=FixtureMaterials.Get(parent,FixtureFinish.Navy);var orange=FixtureMaterials.Get(parent,FixtureFinish.Orange);var root=new GameObject("Service adjustable wrench").transform;root.SetParent(parent,false);root.localPosition=position;root.localRotation=Quaternion.Euler(0,-12,0);
   MeshArt.BevelBox(root,"Steel wrench shaft",new Vector3(0,.025f,-.05f),new Vector3(.07f,.05f,.415f),.020f,metal);
   MeshArt.BevelBox(root,"Orange wrench grip",new Vector3(0,.0325f,-.215f),new Vector3(.095f,.065f,.34f),.024f,orange);
   MeshArt.BevelBox(root,"Wrench rubber grip insert",new Vector3(0,.065f,-.215f),new Vector3(.062f,.005f,.25f),.002f,dark);
   for(int i=0;i<6;i++)MeshArt.BevelBox(root,"Wrench grip raised rib",new Vector3(0,.067f,-.31f+i*.038f),new Vector3(.067f,.005f,.006f),.002f,orange);
   Forging(root,"Forged adjustable wrench head",new[]{new Vector2(-.10f,.14f),new Vector2(-.13f,.23f),new Vector2(-.10f,.29f),new Vector2(.015f,.29f),new Vector2(.095f,.245f),new Vector2(.09f,.18f),new Vector2(.05f,.14f)},metal,true);
   Forging(root,"Adjustable wrench fixed jaw",new[]{new Vector2(-.13f,.235f),new Vector2(-.145f,.365f),new Vector2(-.097f,.379f),new Vector2(-.069f,.263f)},metal);
   Forging(root,"Sliding adjustable jaw",new[]{new Vector2(.025f,.225f),new Vector2(.054f,.345f),new Vector2(.099f,.337f),new Vector2(.091f,.206f)},metal);
   MeshArt.BevelBox(root,"Sliding jaw rack",new Vector3(.034f,.036f,.222f),new Vector3(.12f,.029f,.035f),.005f,dark);
   for(int i=0;i<6;i++)MeshArt.BevelBox(root,"Machined jaw rack tooth",new Vector3(-.013f+i*.018f,.052f,.224f),new Vector3(.010f,.008f,.025f),.002f,metal);
   var worm=MeshArt.Lathe(root,"Knurled adjustment worm",new[]{-.049f,-.049f,.049f,.049f},new[]{0f,.026f,.026f,0f},24,metal,Vector3.one);worm.transform.localRotation=Quaternion.Euler(0,0,90);worm.transform.localPosition=new Vector3(-.016f,.035f,.205f);
   var axle=MeshArt.Lathe(root,"Worm steel axle",new[]{-.083f,-.083f,.075f,.075f},new[]{0f,.010f,.010f,0f},16,metal,Vector3.one);axle.transform.localRotation=Quaternion.Euler(0,0,90);axle.transform.localPosition=new Vector3(-.01f,.035f,.205f);
   for(int i=0;i<7;i++){var groove=MeshArt.Lathe(root,"Worm machined thread",new[]{-.0015f,-.0015f,.0015f,.0015f,-.0015f},new[]{.025f,.027f,.027f,.025f,.025f},24,dark,Vector3.one);groove.transform.localRotation=Quaternion.Euler(0,0,90);groove.transform.localPosition=new Vector3(-.057f+i*.0135f,.035f,.205f);}
  }
 }
}
