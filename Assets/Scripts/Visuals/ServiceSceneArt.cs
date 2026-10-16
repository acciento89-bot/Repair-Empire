using System.Collections.Generic;
using Kamilunavo.RepairEmpire.Gameplay;
using UnityEngine;
namespace Kamilunavo.RepairEmpire.Visuals {
 // These are actual scene models, photographed by one scene-owned camera. No bitmap stands in for gameplay.
 public sealed class ServiceSceneArt:MonoBehaviour {
  public const int PreviewLayer=30;
  readonly Dictionary<string,RenderTexture> images=new();Camera camera;Transform studio;RenderTexture repairImage;string repairKey;int repairPhase=-1,repairContacts=-1;float repairAspect;Rect? repairViewport;GameObject repairModel;Material photoFinish;
  static Material Ceramic=>MeshArt.Mat("FixturePorcelain",new(.92f,.93f,.89f));
  static Material Navy=>MeshArt.Mat("FixtureNavy",new(.025f,.065f,.11f));
  static Material Orange=>MeshArt.Mat("FixtureOrange",new(1,.34f,.055f));
  static Material Metal{get{var m=MeshArt.Mat("FixtureChrome",new(.68f,.76f,.79f));m.SetFloat("_Metallic",.82f);m.SetFloat("_Glossiness",.86f);return m;}}
  public static string VisualKey(string id){var job=JobCatalog.Find(id);if(job?.Presentation!=null)return job.Presentation.FixtureKey;foreach(var item in JobCatalog.All)if(item.Presentation?.FixtureKey==id)return id;return "faucet";}

