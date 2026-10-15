using UnityEngine;
namespace Kamilunavo.RepairEmpire.Visuals
{
 public static class StreetLampArt
 {
  public static void Build(Transform root,Material metal,Material housing,Material lens)
  {
   MeshArt.Lathe(root,"Lamp pole",new[]{0f,.18f,4.2f,4.4f,4.4f},new[]{.16f,.11f,.075f,.065f,0f},12,metal,Vector3.one);
   var path=new Vector3[13];Vector3 p0=new(0,4.28f,0),p1=new(0,5.05f,0),p2=new(.82f,5.25f,0),p3=new(1.35f,4.96f,0);
   for(int i=0;i<path.Length;i++){float t=(float)i/(path.Length-1),q=1-t;path[i]=q*q*q*p0+3*q*q*t*p1+3*q*t*t*p2+t*t*t*p3;}
   MeshArt.Tube(root,"Curved street lamp arm",path,.045f,metal,10);
   var head=MeshArt.Lathe(root,"Lamp housing",new[]{0f,.025f,.11f,.15f,.15f},new[]{0f,.34f,.33f,.25f,0f},20,housing,new Vector3(1,1,.60f));head.transform.localPosition=new Vector3(1.35f,4.84f,0);
   MeshArt.Oval(root,"Recessed street lamp lens",new Vector3(1.35f,4.835f,0),new Vector3(.55f,.025f,.30f),lens,16);
  }
 }
}
