using UnityEngine;

namespace Kamilunavo.RepairEmpire.Visuals
{
 // Original editable runtime workshop kit. Only its cached photograph enters the tablet.
 public static class WorkshopArt
 {
  sealed class Surfaces
  {
   readonly GameObject owner;
   public readonly Material Wall,Wood,Navy,Orange,Steel,Rubber,Paper,Blue,Green,Leaf,Glow,Floor;
   public Surfaces(GameObject root)
   {
    owner=root;
    Wall=Make("Plaster",new Color(.93f,.91f,.86f),.18f,"Workshop/Plaster");
    Wood=Make("Oak",Color.white,.29f,"Workshop/Oak");
    Navy=Make("Navy",new Color(.026f,.065f,.10f),.42f);
    Orange=Make("Orange",new Color(1,.31f,.035f),.46f);
    Steel=Make("Steel",new Color(.62f,.68f,.69f),.65f);Steel.SetFloat("_Metallic",.78f);
    Rubber=Make("Rubber",new Color(.033f,.038f,.043f),.16f);
    Paper=Make("Ivory",new Color(.96f,.94f,.87f),.22f);
    Blue=Make("Blueprint",new Color(.055f,.17f,.28f),.26f);
    Green=Make("Plant",new Color(.11f,.26f,.055f),.24f);
    Leaf=Make("Leaf",new Color(.25f,.41f,.09f),.32f);
    Floor=Make("Concrete",new Color(.64f,.63f,.57f),.25f,"Workshop/Plaster");
    Glow=Make("WarmLuminaire",new Color(1,.89f,.67f),.2f);Glow.EnableKeyword("_EMISSION");Glow.SetColor("_EmissionColor",new Color(1,.73f,.4f)*.8f);
   }
   Material Make(string name,Color color,float smooth,string texture=null)
   {
    var m=new Material(Resources.Load<Material>("Materials/Surface")){name="WorkshopOriginal "+name,color=color};
    m.SetFloat("_Glossiness",smooth);if(texture!=null)m.mainTexture=Resources.Load<Texture2D>("Art/"+texture);
    ArtLifetime.Own(owner,m);return m;
   }
  }
  static GameObject B(Transform root,string name,Vector3 p,Vector3 size,Material m,float bevel=.025f)=>MeshArt.BevelBox(root,name,p,size,bevel,m);
  static void T(Transform root,string name,Material m,float radius,params Vector3[] points)=>MeshArt.Tube(root,name,points,radius,m,10);

  // Quad UVs follow physical dimensions; plaster and oak do not restart on each triangle.
  static void Surface(Transform root,string name,Vector3 a,Vector3 b,Vector3 c,Vector3 d,Material material,float metres)
  {
   float w=Vector3.Distance(a,b)/metres,h=Vector3.Distance(a,d)/metres;
   MeshArt.Mesh(root,name,new[]{a,b,c,d},new[]{0,1,2,0,2,3},new[]{Vector2.zero,new Vector2(w,0),new Vector2(w,h),new Vector2(0,h)},material);
  }

