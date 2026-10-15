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
  public static void VanityAccents(Transform parent)
  {
   var stone=FixtureMaterials.Get(parent,FixtureFinish.Stone);var green=FixtureMaterials.Get(parent,FixtureFinish.Green);var ceramic=FixtureMaterials.Get(parent,FixtureFinish.Ceramic);
   var plant=new GameObject("Original vanity plant").transform;plant.SetParent(parent,false);plant.localPosition=new Vector3(-.86f,.01f,.34f);
   MeshArt.Lathe(plant,"Stoneware plant pot",new[]{0f,.015f,.15f,.17f},new[]{.075f,.08f,.095f,.098f},24,ceramic,Vector3.one);
   for(int leaf=0;leaf<7;leaf++)
   {
    float angle=leaf*2.39996f;var tip=new Vector3(Mathf.Cos(angle)*.14f,.24f+(leaf%3)*.045f,Mathf.Sin(angle)*.14f);var side=new Vector3(-Mathf.Sin(angle),0,Mathf.Cos(angle))*.042f;var stem=new Vector3(0,.13f,0);var middle=Vector3.Lerp(stem,tip,.58f);
    var v=new[]{stem,middle-side,tip,middle+side,middle+Vector3.up*.018f};MeshArt.Mesh(plant,"Modeled houseplant leaf",v,new[]{0,1,4,1,2,4,2,3,4,3,0,4,0,4,1,1,4,2,2,4,3,3,4,0},null,green);
   }
   // The tray sits on the counter, clear of the physical basin opening.
   MeshArt.BevelBox(parent,"Stone soap tray",new Vector3(.83f,.008f,.34f),new Vector3(.24f,.025f,.24f),.018f,stone);
  }
 }
}
