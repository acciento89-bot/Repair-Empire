using System.Collections.Generic;
using UnityEngine;
namespace Kamilunavo.RepairEmpire.Visuals
{
 // Original compact commercial coachwork. These owned visual meshes never carry
 // colliders; the vehicle root retains driving, wheel pivots and paint authority.
 public static class VanCoachworkGeometry
 {
  static readonly float[] Stations={-2.18f,-2.08f,-1.72f,.28f,.58f,.95f,1.28f,1.63f,1.92f,2.11f};
  static readonly float[] Widths={.96f,1.015f,1.055f,1.055f,1.03f,1.01f,.99f,.965f,.94f,.86f};
  static readonly float[] Roof={2.30f,2.37f,2.40f,2.39f,2.31f,2.12f,1.83f,1.44f,1.31f,1.19f};
  static float Arch(float z)
  {
   float height=.42f;foreach(float axle in new[]{-1.42f,1.38f}){float distance=Mathf.Abs(z-axle);if(distance<.59f)height=Mathf.Max(height,.40f+Mathf.Sqrt(.59f*.59f-distance*distance));}return height;
  }
  static float Slope(float[] z,float[] values,int i)
  {
   if(i==0)return(values[1]-values[0])/(z[1]-z[0]);if(i==values.Length-1)return(values[i]-values[i-1])/(z[i]-z[i-1]);
   float before=(values[i]-values[i-1])/(z[i]-z[i-1]),after=(values[i+1]-values[i])/(z[i+1]-z[i]);return before*after<=0?0:2*before*after/(before+after);
  }
  static float Sample(float[] z,float[] values,float at)
  {
   if(at<=z[0])return values[0];for(int i=1;i<z.Length;i++)if(at<=z[i]){float d=z[i]-z[i-1],t=(at-z[i-1])/d,t2=t*t,t3=t2*t;float value=(2*t3-3*t2+1)*values[i-1]+(t3-2*t2+t)*d*Slope(z,values,i-1)+(-2*t3+3*t2)*values[i]+(t3-t2)*d*Slope(z,values,i);return Mathf.Clamp(value,Mathf.Min(values[i-1],values[i]),Mathf.Max(values[i-1],values[i]));}return values[values.Length-1];
  }
  static float BendZ(float z,float x,float y)
  {
   bool rear=z<0;float end=rear?Stations[0]:Stations[Stations.Length-1],w=rear?Widths[0]:Widths[Widths.Length-1],top=rear?Roof[0]:Roof[Roof.Length-1];
   float blend=rear?1-Mathf.SmoothStep(0,1,(z-end)/.42f):Mathf.SmoothStep(0,1,(z-(end-.50f))/.50f);
   float returnDepth=(rear?.14f:.12f)*Mathf.Pow(Mathf.Clamp01(Mathf.Abs(x)/w),4)+(rear?.075f:.055f)*Mathf.Pow(Mathf.Clamp01(Mathf.Abs((y-(top+.42f)*.5f)/((top-.42f)*.5f))),6);
   return z+(rear?1:-1)*blend*returnDepth;
  }
  public static float RearSkinZ(float x,float y)=>BendZ(Stations[0],x,y);
  static float TopAt(float x,float z)
  {
   float w=Sample(Stations,Widths,z),top=Sample(Stations,Roof,z),t=Mathf.Clamp01((Mathf.Abs(x)-(w-.34f))/.34f);return top-.32f+.32f*Mathf.Sqrt(1-t*t);
  }
  static float SideAt(float y,float z)
  {
   float w=Sample(Stations,Widths,z),top=Sample(Stations,Roof,z);if(y>top-.32f){float d=Mathf.Clamp01((y-(top-.32f))/.32f);return w-.34f+.34f*Mathf.Sqrt(1-d*d);}return w;
  }
  public static float FrontSkinZ(float x,float y)
  {
   float high=Stations[Stations.Length-1];bool Inside(float z)=>Mathf.Abs(x)<=Sample(Stations,Widths,z)&&y<=TopAt(x,z)&&y>=.42f;
   if(Inside(high))return BendZ(high,x,y);
   for(int i=Stations.Length-2;i>=0;i--)if(Inside(Stations[i])){float low=Stations[i];for(int n=0;n<14;n++){float mid=(low+high)*.5f;if(Inside(mid))low=mid;else high=mid;}return BendZ(low,x,y);}else high=Stations[i];
   return BendZ(Stations[0],x,y);
  }
  static List<float> BodyRings()
  {
   var rings=new List<float>(Stations);rings.Add(-1.42f);rings.Add(1.38f);
   for(int i=0;i<=60;i++){float z=Mathf.Lerp(Stations[0],Stations[Stations.Length-1],i/60f);bool near=false;foreach(float existing in rings)if(Mathf.Abs(existing-z)<.002f){near=true;break;}if(!near)rings.Add(z);}rings.Sort();return rings;
  }
  public static GameObject Windshield(Transform parent,Material material)
  {
   var v=new List<Vector3>();var uv=new List<Vector2>();var triangles=new List<int>();const int across=8;
   foreach(float z in BodyRings())
   {
    if(z<.95f||z>1.63f)continue;float t=(z-.95f)/.68f,w=Mathf.Lerp(.74f,.75f,t);int row=v.Count;
    for(int x=0;x<=across;x++){float at=Mathf.Lerp(-w,w,x/(float)across);v.Add(new Vector3(at,TopAt(at,z)+.021f,z));uv.Add(new Vector2(x/(float)across,t));}
    if(row>0)for(int x=0;x<across;x++){int a=row+x,b=a-across-1;triangles.AddRange(new[]{b,a,b+1,b+1,a,a+1});}
   }
   return MeshArt.Mesh(parent,"Swept panoramic windshield",v.ToArray(),triangles.ToArray(),uv.ToArray(),material);
  }
  public static void Wiper(Transform parent,int side,Material material)
  {
   var path=new Vector3[7];for(int i=0;i<path.Length;i++){float t=i/(float)(path.Length-1),z=Mathf.Lerp(1.59f,1.35f,t),x=side*Mathf.Lerp(.40f,.57f,t);path[i]=new Vector3(x,TopAt(x,z)+.043f,z);}MeshArt.Tube(parent,"Windshield wiper",path,.010f,material,8);
  }
  public static GameObject Body(Transform parent,Material material)
  {
   var rings=BodyRings();const int corners=16,sides=4*corners;var v=new List<Vector3>();var uv=new List<Vector2>();var triangles=new List<int>();
   foreach(float z in rings)
   {
    float width=Sample(Stations,Widths,z),top=Sample(Stations,Roof,z);
    for(int corner=0;corner<4;corner++)for(int n=0;n<corners;n++)
    {
     float a=(corner+n/(float)corners)*Mathf.PI*.5f;bool upper=corner<2;float rx=upper?.34f:.12f,ry=upper?.32f:.12f;
     float cx=(corner==0||corner==3?1:-1)*(width-rx),cy=upper?top-ry:.42f+ry,x=cx+Mathf.Cos(a)*rx,y=cy+Mathf.Sin(a)*ry;
     float side=Mathf.SmoothStep(0,1,(Mathf.Abs(x)/width-.72f)/.20f);if(y<1.06f)y=Mathf.Max(y,Mathf.Lerp(.42f,Arch(z),side));
     v.Add(new Vector3(x,y,BendZ(z,x,y)));uv.Add(new Vector2((corner*corners+n)/(float)sides,(z+2.18f)/4.29f));
    }
   }
   for(int ring=1;ring<rings.Count;ring++)for(int i=0;i<sides;i++){int a=(ring-1)*sides+i,b=ring*sides+i,next=(i+1)%sides;triangles.AddRange(new[]{a,(ring-1)*sides+next,b,(ring-1)*sides+next,ring*sides+next,b});}
   // Nested curved skins replace the old planar triangle fans at the rear and nose.
   foreach(int end in new[]{0,rings.Count-1})
   {
    bool rear=end==0;int previous=end*sides;float at=rings[end],cy=(Sample(Stations,Roof,at)+.42f)*.5f;var edge=new Vector3[sides];for(int i=0;i<sides;i++)edge[i]=v[previous+i];
    for(int inset=1;inset<6;inset++)
    {
     float radius=1-inset/6f;int current=v.Count;
     for(int i=0;i<sides;i++){float x=edge[i].x*radius,y=Mathf.Lerp(cy,edge[i].y,radius);v.Add(new Vector3(x,y,BendZ(at,x,y)));uv.Add(new Vector2(x*.45f+.5f,(y-.42f)/2));}
     for(int i=0;i<sides;i++){int a=previous+i,b=previous+(i+1)%sides,c=current+i,d=current+(i+1)%sides;triangles.AddRange(rear?new[]{a,c,b,b,c,d}:new[]{a,b,c,b,d,c});}previous=current;
    }
    int center=v.Count;v.Add(new Vector3(0,cy,BendZ(at,0,cy)));uv.Add(new Vector2(.5f,.5f));for(int i=0;i<sides;i++){int a=previous+i,b=previous+(i+1)%sides;triangles.AddRange(rear?new[]{center,b,a}:new[]{center,a,b});}
   }
   return MeshArt.Mesh(parent,"Bevelled service body",v.ToArray(),triangles.ToArray(),uv.ToArray(),material);
  }
  public static GameObject SculptedPanel(Transform parent,string name,Vector2 center,Vector2 size,float radius,Material material,bool rear=true,float offset=.018f,float depth=.014f)
  {
   const int cornerSteps=7,count=cornerSteps*4,insets=4;var shape=new Vector2[count];var v=new List<Vector3>();var uv=new List<Vector2>();var triangles=new List<int>();
   for(int corner=0;corner<4;corner++)for(int n=0;n<cornerSteps;n++){float a=(corner+n/(float)cornerSteps)*Mathf.PI*.5f;var c=new Vector2((corner==0||corner==3?1:-1)*(size.x*.5f-radius),(corner<2?1:-1)*(size.y*.5f-radius));shape[corner*cornerSteps+n]=c+new Vector2(Mathf.Cos(a),Mathf.Sin(a))*radius;}
   for(int layer=0;layer<2;layer++)
   {
    bool back=layer==1;int first=v.Count;
    for(int inset=0;inset<insets;inset++)for(int i=0;i<count;i++){float r=1-inset/(float)insets;var p=center+shape[i]*r;float z=rear?RearSkinZ(p.x,p.y):FrontSkinZ(p.x,p.y);float outwards=offset+(back?-1:1)*depth*.5f;v.Add(new Vector3(p.x,p.y,z+(rear?-1:1)*outwards));uv.Add(new Vector2(shape[i].x*r/size.x+.5f,shape[i].y*r/size.y+.5f));}
    bool reverse=rear!=back;
    for(int ring=1;ring<insets;ring++)for(int i=0;i<count;i++){int a=first+(ring-1)*count+i,b=first+(ring-1)*count+(i+1)%count,c=first+ring*count+i,d=first+ring*count+(i+1)%count;triangles.AddRange(reverse?new[]{a,c,b,b,c,d}:new[]{a,b,c,b,d,c});}
    int pole=v.Count;float cz=rear?RearSkinZ(center.x,center.y):FrontSkinZ(center.x,center.y);v.Add(new Vector3(center.x,center.y,cz+(rear?-1:1)*(offset+(back?-1:1)*depth*.5f)));uv.Add(new Vector2(.5f,.5f));int last=first+(insets-1)*count;
    for(int i=0;i<count;i++){int a=last+i,b=last+(i+1)%count;triangles.AddRange(reverse?new[]{pole,b,a}:new[]{pole,a,b});}
   }
   // The thin panel edge has its own normals; averaging it into the face makes
   // the glass look like four folded triangles under the reflection probe.
   int other=insets*count+1,wall=v.Count;for(int layer=0;layer<2;layer++)for(int i=0;i<count;i++){int source=(layer==0?0:other)+i;v.Add(v[source]);uv.Add(uv[source]);}
   for(int i=0;i<count;i++){int a=wall+i,b=wall+(i+1)%count,c=wall+count+i,d=wall+count+(i+1)%count;triangles.AddRange(rear?new[]{a,b,c,b,d,c}:new[]{a,c,b,b,c,d});}
   return MeshArt.Mesh(parent,name,v.ToArray(),triangles.ToArray(),uv.ToArray(),material);
  }
  public static void CabGlazing(Transform parent,int side,Material material,bool seal)
  {
   var outline=new[]{new Vector2(.47f,1.38f),new Vector2(1.50f,1.38f),new Vector2(.88f,2.04f),new Vector2(.47f,2.18f)};var center=new Vector2(.81f,1.68f);var loop=new List<Vector2>();
   for(int corner=0;corner<4;corner++){var at=outline[corner];var before=Vector2.Lerp(at,outline[(corner+3)%4],.12f);var after=Vector2.Lerp(at,outline[(corner+1)%4],.12f);for(int step=0;step<10;step++){float t=step/9f;loop.Add((1-t)*(1-t)*before+2*(1-t)*t*at+t*t*after);}}
   var v=new List<Vector3>();var uv=new List<Vector2>();var triangles=new List<int>();
   for(int ring=0;ring<5;ring++)foreach(var point in loop){float r=(1-ring/5f)*(seal?1.045f:1);var p=center+(point-center)*r;v.Add(new Vector3(side*(SideAt(p.y,p.x)+(seal?.010f:.022f)),p.y,p.x));uv.Add(new Vector2(p.x-.4f,p.y-1.3f));}
   for(int ring=1;ring<5;ring++)for(int i=0;i<loop.Count;i++){int a=(ring-1)*loop.Count+i,b=(ring-1)*loop.Count+(i+1)%loop.Count,c=ring*loop.Count+i,d=ring*loop.Count+(i+1)%loop.Count;triangles.AddRange(side<0?new[]{a,b,c,b,d,c}:new[]{a,c,b,b,c,d});}
   int pole=v.Count;v.Add(new Vector3(side*(SideAt(center.y,center.x)+(seal?.010f:.022f)),center.y,center.x));uv.Add(new Vector2(.5f,.5f));int last=4*loop.Count;for(int i=0;i<loop.Count;i++){int a=last+i,b=last+(i+1)%loop.Count;triangles.AddRange(side<0?new[]{pole,a,b}:new[]{pole,b,a});}
   MeshArt.Mesh(parent,seal?"Cab glass perimeter seal":"Sculpted cab side glazing",v.ToArray(),triangles.ToArray(),uv.ToArray(),material);
  }
  public static GameObject RearBand(Transform parent,string name,float bottom,float top,Material material)
  {
   var v=new List<Vector3>();var t=new List<int>();var uv=new List<Vector2>();const int columns=32,rows=5;
   float standOff=name=="Orange rear livery"?.020f:.010f;
   for(int y=0;y<=rows;y++)for(int x=0;x<=columns;x++){float xx=Mathf.Lerp(-.89f,.89f,x/(float)columns),yy=Mathf.Lerp(bottom,top,y/(float)rows);v.Add(new Vector3(xx,yy,RearSkinZ(xx,yy)-standOff));uv.Add(new Vector2(x/(float)columns,y/(float)rows));}
   for(int y=0;y<rows;y++)for(int x=0;x<columns;x++){int a=y*(columns+1)+x,b=a+columns+1;t.AddRange(new[]{a,b,a+1,a+1,b,b+1});}return MeshArt.Mesh(parent,name,v.ToArray(),t.ToArray(),uv.ToArray(),material);
  }
  public static GameObject SideBand(Transform parent,string name,int side,float bottom,float top,Material material)
  {
   const int samples=70;var v=new List<Vector3>();var t=new List<int>();var uv=new List<Vector2>();float standOff=name=="Orange service band"?.018f:.009f;
   for(int i=0;i<samples;i++){
    float z0=Mathf.Lerp(-2.0f,1.28f,i/(float)samples),z1=Mathf.Lerp(-2.0f,1.28f,(i+1)/(float)samples);
    float lower0=Mathf.Max(bottom,Arch(z0)+.017f),lower1=Mathf.Max(bottom,Arch(z1)+.017f);if(lower0>=top&&lower1>=top)continue;
    lower0=Mathf.Min(lower0,top);lower1=Mathf.Min(lower1,top);int k=v.Count;float x0=side*(SideAt(top,z0)+standOff),x1=side*(SideAt(top,z1)+standOff);
    v.AddRange(new[]{new Vector3(x0,lower0,BendZ(z0,x0,lower0)),new Vector3(x0,top,BendZ(z0,x0,top)),new Vector3(x1,top,BendZ(z1,x1,top)),new Vector3(x1,lower1,BendZ(z1,x1,lower1))});
    uv.AddRange(new[]{new Vector2(0,0),new Vector2(0,1),new Vector2(1,1),new Vector2(1,0)});t.AddRange(side>0?new[]{k,k+1,k+2,k,k+2,k+3}:new[]{k,k+2,k+1,k,k+3,k+2});
   }
   return MeshArt.Mesh(parent,name,v.ToArray(),t.ToArray(),uv.ToArray(),material);
  }
  public static GameObject RearPanel(Transform parent,string name,Vector3 at,Vector3 size,float radius,Material material)
  {
   const int corners=10,sides=corners*4;var v=new List<Vector3>();var uv=new List<Vector2>();var t=new List<int>();
   for(int ring=0;ring<3;ring++)for(int corner=0;corner<4;corner++)for(int n=0;n<corners;n++){
    float bevel=ring==1?0:.008f,a=(corner+n/(float)corners)*Mathf.PI*.5f,rx=size.x*.5f-bevel,ry=size.y*.5f-bevel;
    float cx=(corner==0||corner==3?1:-1)*(rx-radius),cy=(corner<2?1:-1)*(ry-radius);
    float x=cx+Mathf.Cos(a)*radius,y=cy+Mathf.Sin(a)*radius,z=ring==0?size.z*.5f:ring==1?0:-size.z*.5f;
    v.Add(new Vector3(x,y,z));uv.Add(new Vector2(x/size.x+.5f,y/size.y+.5f));
   }
   for(int ring=1;ring<3;ring++)for(int i=0;i<sides;i++){int a=(ring-1)*sides+i,b=(ring-1)*sides+(i+1)%sides,c=ring*sides+i,d=ring*sides+(i+1)%sides;t.AddRange(new[]{a,c,b,b,c,d});}
   foreach(int end in new[]{0,2}){int center=v.Count;v.Add(new Vector3(0,0,end==0?size.z*.5f:-size.z*.5f));uv.Add(new Vector2(.5f,.5f));for(int i=0;i<sides;i++){int a=end*sides+i,b=end*sides+(i+1)%sides;t.AddRange(end==0?new[]{center,a,b}:new[]{center,b,a});}}
   var go=MeshArt.Mesh(parent,name,v.ToArray(),t.ToArray(),uv.ToArray(),material);go.transform.localPosition=at;return go;
  }
  public static GameObject Bumper(Transform parent,string name,Vector3 at,Material material)
  {
   float[] x={-1.085f,-1.07f,-1.03f,-.96f,-.72f,0,.72f,.96f,1.03f,1.07f,1.085f};
   float depth=name=="Front bumper"?.09f:.12f;
   const int sides=20;var v=new List<Vector3>();var uv=new List<Vector2>();var t=new List<int>();
   for(int ring=0;ring<x.Length;ring++)for(int i=0;i<sides;i++){
    float a=i*Mathf.PI*2/sides,c=Mathf.Cos(a),s=Mathf.Sin(a),roll=Mathf.SmoothStep(0,1,(1.085f-Mathf.Abs(x[ring]))/.125f);
    float wrap=(name=="Rear bumper"?.10f:-.16f)*Mathf.Pow(Mathf.Abs(x[ring])/1.085f,4);v.Add(new Vector3(x[ring]*.95f,Mathf.Sign(c)*Mathf.Pow(Mathf.Abs(c),.55f)*Mathf.Lerp(.043f,.11f,roll),wrap+Mathf.Sign(s)*Mathf.Pow(Mathf.Abs(s),.55f)*Mathf.Lerp(depth*.29f,depth,roll)));uv.Add(new Vector2(ring/(float)(x.Length-1),i/(float)sides));
   }
   for(int ring=1;ring<x.Length;ring++)for(int i=0;i<sides;i++){int a=(ring-1)*sides+i,b=ring*sides+i,next=(i+1)%sides;t.AddRange(new[]{a,(ring-1)*sides+next,b,(ring-1)*sides+next,ring*sides+next,b});}
   foreach(int end in new[]{0,x.Length-1}){int center=v.Count;v.Add(new Vector3(x[end]*.95f,0,(name=="Rear bumper"?.10f:-.16f)*Mathf.Pow(Mathf.Abs(x[end])/1.085f,4)));uv.Add(new(.5f,.5f));for(int i=0;i<sides;i++){int a=end*sides+i,b=end*sides+(i+1)%sides;t.AddRange(end==0?new[]{center,b,a}:new[]{center,a,b});}}
   var go=MeshArt.Mesh(parent,name,v.ToArray(),t.ToArray(),uv.ToArray(),material);go.transform.localPosition=at;return go;
  }
  public static GameObject WheelArch(Transform parent,int side,float axle,Material material)
  {
   const int segments=28;var v=new List<Vector3>();var t=new List<int>();
   for(int ring=0;ring<=segments;ring++){float a=ring*Mathf.PI/segments;foreach(var section in new[]{new Vector2(1.073f,.540f),new Vector2(1.132f,.540f),new Vector2(1.132f,.595f),new Vector2(1.073f,.595f)})v.Add(new Vector3(side*section.x,.40f+Mathf.Sin(a)*section.y,axle+Mathf.Cos(a)*section.y));}
   for(int ring=0;ring<segments;ring++)for(int p=0;p<4;p++){int a=ring*4+p,b=(ring+1)*4+p,c=ring*4+(p+1)%4,d=(ring+1)*4+(p+1)%4;t.AddRange(new[]{a,b,c,c,b,d});}
   foreach(int end in new[]{0,segments}){int center=v.Count;Vector3 point=Vector3.zero;for(int p=0;p<4;p++)point+=v[end*4+p];v.Add(point*.25f);for(int p=0;p<4;p++){int a=end*4+p,b=end*4+(p+1)%4;t.AddRange(end==0?new[]{center,a,b}:new[]{center,b,a});}}
   if(side<0)for(int i=0;i<t.Count;i+=3){int swap=t[i+1];t[i+1]=t[i+2];t[i+2]=swap;}
   return MeshArt.Mesh(parent,"Raised wheel arch trim",v.ToArray(),t.ToArray(),null,material);
  }
 }
}