  public static GameObject Build(Transform parent)
  {
   var model=new GameObject("Original artisan service workshop");model.transform.SetParent(parent,false);var root=model.transform;var s=new Surfaces(model);
   Surface(root,"Workshop concrete slab",new(-6,-.06f,-5),new(-6,-.06f,4),new(6,-.06f,4),new(6,-.06f,-5),s.Floor,3);
   Surface(root,"Warm plaster rear wall",new(6,0,3.8f),new(-6,0,3.8f),new(-6,4.5f,3.8f),new(6,4.5f,3.8f),s.Wall,3);
   Surface(root,"Recessed workshop side wall",new(-6,0,3.8f),new(-6,0,-4.2f),new(-6,4.5f,-4.2f),new(-6,4.5f,3.8f),s.Wall,3);
   Surface(root,"Workshop right return wall",new(6,0,-5),new(6,0,3.8f),new(6,4.5f,3.8f),new(6,4.5f,-5),s.Wall,3);
   Surface(root,"Oak workshop ceiling",new(-6,4.5f,3.8f),new(-6,4.5f,-5),new(6,4.5f,-5),new(6,4.5f,3.8f),s.Wood,3);
   B(root,"Lower wall service skirting",new(0,.14f,3.72f),new(12,.27f,.11f),s.Navy);
   for(int i=0;i<5;i++)
   {
    float x=-5.5f+i*2.75f;B(root,"Exposed roof joist",new(x,4.34f,-.25f),new(.17f,.25f,8.1f),s.Wood);
    B(root,"Steel roof shoe",new(x,4.26f,3.56f),new(.28f,.34f,.19f),s.Steel);
   }
   B(root,"Transverse roof beam",new(0,4.12f,.8f),new(12,.24f,.19f),s.Wood);
   for(int i=0;i<2;i++)
   {
    float x=-2.5f+i*5;B(root,"Suspended warm work light",new(x,4.02f,-.35f),new(2.4f,.10f,.23f),s.Navy);
    B(root,"Diffused task light lens",new(x,3.96f,-.35f),new(2.24f,.03f,.15f),s.Glow);
    var go=new GameObject("Local warm workshop task light",typeof(Light));go.transform.SetParent(root,false);go.transform.localPosition=new(x,3.7f,-.3f);
    var light=go.GetComponent<Light>();light.type=LightType.Point;light.color=new(1,.84f,.62f);light.intensity=1.2f;light.range=9;light.shadows=LightShadows.None;light.cullingMask=1<<ServiceSceneArt.PreviewLayer;
   }
   Brand(root,s);
   Shelves(root,s);
   Pegboard(root,s);
   Workbench(root,s);
   Plant(root,new(5.15f,0,2.35f),1.25f,s);
   Plant(root,new(-4.65f,0,2.85f),1.65f,s);
   // Glazed clerestory gives the left side a lit workshop entrance, with real framing.
   B(root,"Workshop daylight window",new(-5.92f,2.55f,-.6f),new(.06f,2.25f,3.15f),s.Glow);
   for(int i=0;i<3;i++)B(root,"Window upright",new(-5.84f,2.55f,-1.94f+i*1.34f),new(.09f,2.3f,.08f),s.Paper);
   foreach(float y in new[]{1.45f,2.55f,3.67f})B(root,"Window cross rail",new(-5.84f,y,-.6f),new(.09f,.08f,2.8f),s.Paper);
   B(root,"Van service rubber floor mat",new(-2,.005f,.15f),new(3.1f,.025f,5.3f),s.Rubber);
   for(int i=0;i<2;i++)B(root,"Service bay orange guide",new(-3.45f+i*2.9f,.022f,.15f),new(.055f,.008f,5.3f),s.Orange,.002f);
   var van=new GameObject("Workshop branded service van");van.transform.SetParent(root,false);van.transform.localPosition=new(-2.1f,0,.3f);van.transform.localRotation=Quaternion.Euler(0,143,0);van.AddComponent<VanArt>().Build();
   // The photo has no animated motor; merge its static props and parked van by material.
   DistrictArtGeometry.Combine(root,false);
   return model;
  }

  static void Brand(Transform root,Surfaces s)
  {
   var logo=new GameObject("Workshop gear and open wrench").transform;logo.SetParent(root,false);logo.localPosition=new(-4.2f,3.12f,3.65f);
   var ring=MeshArt.Ring(logo,"Gear annulus",.50f,.13f,0,s.Navy,40);ring.transform.localRotation=Quaternion.Euler(-90,0,0);
   for(int i=0;i<12;i++){float a=i*Mathf.PI/6;var tooth=B(logo,"Machined gear tooth",new(Mathf.Cos(a)*.49f,Mathf.Sin(a)*.49f,0),new(.19f,.19f,.065f),s.Navy,.012f);tooth.transform.localRotation=Quaternion.Euler(0,0,i*30);}
   var wrench=new GameObject("Raised orange brand wrench").transform;wrench.SetParent(logo,false);wrench.localRotation=Quaternion.Euler(0,0,-35);
   B(wrench,"Wrench handle",new(0,-.03f,-.05f),new(.14f,.72f,.07f),s.Orange,.05f);
   MeshArt.Oval(wrench,"Open wrench head",new(0,.32f,-.05f),new(.37f,.34f,.085f),s.Orange);
   B(wrench,"Open wrench throat",new(0,.44f,-.105f),new(.15f,.21f,.055f),s.Paper,.014f);
   VanArt.Text(root,"REPAIR",new(-1.6f,3.43f,3.67f),.88f,new(.025f,.065f,.11f),Quaternion.identity);
   VanArt.Text(root,"EMPIRE",new(-1.6f,2.63f,3.67f),.82f,new(1,.31f,.035f),Quaternion.identity);
  }

