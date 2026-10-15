using System.Collections.Generic;
using UnityEngine;
using Kamilunavo.RepairEmpire.Gameplay;
namespace Kamilunavo.RepairEmpire.Visuals {
 public sealed class VanArt:MonoBehaviour {
  public bool CapturedStreetReflection {get;private set;}
  public VehicleController Motor;readonly List<Transform> wheels=new();Material livery,tailLight;Rigidbody body;bool built,braking;int lastStyle=-1,lastVehicle=-1;
  static readonly Color Navy=new(.035f,.045f,.055f),Orange=new(1,.32f,.045f);
  Material Own(string name,Color color,bool glow=false,string prototype="Materials/Surface"){var material=new Material(Resources.Load<Material>(prototype)){name=name,color=color};material.SetFloat("_Glossiness",.32f);if(glow){material.EnableKeyword("_EMISSION");material.SetColor("_EmissionColor",color*.55f);}ArtLifetime.Own(gameObject,material);return material;}
  public void Build()
  {
   if(built)return;built=true;
   var white=Own("VanPearl",new(.92f,.925f,.92f));white.SetFloat("_Glossiness",.61f);white.SetFloat("_Metallic",.025f);
   var navy=Own("VanNavy",Navy,false,"Materials/VanMoldedSurface");navy.SetFloat("_Glossiness",.20f);navy.SetFloat("_BumpScale",.24f);var orange=Own("VanOrange",Orange);livery=Own("VanStyleLivery",Orange);livery.SetFloat("_Glossiness",.64f);
   var glass=Own("VanGlass",new(.48f,.53f,.54f,.16f),false,"Materials/VanCabGlass");glass.SetFloat("_Metallic",0);glass.SetFloat("_Glossiness",.94f);
   glass.SetFloat("_Mode",3);glass.SetInt("_SrcBlend",(int)UnityEngine.Rendering.BlendMode.One);glass.SetInt("_DstBlend",(int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);glass.SetInt("_ZWrite",0);glass.DisableKeyword("_ALPHATEST_ON");glass.DisableKeyword("_ALPHABLEND_ON");glass.EnableKeyword("_ALPHAPREMULTIPLY_ON");glass.SetOverrideTag("RenderType","Transparent");glass.renderQueue=3000;
   var metal=Own("VanChrome",new(.48f,.50f,.52f));metal.SetFloat("_Metallic",.74f);metal.SetFloat("_Glossiness",.48f);
   var tyre=Own("VanTyre",new(.023f,.025f,.026f),false,"Materials/VanMoldedSurface");tyre.SetFloat("_Glossiness",.12f);tyre.SetFloat("_BumpScale",.12f);tailLight=Own("VanTail",new(.46f,.018f,.012f),true);tailLight.SetFloat("_Glossiness",.72f);tailLight.mainTexture=Resources.Load<Texture2D>("Art/VanRedLens-v1");
   var headLight=Own("VanHeadlamp",new(.78f,.83f,.86f,.16f),false,"Materials/VanCabGlass");headLight.SetFloat("_Glossiness",.94f);headLight.SetFloat("_Metallic",.04f);headLight.mainTexture=Resources.Load<Texture2D>("Art/VanHeadlampOptics-v1");
   VanCoachworkGeometry.Body(transform,white);
   MeshArt.BevelBox(transform,"Underbody",new(0,.255f,0),new(1.52f,.13f,4.21f),.045f,navy);
   VanCoachworkGeometry.Windshield(transform,navy,true);VanCoachworkGeometry.Windshield(transform,glass).GetComponent<MeshRenderer>().shadowCastingMode=UnityEngine.Rendering.ShadowCastingMode.Off;Cabin(navy,tyre,metal);
   foreach(int side in new[]{-1,1})
   {
    VanCoachworkGeometry.CabGlazing(transform,side,navy,true);VanCoachworkGeometry.CabGlazing(transform,side,glass,false);VanCoachworkGeometry.PressedDoors(transform,side,navy,white);
    var rail=new Vector3[23];for(int n=0;n<rail.Length;n++)rail[n]=VanCoachworkGeometry.SideSkinPoint(side,1.035f,Mathf.Lerp(-1.90f,-.21f,n/22f),.007f);MeshArt.Tube(transform,"Sliding door rail",rail,.007f,metal,6);
    var handleAt=VanCoachworkGeometry.SideSkinPoint(side,1.045f,.05f,.013f);MeshArt.BevelBox(transform,"Cab door handle",handleAt,new(.017f,.028f,.14f),.010f,navy);
    MeshArt.BevelBox(transform,"Cargo sliding handle",VanCoachworkGeometry.SideSkinPoint(side,1.045f,-.26f,.013f),new(.017f,.028f,.14f),.010f,navy);
    MeshArt.Tube(transform,"Mirror arm",new[]{VanCoachworkGeometry.SideSkinPoint(side,1.30f,1.16f),new Vector3(side*.99f,1.32f,1.20f)},.015f,navy,8);
    MeshArt.BevelBox(transform,"Mirror housing",new(side*1.00f,1.38f,1.18f),new(.12f,.25f,.17f),.032f,navy);MeshArt.BevelBox(transform,"Mirror lens",new(side*1.00f,1.405f,1.089f),new(.091f,.153f,.008f),.023f,metal);
    VanCoachworkGeometry.SideBand(transform,"Navy lower service wrap",side,.24f,.38f,navy);VanCoachworkGeometry.SideBand(transform,"Orange service band",side,.36f,.96f,livery);
    var emblem=new GameObject("Side service emblem").transform;emblem.SetParent(transform,false);emblem.localPosition=VanCoachworkGeometry.SideSkinPoint(side,1.40f,-.64f,.006f);emblem.localRotation=Quaternion.Euler(0,side>0?-90:90,0);emblem.localScale=new Vector3(1,1,.025f);Gear(emblem,.20f,orange,navy,white);VanCoachworkGeometry.FitPrintedGear(emblem,transform,side);
    var lettering=new GameObject("Side brand lettering").transform;lettering.SetParent(transform,false);lettering.localPosition=VanCoachworkGeometry.SideSkinPoint(side,1.40f,-1.29f,.009f);lettering.localRotation=Quaternion.Euler(0,side>0?-90:90,0);Text(lettering,"REPAIR\nEMPIRE",Vector3.zero,.10f,Navy,Quaternion.identity);
    MeshArt.BevelBox(transform,"Side step tread",new(side*.86f,.20f,.65f),new(.12f,.045f,.66f),.013f,navy);for(int i=0;i<5;i++)MeshArt.Box(transform,"Step anti-slip groove",new(side*.872f,.225f,.41f+i*.12f),new(.08f,.003f,.012f),metal);
    foreach(float axle in new[]{-1.42f,1.38f})VanCoachworkGeometry.WheelArch(transform,side,axle,navy);
    MeshArt.BevelBox(transform,"Mud flap",new(side*.81f,.10f,-1.79f),new(.14f,.17f,.018f),.006f,navy);
    MeshArt.Tube(transform,"Ladder rail",new[]{new Vector3(side*.26f,2.14f,-2.0f),new Vector3(side*.26f,2.14f,.40f)},.020f,metal,10);
    for(int i=0;i<3;i++){float z=-1.70f+i*.83f;MeshArt.BevelBox(transform,"Rack mounting foot",new(side*.60f,2.035f,z),new(.10f,.06f,.10f),.012f,navy);}
   }
   for(int i=0;i<10;i++)MeshArt.Tube(transform,"Ladder rung",new[]{new Vector3(-.26f,2.14f,-1.92f+i*.25f),new Vector3(.26f,2.14f,-1.92f+i*.25f)},.017f,metal,8);
   for(int i=0;i<3;i++)MeshArt.BevelBox(transform,"Roof rack crossbar",new(0,2.08f,-1.70f+i*.83f),new(1.40f,.043f,.065f),.014f,metal);
   MeshArt.BevelBox(transform,"Roof tool case",new(.46f,2.15f,-1.12f),new(.20f,.10f,.61f),.025f,orange);MeshArt.BevelBox(transform,"Tool case lid",new(.46f,2.21f,-1.12f),new(.21f,.018f,.62f),.008f,navy);
   var carrier=MeshArt.Lathe(transform,"Service pipe carrier",new[]{-1.12f,-1.115f,1.115f,1.12f},new[]{0f,.047f,.047f,0f},16,navy,Vector3.one);carrier.transform.localPosition=new(-.51f,2.14f,-.74f);carrier.transform.localRotation=Quaternion.Euler(90,0,0);foreach(float z in new[]{-1.86f,.38f})MeshArt.Oval(transform,"Carrier orange endcap",new(-.51f,2.14f,z),new(.098f,.098f,.014f),orange,10);
   VanCoachworkGeometry.RearBand(transform,"Rear navy service wrap",.24f,.38f,navy);VanCoachworkGeometry.RearBand(transform,"Orange rear livery",.36f,.96f,livery);
   var seam=new Vector3[21];for(int i=0;i<seam.Length;i++){float y=Mathf.Lerp(.36f,1.86f,i/20f);seam[i]=new Vector3(0,y,VanCoachworkGeometry.RearSkinZ(0,y)-.004f);}MeshArt.Tube(transform,"Rear split seam",seam,.0034f,navy,6);
   foreach(int side in new[]{-1,1})
   {
    var gap=new Vector3[25];for(int i=0;i<gap.Length;i++){float y=Mathf.Lerp(.40f,1.82f,i/24f);gap[i]=new Vector3(side*.716f,y,VanCoachworkGeometry.RearSkinZ(side*.716f,y)-.004f);}MeshArt.Tube(transform,"Rear door outer seam",gap,.0025f,navy,6);
    VanCoachworkGeometry.SculptedPanel(transform,"Rear lamp housing",new Vector2(side*.747f,.84f),new Vector2(.115f,.66f),.026f,navy,true,.010f,.012f);
    VanCoachworkGeometry.SculptedPanel(transform,"Rear tail lamp",new Vector2(side*.747f,.98f),new Vector2(.083f,.32f),.020f,tailLight,true,.020f,.010f);
    VanCoachworkGeometry.SculptedPanel(transform,"Rear indicator",new Vector2(side*.747f,.75f),new Vector2(.083f,.095f),.015f,orange,true,.020f,.010f);
    VanCoachworkGeometry.SculptedPanel(transform,"Rear reverse lamp",new Vector2(side*.747f,.63f),new Vector2(.083f,.090f),.015f,white,true,.020f,.010f);
    foreach(float y in new[]{.65f,1.42f})VanCoachworkGeometry.SculptedPanel(transform,"Cargo door hinge",new Vector2(side*.751f,y),new Vector2(.027f,.078f),.009f,metal,true,.009f,.010f);
    MeshArt.BevelBox(transform,"Rear bumper reflector",new(side*.64f,.265f,-2.368f),new(.13f,.023f,.010f),.006f,tailLight);
   }
   VanCoachworkGeometry.SculptedPanel(transform,"Cargo door handle",new Vector2(.075f,.98f),new Vector2(.14f,.028f),.012f,navy,true,.011f,.012f);
   VanCoachworkGeometry.SculptedPanel(transform,"Roof brake lamp",new Vector2(0,1.875f),new Vector2(.28f,.022f),.010f,tailLight,true,.010f,.008f);
   VanCoachworkGeometry.SculptedPanel(transform,"Number plate surround",new Vector2(-.34f,.49f),new Vector2(.56f,.145f),.020f,navy,true,.012f,.010f);
   VanCoachworkGeometry.SculptedPanel(transform,"Rear number plate",new Vector2(-.34f,.49f),new Vector2(.51f,.105f),.010f,white,true,.024f,.008f);
   Text(transform,"RE-1027",new(-.34f,.49f,VanCoachworkGeometry.RearSkinZ(-.34f,.49f)-.034f),.054f,Navy,Quaternion.identity);
   var logo=new GameObject("Repair gear and wrench").transform;logo.SetParent(transform,false);logo.localPosition=new(-.31f,1.39f,VanCoachworkGeometry.RearSkinZ(-.31f,1.39f)-.006f);logo.localScale=new Vector3(1,1,.025f);Gear(logo,.235f,orange,navy,white);VanCoachworkGeometry.FitPrintedGear(logo,transform);
   Text(transform,"REPARIEREN\nVERBESSERN\nMENSCHEN\nGLÜCKLICHER\nMACHEN",new(.30f,1.40f,VanCoachworkGeometry.RearSkinZ(.30f,1.40f)-.008f),.069f,Navy,Quaternion.identity);
   Text(transform,"KAMILUNAVO",new(.32f,.57f,VanCoachworkGeometry.RearSkinZ(.32f,.57f)-.028f),.039f,Color.white,Quaternion.identity);
   VanCoachworkGeometry.Bumper(transform,"Rear bumper",new(0,.26f,-2.27f),navy);VanCoachworkGeometry.Bumper(transform,"Front bumper",new(0,.33f,2.19f),navy);
   VanCoachworkGeometry.SculptedPanel(transform,"Front lower bumper fascia",new Vector2(0,.46f),new Vector2(1.55f,.29f),.055f,navy,false,.018f,.020f);
   VanCoachworkGeometry.SculptedPanel(transform,"Grille",new Vector2(0,.81f),new Vector2(1.10f,.43f),.055f,navy,false,.014f,.012f,.22f);
   VanCoachworkGeometry.SculptedPanel(transform,"Front fleet badge",new Vector2(0,1.025f),new Vector2(.12f,.045f),.020f,metal,false,.014f,.006f);
   VanCoachworkGeometry.SculptedPanel(transform,"Front number plate",new Vector2(0,.51f),new Vector2(.48f,.10f),.009f,white,false,.036f,.006f);
   Text(transform,"RE-1027",new(0,.51f,VanCoachworkGeometry.FrontSkinZ(0,.51f)+.043f),.050f,Navy,Quaternion.Euler(0,180,0));
   foreach(int side in new[]{-1,1})
   {
    VanCoachworkGeometry.SculptedPanel(transform,"Fog light recess",new Vector2(side*.60f,.46f),new Vector2(.18f,.105f),.025f,navy,false,.034f,.006f);
    VanCoachworkGeometry.SculptedPanel(transform,"Fog lamp lens",new Vector2(side*.60f,.46f),new Vector2(.083f,.045f),.018f,metal,false,.047f,.006f);
    VanCoachworkGeometry.Wiper(transform,side,navy);
   }
   VanProductionDetails.Build(transform,white,livery,navy,tyre,metal,orange,headLight);
   VanProductionDetails.PrepareMoldedSurfaces(transform,navy,tyre);
   foreach(int side in new[]{-1,1})foreach(float z in new[]{-1.42f,1.38f})BuildWheel(side,z,metal,tyre,navy);
   VehicleReflection();DistrictArtGeometry.Combine(transform,true);VanProductionDetails.ReleaseBatchedDetails(transform);foreach(var renderer in GetComponentsInChildren<MeshRenderer>(true))if(renderer.sharedMaterial==glass||renderer.sharedMaterial==headLight)renderer.shadowCastingMode=UnityEngine.Rendering.ShadowCastingMode.Off;if(Motor!=null)body=Motor.GetComponent<Rigidbody>();
  }
  void BuildWheel(int side,float axle,Material metal,Material tyre,Material navy)
  {
   // Full-size road-van proportions in the existing physics envelope; preserve
   // the actual collider support at local-.10 rather than art-local zero.
   var wheel=new GameObject("Wheel").transform;wheel.SetParent(transform,false);wheel.localPosition=new Vector3(side*.785f,.22f,axle);wheel.localRotation=Quaternion.Euler(0,0,90);
   VanProductionDetails.RoadTire(wheel,tyre);
   MeshArt.Lathe(wheel,"Steel wheel barrel",new[]{-.090f,-.091f,.091f,.090f},new[]{.184f,.195f,.195f,.184f},40,metal,Vector3.one);
   foreach(int face in new[]{-side})
   {
    var rim=new GameObject("Pressed steel wheel face").transform;rim.SetParent(wheel,false);rim.localRotation=face<0?Quaternion.Euler(180,0,0):Quaternion.identity;
    VanProductionDetails.SteelDish(rim,metal);MeshArt.Lathe(rim,"Visible brake drum",new[]{.039f,.041f,.067f,.069f},new[]{0f,.174f,.174f,0f},24,navy,Vector3.one);
    MeshArt.Lathe(rim,"Steel centre cap",new[]{.106f,.111f,.114f},new[]{.043f,.045f,.040f},24,metal,Vector3.one);
    for(int bolt=0;bolt<5;bolt++){float a=bolt*Mathf.PI*2/5;var nut=MeshArt.Lathe(rim,"Wheel lug nut",new[]{0f,.002f,.010f,.011f},new[]{.0085f,.0085f,.0085f,0f},6,metal,Vector3.one);nut.transform.localPosition=new(Mathf.Cos(a)*.067f,.106f,Mathf.Sin(a)*.067f);}
   }
   VanProductionDetails.TireSipes(wheel,tyre);VanProductionDetails.PrepareMoldedSurfaces(wheel,navy,tyre);wheels.Add(wheel);DistrictArtGeometry.Combine(wheel,false);
  }
  void Cabin(Material plastic,Material cloth,Material metal)
  {
   MeshArt.BevelBox(transform,"Cabin floor",new(0,.64f,.57f),new(1.57f,.10f,1.35f),.025f,cloth);
   MeshArt.BevelBox(transform,"Cabin bulkhead",new(0,1.20f,-.125f),new(1.55f,1.33f,.045f),.012f,plastic);
   foreach(int side in new[]{-1,1})
   {
    string seat=side<0?"Driver":"Passenger";float x=side*.39f;
    MeshArt.BevelBox(transform,seat+" seat cushion",new(x,.98f,.44f),new(.51f,.16f,.53f),.055f,cloth);
    var back=MeshArt.BevelBox(transform,seat+" seat back",new(x,1.30f,.18f),new(.50f,.60f,.15f),.055f,cloth);back.transform.localRotation=Quaternion.Euler(-8,0,0);
    MeshArt.BevelBox(transform,seat+" headrest",new(x,1.69f,.15f),new(.29f,.20f,.12f),.040f,cloth);
    foreach(float dx in new[]{-.20f,.20f})MeshArt.BevelBox(transform,"Seat side bolster",new(x+dx,1.02f,.43f),new(.08f,.16f,.50f),.030f,plastic);
    MeshArt.BevelBox(transform,"Door inner card",new(side*.797f,1.02f,.56f),new(.025f,.22f,.97f),.008f,plastic);
    MeshArt.BevelBox(transform,"Cabin door pull",new(side*.760f,1.16f,.42f),new(.055f,.027f,.16f),.009f,metal);
   }
   var dash=MeshArt.BevelBox(transform,"Cabin dashboard",new(0,1.11f,1.08f),new(1.50f,.24f,.40f),.055f,plastic);dash.transform.localRotation=Quaternion.Euler(-8,0,0);
   MeshArt.BevelBox(transform,"Instrument binnacle",new(-.39f,1.26f,1.04f),new(.36f,.10f,.24f),.032f,cloth);
   MeshArt.BevelBox(transform,"Centre console",new(.05f,1.16f,.856f),new(.23f,.16f,.025f),.008f,cloth);
   for(int i=0;i<4;i++)MeshArt.Box(transform,"Console vent",new(-.023f+i*.045f,1.195f,.839f),new(.018f,.040f,.004f),metal);
   var steering=new GameObject("Steering column").transform;steering.SetParent(transform,false);steering.localPosition=new(-.39f,1.25f,.80f);steering.localRotation=Quaternion.Euler(24,0,0);
   var path=new Vector3[25];for(int i=0;i<path.Length;i++){float a=i*Mathf.PI*2/24;path[i]=new Vector3(Mathf.Cos(a)*.16f,Mathf.Sin(a)*.16f,0);}var rim=MeshArt.Tube(transform,"Steering wheel rim",path,.017f,cloth,8);rim.transform.SetParent(steering,false);
   MeshArt.BevelBox(steering,"Steering wheel hub",Vector3.zero,new(.09f,.065f,.05f),.014f,plastic);
   for(int i=0;i<3;i++){float a=(i*120+30)*Mathf.Deg2Rad;MeshArt.Tube(steering,"Steering wheel spoke",new[]{Vector3.zero,new Vector3(Mathf.Cos(a)*.147f,Mathf.Sin(a)*.147f,0)},.010f,plastic,6);}
  }
  void VehicleReflection()
  {
   const int size=32;var cube=new Cubemap(size,TextureFormat.RGB24,true){name="VanStreetReflection",filterMode=FilterMode.Trilinear};
   for(int face=0;face<6;face++)
   {
    var pixels=new Color[size*size];for(int y=0;y<size;y++)for(int x=0;x<size;x++)
    {
     float u=(x+.5f)/size*2-1,v=(y+.5f)/size*2-1;Vector3 d=face switch {0=>new(1,-v,-u),1=>new(-1,-v,u),2=>new(u,1,v),3=>new(u,-1,-v),4=>new(u,-v,1),_=>new(-u,-v,-1)};d.Normalize();
     var color=Color.Lerp(new Color(.25f,.25f,.24f),new Color(.67f,.78f,.88f),Mathf.SmoothStep(0,1,(d.y+.18f)/.90f));float facade=Mathf.Exp(-Mathf.Pow(d.y/.19f,2));color=Color.Lerp(color,new Color(.37f,.40f,.42f),facade*.45f);float cloud=Mathf.Clamp01((Mathf.Sin(d.x*3+d.z*2)+Mathf.Sin(d.z*4-d.x*2))*.18f+.14f)*Mathf.Clamp01(d.y*2);pixels[y*size+x]=Color.Lerp(color,new Color(.96f,.95f,.90f),cloud);
    }
    cube.SetPixels(pixels,(CubemapFace)face);
   }
   cube.Apply(true,false);ArtLifetime.Own(gameObject,cube);
   // Capture the already built street once. No realtime reflection rendering,
   // camera stacking, global environment mutation or vehicle self-reflection.
   if(Application.isPlaying&&Motor!=null)
   {
    var renderers=GetComponentsInChildren<Renderer>(true);var states=new bool[renderers.Length];for(int i=0;i<renderers.Length;i++){states[i]=renderers[i].enabled;renderers[i].enabled=false;}
    var host=new GameObject("One-time van street capture",typeof(Camera));var camera=host.GetComponent<Camera>();camera.enabled=false;camera.clearFlags=CameraClearFlags.Skybox;camera.nearClipPlane=.12f;camera.farClipPlane=80;camera.cullingMask=~((1<<ServiceSceneArt.PreviewLayer)|(1<<5));camera.allowHDR=false;camera.transform.position=transform.TransformPoint(new Vector3(0,1.20f,0));var previous=RenderTexture.active;
    try{CapturedStreetReflection=camera.RenderToCubemap(cube);}
    finally{RenderTexture.active=previous;for(int i=0;i<renderers.Length;i++)if(renderers[i]!=null)renderers[i].enabled=states[i];Destroy(host);}
   }
var node=new GameObject("Owned van street reflection",typeof(ReflectionProbe));node.transform.SetParent(transform,false);node.transform.localPosition=Vector3.up;var probe=node.GetComponent<ReflectionProbe>();probe.mode=UnityEngine.Rendering.ReflectionProbeMode.Custom;probe.customBakedTexture=cube;probe.size=new Vector3(4,5,7);probe.blendDistance=0;probe.intensity=.85f;probe.importance=20;probe.cullingMask=0;
  }
  public void Apply(int style,int vehicle){style=Mathf.Clamp(style,0,7);if(lastStyle==style&&lastVehicle==vehicle)return;lastStyle=style;lastVehicle=vehicle;Color[] colors={Orange,new(.08f,.64f,.82f),new(.24f,.75f,.38f),new(.66f,.3f,.94f),new(1,.73f,.1f),new(.16f,.77f,1),new(.35f,.95f,.64f),new(.89f,.30f,.67f)};if(livery!=null)livery.color=colors[style];transform.localScale=new Vector3(1,vehicle==1?1.10f:1,vehicle==1?1.06f:1);}
  void Update(){if(Motor==null)return;if(body==null)body=Motor.GetComponent<Rigidbody>();if(body!=null){float spin=Vector3.Dot(body.linearVelocity,Motor.transform.forward)/.32f*Mathf.Rad2Deg*Time.deltaTime;foreach(var wheel in wheels)wheel.Rotate(Vector3.up,spin,Space.Self);}bool brake=Motor.Brake!=null&&Motor.Brake.Held;if(brake!=braking&&tailLight!=null){braking=brake;var color=brake?new Color(1,.04f,.02f):new Color(.65f,.035f,.025f);tailLight.color=color;tailLight.SetColor("_EmissionColor",color*(brake?1.15f:.55f));}}
  public static void Text(Transform parent,string words,Vector3 position,float size,Color color,Quaternion rotation){var go=new GameObject(words,typeof(TextMesh));go.transform.SetParent(parent,false);go.transform.localPosition=position;go.transform.localRotation=rotation;var text=go.GetComponent<TextMesh>();text.text=words;text.characterSize=size/5f;text.fontSize=64;text.anchor=TextAnchor.MiddleCenter;text.alignment=TextAlignment.Center;text.color=color;text.font=Resources.Load<Font>("Fonts/Barlow-Bold");WorldTextMaterialBinding.Bind(text);}
  static void Gear(Transform root,float radius,Material orange,Material navy,Material white){var ring=MeshArt.Ring(root,"Gear",radius,.10f,0,navy,32);ring.transform.localRotation=Quaternion.Euler(-90,0,0);for(int i=0;i<12;i++){float a=i*30*Mathf.Deg2Rad;var tooth=MeshArt.Box(root,"Gear tooth",new(Mathf.Cos(a)*radius,Mathf.Sin(a)*radius,0),new(radius*.32f,radius*.32f,.035f),navy);tooth.transform.localRotation=Quaternion.Euler(0,0,i*30);}var wrench=new GameObject("Wrench").transform;wrench.SetParent(root,false);wrench.localRotation=Quaternion.Euler(0,0,-34);MeshArt.Box(wrench,"Handle",new(0,-.02f,-.035f),new(.07f,.43f,.055f),orange);MeshArt.Oval(wrench,"Wrench head",new(0,.19f,-.035f),new(.18f,.18f,.055f),orange);MeshArt.Box(wrench,"Open jaw",new(0,.26f,-.08f),new(.075f,.09f,.015f),white);}
 }
}
