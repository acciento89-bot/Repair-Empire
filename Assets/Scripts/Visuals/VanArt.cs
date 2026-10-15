using System.Collections.Generic;
using UnityEngine;
using Kamilunavo.RepairEmpire.Gameplay;
namespace Kamilunavo.RepairEmpire.Visuals {
 public sealed class VanArt:MonoBehaviour {
  public VehicleController Motor;readonly List<Transform> wheels=new();Material livery,tailLight;Rigidbody body;bool built,braking;int lastStyle=-1,lastVehicle=-1;
  static readonly Color Navy=new(.025f,.075f,.13f),Orange=new(1,.32f,.045f);
  Material Own(string name,Color color,bool glow=false){var material=new Material(Resources.Load<Material>("Materials/Surface")){name=name,color=color};material.SetFloat("_Glossiness",.32f);if(glow){material.EnableKeyword("_EMISSION");material.SetColor("_EmissionColor",color*.55f);}ArtLifetime.Own(gameObject,material);return material;}
  public void Build()
  {
   if(built)return;built=true;
   var white=Own("VanPearl",new(.925f,.94f,.925f));white.SetFloat("_Glossiness",.78f);white.SetFloat("_Metallic",.18f);
   var navy=Own("VanNavy",Navy);var orange=Own("VanOrange",Orange);livery=Own("VanStyleLivery",Orange);livery.SetFloat("_Glossiness",.55f);
   var glass=Own("VanGlass",new(.055f,.12f,.16f));glass.SetFloat("_Metallic",.30f);glass.SetFloat("_Glossiness",.90f);
   var metal=Own("VanChrome",new(.64f,.7f,.74f));metal.SetFloat("_Metallic",.8f);metal.SetFloat("_Glossiness",.8f);
   var tyre=Own("VanTyre",new(.035f,.04f,.045f));tailLight=Own("VanTail",new(.65f,.035f,.025f),true);var headLight=Own("VanHeadlamp",new(1,.96f,.78f),true);
   VanCoachworkGeometry.Body(transform,white);MeshArt.BevelBox(transform,"Underbody",new(0,.42f,0),new(1.94f,.22f,4.25f),.09f,navy);VanCoachworkGeometry.Windshield(transform,glass);
   foreach(int side in new[]{-1,1})
   {
    VanCoachworkGeometry.CabGlazing(transform,side,navy,true);VanCoachworkGeometry.CabGlazing(transform,side,glass,false);
    MeshArt.BevelBox(transform,"Sliding door rail",new(side*1.064f,1.17f,-.72f),new(.018f,.026f,2.10f),.007f,metal);
    MeshArt.Tube(transform,"Cargo door shut line",new[]{new Vector3(side*1.064f,.99f,.38f),new Vector3(side*1.061f,1.70f,.38f),new Vector3(side*.97f,2.13f,.38f)},.005f,navy,6);
    MeshArt.BevelBox(transform,"Door handle",new(side*1.075f,1.28f,.14f),new(.035f,.065f,.20f),.020f,navy);
    MeshArt.Tube(transform,"Mirror arm",new[]{new Vector3(side*.94f,1.52f,1.55f),new Vector3(side*1.18f,1.55f,1.58f)},.027f,navy,10);
    MeshArt.BevelBox(transform,"Mirror housing",new(side*1.22f,1.61f,1.55f),new(.15f,.24f,.24f),.06f,navy);MeshArt.BevelBox(transform,"Mirror lens",new(side*1.22f,1.61f,1.421f),new(.11f,.19f,.015f),.035f,metal);
    VanCoachworkGeometry.SideBand(transform,"Navy lower service wrap",side,.45f,.72f,navy);VanCoachworkGeometry.SideBand(transform,"Orange service band",side,.68f,1.07f,livery);
    MeshArt.Tube(transform,"Ladder rail",new[]{new Vector3(side*.32f,2.63f,-2.0f),new Vector3(side*.32f,2.63f,.46f)},.032f,metal,12);
    MeshArt.Tube(transform,"Roof rack curved rail",new[]{new Vector3(side*.77f,2.42f,-1.97f),new Vector3(side*.77f,2.57f,-1.93f),new Vector3(side*.77f,2.61f,-1.80f),new Vector3(side*.77f,2.61f,.45f),new Vector3(side*.77f,2.49f,.56f)},.029f,metal,12);
    for(int i=0;i<4;i++)MeshArt.BevelBox(transform,"Ladder fastening bracket",new(side*.35f,2.66f,-1.8f+i*.66f),new(.09f,.025f,.055f),.01f,navy);
    var emblem=new GameObject("Side service emblem").transform;emblem.SetParent(transform,false);emblem.localPosition=new(side*1.080f,1.62f,-.67f);emblem.localRotation=Quaternion.Euler(0,side>0?-90:90,0);Gear(emblem,.20f,orange,navy,white);
    var lettering=new GameObject("Side brand lettering").transform;lettering.SetParent(transform,false);lettering.localPosition=new(side*1.080f,1.60f,-1.28f);lettering.localRotation=Quaternion.Euler(0,side>0?-90:90,0);Text(lettering,"REPAIR\nEMPIRE",Vector3.zero,.11f,Navy,Quaternion.identity);
    MeshArt.BevelBox(transform,"Side step tread",new(side*1.085f,.29f,.81f),new(.20f,.08f,1.12f),.035f,metal);for(int i=0;i<6;i++)MeshArt.Box(transform,"Step anti-slip groove",new(side*1.10f,.335f,.36f+i*.18f),new(.15f,.012f,.023f),navy);
    foreach(float axle in new[]{-1.42f,1.38f})VanCoachworkGeometry.WheelArch(transform,side,axle,navy);
    MeshArt.BevelBox(transform,"Mud flap",new(side*1.04f,.24f,-1.94f),new(.14f,.32f,.055f),.015f,navy);
   }
   for(int i=0;i<10;i++)MeshArt.Tube(transform,"Ladder rung",new[]{new Vector3(-.32f,2.63f,-1.92f+i*.26f),new Vector3(.32f,2.63f,-1.92f+i*.26f)},.024f,metal,10);
   for(int i=0;i<3;i++)MeshArt.BevelBox(transform,"Rack clamp",new(0,2.43f,-1.70f+i*.9f),new(1.50f,.08f,.09f),.025f,navy);
   MeshArt.BevelBox(transform,"Roof tool case",new(.55f,2.62f,-1.11f),new(.27f,.18f,.70f),.055f,orange);MeshArt.BevelBox(transform,"Tool case lid",new(.55f,2.72f,-1.11f),new(.29f,.035f,.72f),.016f,navy);
   var carrier=MeshArt.Lathe(transform,"Service pipe carrier",new[]{-1.16f,-1.15f,1.15f,1.16f},new[]{0f,.065f,.065f,0f},20,navy,Vector3.one);carrier.transform.localPosition=new(-.60f,2.64f,-.74f);carrier.transform.localRotation=Quaternion.Euler(90,0,0);foreach(float z in new[]{-1.90f,.42f})MeshArt.Oval(transform,"Carrier orange endcap",new(-.60f,2.64f,z),new(.135f,.135f,.025f),orange,12);
   // Rear details are shaped on the same compound surface as the body, not raised slabs.
   VanCoachworkGeometry.RearBand(transform,"Rear navy service wrap",.48f,.72f,navy);VanCoachworkGeometry.RearBand(transform,"Orange rear livery",.69f,1.065f,livery);
   var seam=new Vector3[17];for(int i=0;i<seam.Length;i++){float y=Mathf.Lerp(.67f,2.23f,i/(float)(seam.Length-1));seam[i]=new Vector3(0,y,VanCoachworkGeometry.RearSkinZ(0,y)-.006f);}MeshArt.Tube(transform,"Rear split seam",seam,.006f,navy,6);
   foreach(int side in new[]{-1,1})
   {
    VanCoachworkGeometry.SculptedPanel(transform,"Rear lamp housing",new Vector2(side*.87f,1.30f),new Vector2(.145f,1.03f),.060f,navy,true,.021f,.025f);
    VanCoachworkGeometry.SculptedPanel(transform,"Rear tail lamp",new Vector2(side*.87f,1.57f),new Vector2(.10f,.36f),.044f,tailLight,true,.040f,.012f);
    VanCoachworkGeometry.SculptedPanel(transform,"Rear indicator",new Vector2(side*.87f,1.26f),new Vector2(.10f,.16f),.035f,orange,true,.040f,.012f);
    VanCoachworkGeometry.SculptedPanel(transform,"Rear reverse lamp",new Vector2(side*.87f,1.06f),new Vector2(.10f,.13f),.035f,white,true,.040f,.012f);
    foreach(float y in new[]{.91f,1.69f})VanCoachworkGeometry.SculptedPanel(transform,"Cargo door hinge",new Vector2(side*.90f,y),new Vector2(.06f,.13f),.024f,metal,true,.022f,.018f);
   }
   VanCoachworkGeometry.SculptedPanel(transform,"Cargo door handle",new Vector2(-.12f,1.13f),new Vector2(.21f,.055f),.022f,navy,true,.022f,.025f);
   VanCoachworkGeometry.SculptedPanel(transform,"Roof brake lamp",new Vector2(0,2.245f),new Vector2(.43f,.045f),.018f,tailLight,true,.022f,.012f);
   VanCoachworkGeometry.SculptedPanel(transform,"Number plate surround",new Vector2(0,.58f),new Vector2(.84f,.22f),.04f,navy,true,.022f,.018f);
   VanCoachworkGeometry.SculptedPanel(transform,"Rear number plate",new Vector2(0,.58f),new Vector2(.76f,.16f),.024f,white,true,.037f,.012f);
   Text(transform,"REPAIR",new(0,.59f,VanCoachworkGeometry.RearSkinZ(0,.59f)-.050f),.078f,Navy,Quaternion.identity);
   var logo=new GameObject("Repair gear and wrench").transform;logo.SetParent(transform,false);logo.localPosition=new(-.44f,1.78f,VanCoachworkGeometry.RearSkinZ(-.44f,1.78f)-.025f);Gear(logo,.27f,orange,navy,white);
   Text(transform,"REPAIR",new(.33f,1.94f,VanCoachworkGeometry.RearSkinZ(.33f,1.94f)-.022f),.18f,Navy,Quaternion.identity);Text(transform,"EMPIRE",new(.33f,1.71f,VanCoachworkGeometry.RearSkinZ(.33f,1.71f)-.022f),.17f,Orange,Quaternion.identity);
   Text(transform,"KAMILUNAVO",new(0,.83f,VanCoachworkGeometry.RearSkinZ(0,.83f)-.025f),.060f,Color.white,Quaternion.identity);
   VanCoachworkGeometry.Bumper(transform,"Rear bumper",new(0,.42f,-2.22f),navy);VanCoachworkGeometry.Bumper(transform,"Front bumper",new(0,.42f,2.16f),navy);
   VanCoachworkGeometry.SculptedPanel(transform,"Grille",new Vector2(0,.92f),new Vector2(1.04f,.32f),.10f,navy,false,.023f,.020f);
   for(int i=0;i<4;i++){var path=new Vector3[17];float y=.82f+i*.065f;for(int j=0;j<path.Length;j++){float x=Mathf.Lerp(-.43f,.43f,j/(float)(path.Length-1));path[j]=new Vector3(x,y,VanCoachworkGeometry.FrontSkinZ(x,y)+.039f);}MeshArt.Tube(transform,"Grille slat",path,.008f,metal,6);}
   foreach(int side in new[]{-1,1}){VanCoachworkGeometry.SculptedPanel(transform,"Headlight surround",new Vector2(side*.74f,1.07f),new Vector2(.44f,.23f),.07f,navy,false,.022f,.020f);VanCoachworkGeometry.SculptedPanel(transform,"Headlight",new Vector2(side*.74f,1.07f),new Vector2(.38f,.17f),.05f,headLight,false,.039f,.012f);VanCoachworkGeometry.Wiper(transform,side,navy);}
   foreach(int side in new[]{-1,1})foreach(float z in new[]{-1.42f,1.38f}){var wheel=new GameObject("Wheel").transform;wheel.SetParent(transform,false);wheel.localPosition=new(side*1.035f,.38f,z);wheel.localRotation=Quaternion.Euler(0,0,90);MeshArt.Lathe(wheel,"Rubber tire",new[]{-.14f,-.12f,0,.12f,.14f},new[]{.36f,.45f,.48f,.45f,.36f},32,tyre,Vector3.one);MeshArt.Lathe(wheel,"Alloy rim",new[]{-.151f,-.151f,.151f,.151f},new[]{0f,.31f,.31f,0f},24,metal,Vector3.one);foreach(int face in new[]{-1,1}){var rim=new GameObject("Pressed steel wheel face").transform;rim.SetParent(wheel,false);rim.localRotation=face<0?Quaternion.Euler(180,0,0):Quaternion.identity;for(int i=0;i<8;i++){float a=i*45*Mathf.Deg2Rad;var spoke=MeshArt.Box(rim,"Rim ventilation recess",new(Mathf.Cos(a)*.215f,.157f,Mathf.Sin(a)*.215f),new(.105f,.025f,.052f),navy);spoke.transform.localRotation=Quaternion.Euler(0,-i*45,0);}MeshArt.Lathe(rim,"Alloy center cap",new[]{.16f,.175f,.18f},new[]{.085f,.09f,.06f},20,metal,Vector3.one);for(int bolt=0;bolt<5;bolt++){float a=bolt*Mathf.PI*2/5;MeshArt.Oval(rim,"Wheel lug nut",new(Mathf.Cos(a)*.105f,.183f,Mathf.Sin(a)*.105f),new(.036f,.018f,.036f),metal,8);}}for(int tread=0;tread<24;tread++){float a=tread*Mathf.PI*2/24;var block=MeshArt.Box(wheel,"Tire tread ridge",new(Mathf.Cos(a)*.474f,0,Mathf.Sin(a)*.474f),new(.018f,.24f,.045f),tyre);block.transform.localRotation=Quaternion.Euler(0,-tread*15,0);}wheels.Add(wheel);DistrictArtGeometry.Combine(wheel,false);}
   VehicleReflection();DistrictArtGeometry.Combine(transform,true);if(Motor!=null)body=Motor.GetComponent<Rigidbody>();
  }
  void VehicleReflection(){const int size=32;var cube=new Cubemap(size,TextureFormat.RGB24,true){name="VanStreetReflection",filterMode=FilterMode.Trilinear};for(int face=0;face<6;face++){var pixels=new Color[size*size];for(int y=0;y<size;y++)for(int x=0;x<size;x++){float u=(x+.5f)/size*2-1,v=(y+.5f)/size*2-1;Vector3 d=face switch {0=>new(1,-v,-u),1=>new(-1,-v,u),2=>new(u,1,v),3=>new(u,-1,-v),4=>new(u,-v,1),_=>new(-u,-v,-1)};d.Normalize();var c=Color.Lerp(new Color(.24f,.22f,.18f),new Color(.57f,.73f,.86f),Mathf.Clamp01(d.y*.9f+.45f));float cloud=Mathf.Clamp01((Mathf.Sin(d.x*11+d.z*6)+Mathf.Sin(d.z*17-d.x*5)-.35f)*1.2f)*Mathf.Clamp01(d.y*2);c=Color.Lerp(c,new Color(.98f,.96f,.89f),cloud);if(Mathf.Abs(d.y)<.25f){float window=Mathf.Abs(Mathf.Sin(d.x*28+d.z*13));c=Color.Lerp(new Color(.37f,.30f,.23f),new Color(.76f,.80f,.79f),window>.85f?.68f:.08f);}pixels[y*size+x]=c;}cube.SetPixels(pixels,(CubemapFace)face);}cube.Apply(true,true);ArtLifetime.Own(gameObject,cube);var node=new GameObject("Owned van street reflection",typeof(ReflectionProbe));node.transform.SetParent(transform,false);node.transform.localPosition=Vector3.up;var probe=node.GetComponent<ReflectionProbe>();probe.mode=UnityEngine.Rendering.ReflectionProbeMode.Custom;probe.customBakedTexture=cube;probe.size=new Vector3(4,5,7);probe.blendDistance=0;probe.intensity=1;probe.importance=20;probe.cullingMask=0;}
  public void Apply(int style,int vehicle){style=Mathf.Clamp(style,0,7);if(lastStyle==style&&lastVehicle==vehicle)return;lastStyle=style;lastVehicle=vehicle;Color[] colors={Orange,new(.08f,.64f,.82f),new(.24f,.75f,.38f),new(.66f,.3f,.94f),new(1,.73f,.1f),new(.16f,.77f,1),new(.35f,.95f,.64f),new(.89f,.30f,.67f)};if(livery!=null)livery.color=colors[style];transform.localScale=new Vector3(1,vehicle==1?1.10f:1,vehicle==1?1.06f:1);}
  void Update(){if(Motor==null)return;if(body==null)body=Motor.GetComponent<Rigidbody>();if(body!=null){float spin=Vector3.Dot(body.linearVelocity,Motor.transform.forward)/.48f*Mathf.Rad2Deg*Time.deltaTime;foreach(var wheel in wheels)wheel.Rotate(Vector3.up,spin,Space.Self);}bool brake=Motor.Brake!=null&&Motor.Brake.Held;if(brake!=braking&&tailLight!=null){braking=brake;var color=brake?new Color(1,.04f,.02f):new Color(.65f,.035f,.025f);tailLight.color=color;tailLight.SetColor("_EmissionColor",color*(brake?1.15f:.55f));}}
  public static void Text(Transform parent,string words,Vector3 position,float size,Color color,Quaternion rotation){var go=new GameObject(words,typeof(TextMesh));go.transform.SetParent(parent,false);go.transform.localPosition=position;go.transform.localRotation=rotation;var text=go.GetComponent<TextMesh>();text.text=words;text.characterSize=size/5f;text.fontSize=64;text.anchor=TextAnchor.MiddleCenter;text.alignment=TextAlignment.Center;text.color=color;text.font=Resources.Load<Font>("Fonts/Barlow-Bold");WorldTextMaterialBinding.Bind(text);}
  static void Gear(Transform root,float radius,Material orange,Material navy,Material white){var ring=MeshArt.Ring(root,"Gear",radius,.10f,0,navy,32);ring.transform.localRotation=Quaternion.Euler(-90,0,0);for(int i=0;i<12;i++){float a=i*30*Mathf.Deg2Rad;var tooth=MeshArt.Box(root,"Gear tooth",new(Mathf.Cos(a)*radius,Mathf.Sin(a)*radius,0),new(radius*.32f,radius*.32f,.035f),navy);tooth.transform.localRotation=Quaternion.Euler(0,0,i*30);}var wrench=new GameObject("Wrench").transform;wrench.SetParent(root,false);wrench.localRotation=Quaternion.Euler(0,0,-34);MeshArt.Box(wrench,"Handle",new(0,-.02f,-.035f),new(.07f,.43f,.055f),orange);MeshArt.Oval(wrench,"Wrench head",new(0,.19f,-.035f),new(.18f,.18f,.055f),orange);MeshArt.Box(wrench,"Open jaw",new(0,.26f,-.08f),new(.075f,.09f,.015f),white);}
 }
}
