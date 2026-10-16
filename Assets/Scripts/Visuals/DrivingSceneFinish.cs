using UnityEngine;
using UnityEngine.Rendering;
namespace Kamilunavo.RepairEmpire.Visuals
{
 // One fixed world-only display pass. Overlay UI and isolated repair photographs
 // retain their own rendering; there are no retained frame targets or updates.
 [RequireComponent(typeof(Camera)),DisallowMultipleComponent]
 public sealed class DrivingSceneFinish:MonoBehaviour
 {
  Camera sceneCamera;Material finish;bool previousHdr;
  public bool Ready=>finish!=null&&finish.shader.isSupported;
  public int CompletedRenders{get;private set;}
  public bool InputWasHdr{get;private set;}
  void OnEnable()
  {
   sceneCamera=GetComponent<Camera>();previousHdr=sceneCamera.allowHDR;var shader=Resources.Load<Shader>("DrivingSceneFinish");
   if(GraphicsSettings.currentRenderPipeline!=null||!SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.ARGBHalf)||shader==null||!shader.isSupported){enabled=false;return;}
   finish=new Material(shader){name="Owned driving scene finish"};ArtLifetime.Own(gameObject,finish);sceneCamera.allowHDR=true;
  }
  void OnRenderImage(RenderTexture source,RenderTexture destination)
  {
   if(!Ready){Graphics.Blit(source,destination);return;}
   InputWasHdr=source.format==RenderTextureFormat.ARGBHalf||source.format==RenderTextureFormat.ARGBFloat||source.format==RenderTextureFormat.RGB111110Float;Graphics.Blit(source,destination,finish);CompletedRenders++;
  }
  void OnDisable(){if(sceneCamera!=null)sceneCamera.allowHDR=previousHdr;if(finish!=null){ArtLifetime.Release(gameObject,finish);finish=null;}}
 }
}
