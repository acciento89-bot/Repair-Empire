using System.Collections.Generic;
using UnityEngine;

namespace Kamilunavo.RepairEmpire.Visuals
{
 public static class DistrictArtGeometry
 {
  // Longitudinal sections author the cargo shoulder, rolled roof, windscreen
  // transition and hood as one continuous surface rather than stacked boxes.
  public static GameObject VanShell(Transform parent,Material material)
  {
   float[] z={-2.18f,-2.08f,-1.72f,.28f,.58f,.95f,1.28f,1.63f,1.92f,2.11f};
   float[] width={.89f,1.00f,1.055f,1.055f,1.03f,1.01f,.99f,.965f,.94f,.86f};
   float[] roof={2.18f,2.37f,2.40f,2.39f,2.31f,2.12f,1.77f,1.31f,1.20f,1.06f};
   const int sides=28;var vertices=new List<Vector3>();var uv=new List<Vector2>();var triangles=new List<int>();
   for(int ring=0;ring<z.Length;ring++)for(int i=0;i<=sides;i++){
    float angle=i*Mathf.PI*2/sides,c=Mathf.Cos(angle),s=-Mathf.Sin(angle),bottom=.42f;
    float x=width[ring]*Mathf.Sign(c)*Mathf.Pow(Mathf.Abs(c),.24f),y=(roof[ring]+bottom)*.5f+(roof[ring]-bottom)*.5f*Mathf.Sign(s)*Mathf.Pow(Mathf.Abs(s),.34f);
    vertices.Add(new Vector3(x,y,z[ring]));uv.Add(new Vector2((float)i/sides,(float)ring/(z.Length-1)));
   }
   for(int ring=0;ring<z.Length-1;ring++)for(int i=0;i<sides;i++){int a=ring*(sides+1)+i,b=a+sides+1;triangles.AddRange(new[]{a,b,a+1,a+1,b,b+1});}
   foreach(int end in new[]{0,z.Length-1}){int center=vertices.Count;vertices.Add(new Vector3(0,(roof[end]+.42f)*.5f,z[end]));uv.Add(new Vector2(.5f,.5f));int start=end*(sides+1);for(int i=0;i<sides;i++)triangles.AddRange(end==0?new[]{start+i,start+i+1,center}:new[]{start+i,center,start+i+1});}
   return MeshArt.Mesh(parent,"Bevelled service body",vertices.ToArray(),triangles.ToArray(),uv.ToArray(),material);
  }
  public static GameObject CargoDoor(Transform parent,Vector3 at,Material material){
   const int corners=12,loop=corners*4;var v=new List<Vector3>();var uv=new List<Vector2>();var triangles=new List<int>();float[] z={.022f,-.025f,-.034f},inset={.014f,0f,.02f};
   for(int ring=0;ring<3;ring++)for(int corner=0;corner<4;corner++)for(int n=0;n<corners;n++){float a=(corner+(float)n/corners)*Mathf.PI*.5f;float r=.115f,w=.44f-inset[ring],h=.85f-inset[ring];float cx=(corner==0||corner==3?1:-1)*(w-r),cy=(corner<2?1:-1)*(h-r);v.Add(new Vector3(cx+Mathf.Cos(a)*r,cy+Mathf.Sin(a)*r,z[ring]));uv.Add(new Vector2((cx+Mathf.Cos(a)*r)/.88f+.5f,(cy+Mathf.Sin(a)*r)/1.70f+.5f));}
   for(int ring=1;ring<3;ring++)for(int side=0;side<loop;side++){int a=(ring-1)*loop+side,b=(ring-1)*loop+(side+1)%loop,c=ring*loop+side,d=ring*loop+(side+1)%loop;triangles.AddRange(new[]{a,c,b,b,c,d});}
   int rear=v.Count;v.Add(new Vector3(0,0,z[0]));uv.Add(new(.5f,.5f));int front=v.Count;v.Add(new Vector3(0,0,z[2]));uv.Add(new(.5f,.5f));for(int side=0;side<loop;side++)triangles.AddRange(new[]{rear,side,(side+1)%loop,front,2*loop+(side+1)%loop,2*loop+side});
   var door=MeshArt.Mesh(parent,"Rear sculpted cargo door",v.ToArray(),triangles.ToArray(),uv.ToArray(),material);door.transform.localPosition=at;return door;
  }
  public static GameObject Pane(Transform parent,string name,Vector3[] outline,Material material)
  {return MeshArt.Mesh(parent,name,outline,new[]{0,2,1,0,3,2},new[]{Vector2.zero,Vector2.right,Vector2.one,Vector2.up},material);}

