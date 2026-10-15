using UnityEngine;
using UnityEngine.UI;

namespace Kamilunavo.RepairEmpire.UI
{
 // Original vector silhouettes for the service interface; no font-symbol fallback.
 public sealed class ServiceUiIcon:MaskableGraphic
 {
  public string Symbol="Calls";
  VertexHelper mesh;Vector2 origin;float scale;
  protected override void OnPopulateMesh(VertexHelper vh)
  {
   vh.Clear();mesh=vh;var rect=rectTransform.rect;scale=Mathf.Min(rect.width,rect.height)/24;origin=rect.center-Vector2.one*12*scale;
   switch(Symbol)
   {
    case "Calls":
     Outline(5,2,14,19);Box(8,19,8,4);for(int i=0;i<3;i++){Line(10,6+i*4,16,6+i*4,1.5f);Box(7,5.5f+i*4,1.4f,1.4f);}break;
    case "Equipment":
     Line(5,4,17,17,3);Circle(5,4,2.6f);Poly(new(14,16),new(14,21),new(17,23),new(17,19),new(20,17),new(23,17),new(20,14),new(17,14));
     Line(5,20,19,5,1.4f);Line(16,8,20,4,3.2f);break;
    case "Workshop":
     Outline(3,3,18,13);Outline(8,16,8,5);Box(2,12,20,2);Box(10.5f,10,3,5);break;
    case "Company":
     Line(3,3,22,3,1.8f);Box(4,5,4,7);Box(10,5,4,12);Box(16,5,4,17);break;
    case "Cash":
     Outline(2,5,20,14);Line(3,6,7,10,1.5f);Line(17,14,21,18,1.5f);Circle(12,12,3);break;
    case "Shop":
     Outline(4,3,16,15);Line(8,17,8,20,1.7f);Line(8,20,16,20,1.7f);Line(16,20,16,17,1.7f);break;
    case "Pause":Box(6,4,4,16);Box(14,4,4,16);break;
    case "Left":Line(15,4,7,12,2.3f);Line(7,12,15,20,2.3f);break;
    case "Right":Line(9,4,17,12,2.3f);Line(17,12,9,20,2.3f);break;
    case "Brake":case "Gas":
     Outline(6,2,12,20);for(int i=0;i<4;i++)Line(9,6+i*4,15,6+i*4,1.4f);break;
    default:Circle(12,12,7);Line(12,8,12,16,1.7f);break;
   }
  }
  Vector2 P(Vector2 p)=>origin+p*scale;
  void Poly(params Vector2[] points){int first=mesh.currentVertCount;foreach(var p in points)mesh.AddVert(P(p),color,Vector2.zero);for(int i=1;i<points.Length-1;i++)mesh.AddTriangle(first,first+i,first+i+1);}
  void Box(float x,float y,float w,float h)=>Poly(new(x,y),new(x+w,y),new(x+w,y+h),new(x,y+h));
  void Line(float ax,float ay,float bx,float by,float width){Vector2 a=new(ax,ay),b=new(bx,by),n=new Vector2(-(b-a).y,(b-a).x).normalized*width*.5f;Poly(a-n,b-n,b+n,a+n);}
  void Outline(float x,float y,float w,float h){Line(x,y,x+w,y,1.7f);Line(x+w,y,x+w,y+h,1.7f);Line(x+w,y+h,x,y+h,1.7f);Line(x,y+h,x,y,1.7f);}
  void Circle(float x,float y,float radius){for(int i=0;i<24;i++){float a=i*Mathf.PI/12,b=(i+1)*Mathf.PI/12;Poly(new(x,y),new(x+Mathf.Cos(a)*radius,y+Mathf.Sin(a)*radius),new(x+Mathf.Cos(b)*radius,y+Mathf.Sin(b)*radius));}}
 }
}
