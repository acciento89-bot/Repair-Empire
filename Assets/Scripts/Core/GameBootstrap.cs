using UnityEngine;
using UnityEngine.EventSystems;
using Kamilunavo.RepairEmpire.CameraSystem;
using Kamilunavo.RepairEmpire.Gameplay;
using Kamilunavo.RepairEmpire.UI;
using Kamilunavo.RepairEmpire.Visuals;
using Kamilunavo.RepairEmpire.Monetization;
namespace Kamilunavo.RepairEmpire {
 public sealed class GameBootstrap:MonoBehaviour {
  void Start(){Screen.orientation=ScreenOrientation.AutoRotation;Screen.autorotateToLandscapeLeft=Screen.autorotateToLandscapeRight=Screen.autorotateToPortrait=true;Screen.autorotateToPortraitUpsideDown=false;Application.targetFrameRate=60;QualitySettings.vSyncCount=0;QualitySettings.antiAliasing=4;QualitySettings.shadowResolution=ShadowResolution.High;QualitySettings.shadowCascades=2;
   if(FindFirstObjectByType<EventSystem>()==null)new GameObject("EventSystem",typeof(EventSystem),typeof(StandaloneInputModule));
   var sun=new GameObject("Daylight",typeof(Light));var light=sun.GetComponent<Light>();light.type=LightType.Directional;light.intensity=1.15f;light.color=new Color(1,.92f,.78f);light.shadows=LightShadows.Soft;sun.transform.rotation=Quaternion.Euler(42,-25,0);QualitySettings.shadowDistance=65;
   var city=new GameObject("Repair Empire city").AddComponent<CityBuilder>();city.Build();var game=new GameObject("RepairGame").AddComponent<RepairGame>();
   var van=new GameObject("ServiceVan");var rigidbody=van.AddComponent<Rigidbody>();rigidbody.mass=1450;rigidbody.linearDamping=.25f;rigidbody.angularDamping=2.5f;rigidbody.interpolation=RigidbodyInterpolation.Interpolate;rigidbody.collisionDetectionMode=CollisionDetectionMode.ContinuousDynamic;rigidbody.constraints=RigidbodyConstraints.FreezeRotationX|RigidbodyConstraints.FreezeRotationZ;
   var collider=van.AddComponent<BoxCollider>();collider.size=new Vector3(2.2f,1.8f,4.6f);collider.center=new Vector3(0,.8f,0);var vehicle=van.AddComponent<VehicleController>();game.Vehicle=vehicle;game.RestoreVehicle();
   var visual=new GameObject("Detailed branded van");visual.transform.SetParent(van.transform,false);var art=visual.AddComponent<VanArt>();art.Motor=vehicle;art.Build();art.Apply(game.Profile.Style,game.Profile.Vehicle);game.Changed+=()=>art.Apply(game.Profile.Style,game.Profile.Vehicle);city.Bind(game);
   var backdrop=new GameObject("Unused region clear",typeof(Camera));var clear=backdrop.GetComponent<Camera>();clear.depth=-100;clear.clearFlags=CameraClearFlags.SolidColor;clear.backgroundColor=Color.black;clear.cullingMask=0;
   var camera=new GameObject("Main Camera",typeof(Camera),typeof(AudioListener),typeof(VehicleCamera));camera.tag="MainCamera";camera.GetComponent<Camera>().fieldOfView=62;camera.GetComponent<Camera>().farClipPlane=600;camera.GetComponent<VehicleCamera>().Target=van.transform;camera.transform.position=van.transform.position+new Vector3(0,4.2f,-8.5f);camera.transform.LookAt(van.transform.position+new Vector3(0,1.5f,4));
   var canvas=UiFactory.CreateCanvas();var safe=UiFactory.Panel(canvas.transform,"SafeArea",Color.clear,Vector2.zero,Vector2.one);safe.gameObject.AddComponent<SafeAreaFitter>();Canvas.ForceUpdateCanvases();var hud=safe.gameObject.AddComponent<RepairHud>();hud.Build(safe,game);
   game.Store=game.gameObject.AddComponent<StorePurchases>();game.Videos=game.gameObject.AddComponent<RewardedVideos>();game.NativePresenting=()=>game.Store.IsPresenting||game.Videos.IsPresenting;game.Store.Changed+=hud.RefreshProfile;game.Videos.Changed+=hud.RefreshProfile;game.Store.Initialize(game);game.Videos.Initialize(game);
   var feedback=game.gameObject.AddComponent<RepairFeedback>();feedback.Initialize(game);game.RefreshProfile();
  }
 }
}