  // Rigid vehicle detail is grouped by material. Wheels are grouped separately,
  // preserving their animated roots. Original buffers remain explicitly owned.
  public static void Combine(Transform root,bool excludeWheels)
  {
   var groups=new Dictionary<Material,List<MeshFilter>>();
   foreach(var filter in root.GetComponentsInChildren<MeshFilter>()){
    var renderer=filter.GetComponent<MeshRenderer>();if(renderer==null||!renderer.enabled||renderer.sharedMaterials.Length!=1||filter.sharedMesh==null)continue;
    bool wheel=false;for(var node=filter.transform;node!=root&&node!=null;node=node.parent)if(node.name=="Wheel"){wheel=true;break;}
    if(excludeWheels&&wheel)continue;var material=renderer.sharedMaterial;if(!groups.TryGetValue(material,out var list)){list=new List<MeshFilter>();groups.Add(material,list);}list.Add(filter);
   }
   foreach(var group in groups){if(group.Value.Count<2)continue;var instances=new CombineInstance[group.Value.Count];for(int i=0;i<instances.Length;i++)instances[i]=new CombineInstance{mesh=group.Value[i].sharedMesh,transform=root.worldToLocalMatrix*group.Value[i].transform.localToWorldMatrix};
    var mesh=new Mesh{name="Rigid vehicle "+group.Key.name};mesh.CombineMeshes(instances,true,true);mesh.RecalculateBounds();
    var go=new GameObject(mesh.name,typeof(MeshFilter),typeof(MeshRenderer));go.transform.SetParent(root,false);go.GetComponent<MeshFilter>().sharedMesh=mesh;go.GetComponent<MeshRenderer>().sharedMaterial=group.Key;ArtLifetime.Own(go,mesh);
    foreach(var filter in group.Value)filter.GetComponent<MeshRenderer>().enabled=false;
   }
  }
 }

