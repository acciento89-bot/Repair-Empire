using UnityEngine;
using UnityEngine.UI;
namespace Kamilunavo.RepairEmpire.UI
{
 // Item previews are UI geometry only: they never equip a tool, paint the live van or write a profile.
 public sealed class ServiceItemGlyph:MaskableGraphic
 {
  public string Item="Tool0";
  VertexHelper mesh;Vector2 origin;float scale;
  static readonly Color Navy=new(.025f,.065f,.11f),Steel=new(.47f,.60f,.66f),Orange=new(1,.34f,.055f),Light=new(.92f,.96f,.98f);
  public static Color Paint(int index)=>new[]{new Color(.95f,.95f,.89f),new Color(.08f,.47f,.66f),new Color(.18f,.43f,.30f),new Color(.69f,.08f,.19f),new Color(.77f,.38f,.18f),new Color(.10f,.80f,.61f),new Color(.81f,.84f,.90f),new Color(.93f,.39f,.13f)}[Mathf.Clamp(index,0,7)];
  protected override void OnPopulateMesh(VertexHelper vh){vh.Clear();mesh=vh;var rect=rectTransform.rect;scale=Mathf.Min(rect.width/100,rect.height/80);origin=new Vector2(rect.xMin+(rect.width-100*scale)/2,rect.yMin+(rect.height-80*scale)/2);
   if(Item.StartsWith("Paint")){int.TryParse(Item.Substring(5),out int paint);Van(4,16,.91f,Paint(paint));return;}
   if(Item.StartsWith("Vehicle")){int.TryParse(Item.Substring(7),out int van);Van(4,16,.91f,van==2?new Color(.1f,.6f,.53f):van==1?Steel:Paint(0));if(van==1)Rect(14,64,48,5,Steel);if(van==2)Poly(Orange,new(46,66),new(40,51),new(48,51),new(42,38),new(59,56),new(49,56));return;}
   switch(Item){case "Tool0":Wrench();break;case "Tool1":Tester();break;case "Tool2":Kit();break;case "Screwdriver":Driver(24,9,1);break;case "FleetShortcut":Van(2,30,.80f,Steel);Van(20,5,.80f,Light);break;case "Workshop":Building(false);break;case "Headquarters":Building(true);break;case "Employees":People();break;case "Daily":case "DailyJobs":Calendar();break;case "Purchase0":case "Purchase1":Van(4,16,.91f,Paint(Item=="Purchase0"?4:5));break;default:Gear();break;}
  }
  Vector2 P(Vector2 point)=>origin+point*scale;
  void Poly(Color color,params Vector2[] points){int start=mesh.currentVertCount;foreach(var point in points)mesh.AddVert(P(point),color,Vector2.zero);for(int i=1;i<points.Length-1;i++)mesh.AddTriangle(start,start+i,start+i+1);}
  void Rect(float x,float y,float w,float h,Color color)=>Poly(color,new(x,y),new(x+w,y),new(x+w,y+h),new(x,y+h));
  void Circle(float x,float y,float radius,Color color){int start=mesh.currentVertCount;mesh.AddVert(P(new(x,y)),color,Vector2.zero);for(int i=0;i<=20;i++){float a=i*Mathf.PI/10;mesh.AddVert(P(new(x+Mathf.Cos(a)*radius,y+Mathf.Sin(a)*radius)),color,Vector2.zero);if(i>0)mesh.AddTriangle(start,start+i,start+i+1);}}
  void Line(float ax,float ay,float bx,float by,float width,Color color){Vector2 a=new(ax,ay),b=new(bx,by),n=new Vector2(-(b-a).y,(b-a).x).normalized*width/2;Poly(color,a-n,b-n,b+n,a+n);}
  void Wrench(){Line(26,16,67,59,13,Steel);Circle(25,16,11,Navy);Circle(25,16,5,Light);Poly(Steel,new(57,52),new(54,66),new(63,75),new(64,61),new(72,56),new(83,65),new(79,50),new(68,45));Line(35,29,54,49,3,Light);}
  void Tester(){Rect(21,15,39,54,Navy);Rect(25,42,31,22,Steel);Rect(28,45,25,16,Light);Line(29,48,32,54,2,Orange);Line(32,54,38,50,2,Orange);Line(38,50,43,57,2,Orange);Circle(40,29,8,Orange);Circle(40,29,3,Navy);Line(61,18,78,25,3,Navy);Line(78,25,78,57,3,Orange);Rect(75,56,6,15,Navy);Line(78,71,78,78,2,Steel);}
  void Driver(float x,float y,float amount){Rect(x+12*amount,y,7*amount,40*amount,Steel);Poly(Steel,new(x+12*amount,y),new(x+15*amount,y-6*amount),new(x+19*amount,y));Rect(x+6*amount,y+36*amount,20*amount,28*amount,Orange);Rect(x+10*amount,y+41*amount,3*amount,18*amount,Navy);Rect(x+18*amount,y+41*amount,3*amount,18*amount,Navy);}
  void Kit(){Rect(10,10,78,42,Navy);Rect(27,54,44,7,Steel);Rect(27,50,7,14,Steel);Rect(64,50,7,14,Steel);Rect(14,44,70,8,Orange);Rect(44,24,11,15,Steel);Driver(58,41,.42f);Line(20,36,37,65,6,Steel);Circle(38,65,8,Steel);Circle(38,65,4,Light);}
  void Van(float x,float y,float s,Color paint){void R(float a,float b,float w,float h,Color c)=>Rect(x+a*s,y+b*s,w*s,h*s,c);void C(float a,float b,float r,Color c)=>Circle(x+a*s,y+b*s,r*s,c);Poly(paint,new(x+4*s,y+12*s),new(x+4*s,y+42*s),new(x+60*s,y+42*s),new(x+76*s,y+28*s),new(x+94*s,y+23*s),new(x+94*s,y+12*s));R(9,16,83,8,Navy);R(9,26,47,5,Orange);Poly(Steel,new(x+62*s,y+37*s),new(x+73*s,y+28*s),new(x+62*s,y+28*s));R(57,28,4,10,Steel);R(85,24,8,4,Orange);R(45,27,7,2,Navy);C(22,12,11,Navy);C(22,12,6,Steel);C(78,12,11,Navy);C(78,12,6,Steel);R(10,41,43,3,Steel);}
  void Building(bool headquarters){Rect(9,9,82,51,Steel);Poly(Navy,new(5,60),new(18,72),new(83,72),new(96,60));Rect(9,54,82,7,Orange);Rect(18,9,39,37,Navy);for(int i=0;i<4;i++)Rect(20,16+i*7,35,2,Steel);Rect(68,9,15,37,Navy);Rect(70,28,11,13,Light);if(headquarters){Rect(42,48,16,18,Navy);Line(46,54,50,50,2,Light);Line(50,50,55,59,2,Light);}else{Rect(77,60,4,15,Navy);Rect(71,66,16,4,Navy);}}
  void People(){for(int i=0;i<3;i++){float x=22+i*27;Circle(x,53,i==1?12:9,Steel);Rect(x-10,17,20,24,i==1?Orange:Navy);}}
  void Calendar(){Rect(19,9,61,61,Navy);Rect(23,13,53,43,Light);Rect(23,57,53,9,Orange);for(int r=0;r<2;r++)for(int c=0;c<3;c++)Rect(29+c*16,22+r*17,10,10,Steel);Line(42,27,48,22,3,Orange);Line(48,22,60,36,3,Orange);}
  void Gear(){Circle(50,40,22,Navy);for(int i=0;i<8;i++){float a=i*Mathf.PI/4;Line(50+Mathf.Cos(a)*15,40+Mathf.Sin(a)*15,50+Mathf.Cos(a)*29,40+Mathf.Sin(a)*29,8,Navy);}Circle(50,40,12,Light);Circle(50,40,5,Orange);}
 }
}