  void Ensure(){if(camera!=null)return;studio=new GameObject("Isolated service photo studio").transform;studio.SetParent(transform,false);studio.localPosition=new(0,-1000,0);var go=new GameObject("Service photography camera",typeof(Camera));go.transform.SetParent(studio,false);camera=go.GetComponent<Camera>();camera.enabled=false;camera.clearFlags=CameraClearFlags.SolidColor;camera.backgroundColor=new(.69f,.65f,.58f);camera.cullingMask=1<<PreviewLayer;camera.nearClipPlane=.05f;camera.farClipPlane=40;camera.fieldOfView=35;camera.allowHDR=true;camera.allowMSAA=true;var finish=Resources.Load<Shader>("ServicePhotoFinish");if(finish==null)throw new System.InvalidOperationException("Original service photo shader missing");photoFinish=new Material(finish){name="ServicePhotoFinish"};ArtLifetime.Own(gameObject,photoFinish);
   var key=new GameObject("Service softbox",typeof(Light));key.transform.SetParent(studio,false);key.transform.localPosition=new(-2,4,-2);key.transform.LookAt(studio.position+Vector3.up*.5f);var light=key.GetComponent<Light>();light.type=LightType.Spot;light.range=12;light.spotAngle=90;light.intensity=3.0f;light.color=new(1,.96f,.88f);light.cullingMask=1<<PreviewLayer;light.shadows=LightShadows.Soft;
   var fill=new GameObject("Service warm fill",typeof(Light));fill.transform.SetParent(studio,false);fill.transform.localPosition=new Vector3(2,1.8f,-1.3f);var fillLight=fill.GetComponent<Light>();fillLight.type=LightType.Point;fillLight.range=8;fillLight.intensity=1.1f;fillLight.color=new Color(1,.86f,.70f);fillLight.cullingMask=1<<PreviewLayer;fillLight.shadows=LightShadows.None;
   var reflection=new GameObject("Isolated service metal reflection",typeof(ReflectionProbe));reflection.transform.SetParent(studio,false);reflection.transform.localPosition=Vector3.up*.7f;var probe=reflection.GetComponent<ReflectionProbe>();probe.mode=UnityEngine.Rendering.ReflectionProbeMode.Custom;probe.customBakedTexture=FixtureMaterials.Kit(studio).Environment();probe.size=new Vector3(12,8,10);probe.center=Vector3.zero;probe.boxProjection=true;probe.blendDistance=0;probe.intensity=1.25f;probe.importance=100;probe.cullingMask=1<<PreviewLayer;
   // Manual first-frame photographs precede the normal reflection update.
   // Publish this one new probe before any immutable thumbnail is cached.
   ReflectionProbe.UpdateCachedState();
  }
  RenderTexture Target(string name,int w,int h,int depth=16){var target=new RenderTexture(w,h,depth,RenderTextureFormat.ARGB32){name=name,antiAliasing=2};target.Create();ArtLifetime.Own(gameObject,target);return target;}
  void Photograph(GameObject model,RenderTexture target,bool workshop=false,Rect? clearViewport=null,bool thumbnail=false)
  {
   SetLayer(model.transform);OwnStudioMaterials(model);FixtureMaterials.PrepareRenderers(model);
   var previousTarget=camera.targetTexture;var previousActive=RenderTexture.active;RenderTexture hdr=null;
   camera.aspect=(float)target.width/target.height;camera.transform.localPosition=workshop?new Vector3(5,2.8f,-7):new Vector3(1.55f,1.50f,-2.55f);
   camera.transform.LookAt(studio.position+(workshop?new Vector3(0,1.65f,.7f):new Vector3(0,.48f,0)));camera.fieldOfView=workshop?40:35;
   var pose=model.GetComponent<FixturePhotoPose>();if(pose!=null&&!workshop){camera.transform.localPosition=pose.Eye;camera.transform.LookAt(studio.TransformPoint(pose.Target));camera.fieldOfView=pose.FieldOfView;}
   if(thumbnail)RepairSceneFraming.FitThumbnail(camera,model.transform.Find("Service fixture"));
   else if(clearViewport.HasValue)RepairSceneFraming.Fit(camera,model.transform.Find("Service fixture"),clearViewport.Value);
   try
   {
    if(SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.ARGBHalf)&&photoFinish.shader.isSupported)
    {
     // Capture highlight energy before the final eight-bit cached photograph.
     // The HDR target is temporary; there is no extra camera or per-frame effect.
     hdr=RenderTexture.GetTemporary(target.width,target.height,24,RenderTextureFormat.ARGBHalf,RenderTextureReadWrite.Default,2);
     camera.targetTexture=hdr;camera.Render();Graphics.Blit(hdr,target,photoFinish);
    }
    else{camera.targetTexture=target;camera.Render();}
   }
   finally{camera.targetTexture=previousTarget;RenderTexture.active=previousActive;if(hdr!=null)RenderTexture.ReleaseTemporary(hdr);model.SetActive(false);}
  }
  void OwnStudioMaterials(GameObject model){foreach(var renderer in model.GetComponentsInChildren<MeshRenderer>()){var material=renderer.sharedMaterial;if(material==null)continue;string name=material.name;if(name.StartsWith("Fixture")||name.StartsWith("Bathroom")||name=="ServiceCloth"||name=="WaterHighlight"||name=="ValveBrass"||name=="SoapAmber"||name=="SwitchRocker"||name=="WorkshopPlywood"||name=="WorkshopPlaster")ArtLifetime.Own(gameObject,material);}}
  static void SetLayer(Transform root){root.gameObject.layer=PreviewLayer;foreach(Transform child in root)SetLayer(child);}
  public Texture Thumbnail(string id){Ensure();string key=VisualKey(id);if(images.TryGetValue(key,out var image))return image;image=Target("Service image "+key,192,192);var model=BuildFixture(studio,key,-1);Photograph(model,image,false,null,true);images.Add(key,image);DestroyModel(model);return image;}
  public Texture WorkshopImage(){Ensure();if(images.TryGetValue("workshop",out var image))return image;image=Target("Workshop hero image",960,600,24);var model=BuildWorkshop(studio);Photograph(model,image,true);images.Add("workshop",image);DestroyModel(model);return image;}
  public Texture RepairImage(string id,int phase,int contacts=0,float aspect=4f/3f,Rect? clearViewport=null)
  {
   Ensure();if(!float.IsFinite(aspect)||aspect<=0)throw new System.ArgumentException("Invalid repair image aspect");string key=VisualKey(id);float desiredHeight=768/aspect;int h=Mathf.Clamp(Mathf.RoundToInt(desiredHeight),1,2048),w=desiredHeight>2048?Mathf.Clamp(Mathf.RoundToInt(2048*aspect),1,768):768;
   if(repairImage!=null&&(repairImage.width!=w||repairImage.height!=h)){if(RenderTexture.active==repairImage)RenderTexture.active=null;repairImage.Release();ArtLifetime.Release(gameObject,repairImage);repairImage=null;repairKey=null;}
   if(repairImage==null)repairImage=Target("Live modeled repair scene",w,h,24);
   Rect? textureViewport=clearViewport.HasValue?RepairSceneFraming.MapViewport(clearViewport.Value,RepairSceneFraming.SampleViewport(aspect,(float)w/h)):null;
   if(repairKey==key&&repairPhase==phase&&repairContacts==contacts&&repairAspect==aspect&&repairViewport.Equals(textureViewport))return repairImage;
   if(repairModel!=null)DestroyModel(repairModel);repairModel=BuildFixture(studio,key,phase,contacts);Photograph(repairModel,repairImage,false,textureViewport);repairKey=key;repairPhase=phase;repairContacts=contacts;repairAspect=aspect;repairViewport=textureViewport;return repairImage;
  }
  void OnDestroy(){if(camera!=null)camera.targetTexture=null;foreach(var target in images.Values)if(target!=null)target.Release();if(repairImage!=null)repairImage.Release();}
  static void DestroyModel(GameObject model){if(Application.isPlaying)Destroy(model);else DestroyImmediate(model);}
  public static GameObject BuildFixture(Transform parent,string id,int phase,int contacts=0){string key=VisualKey(id);var root=new GameObject("Modeled "+key+" service scene");root.transform.SetParent(parent,false);FixtureContextArt.Build(root.transform,key,phase);
   var fixture=new GameObject("Service fixture").transform;fixture.SetParent(root.transform,false);
   if(key=="faucet")Faucet(fixture,phase,false,contacts);else if(key=="toilet")Toilet(fixture,phase);else if(key=="switch")Switch(fixture,phase,contacts);else if(key=="heating")Radiator(fixture,phase);else if(key=="climate")Climate(fixture,phase);else JobFixtureArt.Build(fixture,key,phase,contacts);
   if(FixtureContextArt.Tabletop(key)){
    float top=FixtureContextArt.TabletopHeight(key);ServicePropGeometry.AdjustableWrench(root.transform,new(.88f,top+.0005f,-.34f));ServicePropGeometry.Cloth(root.transform,new(-.86f,top-.006f+.0005f,-.43f));ServicePropGeometry.VanityAccents(root.transform,top);ServicePropGeometry.SoapPump(root.transform,top);
   }
   if(key=="faucet"&&phase==1){var pose=root.GetComponent<FixturePhotoPose>();pose.Eye=new(.88f,.93f,-1.72f);pose.Target=new(-.07f,.39f,-.015f);}
   FixtureMaterials.PrepareRenderers(root);
   return root;
  }
  static void Faucet(Transform root,int phase,bool sink,int contacts){var Ceramic=FixtureMaterials.Get(root,FixtureFinish.Ceramic);var Metal=FixtureMaterials.Get(root,FixtureFinish.Chrome);var Navy=FixtureMaterials.Get(root,FixtureFinish.Navy);var Orange=FixtureMaterials.Get(root,FixtureFinish.Orange);
   MeshArt.Lathe(root,"Porcelain basin",new[]{-.12f,-.06f,.025f,.04f,.03f,-.095f,-.095f},new[]{.13f,.26f,.46f,.48f,.41f,.13f,0f},40,Ceramic,new(1.6f,1,1.1f)).transform.localPosition=new(0,0,-.19f);MeshArt.Lathe(root,"Basin drain",new[]{0f,.001f,.003f,.003f},new[]{0f,.052f,.052f,0f},24,Metal,Vector3.one).transform.localPosition=new(0,-.095f,-.20f);
   var mount=MeshArt.Lathe(root,"Faucet mounting flange",new[]{0f,.018f,.038f,.06f},new[]{.12f,.13f,.11f,.085f},32,Metal,Vector3.one);mount.transform.localPosition=new(-.13f,.04f,.22f);
   var body=MeshArt.Lathe(root,"Curved chrome faucet body",new[]{0f,.025f,.07f,.17f,.27f,.34f,.38f},new[]{.10f,.105f,.09f,.08f,.077f,.094f,.086f},32,Metal,Vector3.one);body.transform.localPosition=new(-.13f,.09f,.22f);
   FaucetSpout(root,Metal);
   MeshArt.Lathe(root,"Aerator outlet",new[]{0f,.006f,.028f,.035f},new[]{.047f,.057f,.057f,.051f},32,Metal,Vector3.one).transform.localPosition=new(-.13f,.326f,-.25f);
   MeshArt.Lathe(root,"Aerator recessed insert",new[]{0f,.003f,.003f},new[]{0f,.039f,0f},24,Navy,Vector3.one).transform.localPosition=new(-.13f,.324f,-.25f);
   for(int i=0;i<16;i++){float a=i*Mathf.PI*2/16;MeshArt.Tube(root,"Aerator machined grip",new[]{new Vector3(-.13f+Mathf.Cos(a)*.0575f,.334f,-.25f+Mathf.Sin(a)*.0575f),new Vector3(-.13f+Mathf.Cos(a)*.0575f,.351f,-.25f+Mathf.Sin(a)*.0575f)},.0014f,Metal,6);}
   bool replace=phase==1;MeshArt.BevelBox(root,"Mixer control cap",new(-.13f,replace?.74f:.47f,.22f),new(.18f,.075f,.16f),.035f,Metal);MeshArt.BevelBox(root,"Mixer lever",new(-.13f,replace?.79f:.52f,.115f),new(.06f,.035f,.31f),.013f,Metal);
   var brass=FixtureMaterials.Get(root,FixtureFinish.Brass);MeshArt.Lathe(root,"Visible valve cartridge",new[]{0f,.075f,.11f},new[]{.055f,.055f,.038f},16,brass,Vector3.one).transform.localPosition=new(-.13f,replace?.46f:.34f,.22f);
   var washer=MeshArt.Ring(root,"Replacement washer",.076f,.023f,replace&&contacts<3?.66f:.455f,Navy,40);washer.transform.localPosition=new(replace&&contacts==2?.16f:-.13f,0,.22f);if(replace){var halo=MeshArt.Ring(root,"Orange replacement focus",.113f,.008f,.66f,Orange,40);halo.transform.localPosition=new(-.13f,0,.22f);}
   if(phase==2||phase<0)
   {
    var water=FixtureMaterials.Get(root,FixtureFinish.Glass);MeshArt.Tube(root,"Water test stream",new[]{new Vector3(-.13f,.324f,-.25f),new Vector3(-.131f,.11f,-.25f),new Vector3(-.13f,-.094f,-.25f)},.0055f,water,10);
    var ripple=MeshArt.Ring(root,"Water impact ripple",.031f,.0025f,-.094f,water,32);ripple.transform.localPosition=new(-.13f,0,-.25f);
   }
   if(sink)MeshArt.Ring(root,"Drain service target",.08f,.013f,.013f,Orange,32).transform.localPosition=new(0,0,-.20f);
  }
  // Fixed X axis prevents the abrupt frame switch in a generic bent tube.
  // A variable elliptical section blends into the mixer body; both ends are sealed.
  static GameObject FaucetSpout(Transform root,Material metal){
   const int rings=25,sides=32;var v=new List<Vector3>();var uv=new List<Vector2>();var triangles=new List<int>();
   Vector3 p0=new(-.13f,.30f,.18f),p1=new(-.13f,.61f,.12f),p2=new(-.13f,.59f,-.24f),p3=new(-.13f,.36f,-.25f);
   for(int ring=0;ring<rings;ring++){float t=(float)ring/(rings-1),q=1-t;var center=q*q*q*p0+3*q*q*t*p1+3*q*t*t*p2+t*t*t*p3;var tangent=(3*q*q*(p1-p0)+6*q*t*(p2-p1)+3*t*t*(p3-p2)).normalized;var transverse=Vector3.Cross(tangent,Vector3.right).normalized;float radius=Mathf.Lerp(.084f,.052f,Mathf.SmoothStep(0,1,t));
    for(int side=0;side<=sides;side++){float a=(side%sides)*Mathf.PI*2/sides;v.Add(center+radius*(Vector3.right*Mathf.Cos(a)+transverse*Mathf.Sin(a)*Mathf.Lerp(.83f,1,t)));uv.Add(new Vector2((float)side/sides,t));if(ring>0&&side<sides){int k=ring*(sides+1)+side,b=k-sides-1;triangles.AddRange(new[]{k,b,k+1,k+1,b,b+1});}}
   }
   int start=v.Count;v.Add(p0);uv.Add(new(.5f,0));int end=v.Count;v.Add(p3);uv.Add(new(.5f,1));for(int side=0;side<sides;side++){int last=(rings-1)*(sides+1)+side;triangles.AddRange(new[]{start,side+1,side,end,last,last+1});}
   return MeshArt.Mesh(root,"Curved chrome spout",v.ToArray(),triangles.ToArray(),uv.ToArray(),metal);
  }
  static void Toilet(Transform root,int phase){var Ceramic=FixtureMaterials.Get(root,FixtureFinish.Ceramic);var Metal=FixtureMaterials.Get(root,FixtureFinish.Chrome);var Navy=FixtureMaterials.Get(root,FixtureFinish.Navy);var Orange=FixtureMaterials.Get(root,FixtureFinish.Orange);root.localScale=Vector3.one*.84f;MeshArt.Lathe(root,"Toilet pedestal",new[]{0f,.13f,.42f,.50f},new[]{.23f,.20f,.18f,.32f},32,Ceramic,new(1,1,1.3f)).transform.localPosition=new(0,-.07f,-.12f);MeshArt.Lathe(root,"Toilet bowl",new[]{.31f,.38f,.57f,.61f,.60f,.40f},new[]{.20f,.34f,.37f,.38f,.30f,.15f},40,Ceramic,new(1,1,1.35f)).transform.localPosition=new(0,0,-.17f);var seat=MeshArt.Ring(root,"Toilet seat",.375f,.075f,.65f,Ceramic,48);seat.transform.localScale=new(1,1,1.35f);seat.transform.localPosition=new(0,0,-.17f);MeshArt.BevelBox(root,"Toilet cistern",new(0,.86f,.28f),new(.74f,.72f,.30f),.065f,Ceramic);MeshArt.BevelBox(root,"Cistern lid",new(0,phase==1?1.40f:1.25f,.28f),new(.79f,.065f,.35f),.023f,Ceramic);MeshArt.BevelBox(root,"Flush button",new(0,phase==1?1.44f:1.29f,.28f),new(.15f,.015f,.06f),.005f,Metal);if(phase==1){MeshArt.Tube(root,"Flush valve",new[]{new Vector3(0,.90f,.28f),new Vector3(0,1.35f,.28f)},.07f,Orange);}}
  static void Switch(Transform root,int phase,int contacts){var Ceramic=FixtureMaterials.Get(root,FixtureFinish.Ceramic);var Metal=FixtureMaterials.Get(root,FixtureFinish.Chrome);var Navy=FixtureMaterials.Get(root,FixtureFinish.Navy);var Orange=FixtureMaterials.Get(root,FixtureFinish.Orange);var plate=MeshArt.BevelBox(root,"Switch faceplate",new(0,.71f,.12f),new(.65f,.85f,.09f),.045f,Ceramic);MeshArt.BevelBox(root,"Switch shadow reveal",new(0,.71f,.18f),new(.72f,.92f,.05f),.015f,Navy);MeshArt.BevelBox(root,"Rocker switch",phase==1?new Vector3(-.58f,.025f,-.27f):new Vector3(0,.70f,.035f),new(.34f,.40f,.07f),.025f,FixtureMaterials.Get(root,FixtureFinish.Concrete)).transform.localRotation=phase==1?Quaternion.Euler(90,0,-20):Quaternion.Euler(-9,0,0);foreach(float y in new[]{.38f,1.04f}){MeshArt.Oval(root,"Faceplate screw",new(0,y,.061f),new(.042f,.042f,.012f),Metal);MeshArt.Box(root,"Screw slot",new(0,y,.05f),new(.025f,.004f,.006f),Navy);}if(phase==1)for(int i=0;i<4;i++)MeshArt.Oval(root,"Electrical contact "+i,new((i%2-.5f)*.13f,.60f+(i/2)*.16f,-.03f),new(.04f,.04f,.015f),i<contacts?Metal:Orange);}
  static void Radiator(Transform root,int phase){var Ceramic=FixtureMaterials.Get(root,FixtureFinish.Ceramic);var Metal=FixtureMaterials.Get(root,FixtureFinish.Chrome);var Navy=FixtureMaterials.Get(root,FixtureFinish.Navy);var Orange=FixtureMaterials.Get(root,FixtureFinish.Orange);for(int i=0;i<10;i++)MeshArt.BevelBox(root,"Radiator modeled fin",new(-.46f+i*.10f,.58f,.14f),new(.075f,.84f,.20f),.027f,Ceramic);foreach(float y in new[]{.20f,.96f})MeshArt.Tube(root,"Heating header",new[]{new Vector3(-.5f,y,.14f),new Vector3(.5f,y,.14f)},.048f,Metal);MeshArt.Tube(root,"Service heating valve",new[]{new Vector3(.52f,.2f,.14f),new Vector3(.68f,.2f,.14f),new Vector3(.68f,.05f,.14f)},.035f,Metal);MeshArt.Oval(root,"Thermostat knob",new(.65f,.28f,.14f),new(.15f,.18f,.15f),phase==1?Orange:Ceramic);}
  static void Climate(Transform root,int phase){var Ceramic=FixtureMaterials.Get(root,FixtureFinish.Ceramic);var Metal=FixtureMaterials.Get(root,FixtureFinish.Chrome);var Navy=FixtureMaterials.Get(root,FixtureFinish.Navy);var Orange=FixtureMaterials.Get(root,FixtureFinish.Orange);MeshArt.BevelBox(root,"Climate enclosure",new(0,.75f,.15f),new(1.15f,.48f,.28f),.055f,Ceramic);for(int i=0;i<7;i++)MeshArt.Box(root,"Climate grille louvre",new(0,.60f+i*.025f,-.008f),new(.90f,.012f,.035f),Navy);MeshArt.BevelBox(root,"Climate filter",new(0,phase==1?.38f:.76f,phase==1?-.16f:.05f),new(.84f,.26f,.028f),.012f,phase==1?Orange:Ceramic);MeshArt.Oval(root,"Climate status lamp",new(.45f,.89f,-.003f),new(.033f,.02f,.008f),Orange);}
  static void Screwdriver(Transform parent,Vector3 position){var Metal=FixtureMaterials.Get(parent,FixtureFinish.Chrome);var Navy=FixtureMaterials.Get(parent,FixtureFinish.Navy);var Orange=FixtureMaterials.Get(parent,FixtureFinish.Orange);var root=new GameObject("Insulated service screwdriver").transform;root.SetParent(parent,false);root.localPosition=position;root.localRotation=Quaternion.Euler(0,-25,0);MeshArt.BevelBox(root,"Orange insulated screwdriver handle",new(0,.03f,-.16f),new(.09f,.075f,.25f),.028f,Orange);MeshArt.Tube(root,"Screwdriver steel shaft",new[]{new Vector3(0,.03f,-.03f),new Vector3(0,.03f,.23f)},.013f,Metal,12);MeshArt.Box(root,"Screwdriver slotted tip",new(0,.03f,.245f),new(.024f,.006f,.035f),Metal);}
  static GameObject BuildWorkshop(Transform parent)=>WorkshopArt.Build(parent); }
}
