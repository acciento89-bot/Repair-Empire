using System.Collections.Generic;
using UnityEngine;
namespace Kamilunavo.RepairEmpire.Visuals
{
 // Original compact commercial coachwork. These owned visual meshes never carry
 // colliders; the vehicle root retains driving, wheel pivots and paint authority.
 public static class VanCoachworkGeometry
 {
  static readonly float[] Stations={-2.24f,-2.18f,-1.72f,-.06f,.30f,.60f,.76f,1.16f,1.32f,1.44f,1.82f,2.14f,2.22f};
  static readonly float[] Widths={.80f,.86f,.875f,.875f,.870f,.870f,.865f,.860f,.855f,.850f,.830f,.790f,.770f};
  static readonly float[] Roof={1.92f,1.99f,2.01f,2.01f,2.00f,1.98f,1.91f,1.50f,1.27f,1.19f,1.16f,1.12f,1.095f};
  const float Sill=.24f,WheelCentre=.22f,Shoulder=.07f;
  static float Arch(float z)
  {
   float height=Sill;foreach(float axle in new[]{-1.42f,1.38f}){float distance=Mathf.Abs(z-axle);if(distance<.375f)height=Mathf.Max(height,WheelCentre+Mathf.Sqrt(.375f*.375f-distance*distance));}return height;
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
   float returnDepth=(rear?.075f:.105f)*Mathf.Pow(Mathf.Clamp01(Mathf.Abs(x)/w),4)+.045f*Mathf.Pow(Mathf.Clamp01(Mathf.Abs((y-(top+Sill)*.5f)/((top-Sill)*.5f))),6);
   return z+(rear?1:-1)*blend*returnDepth;
  }
  public static float RearSkinZ(float x,float y)=>BendZ(Stations[0],x,y);
  static float UpperWidth(float z)=>Sample(Stations,Widths,z)-.035f*Mathf.Clamp01((Sample(Stations,Roof,z)-1.1f)/.6f);
  static float TopAt(float x,float z)
  {
   float w=UpperWidth(z),top=Sample(Stations,Roof,z),t=Mathf.Clamp01((Mathf.Abs(x)-(w-Shoulder))/Shoulder);float baseY=top-Shoulder+Shoulder*Mathf.Sqrt(1-t*t);float hood=Mathf.SmoothStep(0,1,(z-1.32f)/.15f)*(1-Mathf.SmoothStep(0,1,(z-2.10f)/.12f));float across=Mathf.Clamp01(1-Mathf.Abs(x)/(w-Shoulder));return baseY+hood*(.025f*Mathf.Sin(across*Mathf.PI*.5f)+.012f*Mathf.Exp(-Mathf.Pow((Mathf.Abs(x)-.41f)/.09f,2))*Mathf.Sin(across*Mathf.PI*.5f));
  }
  static float SideAt(float y,float z)
  {
   float top=Sample(Stations,Roof,z),w=UpperWidth(z);if(y>top-Shoulder){float d=Mathf.Clamp01((y-(top-Shoulder))/Shoulder);return w-Shoulder+Shoulder*Mathf.Sqrt(1-d*d);}
   float width=Mathf.Lerp(Sample(Stations,Widths,z),w,Mathf.SmoothStep(0,1,(y-.85f)/Mathf.Max(.12f,top-Shoulder-.85f)));float pressing=Mathf.Max(Mathf.Abs((z+1.14f)/.88f),Mathf.Abs((y-1.47f)/.40f));width-=.026f*Mathf.SmoothStep(0,1,(1-pressing)/.18f);return width;
  }
  public static Vector3 SideSkinPoint(int side,float y,float z,float offset=.004f)
  {
   float x=side*(SideAt(y,z)+offset);return new Vector3(x,y,BendZ(z,x,y));
  }
  static Vector3 RoofSkinPoint(float x,float z,float offset)
  {
   float y=TopAt(x,z);return new Vector3(x,y+offset,BendZ(z,x,y));
  }
  public static Vector3 RoofPoint(float x,float z,float offset=.004f)=>RoofSkinPoint(x,z,offset);
  public static float FrontSkinZ(float x,float y)
  {
   float high=Stations[Stations.Length-1];bool Inside(float z)=>Mathf.Abs(x)<=Sample(Stations,Widths,z)&&y<=TopAt(x,z)&&y>=Sill;
   if(Inside(high))return BendZ(high,x,y);
   for(int i=Stations.Length-2;i>=0;i--)if(Inside(Stations[i])){float low=Stations[i];for(int n=0;n<14;n++){float mid=(low+high)*.5f;if(Inside(mid))low=mid;else high=mid;}return BendZ(low,x,y);}else high=Stations[i];
   return BendZ(Stations[0],x,y);
  }
  static List<Vector2> CabOutline()
  {
   var outline=new[]{new Vector2(-.04f,1.12f),new Vector2(1.23f,1.12f),new Vector2(.70f,1.84f),new Vector2(-.04f,1.88f)};var loop=new List<Vector2>();
   for(int corner=0;corner<4;corner++){var at=outline[corner];var before=Vector2.Lerp(at,outline[(corner+3)%4],.12f);var after=Vector2.Lerp(at,outline[(corner+1)%4],.12f);for(int step=0;step<10;step++){float t=step/9f;loop.Add((1-t)*(1-t)*before+2*(1-t)*t*at+t*t*after);}}return loop;
  }
  static readonly Vector2[] CabAperture=CabOpening();
  static Vector2[] CabOpening(){var loop=CabOutline();var center=new Vector2(.47f,1.46f);for(int i=0;i<loop.Count;i++)loop[i]=center+(loop[i]-center)*.97f;return loop.ToArray();}
  static readonly float CabStart=CabEdge(false),CabEnd=CabEdge(true);
  static float CabEdge(bool end){float at=end?float.NegativeInfinity:float.PositiveInfinity;foreach(var p in CabAperture)at=end?Mathf.Max(at,p.x):Mathf.Min(at,p.x);return at;}
  static void CabLimits(float z,out float bottom,out float top)
  {
   z=Mathf.Clamp(z,CabStart,CabEnd);bottom=float.PositiveInfinity;top=float.NegativeInfinity;
   for(int i=0;i<CabAperture.Length;i++){var a=CabAperture[i];var b=CabAperture[(i+1)%CabAperture.Length];if(z<Mathf.Min(a.x,b.x)-.000001f||z>Mathf.Max(a.x,b.x)+.000001f)continue;
    if(Mathf.Abs(a.x-b.x)<.000001f){bottom=Mathf.Min(bottom,Mathf.Min(a.y,b.y));top=Mathf.Max(top,Mathf.Max(a.y,b.y));}else{float y=Mathf.Lerp(a.y,b.y,(z-a.x)/(b.x-a.x));bottom=Mathf.Min(bottom,y);top=Mathf.Max(top,y);}}
   if(!float.IsFinite(bottom)){bottom=1.1336f;top=1.20f;}
   top=Mathf.Min(top,Sample(Stations,Roof,z)-Shoulder-.003f);bottom=Mathf.Min(bottom,top);
  }
  static float WindowHalfWidth(float z)=>.96f*Mathf.Lerp(.64f,.70f,Mathf.Clamp01((z-.78f)/.52f));
  static float WindowCoordinate(float t,float outer,float inner)
  {
   if(t<1f/6)return Mathf.Lerp(outer,inner,t*6);if(t>5f/6)return Mathf.Lerp(-inner,-outer,(t-5f/6)*6);return Mathf.Lerp(inner,-inner,(t-1f/6)*1.5f);
  }
  static float WindowHeight(float t,float outerBottom,float outerTop,float bottom,float top)
  {
   if(t<1f/6)return Mathf.Lerp(outerBottom,bottom,t*6);if(t>5f/6)return Mathf.Lerp(top,outerTop,(t-5f/6)*6);return Mathf.Lerp(bottom,top,(t-1f/6)*1.5f);
  }
  static List<float> BodyRings()
  {
   var rings=new List<float>(Stations);rings.Add(-1.42f);rings.Add(1.38f);rings.Add(.79f);rings.Add(1.29f);foreach(var p in CabAperture)if(!rings.Exists(z=>Mathf.Abs(z-p.x)<.000001f))rings.Add(p.x);
   for(int i=0;i<=46;i++){float z=Mathf.Lerp(Stations[0],Stations[Stations.Length-1],i/46f);bool near=false;foreach(float existing in rings)if(Mathf.Abs(existing-z)<.002f){near=true;break;}if(!near)rings.Add(z);}rings.Sort();return rings;
  }
  public static GameObject Windshield(Transform parent,Material material,bool seal=false)
  {
   if(seal)return WindshieldFrame(parent,material);
   var v=new List<Vector3>();var uv=new List<Vector2>();var triangles=new List<int>();const int across=8;
   float start=seal?.765f:.78f,end=seal?1.315f:1.30f;var glassRings=BodyRings();glassRings.Add(start);glassRings.Add(end);glassRings.Sort();
   foreach(float z in glassRings)
   {
    if(z<start||z>end)continue;float t=(z-start)/(end-start),w=Mathf.Lerp(.64f,.70f,t)+(seal?.010f:0);int row=v.Count;
    for(int x=0;x<=across;x++){float at=Mathf.Lerp(-w,w,x/(float)across);v.Add(RoofSkinPoint(at,z,seal?.007f:.015f));uv.Add(new Vector2(x/(float)across,t));}
    if(row>0)for(int x=0;x<across;x++){int a=row+x,b=a-across-1;triangles.AddRange(new[]{b,a,b+1,b+1,a,a+1});}
   }
   return MeshArt.Mesh(parent,seal?"Windshield perimeter gasket":"Swept panoramic windshield",v.ToArray(),triangles.ToArray(),uv.ToArray(),material);
  }
  static GameObject WindshieldFrame(Transform parent,Material material)
  {
   var v=new List<Vector3>();var uv=new List<Vector2>();var t=new List<int>();
   void Strip(float z0,float z1,bool cross,bool right){const int n=12;int start=v.Count;for(int i=0;i<=n;i++)for(int edge=0;edge<2;edge++){float a=i/(float)n,z=cross?Mathf.Lerp(z0,z1,edge):Mathf.Lerp(z0,z1,a);float outer=Mathf.Lerp(.65f,.71f,Mathf.Clamp01((z-.765f)/.55f)),inner=WindowHalfWidth(z);float x=cross?Mathf.Lerp(-outer,outer,a):(right?1:-1)*(edge==0?inner:outer);v.Add(RoofSkinPoint(x,z,.007f));uv.Add(new Vector2(a,edge));if(i>0&&edge==1){int p=start+(i-1)*2;var a0=v[p];var b0=v[p+1];var c0=v[p+2];bool reverse=Vector3.Cross(b0-a0,c0-a0).y<0;t.AddRange(reverse?new[]{p,p+2,p+1,p+1,p+2,p+3}:new[]{p,p+1,p+2,p+1,p+3,p+2});}}}
   Strip(.765f,.79f,true,false);Strip(1.29f,1.315f,true,false);Strip(.79f,1.29f,false,false);Strip(.79f,1.29f,false,true);
   return MeshArt.Mesh(parent,"Windshield perimeter gasket",v.ToArray(),t.ToArray(),uv.ToArray(),material);
  }
  public static void Wiper(Transform parent,int side,Material material)
  {
   var path=new Vector3[7];for(int i=0;i<path.Length;i++){float t=i/(float)(path.Length-1),z=Mathf.Lerp(1.285f,1.10f,t),x=side*Mathf.Lerp(.32f,.50f,t);path[i]=RoofSkinPoint(x,z,.024f);}MeshArt.Tube(parent,"Windshield wiper",path,.010f,material,8);
  }
  static Vector3 SectionPoint(float z,float around)
  {
   around=Mathf.Repeat(around,8);int part=Mathf.FloorToInt(around);float t=around-part,w=Sample(Stations,Widths,z),top=Sample(Stations,Roof,z),x=0,y=0;const float upper=Shoulder,lower=.045f;float uw=UpperWidth(z);
   float a;CabLimits(z,out float glassBottom,out float glassTop);glassTop=Mathf.Min(glassTop,top-upper-.002f);glassBottom=Mathf.Min(glassBottom,glassTop);
   switch(part)
   {
    case 0:a=t*Mathf.PI*.5f;x=uw-upper+Mathf.Cos(a)*upper;y=top-upper+Mathf.Sin(a)*upper;break;
    case 1:x=WindowCoordinate(t,uw-upper,Mathf.Min(WindowHalfWidth(z),uw-upper-.005f));y=TopAt(x,z);break;
    case 2:a=(1+t)*Mathf.PI*.5f;x=-uw+upper+Mathf.Cos(a)*upper;y=top-upper+Mathf.Sin(a)*upper;break;
    case 3:y=WindowHeight(1-t,Sill+lower,top-upper,glassBottom,glassTop);x=-SideAt(y,z);break;
    case 4:a=(2+t)*Mathf.PI*.5f;x=-w+lower+Mathf.Cos(a)*lower;y=Sill+lower+Mathf.Sin(a)*lower;break;
    case 5:x=Mathf.Lerp(-w+lower,w-lower,t);y=Sill;break;
    case 6:a=(3+t)*Mathf.PI*.5f;x=w-lower+Mathf.Cos(a)*lower;y=Sill+lower+Mathf.Sin(a)*lower;break;
    default:y=WindowHeight(t,Sill+lower,top-upper,glassBottom,glassTop);x=SideAt(y,z);break;
   }
   float side=Mathf.SmoothStep(0,1,(Mathf.Abs(x)/w-.72f)/.20f);if(y<1.06f)y=Mathf.Max(y,Mathf.Lerp(Sill,Arch(z),side));return new Vector3(x,y,BendZ(z,x,y));
  }
  static Vector3 SectionNormal(float z,float around)
  {
   int part=Mathf.FloorToInt(Mathf.Repeat(around,8));var position=SectionPoint(z,around);
   // Aperture-aligned parameter rows can collapse outside the cab. The true
   // side-surface normal is independent of that sampling parameterization.
   if((part==3||part==7)&&position.y>Arch(z)+.0001f&&position.y>Sill+.0451f)return CabNormal(position.y,z,part==3?-1:1);
   const float e=.001f;float before=Mathf.Max(Stations[0],z-e),after=Mathf.Min(Stations[Stations.Length-1],z+e);var along=(SectionPoint(after,around)-SectionPoint(before,around))/(after-before);var aroundFace=(SectionPoint(z,around+e)-SectionPoint(z,around-e))/(2*e);var normal=Vector3.Cross(aroundFace,along);
   if(normal.sqrMagnitude<1e-12f){var p=SectionPoint(z,around);normal=new Vector3(p.x,p.y-1.25f,0);}return normal.normalized;
  }
  static Vector3 CapNormal(float x,float y,bool rear)
  {
   const float e=.001f;float Skin(float xx,float yy)=>rear?RearSkinZ(xx,yy):FrontSkinZ(xx,yy);float dx=(Skin(x+e,y)-Skin(x-e,y))/(2*e),dy=(Skin(x,y+e)-Skin(x,y-e))/(2*e);return (new Vector3(-dx,-dy,1)*(rear?-1:1)).normalized;
  }
  static Vector3 CabNormal(float y,float z,int side)
  {
   const float e=.001f;Vector3 P(float yy,float zz){float x=side*SideAt(yy,zz);return new Vector3(x,yy,BendZ(zz,x,yy));}return (Vector3.Cross((P(y+e,z)-P(y-e,z))/(2*e),(P(y,z+e)-P(y,z-e))/(2*e))*side).normalized;
  }
  public static GameObject Body(Transform parent,Material material)
  {
   var rings=BodyRings();const int sides=48;var v=new List<Vector3>();var uv=new List<Vector2>();var normals=new List<Vector3>();var triangles=new List<int>();
   foreach(float z in rings)for(int i=0;i<sides;i++){float around=i*8f/sides;v.Add(SectionPoint(z,around));normals.Add(SectionNormal(z,around));uv.Add(new Vector2(i/(float)sides,(z-Stations[0])/(Stations[Stations.Length-1]-Stations[0])));}
   for(int ring=1;ring<rings.Count;ring++)for(int i=0;i<sides;i++){
    int part=i/6,cell=i%6;float z0=rings[ring-1],z1=rings[ring];bool pane=cell>=1&&cell<5&&((part==1&&z0>=.79f-.000001f&&z1<=1.29f+.000001f)||((part==3||part==7)&&z0>=CabStart-.000001f&&z1<=CabEnd+.000001f));if(pane)continue;
    int a=(ring-1)*sides+i,b=ring*sides+i,next=(i+1)%sides;triangles.AddRange(new[]{a,(ring-1)*sides+next,b,(ring-1)*sides+next,ring*sides+next,b});}
   foreach(int end in new[]{0,rings.Count-1})
   {
    bool rear=end==0;int previous=end*sides;float at=rings[end],cy=(Sample(Stations,Roof,at)+Sill)*.5f;var edge=new Vector3[sides];for(int i=0;i<sides;i++){edge[i]=v[previous+i];normals[previous+i]=(normals[previous+i]+CapNormal(edge[i].x,edge[i].y,rear)).normalized;}
    for(int inset=1;inset<6;inset++)
    {
     float radius=1-inset/6f;int current=v.Count;
     for(int i=0;i<sides;i++){float x=edge[i].x*radius,y=Mathf.Lerp(cy,edge[i].y,radius);v.Add(new Vector3(x,y,BendZ(at,x,y)));normals.Add(CapNormal(x,y,rear));uv.Add(new Vector2(x*.45f+.5f,(y-Sill)/2));}
     for(int i=0;i<sides;i++){int a=previous+i,b=previous+(i+1)%sides,c=current+i,d=current+(i+1)%sides;triangles.AddRange(rear?new[]{a,c,b,b,c,d}:new[]{a,b,c,b,d,c});}previous=current;
    }
    int center=v.Count;v.Add(new Vector3(0,cy,BendZ(at,0,cy)));normals.Add(CapNormal(0,cy,rear));uv.Add(new Vector2(.5f,.5f));for(int i=0;i<sides;i++){int a=previous+i,b=previous+(i+1)%sides;triangles.AddRange(rear?new[]{center,b,a}:new[]{center,a,b});}
   }
   return MetalShell(parent,v,triangles,uv,normals,material);
  }
  static GameObject MetalShell(Transform parent,List<Vector3> original,List<int> indices,List<Vector2> originalUv,List<Vector3> originalNormals,Material material)
  {
   // Weld collapsed aperture corners before the offset: coincident positions
   // must share a normal or the inner skin opens microscopic cracks.
   var v=new List<Vector3>();var uv=new List<Vector2>();var normals=new List<Vector3>();var welded=new Dictionary<Vector3Int,List<int>>();var map=new int[original.Count];
   for(int i=0;i<original.Count;i++)
   {
    var p=original[i];var key=new Vector3Int(Mathf.FloorToInt(p.x*100000),Mathf.FloorToInt(p.y*100000),Mathf.FloorToInt(p.z*100000));int at=-1;
    // Neighbor cells matter: float-equivalent collapsed rows can straddle a
    // quantization boundary and otherwise produce duplicate metal returns.
    for(int x=-1;x<=1&&at<0;x++)for(int y=-1;y<=1&&at<0;y++)for(int z=-1;z<=1&&at<0;z++)if(welded.TryGetValue(key+new Vector3Int(x,y,z),out var candidates))foreach(int candidate in candidates)if((v[candidate]-p).sqrMagnitude<=1e-10f){at=candidate;break;}
    if(at<0){at=v.Count;if(!welded.TryGetValue(key,out var bucket)){bucket=new List<int>();welded.Add(key,bucket);}bucket.Add(at);v.Add(p);uv.Add(originalUv[i]);normals.Add(Vector3.zero);}map[i]=at;normals[at]+=originalNormals[i];
   }
   for(int i=0;i<normals.Count;i++)normals[i]=normals[i].normalized;
   var triangles=new List<int>();var boundary=new Dictionary<(int,int),(int a,int b,int count)>();
   for(int i=0;i<indices.Count;i+=3){int a=map[indices[i]],b=map[indices[i+1]],c=map[indices[i+2]];if(a==b||a==c||b==c||Vector3.Cross(v[b]-v[a],v[c]-v[a]).sqrMagnitude<=1e-12f)continue;triangles.AddRange(new[]{a,b,c});
    foreach(var e in new[]{(a,b),(b,c),(c,a)}){var key=e.Item1<e.Item2?e:(e.Item2,e.Item1);if(boundary.TryGetValue(key,out var edge))boundary[key]=(edge.a,edge.b,edge.count+1);else boundary[key]=(e.Item1,e.Item2,1);}}
   int count=v.Count,faces=triangles.Count;
   for(int i=0;i<count;i++){v.Add(v[i]-normals[i]*.008f);normals.Add(-normals[i]);uv.Add(uv[i]);}
   for(int i=0;i<faces;i+=3)triangles.AddRange(new[]{triangles[i+2]+count,triangles[i+1]+count,triangles[i]+count});
   foreach(var edge in boundary.Values)if(edge.count==1){int at=v.Count;var a=v[edge.a];var b=v[edge.b];var aa=v[edge.a+count];var bb=v[edge.b+count];var tangent=a-b;var thickness=aa-b;var normal=Vector3.Cross(tangent/tangent.magnitude,thickness/thickness.magnitude).normalized;v.AddRange(new[]{b,a,aa,bb});for(int i=0;i<4;i++){normals.Add(normal);uv.Add(Vector2.zero);}triangles.AddRange(new[]{at,at+1,at+2,at,at+2,at+3});}
   return MeshArt.Mesh(parent,"Bevelled service body",v.ToArray(),triangles.ToArray(),uv.ToArray(),material,normals:normals.ToArray());
  }
  public static GameObject SculptedPanel(Transform parent,string name,Vector2 center,Vector2 size,float radius,Material material,bool rear=true,float offset=.018f,float depth=.014f,float taper=0)
  {
   int cornerSteps=Mathf.Max(size.x,size.y)<.60f?4:7,count=cornerSteps*4,insets=3;var shape=new Vector2[count];var v=new List<Vector3>();var uv=new List<Vector2>();var normals=new List<Vector3>();var triangles=new List<int>();
   for(int corner=0;corner<4;corner++)for(int n=0;n<cornerSteps;n++){float a=(corner+n/(float)cornerSteps)*Mathf.PI*.5f;var c=new Vector2((corner==0||corner==3?1:-1)*(size.x*.5f-radius),(corner<2?1:-1)*(size.y*.5f-radius));shape[corner*cornerSteps+n]=c+new Vector2(Mathf.Cos(a),Mathf.Sin(a))*radius;}
   for(int layer=0;layer<2;layer++)
   {
    bool back=layer==1;int first=v.Count;
    for(int inset=0;inset<insets;inset++)for(int i=0;i<count;i++){float r=1-inset/(float)insets;var p=center+shape[i]*r;p.x=center.x+(p.x-center.x)*(1+taper*(p.y-center.y)/(size.y*.5f));float z=rear?RearSkinZ(p.x,p.y):FrontSkinZ(p.x,p.y);float outwards=offset+(back?-1:1)*depth*.5f;v.Add(new Vector3(p.x,p.y,z+(rear?-1:1)*outwards));normals.Add(CapNormal(p.x,p.y,rear)*(back?-1:1));uv.Add(new Vector2(shape[i].x*r/size.x+.5f,shape[i].y*r/size.y+.5f));}
    bool reverse=rear!=back;
    for(int ring=1;ring<insets;ring++)for(int i=0;i<count;i++){int a=first+(ring-1)*count+i,b=first+(ring-1)*count+(i+1)%count,c=first+ring*count+i,d=first+ring*count+(i+1)%count;triangles.AddRange(reverse?new[]{a,c,b,b,c,d}:new[]{a,b,c,b,d,c});}
    int pole=v.Count;float cz=rear?RearSkinZ(center.x,center.y):FrontSkinZ(center.x,center.y);v.Add(new Vector3(center.x,center.y,cz+(rear?-1:1)*(offset+(back?-1:1)*depth*.5f)));normals.Add(CapNormal(center.x,center.y,rear)*(back?-1:1));uv.Add(new Vector2(.5f,.5f));int last=first+(insets-1)*count;
    for(int i=0;i<count;i++){int a=last+i,b=last+(i+1)%count;triangles.AddRange(reverse?new[]{pole,b,a}:new[]{pole,a,b});}
   }
   // The thin panel edge has its own normals; averaging it into the face makes
   // the glass look like four folded triangles under the reflection probe.
   int other=insets*count+1,wall=v.Count;for(int layer=0;layer<2;layer++)for(int i=0;i<count;i++){int source=(layer==0?0:other)+i;v.Add(v[source]);uv.Add(uv[source]);var tangent=shape[(i+1)%count]-shape[(i+count-1)%count];normals.Add(new Vector3(tangent.y,-tangent.x,0).normalized);}
   for(int i=0;i<count;i++){int a=wall+i,b=wall+(i+1)%count,c=wall+count+i,d=wall+count+(i+1)%count;triangles.AddRange(rear?new[]{a,b,c,b,d,c}:new[]{a,c,b,b,c,d});}
   return MeshArt.Mesh(parent,name,v.ToArray(),triangles.ToArray(),uv.ToArray(),material,normals:normals.ToArray());
  }
  public static void CabGlazing(Transform parent,int side,Material material,bool seal)
  {
   var loop=CabOutline();var center=new Vector2(.47f,1.46f);
   var v=new List<Vector3>();var uv=new List<Vector2>();var normals=new List<Vector3>();var triangles=new List<int>();
   int rings=seal?2:5;for(int ring=0;ring<rings;ring++)foreach(var point in loop){float r=seal?(ring==0?1.018f:.97f):(1-ring/5f);var p=center+(point-center)*r;v.Add(new Vector3(side*(SideAt(p.y,p.x)+(seal?.005f:.012f)),p.y,p.x));normals.Add(CabNormal(p.y,p.x,side));uv.Add(new Vector2(p.x-.4f,p.y-1.3f));}
   for(int ring=1;ring<rings;ring++)for(int i=0;i<loop.Count;i++){int a=(ring-1)*loop.Count+i,b=(ring-1)*loop.Count+(i+1)%loop.Count,c=ring*loop.Count+i,d=ring*loop.Count+(i+1)%loop.Count;triangles.AddRange(side<0?new[]{a,b,c,b,d,c}:new[]{a,c,b,b,c,d});}
   if(!seal){int pole=v.Count;v.Add(new Vector3(side*(SideAt(center.y,center.x)+(seal?.005f:.012f)),center.y,center.x));normals.Add(CabNormal(center.y,center.x,side));uv.Add(new Vector2(.5f,.5f));int last=4*loop.Count;for(int i=0;i<loop.Count;i++){int a=last+i,b=last+(i+1)%loop.Count;triangles.AddRange(side<0?new[]{pole,a,b}:new[]{pole,b,a});}}
   MeshArt.Mesh(parent,seal?"Cab glass perimeter seal":"Sculpted cab side glazing",v.ToArray(),triangles.ToArray(),uv.ToArray(),material,normals:normals.ToArray());
  }
  public static GameObject RearBand(Transform parent,string name,float bottom,float top,Material material)
  {
   var v=new List<Vector3>();var t=new List<int>();var uv=new List<Vector2>();const int columns=32,rows=5;
   float standOff=name=="Orange rear livery"?.020f:.010f;
   for(int y=0;y<=rows;y++)for(int x=0;x<=columns;x++){float xx=Mathf.Lerp(-.775f,.775f,x/(float)columns),yy=Mathf.Lerp(bottom,top+(name=="Orange rear livery"?.16f*Mathf.Pow(Mathf.Abs(xx)/.775f,2):0),y/(float)rows);v.Add(new Vector3(xx,yy,RearSkinZ(xx,yy)-standOff));uv.Add(new Vector2(x/(float)columns,y/(float)rows));}
   for(int y=0;y<rows;y++)for(int x=0;x<columns;x++){int a=y*(columns+1)+x,b=a+columns+1;t.AddRange(new[]{a,b,a+1,a+1,b,b+1});}return MeshArt.Mesh(parent,name,v.ToArray(),t.ToArray(),uv.ToArray(),material);
  }
  public static GameObject SideBand(Transform parent,string name,int side,float bottom,float top,Material material)
  {
   const int samples=70,rows=4;var v=new List<Vector3>();var t=new List<int>();var uv=new List<Vector2>();float standOff=name=="Orange service band"?.018f:.009f;
   for(int i=0;i<samples;i++){
    float z0=Mathf.Lerp(-2.10f,1.44f,i/(float)samples),z1=Mathf.Lerp(-2.10f,1.44f,(i+1)/(float)samples);float lower0=Mathf.Min(top,Mathf.Max(bottom,Arch(z0)+.017f)),lower1=Mathf.Min(top,Mathf.Max(bottom,Arch(z1)+.017f));if(lower0>=top&&lower1>=top)continue;int start=v.Count;
    for(int row=0;row<=rows;row++)for(int end=0;end<2;end++){float y=Mathf.Lerp(end==0?lower0:lower1,top,row/(float)rows),z=end==0?z0:z1;v.Add(SideSkinPoint(side,y,z,standOff));uv.Add(new Vector2(end,row/(float)rows));}
    for(int row=0;row<rows;row++){int k=start+row*2;t.AddRange(side>0?new[]{k,k+2,k+3,k,k+3,k+1}:new[]{k,k+3,k+2,k,k+1,k+3});}
   }
   return MeshArt.Mesh(parent,name,v.ToArray(),t.ToArray(),uv.ToArray(),material);
  }
  public static void FitPrintedGear(Transform decal,Transform van,int side=0)
  {
   var centre=van.InverseTransformPoint(decal.position);
   foreach(var filter in decal.GetComponentsInChildren<MeshFilter>())
   {
    var mesh=filter.sharedMesh;var points=mesh.vertices;
    for(int i=0;i<points.Length;i++)
    {
     var p=van.InverseTransformPoint(filter.transform.TransformPoint(points[i]));
     if(side==0)p.z=RearSkinZ(p.x,p.y)-.004f+(p.z-centre.z);
     else p.x=side*(SideAt(p.y,p.z)+.004f)+(p.x-centre.x);
     points[i]=filter.transform.InverseTransformPoint(van.TransformPoint(p));
    }
    mesh.vertices=points;mesh.RecalculateNormals();mesh.RecalculateBounds();
   }
  }
  public static void PressedDoors(Transform parent,int side,Material seam,Material paint)
  {
   // Fine panel gaps follow the actual tapered sheet, including the short bonnet.
   Vector2[][] outlines={
    new[]{new Vector2(-2.10f,.39f),new Vector2(-2.10f,1.87f),new Vector2(-.15f,1.87f),new Vector2(-.15f,.39f)},
    new[]{new Vector2(-.10f,.39f),new Vector2(-.10f,1.92f),new Vector2(.69f,1.85f),new Vector2(1.29f,1.15f),new Vector2(1.27f,.67f)}};
   foreach(var outline in outlines)
   {
    var path=new List<Vector3>();void Flush(){if(path.Count>=2)MeshArt.Tube(parent,"Pressed door shut line",path.ToArray(),.0032f,seam,6);path.Clear();}
    for(int edge=0;edge<outline.Length;edge++)for(int n=0;n<8;n++)
    {
     var at=Vector2.Lerp(outline[edge],outline[(edge+1)%outline.Length],n/8f);
     if(at.y<Arch(at.x)+.015f){Flush();continue;}path.Add(SideSkinPoint(side,at.y,at.x,.004f));
    }
    if(path.Count>0&&outline[0].y>=Arch(outline[0].x)+.015f)path.Add(SideSkinPoint(side,outline[0].y,outline[0].x,.004f));Flush();
   }
   foreach(float y in new[]{1.00f,1.74f})
   {
    var path=new Vector3[27];for(int n=0;n<path.Length;n++){float z=Mathf.Lerp(-2.06f,-.19f,n/26f);path[n]=SideSkinPoint(side,y,z,.005f);}MeshArt.Tube(parent,"Pressed cargo reinforcement",path,.007f,paint,6);
   }
   // The bonnet perimeter and two stamped ribs give the nose its own panel.
   foreach(float x in new[]{side*.62f})
   {
    var path=new Vector3[15];for(int n=0;n<path.Length;n++){float z=Mathf.Lerp(1.43f,2.14f,n/14f);path[n]=RoofSkinPoint(x,z,.004f);}MeshArt.Tube(parent,"Bonnet panel gap",path,.0032f,seam,6);
   }
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
   float depth=name=="Front bumper"?.07f:.09f;
   const int sides=20;var v=new List<Vector3>();var uv=new List<Vector2>();var t=new List<int>();
   for(int ring=0;ring<x.Length;ring++)for(int i=0;i<sides;i++){
    float a=i*Mathf.PI*2/sides,c=Mathf.Cos(a),s=Mathf.Sin(a),roll=Mathf.SmoothStep(0,1,(1.085f-Mathf.Abs(x[ring]))/.125f);
    float wrap=(name=="Rear bumper"?.10f:-.16f)*Mathf.Pow(Mathf.Abs(x[ring])/1.085f,4);v.Add(new Vector3(x[ring]*.84f,Mathf.Sign(c)*Mathf.Pow(Mathf.Abs(c),.55f)*Mathf.Lerp(.025f,.075f,roll),wrap+Mathf.Sign(s)*Mathf.Pow(Mathf.Abs(s),.55f)*Mathf.Lerp(depth*.29f,depth,roll)));uv.Add(new Vector2(ring/(float)(x.Length-1),i/(float)sides));
   }
   for(int ring=1;ring<x.Length;ring++)for(int i=0;i<sides;i++){int a=(ring-1)*sides+i,b=ring*sides+i,next=(i+1)%sides;t.AddRange(new[]{a,(ring-1)*sides+next,b,(ring-1)*sides+next,ring*sides+next,b});}
   foreach(int end in new[]{0,x.Length-1}){int center=v.Count;v.Add(new Vector3(x[end]*.84f,0,(name=="Rear bumper"?.10f:-.16f)*Mathf.Pow(Mathf.Abs(x[end])/1.085f,4)));uv.Add(new(.5f,.5f));for(int i=0;i<sides;i++){int a=end*sides+i,b=end*sides+(i+1)%sides;t.AddRange(end==0?new[]{center,b,a}:new[]{center,a,b});}}
   var go=MeshArt.Mesh(parent,name,v.ToArray(),t.ToArray(),uv.ToArray(),material);go.transform.localPosition=at;return go;
  }
  public static GameObject WheelArch(Transform parent,int side,float axle,Material material)
  {
   const int segments=28;var v=new List<Vector3>();var t=new List<int>();
   for(int ring=0;ring<=segments;ring++){float a=ring*Mathf.PI/segments;foreach(var section in new[]{new Vector2(.863f,.350f),new Vector2(.892f,.350f),new Vector2(.892f,.375f),new Vector2(.863f,.375f)})v.Add(new Vector3(side*section.x,WheelCentre+Mathf.Sin(a)*section.y,axle+Mathf.Cos(a)*section.y));}
   for(int ring=0;ring<segments;ring++)for(int p=0;p<4;p++){int a=ring*4+p,b=(ring+1)*4+p,c=ring*4+(p+1)%4,d=(ring+1)*4+(p+1)%4;t.AddRange(new[]{a,b,c,c,b,d});}
   foreach(int end in new[]{0,segments}){int center=v.Count;Vector3 point=Vector3.zero;for(int p=0;p<4;p++)point+=v[end*4+p];v.Add(point*.25f);for(int p=0;p<4;p++){int a=end*4+p,b=end*4+(p+1)%4;t.AddRange(end==0?new[]{center,a,b}:new[]{center,b,a});}}
   if(side<0)for(int i=0;i<t.Count;i+=3){int swap=t[i+1];t[i+1]=t[i+2];t[i+2]=swap;}
   return MeshArt.Mesh(parent,"Raised wheel arch trim",v.ToArray(),t.ToArray(),null,material);
  }
 }
}
