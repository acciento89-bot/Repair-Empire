using UnityEngine;

namespace Kamilunavo.RepairEmpire.Visuals
{
 // Simplified game props with task-specific silhouettes and exposed service parts.
 // Every mesh belongs to its preview root; the studio owns the finite shared materials.
 public static class JobFixtureArt
 {
  static Material Part(Transform root,int phase,int completedCount=0,int actionIndex=0)=>phase==2?FixtureMaterials.Get(root,FixtureFinish.Green):phase==1&&completedCount<=actionIndex?FixtureMaterials.Get(root,FixtureFinish.Orange):FixtureMaterials.Get(root,FixtureFinish.Steel);
  static GameObject B(Transform root,string name,Vector3 p,Vector3 size,Material material)=>MeshArt.BevelBox(root,name,p,size,.018f,material);
  static GameObject O(Transform root,string name,Vector3 p,Vector3 size,Material material)=>MeshArt.Oval(root,name,p,size,material,12);
  static GameObject T(Transform root,string name,Material material,float radius,params Vector3[] points)=>MeshArt.Tube(root,name,points,radius,material,12);
  public static bool Electrical(string key)=>key=="switch"||key=="breaker-panel"||key=="wall-outlet"||key=="hall-light"||key=="doorbell-chime"||key=="fuse-cartridge";
  public static void Build(Transform root,string key,int phase,int contacts)
  {
   switch(key){
    case "sink":Sink(root,phase,contacts);break;
    case "pipe-leak":PipeLeak(root,phase,contacts);break;
    case "shower-valve":Shower(root,phase,contacts);break;
    case "kitchen-mixer":KitchenMixer(root,phase,contacts);break;
    case "breaker-panel":Breakers(root,phase,contacts);break;
    case "wall-outlet":Outlet(root,phase,contacts);break;
    case "hall-light":HallLight(root,phase,contacts);break;
    case "doorbell-chime":Doorbell(root,phase,contacts);break;
    case "fuse-cartridge":Fuse(root,phase,contacts);break;
    case "room-thermostat":Thermostat(root,phase,contacts);break;
    case "heating-valve":HeatingValve(root,phase,contacts);break;
    case "circulation-pump":Pump(root,phase,contacts);break;
    case "service-boiler":Boiler(root,phase,contacts);break;
    case "flush-manifold":Flush(root,phase,contacts);break;
    case "ventilation-fan":Fan(root,phase,contacts);break;
    case "condensate-drain":Drain(root,phase,contacts);break;
    case "airflow-dampers":Dampers(root,phase,contacts);break;
    case "cooling-gauge":CoolingGauge(root,phase,contacts);break;
    case "climate-coil":Coil(root,phase,contacts);break;
   }
  }
  static void Dial(Transform root,string name,Vector3 position,float radius,int phase)
  {
   O(root,name+" steel bezel",position,new Vector3(radius*2,radius*2,.075f),FixtureMaterials.Get(root,FixtureFinish.Steel));
   O(root,name+" face",position+Vector3.back*.04f,new Vector3(radius*1.74f,radius*1.74f,.018f),FixtureMaterials.Get(root,FixtureFinish.Ceramic));
   var needle=B(root,name+" needle",position+Vector3.back*.055f,new Vector3(.012f,radius*1.2f,.013f),phase==2?FixtureMaterials.Get(root,FixtureFinish.Green):FixtureMaterials.Get(root,FixtureFinish.Orange));needle.transform.localRotation=Quaternion.Euler(0,0,phase==2?-34:28);
   for(int tick=0;tick<7;tick++){float a=(tick*32-96)*Mathf.Deg2Rad;var mark=B(root,name+" scale tick",position+new Vector3(Mathf.Sin(a)*radius*.69f,Mathf.Cos(a)*radius*.69f,-.054f),new Vector3(.009f,.028f,.009f),FixtureMaterials.Get(root,FixtureFinish.Navy));mark.transform.localRotation=Quaternion.Euler(0,0,-a*Mathf.Rad2Deg);}
  }
  static void Valve(Transform root,string name,Vector3 p,int phase,float size=.16f)
  {
   O(root,name+" valve body",p,new Vector3(size*1.4f,size*.9f,size*.9f),FixtureMaterials.Get(root,FixtureFinish.Copper));
   var knob=B(root,name+" control lever",p+Vector3.up*size*.45f,new Vector3(size*1.7f,.025f,.065f),Part(root,phase));knob.transform.localRotation=Quaternion.Euler(0,phase==1?80:0,0);
  }
  static void Sink(Transform root,int phase,int done)
  {
   // Raised basin leaves the actual removable U-trap visible below it.
   MeshArt.Lathe(root,"Sink raised porcelain bowl",new[]{.43f,.50f,.62f,.63f,.59f,.46f},new[]{.14f,.29f,.44f,.46f,.38f,.16f},28,FixtureMaterials.Get(root,FixtureFinish.Ceramic),new Vector3(1.35f,1,1));
   T(root,"Sink drain tailpiece",FixtureMaterials.Get(root,FixtureFinish.Steel),.038f,new Vector3(0,.45f,0),new Vector3(0,.19f,0));
   T(root,"Sink exposed U-trap",Part(root,phase,done,2),.065f,new Vector3(0,.19f,0),new Vector3(0,.075f,-.05f),new Vector3(.20f,.045f,-.05f),new Vector3(.32f,.16f,-.04f),new Vector3(.32f,.32f,0),new Vector3(.55f,.32f,.28f));
   foreach(var p in new[]{new Vector3(0,.20f,0),new Vector3(.32f,.25f,0)})O(root,"Trap threaded union",p,new Vector3(.18f,.065f,.18f),FixtureMaterials.Get(root,FixtureFinish.Steel));
   if(phase==1&&done<2)O(root,"Visible trap blockage",new Vector3(.17f,.10f,-.09f),new Vector3(.15f,.065f,.10f),FixtureMaterials.Get(root,FixtureFinish.Dirt));
   T(root,"Sink tap supply",FixtureMaterials.Get(root,FixtureFinish.Steel),.031f,new Vector3(-.22f,.60f,.23f),new Vector3(-.22f,.91f,.23f),new Vector3(-.22f,.96f,.10f),new Vector3(-.22f,.80f,-.05f));
  }
  static void PipeLeak(Transform root,int phase,int done)
  {
   T(root,"Leaking copper wall pipe",FixtureMaterials.Get(root,FixtureFinish.Copper),.058f,new Vector3(-.63f,.67f,.17f),new Vector3(.39f,.67f,.17f),new Vector3(.51f,.67f,.17f),new Vector3(.51f,1.11f,.17f));
   foreach(float x in new[]{-.50f,.37f})B(root,"Pipe wall bracket",new Vector3(x,.67f,.29f),new Vector3(.17f,.17f,.08f),FixtureMaterials.Get(root,FixtureFinish.Steel));
   var clamp=O(root,"Repair split clamp",new Vector3(-.02f,.67f,phase==1&&done==0?-.10f:.17f),new Vector3(.27f,.19f,.19f),Part(root,phase,done,2));
   B(clamp.transform,"Clamp seam",Vector3.zero,new Vector3(.23f,.011f,.21f),FixtureMaterials.Get(root,FixtureFinish.Navy));
   foreach(float y in new[]{.60f,.74f})O(root,"Clamp fastening bolt",new Vector3(-.02f,y,.045f),new Vector3(.034f,.034f,.027f),Part(root,phase,done,2));
   if(phase<2)T(root,"Pipe leak droplet trail",FixtureMaterials.Get(root,FixtureFinish.Blue),.009f,new Vector3(-.035f,.61f,.14f),new Vector3(-.035f,.17f,.14f));
  }
  static void Shower(Transform root,int phase,int done)
  {
   T(root,"Shower vertical riser",FixtureMaterials.Get(root,FixtureFinish.Steel),.035f,new Vector3(-.17f,.22f,.22f),new Vector3(-.17f,1.15f,.22f),new Vector3(.17f,1.15f,.05f));
   O(root,"Shower rain head",new Vector3(.17f,1.13f,-.015f),new Vector3(.42f,.065f,.31f),FixtureMaterials.Get(root,FixtureFinish.Steel));
   T(root,"Shower thermostatic mixer barrel",FixtureMaterials.Get(root,FixtureFinish.Steel),.073f,new Vector3(-.44f,.43f,.12f),new Vector3(.44f,.43f,.12f));
   foreach(float x in new[]{-.42f,.42f})O(root,"Hot cold mixer control",new Vector3(x,.43f,.12f),new Vector3(.13f,.17f,.17f),Part(root,phase,done,1));
   O(root,"Shower diverter cartridge",new Vector3(0,phase==1&&done<2?.63f:.43f,.04f),new Vector3(.10f,.17f,.10f),FixtureMaterials.Get(root,FixtureFinish.Copper));
   for(int i=0;i<5;i++)B(root,"Shower head nozzle",new Vector3(.05f+i*.055f,1.093f,-.03f),new Vector3(.015f,.012f,.015f),FixtureMaterials.Get(root,FixtureFinish.Navy));
  }
  static void KitchenMixer(Transform root,int phase,int done)
  {
   FixtureContextArt.KitchenBasin(root);
   T(root,"High kitchen gooseneck",FixtureMaterials.Get(root,FixtureFinish.Steel),.044f,new Vector3(-.29f,.13f,.25f),new Vector3(-.29f,.75f,.25f),new Vector3(-.12f,.91f,.25f),new Vector3(.14f,.91f,.25f),new Vector3(.25f,.77f,.11f),new Vector3(.25f,.57f,-.05f));
   O(root,"Kitchen spray aerator",new Vector3(.25f,phase==0&&done>0?.34f:.54f,-.05f),new Vector3(.10f,.14f,.10f),Part(root,phase));
   Valve(root,"Kitchen hot handle",new Vector3(-.46f,.18f,.24f),phase,.10f);Valve(root,"Kitchen cold handle",new Vector3(.46f,.18f,.24f),phase,.10f);
   if(phase==1)O(root,"Exposed mixer ceramic cartridge",new Vector3(-.45f,.39f,.24f),new Vector3(.10f,.15f,.10f),FixtureMaterials.Get(root,FixtureFinish.Orange));
  }
  static void Breakers(Transform root,int phase,int done)
  {
   B(root,"Distribution panel enclosure",new Vector3(0,.68f,.22f),new Vector3(.93f,1.16f,.19f),FixtureMaterials.Get(root,FixtureFinish.Ceramic));B(root,"Panel inset rail bed",new Vector3(0,.68f,.105f),new Vector3(.76f,.92f,.03f),FixtureMaterials.Get(root,FixtureFinish.Navy));
   for(int i=0;i<6;i++){
    int col=i%3,row=i/3;var p=new Vector3((col-1)*.22f,.40f+row*.41f,.05f);B(root,"Breaker DIN module",p,new Vector3(.19f,.32f,.12f),FixtureMaterials.Get(root,FixtureFinish.Ceramic));
    B(root,i==2?"Tripped breaker handle":"Circuit breaker handle",p+new Vector3(0,i==2&&phase<2?-.04f:.04f,-.08f),new Vector3(.11f,.056f,.07f),i==2?Part(root,phase,done,2):FixtureMaterials.Get(root,FixtureFinish.Navy));
    B(root,"Circuit designation strip",p+new Vector3(0,-.12f,-.071f),new Vector3(.13f,.022f,.008f),FixtureMaterials.Get(root,FixtureFinish.Blue));
   }
  }
  static void Outlet(Transform root,int phase,int done)
  {
   B(root,"Duplex socket faceplate",new Vector3(0,.71f,.10f),new Vector3(.52f,.78f,.08f),FixtureMaterials.Get(root,FixtureFinish.Ceramic));B(root,"Outlet mounting reveal",new Vector3(0,.71f,.17f),new Vector3(.58f,.84f,.06f),FixtureMaterials.Get(root,FixtureFinish.Navy));
   foreach(float y in new[]{.52f,.90f}){
    O(root,"Socket circular recess",new Vector3(0,y,.038f),new Vector3(.28f,.28f,.02f),FixtureMaterials.Get(root,FixtureFinish.Steel));
    foreach(float x in new[]{-.065f,.065f})O(root,"Socket pin opening",new Vector3(x,y,.021f),new Vector3(.03f,.03f,.016f),FixtureMaterials.Get(root,FixtureFinish.Navy));
   }
   foreach(float y in new[]{.37f,1.05f})O(root,"Outlet mounting screw",new Vector3(phase==1&&done==0?.10f:0,y,.022f),new Vector3(.04f,.04f,.027f),Part(root,phase,done,2));
   if(phase==1)T(root,"Outlet exposed terminal lead",FixtureMaterials.Get(root,FixtureFinish.Copper),.012f,new Vector3(.25f,.60f,.045f),new Vector3(.37f,.73f,-.09f),new Vector3(.27f,.91f,.045f));
  }
  static void HallLight(Transform root,int phase,int done)
  {
   B(root,"Hall luminaire backing",new Vector3(0,.87f,.21f),new Vector3(1.35f,.48f,.15f),FixtureMaterials.Get(root,FixtureFinish.Steel));
   B(root,"Hall replaceable LED driver",new Vector3(0,.87f,.093f),new Vector3(.86f,.20f,.07f),Part(root,phase,done,1));
   var diffuser=B(root,"Hall frosted diffuser",new Vector3(0,phase==1?.25f:.87f,phase==1?-.17f:.037f),new Vector3(1.23f,.39f,.06f),phase==2?FixtureMaterials.Get(root,FixtureFinish.Lamp):FixtureMaterials.Get(root,FixtureFinish.Ceramic));if(phase==1)diffuser.transform.localRotation=Quaternion.Euler(80,0,-8);
   foreach(float x in new[]{-.49f,.49f})O(root,"Luminaire end fastening",new Vector3(x,.87f,.02f),new Vector3(.034f,.034f,.02f),FixtureMaterials.Get(root,FixtureFinish.Steel));
  }
  static void Doorbell(Transform root,int phase,int done)
  {
   B(root,"Doorbell chime casing",new Vector3(-.10f,.88f,.20f),new Vector3(.86f,.49f,.13f),FixtureMaterials.Get(root,FixtureFinish.Ceramic));
   for(int i=0;i<6;i++)B(root,"Chime sound grille",new Vector3(-.42f+i*.12f,.88f,.116f),new Vector3(.035f,.24f,.018f),FixtureMaterials.Get(root,FixtureFinish.Navy));
   B(root,"Doorbell pushbutton mount",new Vector3(.49f,.34f,.11f),new Vector3(.17f,.28f,.08f),FixtureMaterials.Get(root,FixtureFinish.Steel));O(root,"Doorbell pushbutton",new Vector3(.49f,.35f,.055f),new Vector3(.084f,.084f,.035f),phase==2?FixtureMaterials.Get(root,FixtureFinish.Green):FixtureMaterials.Get(root,FixtureFinish.Orange));
   T(root,"Doorbell low voltage cable",FixtureMaterials.Get(root,FixtureFinish.Blue),.014f,new Vector3(.49f,.47f,.20f),new Vector3(.49f,.59f,.20f),new Vector3(-.11f,.59f,.20f),new Vector3(-.11f,.65f,.20f));
   if(phase==1)for(int i=0;i<3;i++)B(root,"Chime lead terminal",new Vector3(-.24f+i*.14f,.57f,-.035f),new Vector3(.08f,.045f,.045f),Part(root,phase,done,i));
  }
  static void Fuse(Transform root,int phase,int done)
  {
   B(root,"Fused isolator enclosure",new Vector3(0,.67f,.22f),new Vector3(.70f,.83f,.19f),FixtureMaterials.Get(root,FixtureFinish.Ceramic));B(root,"Fuse holder open cavity",new Vector3(0,.60f,.108f),new Vector3(.51f,.54f,.04f),FixtureMaterials.Get(root,FixtureFinish.Navy));
   T(root,"Ceramic fuse cartridge",phase==1?FixtureMaterials.Get(root,FixtureFinish.Orange):FixtureMaterials.Get(root,FixtureFinish.Ceramic),.085f,new Vector3(-.18f,.60f,phase==1&&done<2?-.07f:.045f),new Vector3(.18f,.60f,phase==1&&done<2?-.07f:.045f));
   foreach(float x in new[]{-.21f,.21f})O(root,"Fuse cartridge end cap",new Vector3(x,.60f,.045f),new Vector3(.08f,.20f,.20f),FixtureMaterials.Get(root,FixtureFinish.Steel));
   B(root,"Fuse disconnect toggle",new Vector3(0,.97f,.052f),new Vector3(.23f,.10f,.09f),Part(root,phase));
  }
  static void Thermostat(Transform root,int phase,int done)
  {
   B(root,"Programmable thermostat casing",new Vector3(0,.74f,.16f),new Vector3(.76f,.62f,.13f),FixtureMaterials.Get(root,FixtureFinish.Ceramic));B(root,"Thermostat LCD",new Vector3(-.10f,.82f,.083f),new Vector3(.43f,.20f,.025f),FixtureMaterials.Get(root,FixtureFinish.Blue));
   for(int digit=0;digit<3;digit++){
    float x=-.25f+digit*.14f;foreach(float y in new[]{.755f,.815f,.875f})B(root,"LCD digit segment",new Vector3(x,y,.064f),new Vector3(.08f,.010f,.009f),phase==2?FixtureMaterials.Get(root,FixtureFinish.Green):FixtureMaterials.Get(root,FixtureFinish.Ceramic));
   }
   O(root,"Thermostat rotary selector",new Vector3(.25f,.69f,.057f),new Vector3(.17f,.17f,.055f),Part(root,phase,done,3));
   for(int i=0;i<4;i++)B(root,"Thermostat schedule key",new Vector3(-.24f+i*.14f,.54f,.059f),new Vector3(.085f,.045f,.035f),Part(root,phase,done,i));
   foreach(float x in new[]{-.31f,.31f})O(root,"Thermostat backplate mounting screw",new Vector3(x,.50f,.073f),new Vector3(.027f,.027f,.014f),FixtureMaterials.Get(root,FixtureFinish.Steel));
  }
  static void HeatingValve(Transform root,int phase,int done)
  {
   T(root,"Heating valve inlet",FixtureMaterials.Get(root,FixtureFinish.Copper),.062f,new Vector3(-.57f,.47f,.15f),new Vector3(.14f,.47f,.15f));T(root,"Heating valve outlet elbow",FixtureMaterials.Get(root,FixtureFinish.Copper),.062f,new Vector3(.14f,.47f,.15f),new Vector3(.39f,.47f,.15f),new Vector3(.39f,.11f,.15f));
   O(root,"Heating valve brass union",new Vector3(.06f,.47f,.15f),new Vector3(.27f,.22f,.22f),FixtureMaterials.Get(root,FixtureFinish.Copper));O(root,"Heating replaceable spindle",new Vector3(.06f,phase==1&&done<2?.83f:.61f,.15f),new Vector3(.085f,.26f,.085f),Part(root,phase,done,2));
   O(root,"Thermostatic valve control head",new Vector3(.06f,phase==1&&done<3?1.04f:.80f,.15f),new Vector3(.25f,.27f,.25f),FixtureMaterials.Get(root,FixtureFinish.Ceramic));
   for(int i=0;i<8;i++){float a=i*Mathf.PI/4;B(root,"Thermostat head rib",new Vector3(.06f+Mathf.Cos(a)*.12f,.80f,.15f+Mathf.Sin(a)*.12f),new Vector3(.016f,.20f,.016f),FixtureMaterials.Get(root,FixtureFinish.Steel));}
  }
  static void Pump(Transform root,int phase,int done)
  {
   T(root,"Pump copper feed return",FixtureMaterials.Get(root,FixtureFinish.Copper),.058f,new Vector3(-.51f,.21f,.20f),new Vector3(-.25f,.21f,.20f),new Vector3(-.25f,.64f,.20f),new Vector3(.40f,.64f,.20f),new Vector3(.40f,.13f,.20f));
   var housing=MeshArt.Lathe(root,"Circulation pump volute",new[]{-.15f,-.16f,-.13f,.10f,.14f,.14f,-.07f,-.15f},new[]{.18f,.25f,.29f,.29f,.23f,0f,0f,.18f},32,FixtureMaterials.Get(root,FixtureFinish.Blue),Vector3.one);housing.transform.localRotation=Quaternion.Euler(90,0,0);housing.transform.localPosition=new Vector3(.02f,.64f,.11f);
   for(int i=0;i<4;i++){
    float a=(i+.5f)*Mathf.PI/2;var pos=new Vector3(.02f+Mathf.Cos(a)*.232f,.64f+Mathf.Sin(a)*.232f,-.058f);
    var screw=MeshArt.Lathe(root,"Pump casing hex fastener",new[]{-.013f,.013f},new[]{.025f,.025f},6,FixtureMaterials.Get(root,FixtureFinish.Steel),Vector3.one,true);screw.transform.localRotation=Quaternion.Euler(90,0,0);screw.transform.localPosition=pos;
    B(root,"Pump fastener inset",pos-Vector3.forward*.015f,new Vector3(.016f,.004f,.004f),FixtureMaterials.Get(root,FixtureFinish.Navy));
   }
   for(int side=-1;side<=1;side+=2){
    var union=MeshArt.Lathe(root,"Pump threaded connector union",new[]{-.034f,-.027f,.027f,.034f},new[]{.067f,.092f,.092f,.067f},8,FixtureMaterials.Get(root,FixtureFinish.Brass),Vector3.one,true);union.transform.localRotation=Quaternion.Euler(0,0,90);union.transform.localPosition=new Vector3(.02f+side*.32f,.64f,.20f);
   }
   O(root,"Pump removable front plate",new Vector3(.02f,phase==1&&done<2?.26f:.64f,phase==1&&done<2?-.10f:-.07f),new Vector3(.42f,.42f,.08f),Part(root,phase,done,2));
   O(root,"Pump impeller hub",new Vector3(.02f,.64f,-.095f),new Vector3(.12f,.12f,.08f),FixtureMaterials.Get(root,FixtureFinish.Copper));
   for(int blade=0;blade<5;blade++){
    float a=blade*Mathf.PI*2/5;var points=new Vector3[5];for(int i=0;i<5;i++){float f=i/4f,angle=a+f*.56f,r=.038f+f*.12f;points[i]=new Vector3(.02f+Mathf.Cos(angle)*r,.64f+Mathf.Sin(angle)*r,-.10f);}
    T(root,"Pump curved impeller blade",phase==1?FixtureMaterials.Get(root,FixtureFinish.Orange):FixtureMaterials.Get(root,FixtureFinish.Steel),.012f,points);
   }
  }
  static void Boiler(Transform root,int phase,int done)
  {
   B(root,"Boiler service chassis",new Vector3(0,.68f,.22f),new Vector3(.82f,1.19f,.25f),FixtureMaterials.Get(root,FixtureFinish.Ceramic));B(root,"Boiler exposed exchanger bed",new Vector3(0,.86f,.064f),new Vector3(.62f,.61f,.035f),FixtureMaterials.Get(root,FixtureFinish.Navy));
   for(int i=0;i<7;i++)T(root,"Boiler heat exchanger tube",phase==1&&done<2?FixtureMaterials.Get(root,FixtureFinish.Copper):FixtureMaterials.Get(root,FixtureFinish.Steel),.026f,new Vector3(-.23f+i*.076f,.62f,.015f),new Vector3(-.23f+i*.076f,1.11f,.015f));
   B(root,"Boiler burner manifold",new Vector3(0,.40f,.026f),new Vector3(.61f,.15f,.14f),FixtureMaterials.Get(root,FixtureFinish.Steel));for(int i=0;i<5;i++)O(root,"Boiler burner port",new Vector3(-.21f+i*.105f,.44f,-.052f),new Vector3(.04f,.04f,.032f),phase==2?FixtureMaterials.Get(root,FixtureFinish.Blue):FixtureMaterials.Get(root,FixtureFinish.Navy));
   B(root,"Boiler service filter",new Vector3(phase==1&&done==0?.55f:0,.23f,.014f),new Vector3(.47f,.11f,.08f),Part(root,phase,done,2));Dial(root,"Boiler pressure gauge",new Vector3(.24f,.17f,-.035f),.078f,phase);
  }
  static void Flush(Transform root,int phase,int done)
  {
   T(root,"System flush manifold",FixtureMaterials.Get(root,FixtureFinish.Copper),.052f,new Vector3(-.59f,.83f,.20f),new Vector3(.59f,.83f,.20f));
   for(int i=0;i<3;i++){float x=-.37f+i*.37f;T(root,"Flush circuit branch",FixtureMaterials.Get(root,FixtureFinish.Copper),.028f,new Vector3(x,.83f,.20f),new Vector3(x,.59f,.20f));Valve(root,"Flush branch valve",new Vector3(x,.59f,.20f),phase,.11f);}
   B(root,"Flush machine tank",new Vector3(-.11f,.26f,-.16f),new Vector3(.65f,.48f,.48f),FixtureMaterials.Get(root,FixtureFinish.Blue));B(root,"Flush pump lid",new Vector3(-.11f,.53f,-.16f),new Vector3(.69f,.07f,.51f),FixtureMaterials.Get(root,FixtureFinish.Navy));
   T(root,"Flush inlet hose",FixtureMaterials.Get(root,FixtureFinish.Orange),.023f,new Vector3(-.32f,.49f,-.16f),new Vector3(-.51f,.36f,-.01f),new Vector3(-.60f,.62f,.10f),new Vector3(-.37f,.72f,.20f));
   T(root,"Flush return hose",FixtureMaterials.Get(root,FixtureFinish.Blue),.023f,new Vector3(.13f,.49f,-.16f),new Vector3(.56f,.23f,-.01f),new Vector3(.68f,.62f,.10f),new Vector3(.37f,.72f,.20f));Dial(root,"Flush machine gauge",new Vector3(-.11f,.32f,-.414f),.095f,phase);
  }
  static void Fan(Transform root,int phase,int done)
  {
   B(root,"Ventilation fan square frame",new Vector3(0,.74f,.20f),new Vector3(.83f,.83f,.16f),FixtureMaterials.Get(root,FixtureFinish.Ceramic));O(root,"Fan circular shroud",new Vector3(0,.74f,.10f),new Vector3(.70f,.70f,.08f),FixtureMaterials.Get(root,FixtureFinish.Navy));O(root,"Fan motor hub",new Vector3(0,.74f,.044f),new Vector3(.14f,.14f,.13f),FixtureMaterials.Get(root,FixtureFinish.Steel));
   for(int i=0;i<5;i++){var blade=B(root,"Ventilation fan rotor blade",new Vector3(0,.74f,.049f),new Vector3(.13f,.51f,.045f),Part(root,phase,done,1));blade.transform.localRotation=Quaternion.Euler(0,0,i*72+20);}
   if(phase!=1)for(int i=0;i<7;i++)B(root,"Fan protective grille bar",new Vector3(-.30f+i*.10f,.74f,-.04f),new Vector3(.012f,.65f,.014f),FixtureMaterials.Get(root,FixtureFinish.Steel));
  }
  static void Drain(Transform root,int phase,int done)
  {
   B(root,"AC condensate collection pan",new Vector3(0,.87f,.10f),new Vector3(1.19f,.13f,.45f),FixtureMaterials.Get(root,FixtureFinish.Ceramic));B(root,"Condensate trough water",new Vector3(0,.94f,.09f),new Vector3(1.04f,.012f,.32f),FixtureMaterials.Get(root,FixtureFinish.Blue));
   T(root,"AC condensate drain elbow",FixtureMaterials.Get(root,FixtureFinish.Ceramic),.043f,new Vector3(.42f,.84f,.10f),new Vector3(.42f,.34f,.10f),new Vector3(.20f,.24f,.10f),new Vector3(-.44f,.24f,.10f));
   O(root,"Drain inspection cap",new Vector3(.42f,.61f,.015f),new Vector3(.13f,.13f,.10f),Part(root,phase));
   if(phase<2)O(root,"Condensate drain obstruction",new Vector3(.18f,.24f,.047f),new Vector3(.15f,.06f,.07f),FixtureMaterials.Get(root,FixtureFinish.Dirt));
   B(root,"Drain test collection vessel",new Vector3(-.47f,.12f,.03f),new Vector3(.28f,.23f,.28f),FixtureMaterials.Get(root,FixtureFinish.Blue));
  }
  static void Dampers(Transform root,int phase,int done)
  {
   B(root,"Ventilation balancing plenum",new Vector3(0,.85f,.27f),new Vector3(1.32f,.38f,.28f),FixtureMaterials.Get(root,FixtureFinish.Steel));
   for(int i=0;i<3;i++){
    float x=-.43f+i*.43f;T(root,"Independent ventilation duct",FixtureMaterials.Get(root,FixtureFinish.Steel),.116f,new Vector3(x,.75f,.25f),new Vector3(x,.38f,.25f));
    B(root,"Outlet air grille",new Vector3(x,.34f,.15f),new Vector3(.35f,.25f,.14f),FixtureMaterials.Get(root,FixtureFinish.Ceramic));
    for(int slat=0;slat<4;slat++)B(root,"Air grille louvre",new Vector3(x,.255f+slat*.052f,.067f),new Vector3(.28f,.012f,.045f),FixtureMaterials.Get(root,FixtureFinish.Navy));
    var lever=B(root,"Damper adjustment tab",new Vector3(x,.58f,.074f),new Vector3(.12f,.034f,.04f),Part(root,phase,done,i));lever.transform.localRotation=Quaternion.Euler(0,0,i<done?25:-25);
   }
  }
  static void CoolingGauge(Transform root,int phase,int done)
  {
   B(root,"Cooling manifold gauge block",new Vector3(0,.40f,.12f),new Vector3(.72f,.15f,.18f),FixtureMaterials.Get(root,FixtureFinish.Steel));Dial(root,"Low pressure gauge",new Vector3(-.24f,.70f,.13f),.17f,phase);Dial(root,"High pressure gauge",new Vector3(.24f,.70f,.13f),.17f,phase);
   Valve(root,"Cooling manifold left valve",new Vector3(-.42f,.40f,.12f),phase,.10f);Valve(root,"Cooling manifold right valve",new Vector3(.42f,.40f,.12f),phase,.10f);
   T(root,"Blue cooling service hose",FixtureMaterials.Get(root,FixtureFinish.Blue),.023f,new Vector3(-.23f,.33f,.12f),new Vector3(-.57f,.07f,-.05f),new Vector3(-.74f,.33f,.15f),new Vector3(-.57f,.62f,.38f));
   T(root,"Orange cooling service hose",FixtureMaterials.Get(root,FixtureFinish.Orange),.023f,new Vector3(.23f,.33f,.12f),new Vector3(.55f,.065f,-.05f),new Vector3(.73f,.31f,.15f),new Vector3(.57f,.62f,.38f));
   B(root,"Cooling test service port",new Vector3(.57f,.66f,.36f),new Vector3(.13f,.13f,.16f),FixtureMaterials.Get(root,FixtureFinish.Copper));
  }
  static void Coil(Transform root,int phase,int done)
  {
   B(root,"Climate coil service enclosure",new Vector3(0,.72f,.25f),new Vector3(1.20f,.91f,.24f),FixtureMaterials.Get(root,FixtureFinish.Ceramic));B(root,"Climate exchanger recess",new Vector3(0,.76f,.107f),new Vector3(1.03f,.58f,.035f),FixtureMaterials.Get(root,FixtureFinish.Navy));
   for(int i=0;i<14;i++)B(root,"Climate aluminum cooling fin",new Vector3(-.46f+i*.071f,.76f,.074f),new Vector3(.025f,.50f,.04f),phase==1&&done==0?FixtureMaterials.Get(root,FixtureFinish.Dirt):FixtureMaterials.Get(root,FixtureFinish.Steel));
   for(int row=0;row<3;row++)T(root,"Climate exposed copper coil",FixtureMaterials.Get(root,FixtureFinish.Copper),.021f,new Vector3(-.47f,.58f+row*.17f,.025f),new Vector3(.47f,.58f+row*.17f,.025f));
   B(root,"Climate condensate service tray",new Vector3(0,.35f,.079f),new Vector3(1.03f,.12f,.19f),Part(root,phase,done,1));
   T(root,"Coil drain tail",FixtureMaterials.Get(root,FixtureFinish.Ceramic),.028f,new Vector3(.43f,.34f,.15f),new Vector3(.43f,.12f,.15f),new Vector3(.64f,.12f,.19f));
  }
 }
}