  static void Shelves(Transform root,Surfaces s)
  {
   for(int shelf=0;shelf<3;shelf++)
   {
    float y=1.05f+shelf*.71f;B(root,"Solid oak storage shelf",new(3.45f,y,3.34f),new(3.8f,.10f,.68f),s.Wood);
    for(int side=0;side<2;side++){float x=1.8f+side*3.3f;T(root,"Shelf steel bracket",s.Steel,.022f,new(x,y-.34f,3.69f),new(x,y-.05f,3.02f),new(x,y-.05f,3.69f));}
    for(int item=0;item<5;item++)
    {
     float x=1.91f+item*.71f;float h=.27f+((shelf+item)%3)*.065f;var mat=(item+shelf)%3==0?s.Orange:(item%2==0?s.Navy:s.Paper);
     var can=MeshArt.Lathe(root,"Service bottle and supply tin",new[]{0f,.025f,h-.03f,h,h+.028f},new[]{.09f,.105f,.105f,.08f,.08f},16,mat,Vector3.one,true);can.transform.localPosition=new(x,y+.05f,3.28f);
     B(root,"Container cap",new(x,y+h+.09f,3.28f),new(.14f,.045f,.14f),s.Navy,.012f);
     B(root,"Small service label",new(x,y+h*.55f+.06f,3.172f),new(.105f,.10f,.009f),s.Paper,.002f);
    }
   }
   for(int i=0;i<2;i++)B(root,"Stacked orange parts case",new(4.5f,.21f+i*.30f,3.14f),new(1.1f,.27f,.62f),s.Orange,.045f);
   B(root,"Storage case carrying handle",new(4.5f,.71f,3.14f),new(.43f,.06f,.17f),s.Navy);
  }

  static void Pegboard(Transform root,Surfaces s)
  {
   B(root,"Oak wall mounted tool board",new(.37f,1.74f,3.64f),new(2.42f,1.34f,.12f),s.Wood);
   for(int x=0;x<11;x++)for(int y=0;y<5;y++)B(root,"Tool board perforation",new(-.68f+x*.21f,1.26f+y*.22f,3.571f),new(.022f,.022f,.008f),s.Navy,.003f);
   for(int i=0;i<7;i++)
   {
    var tool=new GameObject("Hanging service tool").transform;tool.SetParent(root,false);tool.localPosition=new(-.55f+i*.30f,1.76f,3.51f);
    B(tool,"Insulated tool grip",new(0,-.17f,0),new(.07f,.25f,.07f),i%2==0?s.Orange:s.Navy,.025f);
    T(tool,"Tool steel shaft",s.Steel,.014f,new(0,-.05f,0),new(0,.26f,0));
    if(i%3==0){T(tool,"Open adjustable tool jaws",s.Steel,.019f,new(-.052f,.29f,0),new(-.065f,.21f,0),new(0,.18f,0),new(.065f,.21f,0),new(.052f,.29f,0));}
    else if(i%3==1)B(tool,"Hammer steel head",new(0,.23f,0),new(.24f,.09f,.10f),s.Steel);
    else B(tool,"Flat screwdriver tip",new(0,.28f,0),new(.035f,.05f,.009f),s.Steel,.002f);
   }
  }

