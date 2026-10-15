using System.Collections.Generic;
using UnityEngine;

namespace Kamilunavo.RepairEmpire.Visuals
{
 // Original compact road car for the authored parking pockets. Shared district
 // finishes and owned meshes keep it independent of the player's van state.
 public static class ParkedVehicleArt
 {
  static readonly float[] BodyZ={-2.15f,-2.05f,-1.70f,-1.25f,-.50f,.65f,1.26f,1.77f,2.04f,2.12f};
  static readonly float[] BodyW={.62f,.77f,.84f,.85f,.85f,.84f,.83f,.81f,.73f,.58f};
  static readonly float[] BodyH={.56f,.68f,.78f,.80f,.80f,.80f,.77f,.72f,.61f,.49f};
  static readonly float[] CabZ={-1.48f,-1.18f,-.80f,-.35f,.25f,.55f,.95f,1.08f};
  static readonly float[] CabW={.69f,.74f,.75f,.75f,.74f,.72f,.68f,.62f};
  static readonly float[] CabH={.83f,1.17f,1.42f,1.48f,1.46f,1.32f,.91f,.83f};
  static float Sample(float at,float[] z,float[] values)
  {
   if(at<=z[0])return values[0];for(int i=1;i<z.Length;i++)if(at<=z[i])
   {
    int before=Mathf.Max(0,i-2),after=Mathf.Min(z.Length-1,i+1);float d=z[i]-z[i-1],t=(at-z[i-1])/d,t2=t*t,t3=t2*t;
    float a=(values[i]-values[before])/(z[i]-z[before]),b=(values[after]-values[i-1])/(z[after]-z[i-1]);
    return Mathf.Clamp((2*t3-3*t2+1)*values[i-1]+(t3-2*t2+t)*d*a+(-2*t3+3*t2)*values[i]+(t3-t2)*d*b,Mathf.Min(values[i-1],values[i]),Mathf.Max(values[i-1],values[i]));
   }
   return values[values.Length-1];
  }
  static void Loft(Transform root,string name,float[] z,float[] widths,float[] heights,float bottom,Material material,bool arches)
  {
   var rings=new List<float>(z);void Add(float at){if(at>z[0]&&at<z[z.Length-1]&&!rings.Exists(v=>Mathf.Abs(v-at)<.002f))rings.Add(at);}
   for(int i=0;i<=24;i++)Add(Mathf.Lerp(z[0],z[z.Length-1],i/24f));if(arches)foreach(float axle in new[]{-1.25f,1.26f})for(int i=0;i<=12;i++)Add(axle+Mathf.Cos(i*Mathf.PI/12)*.335f);rings.Sort();
   const int sides=24;var v=new List<Vector3>();var uv=new List<Vector2>();var t=new List<int>();
   foreach(float at in rings)for(int i=0;i<=sides;i++)
   {
    float a=i*Mathf.PI*2/sides,c=Mathf.Cos(a),s=-Mathf.Sin(a),width=Sample(at,z,widths),top=Sample(at,z,heights);
    const float power=.30f;float y=(top+bottom)*.5f+(top-bottom)*.5f*Mathf.Sign(s)*Mathf.Pow(Mathf.Abs(s),power),taper=arches?1:Mathf.Lerp(1,.80f,Mathf.Clamp01((y-bottom)/(top-bottom)));
    float x=width*Mathf.Sign(c)*Mathf.Pow(Mathf.Abs(c),power)*taper;
    if(arches&&Mathf.Abs(x)>.55f&&y<.75f)foreach(float axle in new[]{-1.25f,1.26f}){float dz=Mathf.Abs(at-axle);if(dz<.335f)y=Mathf.Max(y,.29f+Mathf.Sqrt(.335f*.335f-dz*dz));}
    v.Add(new Vector3(x,y,at));uv.Add(new Vector2(i/(float)sides,at*.4f));
   }
   for(int ring=1;ring<rings.Count;ring++)for(int i=0;i<sides;i++){int a=(ring-1)*(sides+1)+i,b=a+sides+1;t.AddRange(new[]{a,b,a+1,a+1,b,b+1});}
   foreach(int end in new[]{0,rings.Count-1}){int pole=v.Count;float at=rings[end];v.Add(new Vector3(0,(Sample(at,z,heights)+bottom)*.5f,at));uv.Add(Vector2.one*.5f);for(int i=0;i<sides;i++){int a=end*(sides+1)+i;t.AddRange(end==0?new[]{a,a+1,pole}:new[]{a,pole,a+1});}}
   MeshArt.Mesh(root,name,v.ToArray(),t.ToArray(),uv.ToArray(),material);
  }
  static Vector3 Roof(float x,float z,float offset=0)
  {
   float w=Sample(z,CabZ,CabW),top=Sample(z,CabZ,CabH),low=0,high=Mathf.PI*.5f;
   for(int i=0;i<18;i++){float a=(low+high)*.5f,y=(top+.81f)*.5f+(top-.81f)*.5f*Mathf.Pow(Mathf.Sin(a),.30f),at=w*Mathf.Pow(Mathf.Cos(a),.30f)*Mathf.Lerp(1,.80f,(y-.81f)/(top-.81f));if(at>Mathf.Abs(x))low=a;else high=a;}
   return new Vector3(x,(top+.81f)*.5f+(top-.81f)*.5f*Mathf.Pow(Mathf.Sin((low+high)*.5f),.30f)+offset,z);
  }
  static float CabSide(float y,float z)
  {
   float top=Sample(z,CabZ,CabH),q=Mathf.Clamp01(Mathf.Abs((y-(top+.81f)*.5f)/((top-.81f)*.5f)));
   return Sample(z,CabZ,CabW)*Mathf.Pow(1-Mathf.Pow(q,2/.30f),.30f*.5f)*Mathf.Lerp(1,.80f,Mathf.Clamp01((y-.81f)/(top-.81f)));
  }
  public static void Build(Transform root,Material paint,Material glass,Material plastic,Material rubber,Material steel,Material frontLight,Material tailLight)
  {
   Loft(root,"Sculpted passenger body",BodyZ,BodyW,BodyH,.24f,paint,true);Loft(root,"Curved passenger glazing",CabZ,CabW,CabH,.81f,glass,false);
   MeshArt.BevelBox(root,"Passenger window beltline",new(0,.79f,-.18f),new(1.54f,.08f,2.56f),.035f,paint);
   // A fitted painted roof cap leaves front/rear glazing and shoulder windows.
   var v=new List<Vector3>();var t=new List<int>();var uv=new List<Vector2>();
   for(int z=0;z<=8;z++)for(int x=0;x<=8;x++){v.Add(Roof(Mathf.Lerp(-.52f,.52f,x/8f),Mathf.Lerp(-.78f,.31f,z/8f),.008f));uv.Add(new Vector2(x/8f,z/8f));if(z<8&&x<8){int a=z*9+x;t.AddRange(new[]{a,a+9,a+1,a+1,a+9,a+10});}}
   MeshArt.Mesh(root,"Rounded painted passenger roof",v.ToArray(),t.ToArray(),uv.ToArray(),paint);
   foreach(int side in new[]{-1,1})
   {
    foreach(float z in new[]{-.17f,-1.10f}){var path=new Vector3[9];float top=Roof(side*.59f,z).y;for(int i=0;i<path.Length;i++){float y=Mathf.Lerp(.84f,top,i/8f);path[i]=new Vector3(side*(CabSide(y,z)+.008f),y,z);}MeshArt.Tube(root,"Fitted passenger door pillar",path,.024f,plastic,6);}
    foreach(float axle in new[]{-1.25f,1.26f})
    {
     var wheel=new GameObject("Parked road wheel").transform;wheel.SetParent(root,false);wheel.localPosition=new Vector3(side*.79f,.29f,axle);wheel.localRotation=Quaternion.Euler(0,0,90);
     MeshArt.Lathe(wheel,"Rounded passenger tire",new[]{-.065f,-.085f,-.062f,0,.062f,.085f,.065f},new[]{.19f,.245f,.294f,.30f,.294f,.245f,.19f},20,rubber,Vector3.one);
     var face=MeshArt.Lathe(wheel,"Passenger alloy wheel",new[]{0f,.003f,.009f},new[]{.197f,.185f,0f},20,steel,Vector3.one);face.transform.localPosition=new Vector3(0,-side*.087f,0);face.transform.localRotation=side>0?Quaternion.Euler(180,0,0):Quaternion.identity;
     for(int spoke=0;spoke<5;spoke++){float a=spoke*Mathf.PI*2/5;var slot=MeshArt.Box(wheel,"Dark wheel spoke slot",new Vector3(Mathf.Cos(a)*.13f,-side*.098f,Mathf.Sin(a)*.13f),new Vector3(.013f,.002f,.085f),plastic);slot.transform.localRotation=Quaternion.Euler(0,90-spoke*72,0);}
    }
    foreach(float z in new[]{.38f,-.74f})MeshArt.Box(root,"Passenger door handle",new(side*.854f,.755f,z),new(.014f,.021f,.13f),steel);
    var seam=new[]{new Vector3(side*.858f,.28f,-.17f),new Vector3(side*.858f,.76f,-.17f)};MeshArt.Tube(root,"Passenger door shut line",seam,.003f,plastic,4);
    MeshArt.BevelBox(root,"Passenger mirror",new(side*.86f,.98f,.62f),new(.18f,.12f,.20f),.035f,paint);
    MeshArt.BevelBox(root,"Passenger headlamp",new(side*.53f,.606f,1.997f),new(.31f,.105f,.055f),.025f,frontLight);
    MeshArt.BevelBox(root,"Passenger tail lamp",new(side*.61f,.60f,-2.09f),new(.24f,.12f,.045f),.025f,tailLight);
   }
   MeshArt.BevelBox(root,"Passenger front intake",new(0,.43f,2.116f),new(.82f,.18f,.04f),.04f,plastic);
   MeshArt.BevelBox(root,"Passenger front bumper",new(0,.29f,2.09f),new(1.35f,.10f,.12f),.04f,plastic);
   MeshArt.BevelBox(root,"Passenger rear bumper",new(0,.29f,-2.13f),new(1.48f,.10f,.10f),.04f,plastic);
   MeshArt.Box(root,"Passenger registration plate",new(0,.50f,-2.164f),new(.38f,.09f,.012f),frontLight);
  }
 }
}