 // One small owned material/texture kit per district, shared by all its buildings
 // and plants. It has no mutable global cache and no dependency on physics.
 public sealed class UrbanArtKit
 {
  readonly Transform owner;
  public readonly Material Brick,Plaster,Trim,Glass,Roof,LeafMass,Leaves,Metal;readonly Material paleFacade,goldenCrown,shopTeal,shopCanvas;
  public UrbanArtKit(Transform root,Material stone,Material glass,Material steel)
  {
   owner=root;Metal=steel;Glass=Own("UrbanResidentialGlazing",new Color(.33f,.43f,.48f));Glass.SetFloat("_Metallic",.18f);Glass.SetFloat("_Glossiness",.73f);
   Brick=Own("UrbanWarmBrick",Color.white);Brick.shader=Resources.Load<Shader>("RepairResidentialMasonry");Brick.mainTexture=Texture(false);Brick.SetFloat("_Relief",.13f);
   Plaster=Own("UrbanWarmPlaster",new Color(.91f,.84f,.70f));Plaster.mainTexture=Texture(true);
   Trim=Own("UrbanLimestoneTrim",new Color(.83f,.79f,.66f));Trim.mainTexture=Plaster.mainTexture;
   paleFacade=Own("UrbanWarmPlasterPale",new Color(.95f,.91f,.82f));paleFacade.mainTexture=Plaster.mainTexture;
   goldenCrown=Own("UrbanGoldenCrown",new Color(.47f,.53f,.16f));shopTeal=Own("UrbanPaintedShopTeal",new Color(.12f,.26f,.25f));shopCanvas=Own("UrbanCanvasWarmOchre",new Color(.72f,.44f,.22f));
   Roof=Own("UrbanSlateRoof",new Color(.19f,.24f,.27f));
   LeafMass=Own("UrbanCrownShadow",new Color(.22f,.34f,.12f));
   Leaves=Own("UrbanLeafDetail",new Color(.69f,.80f,.35f));Leaves.shader=Resources.Load<Shader>("Foliage");Leaves.mainTexture=LeafTexture();Leaves.SetFloat("_Cutoff",.42f);
  }
  Material Own(string name,Color color){var material=new Material(Resources.Load<Material>("Materials/Surface")){name=name,color=color};material.SetFloat("_Glossiness",.12f);ArtLifetime.Own(owner.gameObject,material);return material;}
  Texture2D Texture(bool plaster)
  {
   const int size=128;var pixels=new Color[size*size];
   for(int y=0;y<size;y++)for(int x=0;x<size;x++){
    int row=y/16,xx=(x+(row%2)*16)%32;bool mortar=y%16<2||xx<2;float grain=Mathf.Sin(x*12.7f+y*4.9f)*.025f+Mathf.Sin(x*.31f+y*.17f)*.02f;
    float brickShade=.88f+Mathf.Sin((xx/32f+row)*3.71f)*.06f;
    pixels[y*size+x]=plaster?new Color(.91f+grain,.91f+grain,.91f+grain):mortar?new Color(.62f,.59f,.52f):new Color(.66f*brickShade+grain,.32f*brickShade+grain,.20f*brickShade+grain);
   }
   var texture=new Texture2D(size,size,TextureFormat.RGB24,true){name=plaster?"UrbanPlasterGrain":"UrbanBrickCourses",wrapMode=TextureWrapMode.Repeat,filterMode=FilterMode.Bilinear};texture.SetPixels(pixels);texture.Apply(true,true);ArtLifetime.Own(owner.gameObject,texture);return texture;
  }
  Texture2D LeafTexture()
  {
   const int size=64;var pixels=new Color[size*size];
   for(int y=0;y<size;y++)for(int x=0;x<size;x++){
    float u=x/(float)(size-1)*2-1,v=y/(float)(size-1)*2-1;float radius=Mathf.Sqrt(Mathf.Max(0,1-v*v))*(.57f+.05f*Mathf.Sin(v*35));float alpha=Mathf.Abs(u)<radius?1:0;float vein=1-Mathf.Clamp01(Mathf.Abs(u)*32);float light=.70f+.20f*(1-v)*.5f+vein*.08f;
    pixels[y*size+x]=new Color(light*.69f,light,light*.38f,alpha);
   }
   var texture=new Texture2D(size,size,TextureFormat.RGBA32,true){name="UrbanSingleLeafDetail",wrapMode=TextureWrapMode.Clamp,filterMode=FilterMode.Bilinear};texture.SetPixels(pixels);texture.Apply(true,true);ArtLifetime.Own(owner.gameObject,texture);return texture;
  }
  static GameObject Box(Transform parent,string name,Vector3 at,Vector3 scale,Material mat,float bevel=0){var go=bevel>0?MeshArt.BevelBox(parent,name,at,scale,bevel,mat):MeshArt.Box(parent,name,at,scale,mat);
   // Physical brick courses repeat at masonry scale rather than stretching over a pier.
   if(mat.name.StartsWith("UrbanWarmBrick")||mat.name.StartsWith("UrbanWarmPlaster")){var mesh=go.GetComponent<MeshFilter>().sharedMesh;var points=mesh.vertices;var normals=mesh.normals;var uv=new Vector2[points.Length];for(int i=0;i<points.Length;i++){var point=points[i]+at;var n=normals[i];uv[i]=Mathf.Abs(n.y)>.7f?new Vector2(point.x/.92f,point.z/.62f):Mathf.Abs(n.x)>Mathf.Abs(n.z)?new Vector2(point.z/.92f,point.y/.62f):new Vector2(point.x/.92f,point.y/.62f);}mesh.uv=uv;if(mat.shader.name=="Repair/ResidentialMasonry")mesh.RecalculateTangents();}return go;}


