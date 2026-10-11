using UnityEngine;
namespace Kamilunavo.RepairEmpire.Visuals
{
 public sealed class FixturePhotoPose:MonoBehaviour {public Vector3 Eye,Target;public float FieldOfView;}
 public static class FixtureContextArt
 {
  public static bool Tabletop(string key)=>key=="faucet"||key=="kitchen-mixer";
  static GameObject B(Transform p,string name,Vector3 pos,Vector3 size,FixtureFinish finish,float bevel=.012f)=>MeshArt.BevelBox(p,name,pos,size,bevel,FixtureMaterials.Get(p,finish));
  static GameObject Box(Transform p,string name,Vector3 pos,Vector3 size,FixtureFinish finish)=>MeshArt.Box(p,name,pos,size,FixtureMaterials.Get(p,finish));
  public static void Build(Transform model,string key,int phase)
  {
   FixtureMaterials.Kit(model);string name=Context(key);var room=new GameObject("FixtureContext "+name);room.transform.SetParent(model,false);
   var p=room.transform;var pose=model.gameObject.AddComponent<FixturePhotoPose>();Pose(pose,key,phase);
   switch(name){
    case "BathroomVanity":Vanity(p,key=="sink");break;
    case "BathroomToilet":WetRoom(p,false);break;
    case "ShowerWetWall":WetRoom(p,true);break;
    case "KitchenSink":Kitchen(p);break;
    case "PipeUtility":Utility(p,true);break;
    case "DomesticWall":Domestic(p,key);break;
    case "ElectricalAlcove":Utility(p,false);break;
    case "MechanicalAlcove":Mechanical(p,key);break;
    default:Hvac(p,key);break;
   }
  }
  static string Context(string key)=>key switch {
   "faucet" or "sink"=>"BathroomVanity","toilet"=>"BathroomToilet","shower-valve"=>"ShowerWetWall","kitchen-mixer"=>"KitchenSink","pipe-leak"=>"PipeUtility",
   "breaker-panel" or "fuse-cartridge"=>"ElectricalAlcove","circulation-pump" or "service-boiler" or "flush-manifold"=>"MechanicalAlcove",
   "climate" or "ventilation-fan" or "condensate-drain" or "airflow-dampers" or "cooling-gauge" or "climate-coil"=>"HVACSystem",_=>"DomesticWall"};
  static void Pose(FixturePhotoPose pose,string key,int phase)
  {
   pose.Eye=new Vector3(1.08f,1.24f,-2.0f);pose.Target=new Vector3(0,.65f,.08f);pose.FieldOfView=38;
   switch(key){
    case "faucet":pose.Eye=new Vector3(.92f,.83f,-1.60f);pose.Target=new Vector3(-.04f,.32f,-.02f);pose.FieldOfView=34;break;
    case "sink":pose.Eye=new Vector3(1.15f,1.02f,-1.86f);pose.Target=new Vector3(.06f,.36f,.05f);pose.FieldOfView=38;break;
    case "kitchen-mixer":pose.Eye=new Vector3(1.1f,1.05f,-1.98f);pose.Target=new Vector3(0,.38f,.02f);pose.FieldOfView=39;break;
    case "toilet":pose.Eye=new Vector3(1.25f,1.62f,-2.23f);pose.Target=new Vector3(0,.64f,.11f);pose.FieldOfView=39;break;
    case "shower-valve":pose.Eye=new Vector3(.97f,1.3f,-2.05f);pose.Target=new Vector3(0,.68f,.15f);pose.FieldOfView=38;break;
    case "switch":case "wall-outlet":pose.Eye=new Vector3(.66f,1.02f,-1.42f);pose.Target=new Vector3(0,.68f,.10f);pose.FieldOfView=35;break;
    case "room-thermostat":pose.Eye=new Vector3(.69f,1.06f,-1.48f);pose.Target=new Vector3(0,.75f,.10f);pose.FieldOfView=34;break;
    case "circulation-pump":pose.Eye=new Vector3(1.30f,1.16f,-2.05f);pose.Target=new Vector3(.02f,.59f,.11f);pose.FieldOfView=38;break;
    case "service-boiler":pose.Eye=new Vector3(1.06f,1.22f,-2.20f);pose.Target=new Vector3(0,.70f,.13f);pose.FieldOfView=38;break;
    case "pipe-leak":pose.Eye=new Vector3(.96f,1.16f,-1.90f);pose.Target=new Vector3(-.035f,.67f,.15f);pose.FieldOfView=34;break;
    case "breaker-panel":case "fuse-cartridge":pose.Eye=new Vector3(.84f,1.23f,-1.95f);pose.Target=new Vector3(0,.69f,.11f);pose.FieldOfView=37;break;
   }
   if(phase==1&&(key=="switch"||key=="wall-outlet")){pose.Target.y=.58f;pose.FieldOfView=39;}
  }
  static void Wall(Transform p,string name,float front,float width=2.4f,FixtureFinish finish=FixtureFinish.Plaster)
  {Box(p,name,new Vector3(0,.84f,front+.065f),new Vector3(width,2.10f,.13f),finish);}
  static void Floor(Transform p,FixtureFinish finish,float y=-.09f)=>B(p,"Room floor",new Vector3(0,y,.0f),new Vector3(2.5f,.16f,1.95f),finish,.013f);
  static void TileLines(Transform p,float front,int columns,int rows,float bottom,float height)
  {
   for(int i=0;i<columns;i++)Box(p,"Wet wall grout joint",new Vector3((i-(columns-1)*.5f)*.43f,bottom+height*.5f,front-.002f),new Vector3(.006f,height,.006f),FixtureFinish.Grout);
   for(int j=0;j<rows;j++)Box(p,"Wet wall horizontal grout",new Vector3(0,bottom+j*height/(rows-1),front-.002f),new Vector3(2.4f,.006f,.006f),FixtureFinish.Grout);
  }
  // A closed stone annulus leaves the actual bowl opening visible in the counter.
  static void Counter(Transform p,float y,FixtureFinish finish,float holeWidth,float holeDepth,float centerZ,bool rectangular=false)
  {
   const int n=48;const float w=2.1f,d=1.5f;var v=new System.Collections.Generic.List<Vector3>();var uv=new System.Collections.Generic.List<Vector2>();var t=new System.Collections.Generic.List<int>();
   for(int ring=0;ring<4;ring++)for(int i=0;i<=n;i++){
    float a=(i%n)*Mathf.PI*2/n,c=Mathf.Cos(a),sn=Mathf.Sin(a);float innerX=c*holeWidth*.5f,innerZ=sn*holeDepth*.5f;
    if(rectangular){innerX=Mathf.Sign(c)*Mathf.Sqrt(Mathf.Abs(c))*holeWidth*.5f;innerZ=Mathf.Sign(sn)*Mathf.Sqrt(Mathf.Abs(sn))*holeDepth*.5f;}
    float outside=Mathf.Min(w*.5f/Mathf.Max(.0001f,Mathf.Abs(c)),(sn>=0?d*.5f-centerZ:d*.5f+centerZ)/Mathf.Max(.0001f,Mathf.Abs(sn)));
    bool outer=ring==1||ring==2;var point=new Vector3(outer?c*outside:innerX,ring<2?y:y-.11f,(outer?sn*outside:innerZ)+centerZ);v.Add(point);uv.Add(new Vector2(point.x,point.z)*1.2f);
    if(ring>0&&i<n){int k=ring*(n+1)+i,prev=k-(n+1);t.AddRange(new[]{prev,prev+1,k,prev+1,k+1,k});}
   }
   for(int i=0;i<n;i++){int low=3*(n+1)+i;t.AddRange(new[]{low,low+1,i,low+1,i+1,i});}
   MeshArt.Mesh(p,"Cut stone countertop",v.ToArray(),t.ToArray(),uv.ToArray(),FixtureMaterials.Get(p,finish));
  }
  static void Vanity(Transform p,bool exposedTrap)
  {
   Wall(p,"Bathroom stone wall",.54f,2.4f,FixtureFinish.Stone);TileLines(p,.54f,6,4,-.4f,1.95f);
   float top=exposedTrap?.44f:-.025f;Counter(p,top,FixtureFinish.Stone,exposedTrap?1.12f:1.40f,exposedTrap?.88f:.94f,exposedTrap?0:-.18f);
   if(exposedTrap){
    foreach(int side in new[]{-1,1})B(p,"Open vanity side support",new Vector3(side*.84f,.05f,.09f),new Vector3(.12f,.72f,.91f),FixtureFinish.Wood,.014f);
    B(p,"Exposed plumbing back board",new Vector3(0,.05f,.45f),new Vector3(1.8f,.74f,.06f),FixtureFinish.Wood);
    Floor(p,FixtureFinish.Stone,-.39f);
   }else{
    B(p,"Vanity cabinet body",new Vector3(0,-.48f,.02f),new Vector3(1.93f,.79f,1.14f),FixtureFinish.Wood,.025f);
    for(int side=-1;side<=1;side+=2){B(p,"Vanity inset cabinet door",new Vector3(side*.46f,-.46f,-.568f),new Vector3(.88f,.68f,.032f),FixtureFinish.Wood,.007f);B(p,"Vanity brushed handle",new Vector3(side*.46f,-.25f,-.603f),new Vector3(.28f,.021f,.026f),FixtureFinish.Steel,.006f);}
    Floor(p,FixtureFinish.Stone,-.95f);
   }
  }
  static void WetRoom(Transform p,bool shower)
  {
   Floor(p,FixtureFinish.Stone);Wall(p,shower?"Shower waterproof wall":"Bathroom plaster tile wall",.46f,2.4f,FixtureFinish.Stone);TileLines(p,.46f,5,5,-.06f,1.9f);
   if(shower){
    B(p,"Shower tray perimeter",new Vector3(0,-.015f,.01f),new Vector3(1.78f,.065f,1.45f),FixtureFinish.Ceramic,.035f);
    var drain=MeshArt.Lathe(p,"Shower floor drain",new[]{0f,.012f},new[]{.075f,.075f},20,FixtureMaterials.Get(p,FixtureFinish.Steel),Vector3.one);drain.transform.localPosition=new Vector3(.36f,.025f,-.23f);
    for(int i=0;i<4;i++)Box(p,"Drain grate slot",new Vector3(.32f+i*.024f,.038f,-.23f),new Vector3(.008f,.002f,.07f),FixtureFinish.Navy);
    B(p,"Shower fixture wall riser bracket",new Vector3(-.17f,.91f,.355f),new Vector3(.14f,.075f,.21f),FixtureFinish.Chrome,.015f);
   }else{
    Box(p,"Bathroom white skirting",new Vector3(0,.05f,.41f),new Vector3(2.3f,.12f,.055f),FixtureFinish.Ceramic);
    B(p,"Toilet paper holder wall mount",new Vector3(-.66f,.63f,.37f),new Vector3(.07f,.16f,.09f),FixtureFinish.Steel,.012f);
    var roll=MeshArt.Lathe(p,"Toilet paper roll",new[]{-.10f,.10f},new[]{.095f,.095f},20,FixtureMaterials.Get(p,FixtureFinish.Ceramic),Vector3.one);roll.transform.localRotation=Quaternion.Euler(0,0,90);roll.transform.localPosition=new Vector3(-.70f,.67f,.25f);
   }
  }
  static void Kitchen(Transform p)
  {
   Wall(p,"Kitchen backsplash",.53f,2.7f,FixtureFinish.Stone);TileLines(p,.53f,7,4,.09f,1.3f);Counter(p,.028f,FixtureFinish.Stone,1.02f,.63f,-.05f,true);
   B(p,"Kitchen cabinet carcass",new Vector3(0,-.48f,.05f),new Vector3(2.04f,.88f,1.14f),FixtureFinish.Navy,.025f);
   for(int side=-1;side<=1;side+=2){B(p,"Kitchen shaker door",new Vector3(side*.48f,-.47f,-.539f),new Vector3(.92f,.77f,.032f),FixtureFinish.Navy,.012f);B(p,"Kitchen recessed door panel",new Vector3(side*.48f,-.49f,-.559f),new Vector3(.73f,.55f,.020f),FixtureFinish.Blue,.014f);B(p,"Kitchen brass pull",new Vector3(side*.48f,-.15f,-.581f),new Vector3(.26f,.025f,.026f),FixtureFinish.Brass,.006f);}
   Floor(p,FixtureFinish.Wood,-1.06f);
   B(p,"Backsplash outlet",new Vector3(-.88f,.40f,.48f),new Vector3(.13f,.22f,.028f),FixtureFinish.Ceramic,.012f);
  }
  static void Utility(Transform p,bool pipe)
  {
   Floor(p,FixtureFinish.Concrete);Wall(p,pipe?"Exposed service masonry":"Electrical room plaster",pipe?.49f:.33f,2.4f,pipe?FixtureFinish.Concrete:FixtureFinish.Plaster);
   if(pipe){
    for(int i=0;i<5;i++)Box(p,"Masonry horizontal mortar",new Vector3(0,.04f+i*.36f,.486f),new Vector3(2.4f,.008f,.008f),FixtureFinish.Grout);
    for(int i=0;i<8;i++)Box(p,"Masonry vertical mortar",new Vector3((i%4-1.5f)*.57f+(i/4)*.16f,.42f+(i/4)*.72f,.486f),new Vector3(.008f,.35f,.008f),FixtureFinish.Grout);
    foreach(float y in new[]{.20f,1.14f})Bracket(p,new Vector3(-.035f,y,.21f),.27f);
    Box(p,"Service pipe label plate",new Vector3(.43f,1.28f,.46f),new Vector3(.29f,.13f,.025f),FixtureFinish.Steel);
   }else{
    B(p,"Utility cable trunking",new Vector3(-.78f,.91f,.27f),new Vector3(.09f,1.82f,.10f),FixtureFinish.Ceramic,.009f);
    B(p,"Panel upper cable conduit",new Vector3(0,1.48f,.25f),new Vector3(.085f,.46f,.10f),FixtureFinish.Ceramic,.009f);
    Box(p,"Electrical alcove corner return",new Vector3(-1.18f,.85f,-.02f),new Vector3(.13f,2.1f,.75f),FixtureFinish.Concrete);
    Box(p,"Utility room kick plate",new Vector3(0,.055f,.29f),new Vector3(2.35f,.12f,.022f),FixtureFinish.Steel);
   }
  }
  static void Domestic(Transform p,string key)
  {
   Floor(p,FixtureFinish.Wood);Wall(p,"Domestic painted plaster",key=="heating"||key=="heating-valve"?.32f:.215f,2.4f);
   Box(p,"Painted room skirting",new Vector3(0,.072f,.15f),new Vector3(2.4f,.15f,.04f),FixtureFinish.Ceramic);
   Box(p,"Skirting upper molding",new Vector3(0,.158f,.145f),new Vector3(2.4f,.023f,.048f),FixtureFinish.Ceramic);
   if(key=="doorbell-chime"){
    Box(p,"Hall door jamb",new Vector3(-.95f,.75f,.04f),new Vector3(.16f,1.8f,.15f),FixtureFinish.Wood);Box(p,"Door frame inner reveal",new Vector3(-1.07f,.75f,-.015f),new Vector3(.025f,1.8f,.06f),FixtureFinish.Ceramic);
   }else if(key=="hall-light"){
    Box(p,"Hall ceiling return",new Vector3(0,1.28f,.04f),new Vector3(2.4f,.12f,.63f),FixtureFinish.Plaster);Box(p,"Ceiling cornice",new Vector3(0,1.20f,.11f),new Vector3(2.4f,.075f,.16f),FixtureFinish.Ceramic);
   }else if(key=="heating"||key=="heating-valve"){
    for(int i=0;i<2;i++)B(p,"Radiator wall support",new Vector3((i-.5f)*.55f,.58f,.26f),new Vector3(.065f,.61f,.10f),FixtureFinish.Steel,.009f);
   }else{
    Box(p,"Domestic door architrave edge",new Vector3(1.11f,.75f,.12f),new Vector3(.10f,1.8f,.12f),FixtureFinish.Ceramic);
   }
  }
  static void Mechanical(Transform p,string key)
  {
   Floor(p,FixtureFinish.Concrete);Wall(p,"Mechanical service wall",.39f,2.5f,FixtureFinish.Plaster);
   Box(p,"Mechanical side alcove",new Vector3(-1.23f,.81f,-.05f),new Vector3(.10f,1.9f,.75f),FixtureFinish.Concrete);
   foreach(int sign in new[]{-1,1}){
    float x=sign*.87f;MeshArt.Tube(p,"Fixed service return pipe",new[]{new Vector3(x,.04f,.27f),new Vector3(x,1.32f,.27f),new Vector3(x*.84f,1.51f,.27f)},.045f,FixtureMaterials.Get(p,FixtureFinish.Copper),20);
    foreach(float y in new[]{.19f,1.14f})Bracket(p,new Vector3(x,y,.27f),.12f);
   }
   if(key=="circulation-pump"){
    B(p,"Pump wall mounting cradle",new Vector3(.02f,.55f,.30f),new Vector3(.55f,.12f,.17f),FixtureFinish.Steel,.012f);
    foreach(float x in new[]{-.19f,.23f})MeshArt.Oval(p,"Pump cradle anchor",new Vector3(x,.55f,.20f),new Vector3(.039f,.039f,.021f),FixtureMaterials.Get(p,FixtureFinish.Chrome),10);
   }else if(key=="service-boiler"){
    B(p,"Boiler upper suspension rail",new Vector3(0,1.29f,.31f),new Vector3(.93f,.072f,.12f),FixtureFinish.Steel,.009f);
    MeshArt.Tube(p,"Boiler rear flue connection",new[]{new Vector3(.15f,1.28f,.28f),new Vector3(.15f,1.65f,.28f),new Vector3(.15f,1.65f,.44f)},.09f,FixtureMaterials.Get(p,FixtureFinish.Steel),20);
   }
   B(p,"Mechanical service tray",new Vector3(.69f,.025f,-.35f),new Vector3(.36f,.045f,.32f),FixtureFinish.Steel,.012f);
  }
  static void Hvac(Transform p,string key)
  {
   Floor(p,FixtureFinish.Concrete);Wall(p,"HVAC system service wall",.42f,2.65f,FixtureFinish.Plaster);
   B(p,"HVAC ceiling soffit",new Vector3(0,1.42f,.20f),new Vector3(2.65f,.17f,.93f),FixtureFinish.Plaster,.018f);
   B(p,"Galvanized supply duct",new Vector3(0,1.25f,.27f),new Vector3(1.85f,.21f,.29f),FixtureFinish.Steel,.013f);
   for(int i=0;i<3;i++)Box(p,"Duct folded seam",new Vector3((i-1)*.59f,1.25f,.105f),new Vector3(.016f,.21f,.014f),FixtureFinish.Chrome);
   Box(p,"HVAC service access frame",new Vector3(0,.68f,.36f),new Vector3(1.49f,1.17f,.055f),FixtureFinish.Steel);
   foreach(float x in new[]{-.67f,.67f})for(int j=0;j<3;j++)MeshArt.Oval(p,"Service panel fastener",new Vector3(x,.22f+j*.43f,.32f),new Vector3(.028f,.028f,.013f),FixtureMaterials.Get(p,FixtureFinish.Chrome),8);
   if(key=="cooling-gauge")B(p,"Cooling port service bracket",new Vector3(.57f,.69f,.34f),new Vector3(.24f,.05f,.12f),FixtureFinish.Steel,.008f);
   if(key=="condensate-drain"||key=="climate-coil")MeshArt.Tube(p,"Fixed condensate continuation",new[]{new Vector3(.86f,.12f,.32f),new Vector3(.86f,.54f,.32f)},.030f,FixtureMaterials.Get(p,FixtureFinish.Ceramic),16);
  }
  public static void KitchenBasin(Transform p)
  {
   const int n=48;var rim=new System.Collections.Generic.List<Vector3>();var rt=new System.Collections.Generic.List<int>();var inside=new System.Collections.Generic.List<Vector3>();var it=new System.Collections.Generic.List<int>();
   Vector3 Point(int i,float width,float depth,float y){float a=(i%n)*Mathf.PI*2/n,c=Mathf.Cos(a),sn=Mathf.Sin(a);return new Vector3(Mathf.Sign(c)*Mathf.Sqrt(Mathf.Abs(c))*width*.5f,y,Mathf.Sign(sn)*Mathf.Sqrt(Mathf.Abs(sn))*depth*.5f-.05f);}
   for(int ring=0;ring<2;ring++)for(int i=0;i<=n;i++){
    rim.Add(Point(i,ring==0?1.12f:.90f,ring==0?.72f:.55f,.083f));inside.Add(Point(i,ring==0?.90f:.72f,ring==0?.55f:.39f,ring==0?.083f:-.19f));
    if(ring>0&&i<n){int k=ring*(n+1)+i,prev=k-(n+1);rt.AddRange(new[]{prev,k,prev+1,prev+1,k,k+1});it.AddRange(new[]{prev,k,prev+1,prev+1,k,k+1});}
   }
   int center=inside.Count;inside.Add(new Vector3(0,-.19f,-.05f));for(int i=0;i<n;i++){int k=n+1+i;it.AddRange(new[]{center,k+1,k});}
   var steel=FixtureMaterials.Get(p,FixtureFinish.Steel);MeshArt.Mesh(p,"Stainless kitchen sink rim",rim.ToArray(),rt.ToArray(),null,steel);MeshArt.Mesh(p,"Kitchen sink recess",inside.ToArray(),it.ToArray(),null,steel);
   var drain=MeshArt.Lathe(p,"Kitchen basket drain",new[]{0f,.014f,.023f},new[]{.066f,.066f,.048f},24,FixtureMaterials.Get(p,FixtureFinish.Chrome),Vector3.one);drain.transform.localPosition=new Vector3(0,-.187f,-.05f);
   for(int i=0;i<5;i++)Box(p,"Basket drain slot",new Vector3((i-2)*.016f,-.16f,-.05f),new Vector3(.006f,.004f,.07f),FixtureFinish.Navy);
  }
  static void Bracket(Transform p,Vector3 pipe,float reach)
  {
   B(p,"Pipe mounting wall shoe",pipe+Vector3.forward*reach,new Vector3(.12f,.13f,.025f),FixtureFinish.Steel,.007f);
   B(p,"Pipe mounting standoff",pipe+Vector3.forward*reach*.5f,new Vector3(.025f,.036f,reach),FixtureFinish.Steel,.006f);
   var ring=MeshArt.Lathe(p,"Pipe support collar",new[]{-.023f,.023f},new[]{.065f,.065f},20,FixtureMaterials.Get(p,FixtureFinish.Steel),Vector3.one);ring.transform.localPosition=pipe;
   foreach(float x in new[]{-.047f,.047f})MeshArt.Oval(p,"Pipe clip fixing bolt",pipe+new Vector3(x,0,-.042f),new Vector3(.024f,.024f,.018f),FixtureMaterials.Get(p,FixtureFinish.Chrome),8);
  }
 }
}
