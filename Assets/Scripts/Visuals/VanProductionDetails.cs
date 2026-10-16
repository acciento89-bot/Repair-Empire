using System.Collections.Generic;
using UnityEngine;
namespace Kamilunavo.RepairEmpire.Visuals
{
 // Original commercial-vehicle detailing, fitted to the actual authored skin.
 // Manufacturer photographs are shape references; no logos or copied mesh.
 public static class VanProductionDetails
 {
  const int TireSides=64;
  static readonly float[] TireAxial={-.080f,-.093f,-.067f,-.032f,0,.032f,.067f,.093f,.080f};
  static readonly float[] TireRadius={.188f,.242f,.306f,.320f,.320f,.320f,.306f,.242f,.188f};
  public static void RoadTire(Transform wheel,Material rubber)
  {
   MeshArt.Lathe(wheel,"Rubber tire",TireAxial,TireRadius,TireSides,rubber,Vector3.one);
  }
  static float TireSurfaceRadius(float axial,float angle)
  {
   // Bead folds overlap axially. Select the outermost intersection with the
   // same profile used by RoadTire, including its actual polygonal surface.
   float radius=0;
   for(int i=1;i<TireAxial.Length;i++)if(axial>=Mathf.Min(TireAxial[i-1],TireAxial[i])&&axial<=Mathf.Max(TireAxial[i-1],TireAxial[i]))
    radius=Mathf.Max(radius,Mathf.Lerp(TireRadius[i-1],TireRadius[i],(axial-TireAxial[i-1])/(TireAxial[i]-TireAxial[i-1])));
   float half=Mathf.PI/TireSides;
   return radius*Mathf.Cos(half)/Mathf.Cos(Mathf.Repeat(angle,2*half)-half);
  }
  public static GameObject SteelDish(Transform root,Material material)
  {
   const int sides=60;float[] radius={0,.060f,.100f,.125f,.130f,.160f,.166f,.184f,.191f};
   var v=new List<Vector3>();var t=new List<int>();var uv=new List<Vector2>();
   for(int j=0;j<radius.Length;j++)for(int i=0;i<sides;i++){float a=i*Mathf.PI*2/sides,r=radius[j],y=.111f-.016f*Mathf.SmoothStep(0,1,r/.191f);v.Add(new Vector3(Mathf.Cos(a)*r,y,Mathf.Sin(a)*r));uv.Add(new Vector2(.5f+Mathf.Cos(a)*r/.4f,.5f+Mathf.Sin(a)*r/.4f));}
   for(int j=0;j<radius.Length-1;j++)for(int i=0;i<sides;i++){if(j==4&&i%6>=1&&i%6<5)continue;int a=j*sides+i,b=j*sides+(i+1)%sides,c=a+sides,d=b+sides;t.AddRange(new[]{a,b,c,b,d,c});}
   // The ten actual cutouts reveal the brake/drum beneath. Folded lips have
   // thickness; dark painted discs are not used to imitate an opening.
   for(int vent=0;vent<10;vent++)
   {
    int first=vent*6+1,last=vent*6+5;var border=new List<int>();for(int i=first;i<=last;i++)border.Add(4*sides+i%sides);border.Add(5*sides+last%sides);for(int i=last-1;i>=first;i--)border.Add(5*sides+i%sides);
    for(int i=0;i<border.Count;i++){var a=v[border[i]];var b=v[border[(i+1)%border.Count]];int n=v.Count;v.AddRange(new[]{a,b,b-Vector3.up*.008f,a-Vector3.up*.008f});uv.AddRange(new[]{Vector2.zero,Vector2.right,Vector2.one,Vector2.up});t.AddRange(new[]{n,n+1,n+2,n,n+2,n+3});}
   }
   return MeshArt.Mesh(root,"Dished steel wheel centre",v.ToArray(),t.ToArray(),uv.ToArray(),material);
  }
  public static void TireSipes(Transform wheel,Material rubber)
  {
   var v=new List<Vector3>();var t=new List<int>();
   // Each quad stays on one angular facet and one axial profile interval.
   // A four-corner patch across the shoulder would bury its middle in rubber.
   float step=Mathf.PI*2/TireSides;
   for(int block=0;block<32;block++)for(int row=0;row<3;row++)
   {
    float start=block*2+row%2,y=(row-1)*.05f;int n=v.Count;
    foreach(float column in new[]{.3f,1f,1.7f})foreach(float edge in new[]{-.012f,.012f}){float a=(start+column)*step,r=TireSurfaceRadius(y+edge,a)+.0003f;v.Add(new Vector3(Mathf.Cos(a)*r,y+edge,Mathf.Sin(a)*r));}
    for(int column=0;column<2;column++){int a=n+column*2;t.AddRange(new[]{a,a+1,a+2,a+1,a+3,a+2});}
   }
   MeshArt.Mesh(wheel,"Road tire tread blocks",v.ToArray(),t.ToArray(),null,rubber);
  }
  public static void PrepareMoldedSurfaces(Transform root,Material plastic,Material rubber)
  {
   // Owned geometry only, once before batching. Metric diagonal projection
   // supplies stable UVs even to the original untextured tubes and trim.
   foreach(var filter in root.GetComponentsInChildren<MeshFilter>(true))
   {
    var renderer=filter.GetComponent<MeshRenderer>();if(renderer==null||(renderer.sharedMaterial!=plastic&&renderer.sharedMaterial!=rubber))continue;
    var mesh=filter.sharedMesh;var points=mesh.vertices;var uv=new Vector2[points.Length];var matrix=root.worldToLocalMatrix*filter.transform.localToWorldMatrix;
    for(int i=0;i<points.Length;i++){var p=matrix.MultiplyPoint3x4(points[i]);uv[i]=new Vector2(p.x+p.z*.71f,p.y+p.z*.47f)*3.6f;}
    mesh.uv=uv;mesh.RecalculateTangents();
   }
  }
  static void Reflector(Transform root,int side,float x,Material metal,Material plastic)
  {
   x*=side;const float y=.985f,e=.002f;float z=VanCoachworkGeometry.FrontSkinZ(x,y);
   float dx=(VanCoachworkGeometry.FrontSkinZ(x+e,y)-VanCoachworkGeometry.FrontSkinZ(x-e,y))/(2*e),dy=(VanCoachworkGeometry.FrontSkinZ(x,y+e)-VanCoachworkGeometry.FrontSkinZ(x,y-e))/(2*e);
   var pivot=new GameObject("Recessed headlamp projector").transform;pivot.SetParent(root,false);pivot.localPosition=new Vector3(x,y,z+.025f);pivot.localRotation=Quaternion.FromToRotation(Vector3.up,new Vector3(-dx,-dy,1).normalized);
   MeshArt.Lathe(pivot,"Hollow projector retaining cup",new[]{-.021f,-.021f,-.001f,-.001f,-.019f,-.019f},new[]{0f,.060f,.060f,.052f,.052f,0f},20,plastic,Vector3.one);
   MeshArt.Lathe(pivot,"Concave optical reflector",new[]{.006f,.002f,-.005f,-.010f,-.011f},new[]{.055f,.051f,.037f,.018f,0f},20,metal,Vector3.one);
   MeshArt.Lathe(pivot,"Projector optical core",new[]{.001f,.003f,.005f},new[]{.020f,.019f,0f},20,plastic,Vector3.one);
  }
  static void SidePlate(Transform root,string name,int side,Vector2 center,Vector2 size,float radius,float offset,Material material)
  {
   const int count=24;var v=new List<Vector3>();var t=new List<int>();var uv=new List<Vector2>();
   for(int ring=0;ring<3;ring++)for(int i=0;i<count;i++){int corner=i/6;float a=(corner+i%6/6f)*Mathf.PI*.5f;var c=new Vector2((corner==0||corner==3?1:-1)*(size.x*.5f-radius),(corner<2?1:-1)*(size.y*.5f-radius));var p=center+(c+new Vector2(Mathf.Cos(a),Mathf.Sin(a))*radius)*(1-ring/3f);v.Add(VanCoachworkGeometry.SideSkinPoint(side,p.y,p.x,offset+(ring==0?0:.004f)));uv.Add(Vector2.zero);}
   for(int ring=1;ring<3;ring++)for(int i=0;i<count;i++){int a=(ring-1)*count+i,b=(ring-1)*count+(i+1)%count,c=a+count,d=b+count;t.AddRange(side>0?new[]{a,c,b,b,c,d}:new[]{a,b,c,b,d,c});}
   int pole=v.Count;v.Add(VanCoachworkGeometry.SideSkinPoint(side,center.y,center.x,offset+.004f));uv.Add(Vector2.one*.5f);for(int i=0;i<count;i++)t.AddRange(side>0?new[]{pole,2*count+(i+1)%count,2*count+i}:new[]{pole,2*count+i,2*count+(i+1)%count});
   MeshArt.Mesh(root,name,v.ToArray(),t.ToArray(),uv.ToArray(),material);
  }
  static void Fender(Transform root,int side,float axle,Material paint,Material rubber)
  {
   const int count=40;var v=new List<Vector3>();var t=new List<int>();float[] r={.375f,.390f,.435f,.510f};
   for(int ring=0;ring<r.Length;ring++)for(int i=0;i<=count;i++){float a=i*Mathf.PI/count,y=.22f+Mathf.Sin(a)*r[ring],z=axle+Mathf.Cos(a)*r[ring];var p=VanCoachworkGeometry.SideSkinPoint(side,y,z,.002f);float crown=ring==1?.035f:ring==2?.022f:0;p.x+=side*crown;v.Add(p);}
   for(int j=0;j<r.Length-1;j++)for(int i=0;i<count;i++){int a=j*(count+1)+i,b=a+1,c=a+count+1,d=c+1;t.AddRange(side>0?new[]{a,b,c,b,d,c}:new[]{a,c,b,b,c,d});}
   MeshArt.Mesh(root,axle>0?"Sculpted front quarter fender":"Sculpted rear wheel shoulder",v.ToArray(),t.ToArray(),null,paint);
   v.Clear();t.Clear();for(int i=0;i<=count;i++){float a=i*Mathf.PI/count;foreach(float x in new[]{.62f,.903f})v.Add(new Vector3(side*x,.22f+Mathf.Sin(a)*.370f,axle+Mathf.Cos(a)*.370f));if(i<count){int k=i*2;t.AddRange(side>0?new[]{k,k+2,k+1,k+1,k+2,k+3}:new[]{k,k+1,k+2,k+1,k+3,k+2});}}
   MeshArt.Mesh(root,"Deep wheelhouse liner",v.ToArray(),t.ToArray(),null,rubber);
   v.Clear();t.Clear();v.Add(new Vector3(side*.62f,.22f,axle));
   for(int i=0;i<=count;i++){float a=i*Mathf.PI/count;v.Add(new Vector3(side*.62f,.22f+Mathf.Sin(a)*.370f,axle+Mathf.Cos(a)*.370f));if(i<count)t.AddRange(side>0?new[]{0,i+2,i+1}:new[]{0,i+1,i+2});}
   MeshArt.Mesh(root,"Wheelhouse inboard liner",v.ToArray(),t.ToArray(),null,rubber);
  }
  static GameObject Lamp(Transform root,int side,string name,Material material,float scale,float offset,bool housing=false)
  {
   var corners=new[]{new Vector2(.400f,.970f),new Vector2(.485f,1.095f),new Vector2(.765f,1.078f),new Vector2(.802f,1.015f),new Vector2(.762f,.850f),new Vector2(.525f,.865f)};var center=new Vector2(.615f,.980f);var loop=new List<Vector2>();
   for(int c=0;c<corners.Length;c++)for(int i=0;i<5;i++){float q=i/5f;var at=corners[c];var before=Vector2.Lerp(at,corners[(c+corners.Length-1)%corners.Length],.15f);var after=Vector2.Lerp(at,corners[(c+1)%corners.Length],.15f);loop.Add(center+((1-q)*(1-q)*before+2*(1-q)*q*at+q*q*after-center)*scale);}
   var v=new List<Vector3>();var n=new List<Vector3>();var uv=new List<Vector2>();var t=new List<int>();int count=loop.Count;
   Vector3 Point(Vector2 p,float stand){p.x*=side;return new Vector3(p.x,p.y,VanCoachworkGeometry.FrontSkinZ(p.x,p.y)+stand);}
   Vector3 Normal(Vector2 p){const float e=.001f;float x=p.x*side,y=p.y;float dx=(VanCoachworkGeometry.FrontSkinZ(x+e,y)-VanCoachworkGeometry.FrontSkinZ(x-e,y))/(2*e),dy=(VanCoachworkGeometry.FrontSkinZ(x,y+e)-VanCoachworkGeometry.FrontSkinZ(x,y-e))/(2*e);return new Vector3(-dx,-dy,1).normalized;}
   if(housing)
   {
    // Closed annular moulding: outer wall, front lip, inner wall, rear lip.
    // There is no opaque plate across the reflector opening.
    for(int ring=0;ring<4;ring++)foreach(var p0 in loop){var p=Vector2.Lerp(center,p0,ring<2?1:.94f);v.Add(Point(p,ring==0||ring==3?.004f:offset));uv.Add(new Vector2((p.x-.400f)/.402f,(p.y-.850f)/.245f));}
    for(int ring=0;ring<4;ring++)for(int i=0;i<count;i++){int a=ring*count+i,b=((ring+1)%4)*count+i,c=ring*count+(i+1)%count,d=((ring+1)%4)*count+(i+1)%count;t.AddRange(side>0?new[]{a,b,c,c,b,d}:new[]{a,c,b,c,d,b});}
    return MeshArt.Mesh(root,name,v.ToArray(),t.ToArray(),uv.ToArray(),material);
   }
   for(int ring=0;ring<4;ring++)foreach(var p0 in loop){var p=Vector2.Lerp(p0,center,ring/4f);v.Add(Point(p,offset+(ring==0?0:.003f)));n.Add(Normal(p));uv.Add(new Vector2((p.x-.400f)/.402f,(p.y-.850f)/.245f));}
   for(int ring=1;ring<4;ring++)for(int i=0;i<count;i++){int a=(ring-1)*count+i,b=(ring-1)*count+(i+1)%count,c=a+count,d=b+count;t.AddRange(side>0?new[]{a,b,c,b,d,c}:new[]{a,c,b,b,c,d});}
   int pole=v.Count;v.Add(Point(center,offset+.003f));n.Add(Normal(center));uv.Add(new Vector2((center.x-.400f)/.402f,(center.y-.850f)/.245f));for(int i=0;i<count;i++)t.AddRange(side>0?new[]{pole,3*count+i,3*count+(i+1)%count}:new[]{pole,3*count+(i+1)%count,3*count+i});
   // Outline winds clockwise in XY; positive-X lamp requires reversal.
   for(int i=0;i<t.Count;i+=3){int k=t[i+1];t[i+1]=t[i+2];t[i+2]=k;}
   return MeshArt.Mesh(root,name,v.ToArray(),t.ToArray(),uv.ToArray(),material,normals:n.ToArray());
  }
  public static void Build(Transform root,Material paint,Material livery,Material plastic,Material rubber,Material metal,Material amber,Material lamp)
  {
   foreach(int side in new[]{-1,1})
   {
    Fender(root,side,1.38f,paint,rubber);Fender(root,side,-1.42f,livery,rubber);
    SidePlate(root,"Side impact protection molding",side,new Vector2(-.47f,.695f),new Vector2(3.05f,.105f),.035f,.023f,plastic);
    foreach(float z in new[]{.05f,-.26f})SidePlate(root,"Recessed door handle pocket",side,new Vector2(z,1.045f),new Vector2(.215f,.063f),.025f,.008f,plastic);
    SidePlate(root,"Front fender repeater base",side,new Vector2(1.49f,.83f),new Vector2(.17f,.048f),.017f,.009f,plastic);SidePlate(root,"Amber fender indicator",side,new Vector2(1.49f,.83f),new Vector2(.135f,.027f),.010f,.016f,amber);
    SidePlate(root,"Lower sliding-door runner",side,new Vector2(-.59f,.335f),new Vector2(.82f,.025f),.009f,.014f,metal);
    var fuel=new Vector3[33];for(int i=0;i<fuel.Length;i++){float a=i*Mathf.PI*2/32;fuel[i]=VanCoachworkGeometry.SideSkinPoint(side,.84f+Mathf.Sin(a)*.071f,.0f+Mathf.Cos(a)*.073f,.022f);}if(side<0)MeshArt.Tube(root,"Fuel filler door seam",fuel,.0027f,plastic,6);
    MeshArt.BevelBox(root,"Mirror turn repeater",new(side*1.035f,1.395f,1.272f),new(.09f,.021f,.012f),.006f,amber);MeshArt.BevelBox(root,"Mirror lower blind-spot glass",new(side*1.00f,1.296f,1.089f),new(.091f,.052f,.008f),.013f,metal);
    Lamp(root,side,"Swept headlamp gasket",plastic,1.045f,.038f,true);Lamp(root,side,"Formed headlamp reflector backing",metal,.985f,.006f);Reflector(root,side,.505f,metal,plastic);Reflector(root,side,.700f,metal,plastic);Lamp(root,side,"Swept optical headlamp",lamp,1,.042f);
    var drl=new Vector3[15];for(int i=0;i<drl.Length;i++){float t=i/14f,x=side*Mathf.Lerp(.525f,.750f,t),y=.880f+.007f*t;drl[i]=new Vector3(x,y,VanCoachworkGeometry.FrontSkinZ(x,y)+.033f);}MeshArt.Tube(root,"Daylight guide inside lamp",drl,.007f,paint,6);
    for(int h=0;h<2;h++){float y=.65f+h*.77f,x=side*.751f;VanCoachworkGeometry.SculptedPanel(root,"Hinge central knuckle",new Vector2(x,y),new Vector2(.045f,.025f),.009f,metal,true,.022f,.014f);}
    VanCoachworkGeometry.SculptedPanel(root,"Rear plate-light housing",new Vector2(-.34f+side*.18f,.575f),new Vector2(.075f,.028f),.010f,plastic,true,.021f,.016f);
   }
   // Actual curved bonnet crown is in the body surface. These narrow joints
   // and cowl vents sit on that same mapping instead of hovering over a box.
   var cowlV=new List<Vector3>();var cowlT=new List<int>();for(int z=0;z<4;z++)for(int x=0;x<=16;x++){cowlV.Add(VanCoachworkGeometry.RoofPoint(Mathf.Lerp(-.65f,.65f,x/16f),Mathf.Lerp(1.312f,1.416f,z/3f),.007f));if(z<3&&x<16){int a=z*17+x;cowlT.AddRange(new[]{a,a+17,a+1,a+1,a+17,a+18});}}MeshArt.Mesh(root,"Recessed windscreen scuttle tray",cowlV.ToArray(),cowlT.ToArray(),null,plastic);
   for(int i=0;i<12;i++){float x=-.55f+i*.10f;var path=new[]{VanCoachworkGeometry.RoofPoint(x,1.335f,.011f),VanCoachworkGeometry.RoofPoint(x,1.385f,.011f)};MeshArt.Tube(root,"Windscreen scuttle vent",path,.005f,plastic,6);}
   foreach(float x in new[]{-.60f,-.40f,.40f,.60f}){var path=new Vector3[25];for(int i=0;i<path.Length;i++)path[i]=VanCoachworkGeometry.RoofPoint(x,Mathf.Lerp(-1.99f,.51f,i/24f),.007f);MeshArt.Tube(root,"Pressed roof rain channel",path,.004f,paint,6);}
   for(int i=0;i<5;i++){var path=new Vector3[9];float y=.645f+i*.075f,w=Mathf.Lerp(.52f,.35f,i/4f);for(int j=0;j<path.Length;j++){float x=Mathf.Lerp(-w,w,j/8f);path[j]=new Vector3(x,y,VanCoachworkGeometry.FrontSkinZ(x,y)+.035f);}MeshArt.Tube(root,"Molded grille blade",path,.011f,i==0||i==4?metal:plastic,6);}
   foreach(float x in new[]{-.64f,-.28f,.28f,.64f}){VanCoachworkGeometry.SculptedPanel(root,"Front parking sensor",new Vector2(x,.455f),new Vector2(.028f,.028f),.012f,plastic,false,.032f,.004f);VanCoachworkGeometry.SculptedPanel(root,"Rear parking sensor",new Vector2(x,.31f),new Vector2(.028f,.028f),.012f,metal,true,.12f,.004f);}
   MeshArt.BevelBox(root,"Rear molded step tread",new(0,.34f,-2.315f),new(.85f,.035f,.12f),.014f,plastic);for(int i=0;i<15;i++)MeshArt.Box(root,"Rear step traction rib",new(-.38f+i*.054f,.36f,-2.315f),new(.009f,.006f,.083f),metal);
   VanCoachworkGeometry.SculptedPanel(root,"Rear reversing camera",new Vector2(.08f,1.035f),new Vector2(.05f,.026f),.010f,plastic,true,.023f,.015f);
  }
  public static void ReleaseBatchedDetails(Transform root)
  {
   var keep=new HashSet<string>{"Bevelled service body","Rubber tire","Swept panoramic windshield","Windshield perimeter gasket","Cab glass perimeter seal","Sculpted cab side glazing","Navy lower service wrap","Orange service band","Rear navy service wrap","Orange rear livery","Rear bumper","Front bumper","Rear lamp housing","Number plate surround","Raised wheel arch trim","Dished steel wheel centre"};
   foreach(var filter in root.GetComponentsInChildren<MeshFilter>(true))
   {
    var renderer=filter.GetComponent<MeshRenderer>();if(renderer==null||renderer.enabled||keep.Contains(filter.name)||filter.transform.IsChildOf(root.Find("Repair gear and wrench")))continue;
    var mesh=filter.sharedMesh;filter.sharedMesh=null;ArtLifetime.Release(filter.gameObject,mesh);
    if(Application.isPlaying){Object.Destroy(filter);Object.Destroy(renderer);}else{Object.DestroyImmediate(filter);Object.DestroyImmediate(renderer);}
   }
  }
 }
}
