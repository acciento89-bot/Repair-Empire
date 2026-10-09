using UnityEngine;
using UnityEngine.UI;
namespace Kamilunavo.RepairEmpire.UI {
 // Original vector artwork, drawn once when uGUI rebuilds. No borrowed game assets or textures.
 [RequireComponent(typeof(CanvasRenderer))]
 public sealed class ServiceIllustrationGraphic:MaskableGraphic {
  public int Scene;
  static readonly Color Ink=new(.08f,.19f,.23f),Orange=new(1,.48f,.13f),Gold=new(1,.73f,.28f),Cream=new(.99f,.96f,.85f),Sky=new(.65f,.84f,.88f),Leaf=new(.25f,.49f,.36f),Blue=new(.24f,.48f,.56f);
  VertexHelper mesh;Rect bounds;float scale;Vector2 origin;
  protected override void OnPopulateMesh(VertexHelper vh){vh.Clear();mesh=vh;bounds=rectTransform.rect;scale=Mathf.Min(bounds.width/240,bounds.height/180);origin=new Vector2(bounds.xMin+(bounds.width-240*scale)*.5f,bounds.yMin+(bounds.height-180*scale)*.5f);
   if(Scene==9){City();return;}if(Scene==0){Customer();return;}if(Scene==1){Tools();return;}if(Scene==2){Van(10,27,1);return;}if(Scene==3){Workshop();return;}if(Scene==4){Earnings();return;}if(Scene==5){Calendar();return;}if(Scene==6){Options();return;}Paint();
  }
  Vector2 P(float x,float y)=>origin+new Vector2(x,y)*scale;
  void Poly(Color c,params Vector2[] points){int first=mesh.currentVertCount;foreach(var p in points)mesh.AddVert(P(p.x,p.y),c,Vector2.zero);for(int i=1;i<points.Length-1;i++)mesh.AddTriangle(first,first+i,first+i+1);}
  void Rect(float x,float y,float w,float h,Color c)=>Poly(c,new(x,y),new(x+w,y),new(x+w,y+h),new(x,y+h));
  void Circle(float x,float y,float radius,Color c,int sides=24){int first=mesh.currentVertCount;mesh.AddVert(P(x,y),c,Vector2.zero);for(int i=0;i<=sides;i++){float angle=i*Mathf.PI*2/sides;mesh.AddVert(P(x+Mathf.Cos(angle)*radius,y+Mathf.Sin(angle)*radius),c,Vector2.zero);if(i>0)mesh.AddTriangle(first,first+i,first+i+1);}}
  void Line(float x1,float y1,float x2,float y2,float width,Color c){Vector2 a=new(x1,y1),b=new(x2,y2);var n=new Vector2(-(b-a).y,(b-a).x).normalized*(width*.5f);Poly(c,a-n,b-n,b+n,a+n);}
  void Tree(float x,float y,float r){Rect(x-3,y,6,r*1.4f,new Color(.42f,.32f,.22f));Circle(x,y+r*1.4f,r,Leaf);Circle(x-r*.3f,y+r*1.7f,r*.76f,new Color(.40f,.61f,.42f));}
  void Cloud(float x,float y,float s){Circle(x,y,12*s,Cream);Circle(x+16*s,y+7*s,17*s,Cream);Circle(x+33*s,y,11*s,Cream);Rect(x,y-10*s,33*s,17*s,Cream);}
  void House(float x,float y,float w,float h,Color face){Rect(x+5,y-5,w,h,new Color(.34f,.51f,.50f,.20f));Rect(x,y,w,h,face);Poly(Ink,new(x-4,y+h),new(x+w*.5f,y+h+23),new(x+w+4,y+h));Rect(x+8,y+11,w*.27f,h*.31f,Blue);Rect(x+w*.58f,y+11,w*.24f,h*.31f,Blue);Rect(x+8,y+h*.60f,w*.27f,h*.24f,Sky);Rect(x+w*.58f,y+h*.60f,w*.24f,h*.24f,Sky);}
  void City(){Rect(0,0,240,180,Sky);Circle(194,145,22,Gold);Cloud(13,149,.72f);Cloud(120,168,.50f);Rect(0,35,240,26,new Color(.70f,.79f,.66f));Rect(0,0,240,36,new Color(.46f,.59f,.61f));for(int i=0;i<4;i++)Rect(12+i*64,17,25,2,Cream);
   House(8,54,39,67,new Color(.86f,.69f,.48f));House(166,51,43,76,new Color(.86f,.89f,.80f));Rect(63,50,91,58,Cream);Rect(63,108,91,13,Ink);Rect(69,103,79,5,Orange);Rect(78,50,57,43,Blue);for(int i=0;i<4;i++)Rect(80,57+i*8,53,2,Sky);Rect(139,51,9,42,Ink);Tree(222,35,15);Tree(49,39,15);Van(45,16,.72f);
  }
  void Customer(){Rect(0,0,240,180,new Color(.85f,.92f,.88f));Circle(196,145,18,Gold);Cloud(8,145,.7f);Rect(0,0,240,28,new Color(.66f,.77f,.65f));House(45,29,114,89,Cream);Rect(88,29,24,39,Ink);Rect(91,32,18,32,Blue);Rect(38,26,132,4,Ink);Tree(19,26,19);Tree(203,20,22);Circle(177,120,23,Orange);Poly(Orange,new(161,106),new(177,79),new(193,106));Circle(177,121,9,Cream);Van(43,7,.43f);}
  void Van(float x,float y,float s){
   void R(float a,float b,float w,float h,Color c)=>Rect(x+a*s,y+b*s,w*s,h*s,c);
   void C(float a,float b,float r,Color c)=>Circle(x+a*s,y+b*s,r*s,c);
   void Q(Color c,params Vector2[] points){for(int i=0;i<points.Length;i++)points[i]=new(x+points[i].x*s,y+points[i].y*s);Poly(c,points);}
   R(11,9,207,5,new Color(.25f,.35f,.35f,.18f));Q(Cream,new(15,28),new(16,106),new(144,106),new(180,76),new(213,68),new(219,28));Q(new Color(.84f,.89f,.87f),new(144,106),new(153,116),new(190,85),new(180,76));Q(Color.white,new(16,106),new(29,116),new(153,116),new(144,106));Q(Blue,new(151,99),new(176,77),new(152,77));R(132,77,13,23,Blue);R(19,33,196,18,Ink);Q(Orange,new(20,51),new(20,62),new(126,62),new(150,51));R(208,51,12,8,Gold);R(12,28,209,7,Ink);R(112,59,12,3,Ink);R(25,103,96,3,Ink);R(37,108,81,5,new Color(.64f,.70f,.69f));R(55,119,72,6,new Color(.64f,.70f,.69f));R(55,123,5,6,Ink);R(121,123,5,6,Ink);C(51,28,20,Ink);C(51,28,11,new Color(.73f,.79f,.77f));C(51,28,5,Cream);C(183,28,20,Ink);C(183,28,11,new Color(.73f,.79f,.77f));C(183,28,5,Cream);C(70,81,14,Orange);C(70,81,9,Cream);Q(Ink,new(62,86),new(66,90),new(80,76),new(76,72));
  }
  void Workshop(){Rect(0,0,240,180,new Color(.87f,.92f,.85f));Circle(204,147,19,Gold);Rect(18,19,196,110,Cream);Poly(Ink,new(13,129),new(28,153),new(111,153),new(111,137),new(218,137),new(218,125));Rect(18,105,196,17,Ink);Rect(18,101,196,5,Orange);Rect(34,19,99,76,Blue);for(int i=0;i<6;i++)Rect(38,24+i*11,91,2,Sky);Rect(149,19,43,74,Ink);Rect(153,54,35,33,Sky);Rect(0,15,240,5,Ink);Tree(217,16,15);Van(50,0,.5f);}
  void Tools(){Circle(117,91,70,new Color(.91f,.87f,.73f));Line(64,38,154,132,17,Ink);Circle(156,132,24,Ink);Circle(156,132,13,Cream);Poly(new Color(.91f,.87f,.73f),new(147,150),new(168,151),new(162,128));Circle(64,38,14,Ink);Circle(64,38,6,Cream);Line(174,40,91,124,10,Blue);Line(106,110,80,136,18,Orange);Line(174,40,187,25,5,Ink);Rect(153,41,45,8,Gold);}
  void Earnings(){Circle(181,134,21,Gold);Circle(181,134,14,Orange);Rect(39,31,164,8,Ink);Rect(46,39,30,41,Blue);Rect(94,39,30,70,Leaf);Rect(143,39,30,93,Orange);Line(38,95,88,124,5,Ink);Line(88,124,132,145,5,Ink);Poly(Ink,new(131,135),new(147,153),new(125,150));for(int i=0;i<3;i++){Circle(204,38+i*10,16,Gold);Rect(188,34+i*10,32,8,Orange);}}
  void Calendar(){Rect(44,19,157,138,Ink);Rect(48,23,149,109,Cream);Rect(48,132,149,21,Orange);for(int i=0;i<3;i++)Rect(64+i*49,142,8,28,Ink);for(int row=0;row<3;row++)for(int col=0;col<4;col++)Rect(61+col*32,38+row*31,18,18,row==1&&col==2?Orange:Sky);Line(122,78,129,71,4,Ink);Line(129,71,141,89,4,Ink);Circle(47,37,21,Gold);}
  void Options(){Circle(116,90,55,new Color(.90f,.88f,.77f));for(int i=0;i<8;i++){float angle=i*Mathf.PI/4;Line(116+Mathf.Cos(angle)*35,90+Mathf.Sin(angle)*35,116+Mathf.Cos(angle)*60,90+Mathf.Sin(angle)*60,17,Ink);}Circle(116,90,43,Ink);Circle(116,90,25,Cream);Circle(116,90,12,Orange);}
  void Paint(){Rect(30,27,59,116,Ink);Rect(35,33,49,77,Sky);Rect(95,27,59,116,Ink);Rect(100,33,49,77,Leaf);Rect(160,27,59,116,Ink);Rect(165,33,49,77,Orange);Rect(35,110,49,28,Cream);Rect(100,110,49,28,Cream);Rect(165,110,49,28,Cream);Line(48,17,177,149,13,Blue);Line(166,137,192,163,22,Gold);}
 }
}
