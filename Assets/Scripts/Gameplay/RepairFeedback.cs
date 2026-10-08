using UnityEngine;
namespace Kamilunavo.RepairEmpire.Gameplay {
 public sealed class RepairFeedback:MonoBehaviour {
  RepairGame game;AudioSource engine,effect;AudioClip step,success;bool lastMotion;
#if UNITY_IOS && !UNITY_EDITOR
  [System.Runtime.InteropServices.DllImport("__Internal")]static extern void RepairImpact();
#endif
  public void Initialize(RepairGame owner){game=owner;engine=gameObject.AddComponent<AudioSource>();engine.clip=Resources.Load<AudioClip>("Audio/Engine");engine.loop=true;engine.volume=0;engine.Play();effect=gameObject.AddComponent<AudioSource>();step=Resources.Load<AudioClip>("Audio/RepairStep");success=Resources.Load<AudioClip>("Audio/RepairSuccess");game.Feedback+=Feedback;}
  void Update(){if(game==null)return;float speed=game.Vehicle!=null?game.Vehicle.SpeedKmh:0;engine.volume=game.Profile.Sound&&!game.Paused?.035f+Mathf.Clamp01(speed/80)*.075f:0;engine.pitch=.7f+Mathf.Clamp01(speed/80)*.9f;var camera=UnityEngine.Camera.main;if(camera!=null){var follow=camera.GetComponent<CameraSystem.VehicleCamera>();if(follow!=null&&lastMotion!=game.Profile.ReducedMotion){lastMotion=game.Profile.ReducedMotion;follow.Smooth=lastMotion?30:10;}}}
  void Feedback(string message){bool finished=message==game.T("Auftrag abgeschlossen!","Service call completed!");if(game.Profile.Sound)effect.PlayOneShot(finished?success:step,.38f);if(game.Profile.Haptics){
#if UNITY_IOS && !UNITY_EDITOR
   RepairImpact();
#elif UNITY_ANDROID && !UNITY_EDITOR
   Handheld.Vibrate();
#endif
  }}
  void OnDestroy(){if(game!=null)game.Feedback-=Feedback;}
 }
}