  public void Facade(float x,float z,float height,float width,float depth,int facing,int district)
  {
   string[] names={"Brick terrace facade","Recessed office facade","Stepped modern facade","Corner mansard facade"};
   var root=new GameObject(names[district]).transform;root.SetParent(owner,false);root.localPosition=new Vector3(x,0,z);root.localRotation=Quaternion.Euler(0,facing*90,0);
   Material facade=district==0?Brick:district==3?paleFacade:Plaster;
   if(district==2){Envelope(root,depth,width,7.0f,Plaster,4,false);var upper=new GameObject("Setback upper residence").transform;upper.SetParent(root,false);upper.localPosition=new Vector3(1.25f,7,-1.0f);Envelope(upper,depth*.72f,width-2,height-7,Plaster,3,false);FlatRoof(upper,depth*.72f,width-2,height-7);Box(root,"Modern terrace parapet",new Vector3(-depth*.37f,7.35f,width*.28f),new Vector3(depth*.25f,.55f,.18f),Trim);}
   else{Envelope(root,depth,width,height,facade,district==1?5:4,true);if(district==0||district==3)PitchedRoof(root,depth,width,height,district==3);else FlatRoof(root,depth,width,height);}
   // A few broad authored features define each frontage, rather than covering
   // every wall with the same dense window-grid ornament.
   float front=width*.5f;Storefront(root,depth,front,district);
   if(district==1){for(int column=0;column<3;column++)Box(root,"Office projecting vertical fin",new Vector3((column-1)*depth*.31f,height*.5f,front+.11f),new Vector3(.10f,height,.17f),Trim);}
   if(district==0||district==3){for(int floor=2;floor<height/3;floor+=2){float y=floor*3;float xx=district==0?-depth*.22f:depth*.20f;Box(root,"Recessed residential balcony",new Vector3(xx,y-.80f,front+.35f),new Vector3(3.4f,.18f,.80f),Trim);Box(root,"Balcony metal rail",new Vector3(xx,y-.08f,front+.74f),new Vector3(3.4f,.08f,.06f),Metal);for(int post=0;post<6;post++)Box(root,"Balcony slender baluster",new Vector3(xx-1.5f+post*.60f,y-.46f,front+.74f),new Vector3(.05f,.80f,.05f),Metal);}}
   Box(root,"Urban shop sign backing",new Vector3(0,3.08f,front+.14f),new Vector3(depth*.47f,.38f,.12f),Roof,.03f);
   VanArt.Text(root,new[]{"RIVERSIDE MARKET","CITY OFFICES","RIVERSIDE LOFTS","NEIGHBOURHOOD CAFÉ"}[district],new Vector3(0,3.08f,front+.21f),.21f,new Color(.93f,.89f,.77f),Quaternion.Euler(0,180,0));
   foreach(int side in new[]{-1,1}){Box(root,"Shop stone planter",new Vector3(side*depth*.42f,.35f,front+.36f),new Vector3(.78f,.66f,.82f),Trim,.07f);Shrub(root,new Vector3(side*depth*.42f,.78f,front+.36f),.55f);}
  }
  void Storefront(Transform root,float span,float front,int district){
   var paint=district%2==0?shopTeal:Roof;var canvas=district==3?shopTeal:shopCanvas;
   // Two differently recessed shops share a masonry frontage, not a flat ground-floor window grid.
   for(int shop=0;shop<2;shop++){float center=(shop==0?-1:1)*span*.235f,width=span*.405f;
    Box(root,"Painted shopfront lower panel",new Vector3(center,.39f,front+.17f),new Vector3(width,.70f,.22f),paint,.025f);
    foreach(int edge in new[]{-1,1}){float xx=center+edge*width*.5f;Box(root,"Shopfront carved upright",new Vector3(xx,1.42f,front+.19f),new Vector3(.15f,2.80f,.29f),paint);Box(root,"Shopfront upright capital",new Vector3(xx,2.66f,front+.22f),new Vector3(.25f,.17f,.34f),Trim);}
    for(int pane=0;pane<3;pane++){float xx=center+(pane-1)*width*.27f;Box(root,"Shop display transom",new Vector3(xx,2.29f,front+.11f),new Vector3(width*.27f,.045f,.12f),paint);Box(root,"Shop window slim mullion",new Vector3(xx,1.49f,front+.12f),new Vector3(.045f,1.68f,.12f),paint);}
    var v=new List<Vector3>();var t=new List<int>();var uv=new List<Vector2>();const int curve=8;
    for(int row=0;row<=curve;row++){float f=(float)row/curve,yy=2.99f-.27f*Mathf.Sin(f*Mathf.PI*.5f),zz=front+.08f+f*.98f;foreach(int side in new[]{-1,1}){v.Add(new Vector3(center+side*width*.53f,yy,zz));uv.Add(new Vector2(side<0?0:1,f));}if(row>0){int k=row*2;t.AddRange(new[]{k-2,k,k-1,k-1,k,k+1});}}
    MeshArt.Mesh(root,"Shop canvas awning",v.ToArray(),t.ToArray(),uv.ToArray(),canvas);
    Box(root,"Awning hanging valance",new Vector3(center,2.64f,front+1.055f),new Vector3(width*1.06f,.16f,.026f),canvas);
    for(int scallop=0;scallop<10;scallop++){float xx=center-width*.50f+(scallop+.5f)*width*.10f;var flap=MeshArt.Ring(root,"Awning scalloped hem",width*.055f,width*.055f,0,canvas,8,180);flap.transform.localPosition=new Vector3(xx,2.56f,front+1.072f);flap.transform.localRotation=Quaternion.Euler(90,0,0);}
   }
   // A separate narrow entrance gives the block an authored domestic address.
   float door=-span*.5f+span*.105f;Box(root,"Shop recessed entrance",new Vector3(door,1.24f,front+.12f),new Vector3(1.12f,2.20f,.10f),shopTeal,.02f);Box(root,"Entrance glass inset",new Vector3(door,1.68f,front+.18f),new Vector3(.83f,1.09f,.025f),Glass);Box(root,"Entrance lower raised panel",new Vector3(door,.60f,front+.19f),new Vector3(.83f,.55f,.035f),paint);Box(root,"Entrance brass pull",new Vector3(door+.36f,1.17f,front+.23f),new Vector3(.032f,.25f,.025f),Metal);
   for(int dentil=0;dentil<20;dentil++)Box(root,"Shop cornice dentil",new Vector3(-span*.48f+dentil*span*.96f/19,3.43f,front+.22f),new Vector3(.12f,.11f,.22f),Trim);
   Box(root,"Shop continuous cornice",new Vector3(0,3.55f,front+.15f),new Vector3(span,.14f,.40f),Trim,.025f);
   var leaves=new List<Vector3>();var leafTriangles=new List<int>();for(int leaf=0;leaf<18;leaf++){float yy=.6f+leaf*.115f,xx=span*.465f+Mathf.Sin(leaf*1.9f)*.08f;var at=new Vector3(xx,yy,front+.34f);var across=new Vector3(Mathf.Cos(leaf*.8f)*.075f,.018f,Mathf.Sin(leaf*.8f)*.035f);var along=new Vector3(leaf%2==0?-.045f:.045f,-.22f,0);int k=leaves.Count;leaves.AddRange(new[]{at,at+along*.35f-across,at+along,at+along*.35f+across,at+along*.45f+Vector3.forward*.028f,at+along*.45f+Vector3.back*.012f});for(int edge=0;edge<4;edge++)leafTriangles.AddRange(new[]{k+4,k+edge,k+(edge+1)%4,k+5,k+(edge+1)%4,k+edge});}MeshArt.Mesh(root,"Shop climbing vine leaves",leaves.ToArray(),leafTriangles.ToArray(),null,LeafMass);
  }
  void Envelope(Transform root,float span,float depth,float height,Material facade,int columns,bool residential)
  {
   float front=depth*.5f,cell=span/columns;Box(root,"Deep window interior shadow",new Vector3(0,height*.5f,-.26f),new Vector3(span-.14f,height,depth-.60f),Roof);
   foreach(int side in new[]{-1,1})Box(root,"Masonry return wall",new Vector3(side*(span*.5f-.15f),height*.5f,0),new Vector3(.30f,height,depth),facade,.045f);
   for(int col=0;col<=columns;col++)Box(root,"Facade carved vertical pier",new Vector3(-span*.5f+col*cell,height*.5f,front-.06f),new Vector3(col==0||col==columns?.36f:.30f,height,.38f),facade,.04f);
   int floors=Mathf.Max(1,Mathf.FloorToInt(height/3.05f));
   for(int floor=0;floor<=floors;floor++){float y=floor*3.05f;Box(root,"Broad masonry floor course",new Vector3(0,y+.32f,front-.10f),new Vector3(span,.64f,.38f),facade,.03f);}
   for(int floor=0;floor<floors;floor++)for(int col=0;col<columns;col++){
    float xx=-span*.5f+(col+.5f)*cell,y=floor*3.05f+1.78f;float paneWidth=residential&&floor>0?Mathf.Clamp(cell*.36f,1.14f,1.5f):cell-.48f;
    Box(root,"Deeply recessed urban glazing",new Vector3(xx,y,front-.16f),new Vector3(paneWidth,2.08f,.04f),Glass);
    Box(root,"Window projecting stone sill",new Vector3(xx,y-1.08f,front+.10f),new Vector3(paneWidth+.14f,.14f,.48f),Trim,.025f);
    Box(root,"Window inset upper reveal",new Vector3(xx,y+1.08f,front-.06f),new Vector3(paneWidth,.12f,.37f),facade);
    Box(root,"Fine glazing mullion",new Vector3(xx,y,front-.10f),new Vector3(.055f,2.08f,.09f),residential?Trim:Metal);
    if(residential&&floor>0){float infill=(cell-paneWidth)*.5f;foreach(int side in new[]{-1,1})Box(root,"Residential masonry infill",new Vector3(xx+side*(paneWidth*.5f+infill*.5f),y,front-.09f),new Vector3(infill,2.41f,.38f),facade);
     foreach(int side in new[]{-1,1})Box(root,"Recessed sash stone jamb",new Vector3(xx+side*(paneWidth*.5f+.055f),y,front+.035f),new Vector3(.11f,2.13f,.28f),Trim);Box(root,"Sash lintel drip molding",new Vector3(xx,y+1.12f,front+.06f),new Vector3(paneWidth+.29f,.11f,.35f),Trim);
     Box(root,"Residential sash meeting rail",new Vector3(xx,y-.05f,front-.08f),new Vector3(paneWidth,.065f,.08f),Trim);if(floor==1||floor==3)WindowArch(root,xx,y+1.04f,front+.115f,paneWidth*.5f+.055f);
     if(col%2==0&&floor==1){Box(root,"Window flower box",new Vector3(xx,y-1.1f,front+.34f),new Vector3(paneWidth*.85f,.21f,.27f),Roof,.025f);for(int plant=0;plant<3;plant++)Shrub(root,new Vector3(xx+(plant-1)*.30f,y-.94f,front+.34f),.22f);}
    }
   }
   if(residential){float xx=-span*.5f+cell*.5f;Box(root,"Recessed townhouse entrance",new Vector3(xx,1.30f,front-.08f),new Vector3(1.23f,2.20f,.12f),Roof,.035f);foreach(int side in new[]{-1,1})Box(root,"Townhouse entrance stone jamb",new Vector3(xx+side*.70f,1.32f,front+.06f),new Vector3(.17f,2.35f,.23f),Trim,.025f);WindowArch(root,xx,2.47f,front+.15f,.73f);Box(root,"Brass townhouse door pull",new Vector3(xx+.43f,1.28f,front+.018f),new Vector3(.035f,.31f,.025f),Metal);}
   // Return windows matter in the chase-camera's long street perspective.
   foreach(int side in new[]{-1,1})for(int floor=1;floor<floors;floor++)for(int bay=0;bay<2;bay++){float zz=(bay==0?-1:1)*depth*.24f;Box(root,"Return elevation window",new Vector3(side*(span*.5f+.006f),floor*3.05f+1.7f,zz),new Vector3(.04f,2.0f,depth*.32f),Glass);}
  }
  void WindowArch(Transform parent,float x,float y,float z,float radius){const int count=9;for(int i=0;i<count;i++){float a=i*Mathf.PI/count+.012f,b=(i+1)*Mathf.PI/count-.012f;var points=new Vector3[8];for(int layer=0;layer<2;layer++)for(int side=0;side<4;side++){float angle=side<2?a:b,r=(side==0||side==3)?radius:radius+.12f;points[layer*4+side]=new Vector3(x+Mathf.Cos(angle)*r,y+Mathf.Sin(angle)*r,z+layer*.16f);}MeshArt.Mesh(parent,"Residential arch voussoir",points,new[]{0,2,1,0,3,2,4,5,6,4,6,7,0,1,5,0,5,4,1,2,6,1,6,5,2,3,7,2,7,6,3,0,4,3,4,7},null,Trim);}}
  void FlatRoof(Transform root,float span,float depth,float height)
  {
   Box(root,"Flat roof coping",new Vector3(0,height+.10f,0),new Vector3(span+.22f,.22f,depth+.22f),Trim,.045f);
   foreach(int side in new[]{-1,1})Box(root,"Roof garden parapet",new Vector3(0,height+.43f,side*(depth*.5f-.10f)),new Vector3(span,.63f,.20f),Plaster);
   Box(root,"Roof service plant",new Vector3(-span*.24f,height+.65f,-depth*.15f),new Vector3(2.0f,1.1f,1.5f),Metal,.09f);
   for(int vent=0;vent<4;vent++)Box(root,"Ventilation grille",new Vector3(-span*.24f+.22f*vent-.33f,height+.68f,-depth*.15f-.78f),new Vector3(.055f,.67f,.06f),Roof);
  }
  void PitchedRoof(Transform root,float span,float depth,float height,bool mansard)
  {
   float peak=height+(mansard?3.4f:2.7f);float inset=mansard?span*.20f:0;
   Vector3[] v={new(-span*.52f,height,-depth*.54f),new(span*.52f,height,-depth*.54f),new(inset,peak,-depth*.54f),new(-inset,peak,-depth*.54f),new(-span*.52f,height,depth*.54f),new(span*.52f,height,depth*.54f),new(inset,peak,depth*.54f),new(-inset,peak,depth*.54f)};
   MeshArt.Mesh(root,mansard?"Mansard roof shoulders":"Terrace pitched roof",v,new[]{0,3,2,0,2,1,4,5,6,4,6,7,0,4,7,0,7,3,1,2,6,1,6,5,3,7,6,3,6,2},null,Roof);
   Box(root,"Roof ridge cap",new Vector3(0,peak+.05f,0),new Vector3(Mathf.Max(.20f,inset*2),.13f,depth*1.10f),Metal,.03f);
   for(int dormer=0;dormer<3;dormer++){float xx=(dormer-1)*span*.28f,dz=depth*.54f+.16f;Box(root,"Urban dormer casing",new Vector3(xx,height+1.15f,dz-.66f),new Vector3(1.76f,1.65f,1.33f),Plaster,.045f);Box(root,"Dormer inset glazing",new Vector3(xx,height+1.19f,dz+.018f),new Vector3(1.23f,1.06f,.035f),Glass);foreach(int side in new[]{-1,1})Box(root,"Dormer shaped stone jamb",new Vector3(xx+side*.68f,height+1.19f,dz+.06f),new Vector3(.11f,1.18f,.16f),Trim);Box(root,"Dormer sash",new Vector3(xx,height+1.19f,dz+.06f),new Vector3(.055f,1.08f,.08f),Trim);Box(root,"Dormer carved sill",new Vector3(xx,height+.61f,dz+.09f),new Vector3(1.51f,.13f,.25f),Trim);var cap=new[]{new Vector3(xx-.96f,height+2.0f,dz-1.38f),new Vector3(xx,height+2.39f,dz-1.38f),new Vector3(xx+.96f,height+2.0f,dz-1.38f),new Vector3(xx-.96f,height+2.0f,dz+.16f),new Vector3(xx,height+2.39f,dz+.16f),new Vector3(xx+.96f,height+2.0f,dz+.16f)};MeshArt.Mesh(root,"Dormer slate cap",cap,new[]{0,1,2,3,5,4,0,3,4,0,4,1,1,4,5,1,5,2},null,Roof);}
   foreach(int side in new[]{-1,1})Box(root,"Historic eaves cornice",new Vector3(0,height-.14f,side*depth*.52f),new Vector3(span*1.045f,.22f,.28f),Trim,.045f);
   for(int course=0;course<6;course++){float t=(course+.5f)/6;float xx=Mathf.Lerp(span*.52f,inset,t),yy=Mathf.Lerp(height,peak,t);foreach(int side in new[]{-1,1})MeshArt.Tube(root,"Slate roof course",new[]{new Vector3(side*xx,yy+.028f,-depth*.53f),new Vector3(side*xx,yy+.028f,depth*.53f)},.013f,Metal,6);}
   Box(root,"Brick chimney stack",new Vector3(span*.36f,height+1.45f,-depth*.26f),new Vector3(.78f,2.4f,.96f),Brick,.04f);Box(root,"Chimney flue cap",new Vector3(span*.36f,height+2.71f,-depth*.26f),new Vector3(1.01f,.18f,1.17f),Metal);
  }