  static void Workbench(Transform root,Surfaces s)
  {
   var bench=new GameObject("Craftsman workbench").transform;bench.SetParent(root,false);bench.localPosition=new(2.6f,0,-1.7f);
   B(bench,"Thick rounded oak worktop",new(0,1.0f,0),new(4.8f,.15f,1.6f),s.Wood,.035f);
   for(int cabinet=0;cabinet<3;cabinet++)
   {
    float x=-1.45f+cabinet*1.45f;B(bench,"Navy tool cabinet",new(x,.47f,.13f),new(1.30f,.91f,1.17f),s.Navy,.045f);
    for(int drawer=0;drawer<4;drawer++){float y=.20f+drawer*.19f;B(bench,"Recessed drawer reveal",new(x,y,-.469f),new(1.18f,.155f,.025f),s.Rubber,.008f);B(bench,"Steel drawer pull",new(x,y+.02f,-.50f),new(.88f,.027f,.04f),s.Steel,.008f);}
   }
   B(bench,"Folded service blueprint",new(-.67f,1.087f,-.08f),new(1.78f,.012f,1.04f),s.Blue,.003f);
   for(int i=0;i<5;i++)B(bench,"Blueprint plan line",new(-1.29f+i*.28f,1.096f,-.03f),new(.008f,.004f,.72f-i*.07f),s.Paper,.001f);
   for(int i=0;i<4;i++)B(bench,"Blueprint cross line",new(-.71f,1.096f,-.38f+i*.23f),new(1.37f,.004f,.007f),s.Paper,.001f);
   var vice=new GameObject("Working bench vise").transform;vice.SetParent(bench,false);vice.localPosition=new(1.65f,1.08f,.20f);
   B(vice,"Vise mounting foot",new(0,.035f,0),new(.49f,.07f,.42f),s.Navy);
   B(vice,"Vise cast body",new(0,.19f,0),new(.28f,.30f,.28f),s.Navy,.045f);
   foreach(float z in new[]{-.13f,.16f})B(vice,"Milled steel vise jaw",new(0,.38f,z),new(.40f,.14f,.09f),s.Steel,.012f);
   T(vice,"Vise screw spindle",s.Steel,.028f,new(0,.18f,-.05f),new(0,.18f,-.48f));T(vice,"Vise turning handle",s.Steel,.017f,new(-.19f,.18f,-.49f),new(.19f,.18f,-.49f));
   B(bench,"Tape measure body",new(.54f,1.19f,-.21f),new(.31f,.22f,.24f),s.Orange,.055f);B(bench,"Tape measure belt clip",new(.54f,1.20f,-.335f),new(.16f,.13f,.017f),s.Steel);
   B(bench,"Cordless drill housing",new(.15f,1.35f,.37f),new(.38f,.19f,.18f),s.Navy,.05f);B(bench,"Drill orange grip",new(.19f,1.19f,.37f),new(.12f,.22f,.14f),s.Orange,.025f);T(bench,"Drill chuck and bit",s.Steel,.027f,new(-.03f,1.35f,.37f),new(-.28f,1.35f,.37f));
   var mug=MeshArt.Lathe(bench,"Ceramic workshop mug",new[]{0f,.02f,.24f,.25f,.245f,.035f},new[]{.10f,.115f,.12f,.12f,.098f,.093f},22,s.Paper,Vector3.one);mug.transform.localPosition=new(-1.98f,1.08f,.35f);
   T(bench,"Mug handle",s.Paper,.017f,new(-2.08f,1.26f,.35f),new(-2.23f,1.28f,.35f),new(-2.23f,1.14f,.35f),new(-2.08f,1.13f,.35f));
  }

  static void Plant(Transform root,Vector3 at,float height,Surfaces s)
  {
   var plant=new GameObject("Original workshop indoor plant").transform;plant.SetParent(root,false);plant.localPosition=at;
   MeshArt.Lathe(plant,"Terracotta planter",new[]{0f,.04f,.35f,.39f},new[]{.20f,.23f,.31f,.32f},24,s.Orange,Vector3.one);
   for(int stem=0;stem<4;stem++)
   {
    float a=stem*2.399f;var top=new Vector3(Mathf.Cos(a)*.25f,height,Mathf.Sin(a)*.25f);T(plant,"Living plant stem",s.Green,.014f,new(0,.32f,0),top);
    for(int leaf=0;leaf<6;leaf++)
    {
     float t=.25f+leaf*.13f;var start=Vector3.Lerp(new(0,.32f,0),top,t);float angle=a+leaf*2.4f;var reach=new Vector3(Mathf.Cos(angle)*.44f,.12f,Mathf.Sin(angle)*.44f);var side=Vector3.Cross(Vector3.up,reach).normalized*.13f;
     var v=new[]{start,start+reach*.46f+side,start+reach+Vector3.down*.05f,start+reach*.46f-side,start+reach*.44f+Vector3.up*.065f};
     MeshArt.Mesh(plant,"Folded glossy plant leaf",v,new[]{0,4,1,1,4,2,2,4,3,3,4,0,1,4,0,2,4,1,3,4,2,0,4,3},null,leaf%2==0?s.Green:s.Leaf);
    }
   }
  }
 }
}
