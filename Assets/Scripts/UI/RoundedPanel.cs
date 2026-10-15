using UnityEngine;
using UnityEngine.UI;
namespace Kamilunavo.RepairEmpire.UI
{
 public sealed class RoundedPanel:Image
 {
  // Real rounded geometry uses the standard masked UI material. It therefore
  // remains rounded when a presenter deliberately clears a custom material.
  public float Radius=10;
  const int Steps=8,Count=4*(Steps+1);
  protected override void OnPopulateMesh(VertexHelper vh)
  {
   if(Radius<=0||type!=Type.Simple||sprite!=null){base.OnPopulateMesh(vh);return;}
   vh.Clear();var rect=GetPixelAdjustedRect();if(rect.width<=0||rect.height<=0)return;
   float radius=Mathf.Min(Radius,Mathf.Min(rect.width,rect.height)*.5f),inset=Mathf.Min(1.25f,Mathf.Min(rect.width,rect.height)*.1f);
   for(int ring=0;ring<3;ring++)
   {
    float pad=ring==0?0:ring==1?inset*.55f:inset;
    var bounds=Rect.MinMaxRect(rect.xMin+pad,rect.yMin+pad,rect.xMax-pad,rect.yMax-pad);float r=Mathf.Max(0,radius-pad);
    for(int corner=0;corner<4;corner++)for(int step=0;step<=Steps;step++)
    {
     float angle=(corner*90+step*90f/Steps)*Mathf.Deg2Rad;
     var centre=new Vector2(corner==0||corner==3?bounds.xMax-r:bounds.xMin+r,corner<2?bounds.yMax-r:bounds.yMin+r);
     var point=centre+new Vector2(Mathf.Cos(angle),Mathf.Sin(angle))*r;var tint=color;
     if(ring==0)tint.a=0;
     else if(ring==1){var edge=Color.Lerp(color,new Color(.43f,.39f,.32f,color.a),.15f);tint=edge;}
     else{float light=Mathf.Lerp(.982f,1.012f,Mathf.InverseLerp(rect.yMin,rect.yMax,point.y));tint.r=Mathf.Clamp01(tint.r*light);tint.g=Mathf.Clamp01(tint.g*light);tint.b=Mathf.Clamp01(tint.b*light);}
     vh.AddVert(point,tint,Vector2.one*.5f);
    }
   }
   for(int ring=1;ring<3;ring++)for(int i=0;i<Count;i++){int a=(ring-1)*Count+i,b=(ring-1)*Count+(i+1)%Count,c=ring*Count+i,d=ring*Count+(i+1)%Count;vh.AddTriangle(a,b,c);vh.AddTriangle(b,d,c);}
   int middle=vh.currentVertCount;vh.AddVert(rect.center,color,Vector2.one*.5f);for(int i=0;i<Count;i++)vh.AddTriangle(middle,2*Count+i,2*Count+(i+1)%Count);
  }
 }
 public sealed class CanvasOrientation:MonoBehaviour
 {
  private int _w,_h;private void Update(){if(_w==Screen.width&&_h==Screen.height)return;_w=Screen.width;_h=Screen.height;GetComponent<CanvasScaler>().referenceResolution=_w>_h?new Vector2(844,390):new Vector2(390,844);}
 }
}
