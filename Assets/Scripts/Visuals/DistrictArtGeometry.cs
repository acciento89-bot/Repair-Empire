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
  public readonly Material Brick,Plaster,Trim,Glass,Roof,LeafMass,Leaves,Metal;
  public UrbanArtKit(Transform root,Material stone,Material glass,Material steel)
  {
   owner=root;Trim=stone;Glass=glass;Metal=steel;
   Brick=Own("UrbanWarmBrick",Color.white);Brick.mainTexture=Texture(false);
   Plaster=Own("UrbanWarmPlaster",new Color(.91f,.86f,.73f));Plaster.mainTexture=Texture(true);
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
    pixels[y*size+x]=plaster?new Color(.91f+grain,.91f+grain,.91f+grain):mortar?new Color(.62f,.59f,.52f):new Color(.57f*brickShade+grain,.26f*brickShade+grain,.16f*brickShade+grain);
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
  static GameObject Box(Transform parent,string name,Vector3 at,Vector3 scale,Material mat,float bevel=0)
  {return bevel>0?MeshArt.BevelBox(parent,name,at,scale,bevel,mat):MeshArt.Box(parent,name,at,scale,mat);}

  public void Facade(float x,float z,float height,float width,float depth,int facing,int district)
  {
   string[] names={"Brick terrace facade","Recessed office facade","Stepped modern facade","Corner mansard facade"};
   var root=new GameObject(names[district]).transform;root.SetParent(owner,false);root.localPosition=new Vector3(x,0,z);root.localRotation=Quaternion.Euler(0,facing*90,0);
   Material facade=district==0?Brick:Plaster;
   if(district==2){Envelope(root,depth,width,7.0f,Plaster,4);var upper=new GameObject("Setback upper residence").transform;upper.SetParent(root,false);upper.localPosition=new Vector3(1.25f,7,-1.0f);Envelope(upper,depth*.72f,width-2,height-7,Plaster,3);FlatRoof(upper,depth*.72f,width-2,height-7);Box(root,"Modern terrace parapet",new Vector3(-depth*.37f,7.35f,width*.28f),new Vector3(depth*.25f,.55f,.18f),Trim);}
   else{Envelope(root,depth,width,height,facade,district==1?6:4);if(district==0||district==3)PitchedRoof(root,depth,width,height,district==3);else FlatRoof(root,depth,width,height);}
   // A few broad authored features define each frontage, rather than covering
   // every wall with the same dense window-grid ornament.
   float front=width*.5f;
   if(district==1){for(int column=0;column<3;column++)Box(root,"Office projecting vertical fin",new Vector3((column-1)*depth*.31f,height*.5f,front+.16f),new Vector3(.20f,height,.42f),Roof);}
   if(district==0||district==3){for(int floor=2;floor<height/3;floor+=2){float y=floor*3;float xx=district==0?-depth*.22f:depth*.20f;Box(root,"Recessed residential balcony",new Vector3(xx,y-.80f,front+.35f),new Vector3(3.4f,.18f,.80f),Trim);Box(root,"Balcony metal rail",new Vector3(xx,y-.08f,front+.74f),new Vector3(3.4f,.08f,.06f),Metal);for(int post=0;post<6;post++)Box(root,"Balcony slender baluster",new Vector3(xx-1.5f+post*.60f,y-.46f,front+.74f),new Vector3(.05f,.80f,.05f),Metal);}}
   Box(root,"Urban shop sign backing",new Vector3(0,2.64f,front+.10f),new Vector3(depth*.47f,.46f,.12f),Roof,.03f);
   VanArt.Text(root,new[]{"RIVERSIDE MARKET","CITY OFFICES","RIVERSIDE LOFTS","NEIGHBOURHOOD CAFÉ"}[district],new Vector3(0,2.64f,front+.19f),.21f,new Color(.93f,.89f,.77f),Quaternion.Euler(0,180,0));
   foreach(int side in new[]{-1,1}){Box(root,"Shop stone planter",new Vector3(side*depth*.42f,.35f,front+.36f),new Vector3(.78f,.66f,.82f),Trim,.07f);Shrub(root,new Vector3(side*depth*.42f,.78f,front+.36f),.55f);}
  }
  void Envelope(Transform root,float span,float depth,float height,Material facade,int columns)
  {
   float front=depth*.5f,cell=span/columns;Box(root,"Deep window interior shadow",new Vector3(0,height*.5f,-.26f),new Vector3(span-.14f,height,depth-.60f),Roof);
   foreach(int side in new[]{-1,1})Box(root,"Masonry return wall",new Vector3(side*(span*.5f-.15f),height*.5f,0),new Vector3(.30f,height,depth),facade,.045f);
   for(int col=0;col<=columns;col++)Box(root,"Facade carved vertical pier",new Vector3(-span*.5f+col*cell,height*.5f,front-.06f),new Vector3(col==0||col==columns?.36f:.30f,height,.38f),facade,.04f);
   int floors=Mathf.Max(1,Mathf.FloorToInt(height/3.05f));
   for(int floor=0;floor<=floors;floor++){float y=floor*3.05f;Box(root,"Broad masonry floor course",new Vector3(0,y+.32f,front-.10f),new Vector3(span,.64f,.38f),facade,.03f);}
   for(int floor=0;floor<floors;floor++)for(int col=0;col<columns;col++){
    float xx=-span*.5f+(col+.5f)*cell,y=floor*3.05f+1.78f;float paneWidth=cell-.48f;
    Box(root,"Deeply recessed urban glazing",new Vector3(xx,y,front-.16f),new Vector3(paneWidth,2.08f,.04f),Glass);
    Box(root,"Window projecting stone sill",new Vector3(xx,y-1.08f,front+.10f),new Vector3(paneWidth+.14f,.14f,.48f),Trim,.025f);
    Box(root,"Window inset upper reveal",new Vector3(xx,y+1.08f,front-.06f),new Vector3(paneWidth,.12f,.37f),facade);
    Box(root,"Fine glazing mullion",new Vector3(xx,y,front-.10f),new Vector3(.055f,2.08f,.09f),Metal);
   }
   // Return windows matter in the chase-camera's long street perspective.
   foreach(int side in new[]{-1,1})for(int floor=1;floor<floors;floor++)for(int bay=0;bay<2;bay++){float zz=(bay==0?-1:1)*depth*.24f;Box(root,"Return elevation window",new Vector3(side*(span*.5f+.006f),floor*3.05f+1.7f,zz),new Vector3(.04f,2.0f,depth*.32f),Glass);}
  }
  void FlatRoof(Transform root,float span,float depth,float height)
  {
   Box(root,"Flat roof coping",new Vector3(0,height+.10f,0),new Vector3(span+.22f,.22f,depth+.22f),Trim,.045f);
   foreach(int side in new[]{-1,1})Box(root,"Roof garden parapet",new Vector3(0,height+.43f,side*(depth*.5f-.10f)),new Vector3(span,.63f,.20f),Plaster);
   Box(root,"Roof service plant",new Vector3(-span*.24f,height+.65f,-depth*.15f),new Vector3(2.0f,1.1f,1.5f),Metal,.09f);
   for(int vent=0;vent<4;vent++)Box(root,"Ventilation grille",new Vector3(-span*.24f+.22f*vent-.33f,height+.68f,-depth*.15f-.78f),new Vector3(.055f,.67f,.06f),Roof);
  }
  void PitchedRoof(Transform root,float span,float depth,float height,bool mansard)
  {
   float peak=height+(mansard?3.0f:2.1f);float inset=mansard?span*.20f:0;
   Vector3[] v={new(-span*.52f,height,-depth*.54f),new(span*.52f,height,-depth*.54f),new(inset,peak,-depth*.54f),new(-inset,peak,-depth*.54f),new(-span*.52f,height,depth*.54f),new(span*.52f,height,depth*.54f),new(inset,peak,depth*.54f),new(-inset,peak,depth*.54f)};
   MeshArt.Mesh(root,mansard?"Mansard roof shoulders":"Terrace pitched roof",v,new[]{0,3,2,0,2,1,4,5,6,4,6,7,0,4,7,0,7,3,1,2,6,1,6,5,3,7,6,3,6,2},null,Roof);
   Box(root,"Roof ridge cap",new Vector3(0,peak+.05f,0),new Vector3(Mathf.Max(.20f,inset*2),.13f,depth*1.10f),Metal,.03f);
   for(int dormer=0;dormer<3;dormer++){float xx=(dormer-1)*span*.28f;Box(root,"Urban dormer casing",new Vector3(xx,height+1.15f,depth*.36f),new Vector3(1.76f,1.65f,1.33f),Plaster,.075f);Box(root,"Dormer inset glazing",new Vector3(xx,height+1.19f,depth*.36f+.68f),new Vector3(1.23f,1.06f,.035f),Glass);Box(root,"Dormer slate cap",new Vector3(xx,height+2.03f,depth*.36f),new Vector3(1.91f,.17f,1.51f),Roof,.035f);}
   Box(root,"Brick chimney stack",new Vector3(span*.36f,height+1.45f,-depth*.26f),new Vector3(.78f,2.4f,.96f),Brick,.04f);Box(root,"Chimney flue cap",new Vector3(span*.36f,height+2.71f,-depth*.26f),new Vector3(1.01f,.18f,1.17f),Metal);
  }

  public void Tree(Vector3 p,Material wood)
  {
   var root=new GameObject("Authored urban street tree").transform;root.SetParent(owner,false);root.localPosition=p;
   MeshArt.Tube(root,"Irregular bark trunk",new[]{new Vector3(0,0,0),new Vector3(.04f,1.1f,.02f),new Vector3(-.10f,2.3f,.06f),new Vector3(.06f,3.3f,0)},.12f,wood,9);
   for(int branch=0;branch<3;branch++){float angle=(branch*121+((int)p.z%37))*Mathf.Deg2Rad;var center=new Vector3(Mathf.Cos(angle)*.58f,3.55f+(branch%2)*.53f,Mathf.Sin(angle)*.55f);MeshArt.Tube(root,"Natural urban branch",new[]{new Vector3(-.08f,2.1f,.03f),center*.72f,center},.045f,wood,7);Crown(root,center,new Vector3(1.25f,1.36f,1.15f),branch+(int)p.z);LeafClusters(root,center,branch+(int)p.z);}
  }
  void Crown(Transform root,Vector3 at,Vector3 radii,int seed)
  {
   const int sides=16,rings=7;var v=new List<Vector3>();var t=new List<int>();var uv=new List<Vector2>();
   for(int ring=0;ring<rings;ring++)for(int i=0;i<=sides;i++){float a=i*Mathf.PI*2/sides,e=ring*Mathf.PI/(rings-1),r=Mathf.Max(.035f,Mathf.Sin(e));float shape=1+.15f*Mathf.Sin(a*3+seed*.51f+ring*.6f)+.08f*Mathf.Cos(a*5-seed*.17f);v.Add(at+new Vector3(Mathf.Cos(a)*r*radii.x*shape,-Mathf.Cos(e)*radii.y+Mathf.Sin(a*4+seed)*.08f*r,Mathf.Sin(a)*r*radii.z*shape));uv.Add(new Vector2((float)i/sides,(float)ring/(rings-1)));}
   for(int ring=0;ring<rings-1;ring++)for(int i=0;i<sides;i++){int a=ring*(sides+1)+i,b=a+sides+1;t.AddRange(new[]{a,b,a+1,a+1,b,b+1});}
   MeshArt.Mesh(root,"Sculpted urban leaf crown",v.ToArray(),t.ToArray(),uv.ToArray(),LeafMass);
  }
  void LeafClusters(Transform root,Vector3 center,int seed)
  {
   var v=new List<Vector3>();var t=new List<int>();var uv=new List<Vector2>();
   for(int leaf=0;leaf<42;leaf++){
    float angle=(leaf*137.507f+seed*11)*Mathf.Deg2Rad,y=-.85f+1.85f*((leaf%11)/10f),radius=Mathf.Sqrt(Mathf.Max(.06f,1-y*y*.45f))*(1.23f+(leaf%3)*.07f);Vector3 at=center+new Vector3(Mathf.Cos(angle)*radius,y,Mathf.Sin(angle)*radius);
    Vector3 outward=(at-center).normalized,right=Vector3.Cross(outward,Mathf.Abs(outward.y)>.85f?Vector3.forward:Vector3.up).normalized,up=Vector3.Cross(right,outward).normalized;float width=.18f+(leaf%3)*.05f,height=.30f+(leaf%4)*.035f;int first=v.Count;
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
