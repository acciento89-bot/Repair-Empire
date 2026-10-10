#if UNITY_EDITOR
using System;
using UnityEngine;
using Kamilunavo.RepairEmpire.Visuals;
namespace Kamilunavo.RepairEmpire.Validation {
 public static class RepairVisualChecks {
  public static void ValidateWorldTextDepth(){
   var font=Resources.Load<Font>("Fonts/Barlow-Bold");var original=font.material;var originalShader=original.shader;
   var van=new GameObject("WorldTextVanFixture",typeof(VanArt));var sign=new GameObject("WorldTextStreetFixture");Material world=null;
   bool hadWorldText=UnityEngine.Object.FindObjectsByType<WorldTextMaterialBinding>(FindObjectsInactive.Include).Length>0;
   try{
    van.GetComponent<VanArt>().Build();TextMesh rear=null;
    foreach(var text in van.GetComponentsInChildren<TextMesh>())if(text.text=="REPAIR"&&text.transform.parent==van.transform&&text.transform.localPosition.y>1.5f)rear=text;
    if(rear==null)throw new Exception("REPAIR_VISUAL_FAIL missing actual rear branding");world=rear.GetComponent<MeshRenderer>().sharedMaterial;
    if(world==original||world.shader.name!="Repair/WorldText"||world.GetFloat("_ZTest")!=(float)UnityEngine.Rendering.CompareFunction.LessEqual||world.GetFloat("_ZWrite")!=0||world.renderQueue!=3000)throw new Exception("REPAIR_VISUAL_FAIL world font does not respect opaque depth");
    string shaderSource=System.IO.File.ReadAllText(UnityEditor.AssetDatabase.GetAssetPath(world.shader));
    if(!shaderSource.Contains("ZTest [_ZTest]")||UnityEditor.ShaderUtil.ShaderHasError(world.shader))throw new Exception("REPAIR_VISUAL_FAIL world text shader depth state is not compiled");
    if(!VanOccludes(van,rear.transform.position,new Vector3(.34f,1.54f,8))||VanOccludes(van,rear.transform.position,new Vector3(.34f,1.54f,-8)))throw new Exception("REPAIR_VISUAL_FAIL actual van must hide rear lettering from front and expose it from rear");
    VanArt.Text(sign.transform,"WORKSHOP",Vector3.zero,.2f,Color.white,Quaternion.identity);
    var street=sign.GetComponentInChildren<TextMesh>();if(street.GetComponent<MeshRenderer>().sharedMaterial!=world)throw new Exception("REPAIR_VISUAL_FAIL world labels allocate separate font materials");
    font.RequestCharactersInTexture("REPAIR EMPIRE WORKSHOP ÄÖÜß",64);if(world.mainTexture!=font.material.mainTexture)throw new Exception("REPAIR_VISUAL_FAIL world text lost dynamic font atlas");
    UnityEngine.Object.DestroyImmediate(van);van=null;
    if(world==null||street.GetComponent<MeshRenderer>().sharedMaterial!=world)throw new Exception("REPAIR_VISUAL_FAIL preview cleanup destroys surviving street font");
    UnityEngine.Object.DestroyImmediate(sign);sign=null;
    if(!hadWorldText&&world!=null)throw new Exception("REPAIR_VISUAL_FAIL unused shared world font material is retained");
    if(font.material!=original||original.shader!=originalShader)throw new Exception("REPAIR_VISUAL_FAIL world font changes UI font material");
    Debug.Log("REPAIR_WORLD_TEXT_PASS actual front/rear occlusion, depth-tested shader, shared atlas and bounded material lifetime");
   }finally{if(van!=null)UnityEngine.Object.DestroyImmediate(van);if(sign!=null)UnityEngine.Object.DestroyImmediate(sign);}
  }
  static bool VanOccludes(GameObject van,Vector3 target,Vector3 origin){
   var ray=new Ray(origin,(target-origin).normalized);float distance=Vector3.Distance(origin,target);
   foreach(var filter in van.GetComponentsInChildren<MeshFilter>()){
    var renderer=filter.GetComponent<MeshRenderer>();if(renderer==null||renderer.sharedMaterial.renderQueue>2500||!renderer.bounds.IntersectRay(ray))continue;
    var mesh=filter.sharedMesh;var vertices=mesh.vertices;var indices=mesh.triangles;
    for(int t=0;t<indices.Length;t+=3)if(TriangleHit(ray,filter.transform.TransformPoint(vertices[indices[t]]),filter.transform.TransformPoint(vertices[indices[t+1]]),filter.transform.TransformPoint(vertices[indices[t+2]]),out float hit)&&hit<distance-.001f)return true;
   }return false;
  }
  public static void ValidateSwitchContactVisibility(){
   var root=new GameObject("SwitchContactVisibilityFixture");var view=new GameObject("ActualServiceCameraFixture",typeof(Camera));
   try{
    var scene=ServiceSceneArt.BuildFixture(root.transform,"switch",1,2);var camera=view.GetComponent<Camera>();camera.transform.position=new(1.55f,1.50f,-2.55f);camera.transform.LookAt(new Vector3(0,.48f,0));camera.fieldOfView=35;camera.aspect=1;
    var renderers=scene.GetComponentsInChildren<MeshRenderer>();
    for(int i=0;i<4;i++){
     var contact=scene.transform.Find("Service fixture/Electrical contact "+i).GetComponent<MeshRenderer>();Vector3 target=contact.bounds.center;var viewport=camera.WorldToViewportPoint(target);
     if(viewport.z<=0||viewport.x<=0||viewport.x>=1||viewport.y<=0||viewport.y>=1)throw new Exception("REPAIR_VISUAL_FAIL contact outside actual service camera "+i);
     var ray=new Ray(camera.transform.position,(target-camera.transform.position).normalized);float distance=Vector3.Distance(target,camera.transform.position);
     foreach(var renderer in renderers){if(renderer==contact||!renderer.enabled||!renderer.bounds.IntersectRay(ray,out float entry)||entry>=distance)continue;var mesh=renderer.GetComponent<MeshFilter>().sharedMesh;var vertices=mesh.vertices;var indices=mesh.triangles;
      for(int t=0;t<indices.Length;t+=3)if(TriangleHit(ray,renderer.transform.TransformPoint(vertices[indices[t]]),renderer.transform.TransformPoint(vertices[indices[t+1]]),renderer.transform.TransformPoint(vertices[indices[t+2]]),out float hit)&&hit<distance-.001f)throw new Exception("REPAIR_VISUAL_FAIL contact "+i+" hidden from actual service camera by "+renderer.name);
     }
     string expected=i<2?"FixtureChrome":"FixtureOrange";if(contact.sharedMaterial.name!=expected)throw new Exception("REPAIR_VISUAL_FAIL ordered contact progress is not shown "+i);
    }
    Debug.Log("REPAIR_SWITCH_CONTACTS_PASS four exposed contacts inside actual camera and ordered progress");
   }finally{UnityEngine.Object.DestroyImmediate(view);UnityEngine.Object.DestroyImmediate(root);}
  }
  static bool TriangleHit(Ray ray,Vector3 a,Vector3 b,Vector3 c,out float distance){
   distance=0;Vector3 e1=b-a,e2=c-a,p=Vector3.Cross(ray.direction,e2);float determinant=Vector3.Dot(e1,p);if(Mathf.Abs(determinant)<.000001f)return false;float inverse=1/determinant;Vector3 offset=ray.origin-a;float u=Vector3.Dot(offset,p)*inverse;if(u<0||u>1)return false;Vector3 q=Vector3.Cross(offset,e1);float v=Vector3.Dot(ray.direction,q)*inverse;if(v<0||u+v>1)return false;distance=Vector3.Dot(e2,q)*inverse;return distance>=0;
  }
  public static void Run(){
   foreach(string id in new[]{"faucet","toilet","switch","sink","call-2-0","call-3-0"}){
    var root=new GameObject("ModeledServiceFixture");try{
     var scene=ServiceSceneArt.BuildFixture(root.transform,id,1);
     if(scene.GetComponentsInChildren<Collider>().Length!=0)throw new Exception("REPAIR_VISUAL_FAIL preview geometry affects collision");
     int vertices=0;foreach(var mesh in scene.GetComponentsInChildren<MeshFilter>()){if(mesh.sharedMesh==null)throw new Exception("REPAIR_VISUAL_FAIL missing modeled mesh");vertices+=mesh.sharedMesh.vertexCount;}
     if(vertices<500)throw new Exception("REPAIR_VISUAL_FAIL service fixture lacks modeled detail "+id);
     if(id=="faucet"&&scene.transform.Find("Service fixture/Curved chrome spout")==null)throw new Exception("REPAIR_VISUAL_FAIL faucet has no curved spout");
     if(id=="faucet"&&scene.transform.Find("Service fixture/Replacement washer")==null)throw new Exception("REPAIR_VISUAL_FAIL missing real replacement washer");
     if(id=="toilet"&&scene.transform.Find("Service fixture/Toilet cistern")==null)throw new Exception("REPAIR_VISUAL_FAIL incorrect toilet model");
     if(id=="switch"&&scene.transform.Find("Service fixture/Switch faceplate")==null)throw new Exception("REPAIR_VISUAL_FAIL incorrect switch model");
    }finally{UnityEngine.Object.DestroyImmediate(root);}
   }
   if(ServiceSceneArt.VisualKey("faucet")==ServiceSceneArt.VisualKey("toilet")||ServiceSceneArt.VisualKey("toilet")==ServiceSceneArt.VisualKey("switch"))throw new Exception("REPAIR_VISUAL_FAIL unrelated calls share images");
   if(ServiceSceneArt.VisualKey(ServiceSceneArt.VisualKey("call-2-0"))!="heating"||ServiceSceneArt.VisualKey(ServiceSceneArt.VisualKey("call-3-0"))!="climate")throw new Exception("REPAIR_VISUAL_FAIL internal photo keys map to unrelated fixture");
   ValidateSwitchContactVisibility();
   ValidateWorldTextDepth();
   Debug.Log("REPAIR_VISUAL_EDITOR_PASS modeled service identity, detail, replacement and collision isolation");
  }
 }
}
#endif