  public void Tree(Vector3 p,Material wood)
  {
   var root=new GameObject("Authored urban street tree").transform;root.SetParent(owner,false);root.localPosition=p;int seed=Mathf.RoundToInt(p.x*31+p.z*17);root.localScale=new Vector3(1.14f,1.27f+(Mathf.Abs(seed)%5)*.035f,1.14f);
   MeshArt.Tube(root,"Irregular bark trunk",new[]{new Vector3(0,0,0),new Vector3(.04f,1.1f,.02f),new Vector3(-.10f,2.3f,.06f),new Vector3(.06f,3.3f,0)},.12f,wood,9);
   for(int branch=0;branch<3;branch++){float angle=(branch*121+((int)p.z%37))*Mathf.Deg2Rad;var center=new Vector3(Mathf.Cos(angle)*.58f,3.55f+(branch%2)*.53f,Mathf.Sin(angle)*.55f);MeshArt.Tube(root,"Natural urban branch",new[]{new Vector3(-.08f,2.1f,.03f),center*.72f,center},.045f,wood,7);Crown(root,center,new Vector3(1.16f+(seed%3)*.045f,1.36f+(Mathf.Abs(seed)%4)*.07f,1.12f),branch+(int)p.z);LeafClusters(root,center,branch+(int)p.z);}
  }
  void Crown(Transform root,Vector3 at,Vector3 radii,int seed)
  {
   const int sides=18,rings=9;var v=new List<Vector3>();var t=new List<int>();var uv=new List<Vector2>();
   for(int ring=0;ring<rings;ring++)for(int i=0;i<=sides;i++){float a=i*Mathf.PI*2/sides,e=ring*Mathf.PI/(rings-1),r=Mathf.Max(.035f,Mathf.Sin(e));float shape=1+.15f*Mathf.Sin(a*3+seed*.51f+ring*.6f)+.08f*Mathf.Cos(a*5-seed*.17f);v.Add(at+new Vector3(Mathf.Cos(a)*r*radii.x*shape,-Mathf.Cos(e)*radii.y+Mathf.Sin(a*4+seed)*.08f*r,Mathf.Sin(a)*r*radii.z*shape));uv.Add(new Vector2((float)i/sides,(float)ring/(rings-1)));}
   for(int ring=0;ring<rings-1;ring++)for(int i=0;i<sides;i++){int a=ring*(sides+1)+i,b=a+sides+1;t.AddRange(new[]{a,b,a+1,a+1,b,b+1});}
   MeshArt.Mesh(root,"Sculpted urban leaf crown",v.ToArray(),t.ToArray(),uv.ToArray(),seed%3==0?goldenCrown:LeafMass);
  }
  void LeafClusters(Transform root,Vector3 center,int seed)
  {
   var v=new List<Vector3>();var t=new List<int>();var uv=new List<Vector2>();
   for(int leaf=0;leaf<64;leaf++){
    float angle=(leaf*137.507f+seed*11)*Mathf.Deg2Rad,y=-.85f+1.85f*((leaf%11)/10f),radius=Mathf.Sqrt(Mathf.Max(.06f,1-y*y*.45f))*(1.23f+(leaf%3)*.07f);Vector3 at=center+new Vector3(Mathf.Cos(angle)*radius,y,Mathf.Sin(angle)*radius);
    Vector3 outward=(at-center).normalized,right=Vector3.Cross(outward,Mathf.Abs(outward.y)>.85f?Vector3.forward:Vector3.up).normalized,up=Vector3.Cross(right,outward).normalized;float width=.12f+(leaf%3)*.025f,height=.22f+(leaf%4)*.022f;int first=v.Count;
    v.AddRange(new[]{at-right*width-up*height,at+right*width-up*height,at+right*width+up*height,at-right*width+up*height});uv.AddRange(new[]{Vector2.zero,Vector2.right,Vector2.one,Vector2.up});t.AddRange(new[]{first,first+2,first+1,first,first+3,first+2});
   }
   MeshArt.Mesh(root,"Urban leaf clusters",v.ToArray(),t.ToArray(),uv.ToArray(),Leaves);
  }
  public void Shrub(Transform parent,Vector3 position,float size){Crown(parent,position,new Vector3(size,size*.65f,size),Mathf.RoundToInt(position.x*7+position.z*11));}
  public void Workshop()
  {
   var root=new GameObject("Repair workshop hero architecture").transform;root.SetParent(owner,false);root.localPosition=new Vector3(19,0,35);root.localRotation=Quaternion.Euler(0,-90,0);
   float[] x={-10.35f,0,10.35f};var v=new[]{new Vector3(x[0],7.05f,-6.30f),new Vector3(0,9.0f,-6.30f),new Vector3(x[2],7.05f,-6.30f),new Vector3(x[0],7.05f,6.30f),new Vector3(0,9.0f,6.30f),new Vector3(x[2],7.05f,6.30f)};
   MeshArt.Mesh(root,"Workshop hero gable",v,new[]{0,1,2,3,5,4,0,3,4,0,4,1,1,4,5,1,5,2},null,Roof);
   for(int rib=0;rib<18;rib++){float xx=-10.1f+rib*1.18f;float yy=9-Mathf.Abs(xx)*1.95f/10.35f;Box(root,"Workshop corrugated roof rib",new Vector3(xx,yy+.045f,0),new Vector3(.07f,.08f,12.60f),Metal);}
   Box(root,"Workshop pale front gable",new Vector3(0,6.98f,6.37f),new Vector3(20.4f,.43f,.12f),Plaster);
   for(int bay=0;bay<3;bay++){float xx=-6.65f+bay*6.65f;var anchor=new GameObject("Workshop open service bay").transform;anchor.SetParent(root,false);anchor.localPosition=new Vector3(xx,0,6.15f);Box(anchor,"Garage pale side reveal",new Vector3(-2.97f,2.05f,0),new Vector3(.23f,4.1f,.28f),Plaster);Box(anchor,"Garage pale upper reveal",new Vector3(0,4.09f,0),new Vector3(6.0f,.22f,.36f),Plaster);Box(anchor,"Workshop open roll-door cassette",new Vector3(0,4.33f,-.08f),new Vector3(5.83f,.29f,.47f),Metal,.05f);for(int strip=0;strip<6;strip++)Box(anchor,"Industrial upper shutter grooves",new Vector3(0,4.20f+strip*.032f,.17f),new Vector3(5.7f,.018f,.018f),Roof);}
   foreach(int side in new[]{-1,1}){Box(root,"Workshop timber trim",new Vector3(side*9.78f,3.5f,6.40f),new Vector3(.25f,7,.16f),Brick);Shrub(root,new Vector3(side*9.47f,.77f,6.61f),.62f);}
  }
 }
}
