using UnityEngine;
using UnityEngine.UI;
namespace Kamilunavo.RepairEmpire.UI {
 [RequireComponent(typeof(CanvasRenderer))]
 public sealed class SteeringWheelGraphic:Graphic {
  protected override void OnPopulateMesh(VertexHelper vh){vh.Clear();Vector2 center=rectTransform.rect.center;float radius=Mathf.Min(rectTransform.rect.width,rectTransform.rect.height)*.48f;Ring(vh,center,radius,radius*.80f,new Color(.10f,.12f,.14f,.95f));Ring(vh,center,radius*.80f,radius*.67f,new Color(.82f,.84f,.86f));for(int i=0;i<3;i++){float angle=(i*120+30)*Mathf.Deg2Rad;Vector2 a=center+new Vector2(Mathf.Cos(angle),Mathf.Sin(angle))*radius*.25f;Vector2 b=center+new Vector2(Mathf.Cos(angle),Mathf.Sin(angle))*radius*.72f;Quad(vh,a,b,radius*.13f,new Color(.70f,.73f,.75f));}Ring(vh,center,radius*.27f,0,new Color(.82f,.84f,.86f));Ring(vh,center,radius*.19f,0,new Color(.26f,.29f,.32f));}
  static void Ring(VertexHelper vh,Vector2 c,float r,float inside,Color color){for(int i=0;i<48;i++){float a=i*Mathf.PI/24,b=(i+1)*Mathf.PI/24;int n=vh.currentVertCount;Add(vh,c+new Vector2(Mathf.Cos(a),Mathf.Sin(a))*r,color);Add(vh,c+new Vector2(Mathf.Cos(b),Mathf.Sin(b))*r,color);Add(vh,c+new Vector2(Mathf.Cos(b),Mathf.Sin(b))*inside,color);Add(vh,c+new Vector2(Mathf.Cos(a),Mathf.Sin(a))*inside,color);vh.AddTriangle(n,n+1,n+2);vh.AddTriangle(n,n+2,n+3);}}
  static void Quad(VertexHelper vh,Vector2 a,Vector2 b,float width,Color color){Vector2 normal=new Vector2(-(b-a).y,(b-a).x).normalized*width*.5f;int n=vh.currentVertCount;Add(vh,a-normal,color);Add(vh,b-normal,color);Add(vh,b+normal,color);Add(vh,a+normal,color);vh.AddTriangle(n,n+1,n+2);vh.AddTriangle(n,n+2,n+3);}
  static void Add(VertexHelper vh,Vector2 pos,Color color){var v=UIVertex.simpleVert;v.position=pos;v.color=color;vh.AddVert(v);}
 }
}
