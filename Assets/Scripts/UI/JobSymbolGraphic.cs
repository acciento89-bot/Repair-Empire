using UnityEngine;
using UnityEngine.UI;
namespace Kamilunavo.RepairEmpire.UI {
 // Job-specific service diagrams stay crisp at phone/tablet sizes and never borrow an unrelated photo.
 [RequireComponent(typeof(CanvasRenderer))]
 public sealed class JobSymbolGraphic:MaskableGraphic {
  public string JobId="faucet";VertexHelper mesh;
  protected override void OnPopulateMesh(VertexHelper vh){vh.Clear();mesh=vh;string id=JobId??"";
   if(id=="toilet"){Box(.24f,.19f,.53f,.24f);Box(.23f,.65f,.38f,.20f);Line(.29f,.65f,.29f,.45f,.05f);Line(.25f,.45f,.75f,.45f,.06f);Line(.68f,.43f,.62f,.24f,.06f);}
   else if(id=="sink"){Line(.16f,.57f,.84f,.57f,.06f);Line(.18f,.57f,.29f,.30f,.05f);Line(.82f,.57f,.71f,.30f,.05f);Line(.29f,.30f,.71f,.30f,.05f);Line(.49f,.73f,.49f,.87f,.05f);Line(.49f,.87f,.71f,.87f,.05f);}
   else if(id=="faucet"||id=="call-0-2"){Line(.20f,.38f,.20f,.70f,.11f);Line(.20f,.70f,.76f,.70f,.11f);Line(.76f,.70f,.76f,.51f,.11f);Line(.12f,.38f,.29f,.38f,.08f);Line(.29f,.82f,.53f,.82f,.06f);Line(.41f,.70f,.41f,.85f,.05f);Disc(.76f,.28f,.075f);}
   else if(id=="call-0-1"){Line(.24f,.25f,.24f,.80f,.07f);Line(.24f,.80f,.68f,.80f,.07f);Line(.68f,.80f,.77f,.64f,.07f);for(int i=0;i<3;i++)Line(.62f+i*.09f,.53f,.55f+i*.09f,.28f,.025f);}
   else if(id=="call-0-0"||id=="call-3-2"){Line(.20f,.76f,.54f,.76f,.10f);Line(.54f,.76f,.54f,.30f,.10f);Line(.54f,.30f,.82f,.30f,.10f);Disc(.33f,.32f,.065f);}
   else if(id=="switch"){Box(.28f,.17f,.45f,.67f);Box(.39f,.40f,.23f,.30f);}
   else if(id=="call-1-1"){Box(.25f,.20f,.5f,.6f);Disc(.41f,.52f,.04f);Disc(.59f,.52f,.04f);Line(.5f,.31f,.5f,.39f,.04f);}
   else if(id=="call-1-2"){Ring(.5f,.60f,.21f);Line(.40f,.37f,.60f,.37f,.06f);Line(.43f,.27f,.57f,.27f,.06f);for(int i=0;i<4;i++){float a=(45+i*90)*Mathf.Deg2Rad;Line(.5f+Mathf.Cos(a)*.3f,.6f+Mathf.Sin(a)*.3f,.5f+Mathf.Cos(a)*.4f,.6f+Mathf.Sin(a)*.4f,.035f);}}
   else if(id=="call-1-3"){Ring(.5f,.57f,.20f);Line(.28f,.31f,.72f,.31f,.06f);Disc(.5f,.21f,.045f);}
   else if(id.StartsWith("call-1")){Box(.26f,.18f,.47f,.65f);Line(.43f,.74f,.59f,.54f,.06f);Line(.59f,.54f,.40f,.46f,.06f);Line(.40f,.46f,.55f,.27f,.06f);}
   else if(id=="call-2-1"){Ring(.5f,.5f,.31f);Ring(.5f,.5f,.19f);Line(.5f,.5f,.66f,.64f,.055f);}
   else if(id=="call-2-2"){Ring(.5f,.5f,.23f);Line(.18f,.5f,.82f,.5f,.065f);Line(.5f,.18f,.5f,.82f,.065f);}
   else if(id=="call-2-3"||id=="call-3-1"){Ring(.5f,.5f,.32f);for(int i=0;i<4;i++){float a=i*Mathf.PI/2;Line(.5f,.5f,.5f+Mathf.Cos(a)*.24f,.5f+Mathf.Sin(a)*.24f,.10f);}Disc(.5f,.5f,.08f);}
   else if(id.StartsWith("call-2")){Box(.20f,.25f,.6f,.48f);for(int i=0;i<5;i++)Line(.28f+i*.11f,.30f,.28f+i*.11f,.68f,.04f);Line(.15f,.20f,.15f,.78f,.04f);Line(.85f,.20f,.85f,.78f,.04f);}
   else if(id=="call-3-0"){Box(.22f,.20f,.56f,.62f);for(int i=0;i<4;i++){Line(.28f+i*.14f,.25f,.28f+i*.14f,.77f,.025f);Line(.26f,.28f+i*.14f,.74f,.28f+i*.14f,.025f);}}
   else if(id=="call-3-3"){for(int i=0;i<3;i++){Line(.20f,.30f+i*.20f,.75f,.30f+i*.20f,.04f);Line(.65f,.22f+i*.20f,.75f,.30f+i*.20f,.04f);Line(.65f,.38f+i*.20f,.75f,.30f+i*.20f,.04f);}}
   else {for(int i=0;i<3;i++){float a=i*Mathf.PI/3;float x=Mathf.Cos(a)*.31f,y=Mathf.Sin(a)*.31f;Line(.5f-x,.5f-y,.5f+x,.5f+y,.05f);}Disc(.5f,.5f,.09f);}
  }
  void Box(float x,float y,float w,float h){const float t=.045f;Line(x,y,x+w,y,t);Line(x+w,y,x+w,y+h,t);Line(x+w,y+h,x,y+h,t);Line(x,y+h,x,y,t);}
  void Ring(float x,float y,float r){for(int i=0;i<28;i++){float a=i*Mathf.PI*2/28,b=(i+1)*Mathf.PI*2/28;Line(x+Mathf.Cos(a)*r,y+Mathf.Sin(a)*r,x+Mathf.Cos(b)*r,y+Mathf.Sin(b)*r,.045f);}}
  void Disc(float x,float y,float r){for(int i=0;i<20;i++){float a=i*Mathf.PI*2/20,b=(i+1)*Mathf.PI*2/20;Quad(new Vector2(x,y),new Vector2(x+Mathf.Cos(a)*r,y+Mathf.Sin(a)*r),new Vector2(x+Mathf.Cos(b)*r,y+Mathf.Sin(b)*r),new Vector2(x,y));}}
  void Line(float x,float y,float xx,float yy,float thickness){var a=new Vector2(x,y);var b=new Vector2(xx,yy);var n=new Vector2(-(b-a).y,(b-a).x).normalized*thickness/2;Quad(a-n,a+n,b+n,b-n);}
  void Quad(Vector2 a,Vector2 b,Vector2 c,Vector2 d){int start=mesh.currentVertCount;foreach(var point in new[]{a,b,c,d}){var v=UIVertex.simpleVert;v.color=color;v.position=new Vector3(rectTransform.rect.xMin+point.x*rectTransform.rect.width,rectTransform.rect.yMin+point.y*rectTransform.rect.height,0);mesh.AddVert(v);}mesh.AddTriangle(start,start+1,start+2);mesh.AddTriangle(start,start+2,start+3);}
 }
}
