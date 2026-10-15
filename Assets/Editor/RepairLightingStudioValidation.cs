#if UNITY_EDITOR
using System;
using System.Reflection;
using UnityEditor;
using UnityEngine;
using Kamilunavo.RepairEmpire.Core;
using Kamilunavo.RepairEmpire.Gameplay;
using Kamilunavo.RepairEmpire.UI;
using Kamilunavo.RepairEmpire.Visuals;

public static class RepairLightingStudioValidation
{
 public static void ConfigureOriginalLighting()
 {
  const string sourcePath="Assets/ArtSources/ServiceRoomReflection-v1.png",cubePath="Assets/Resources/Art/ServiceRoomReflection-v1.asset";
  Require(AssetDatabase.LoadAssetAtPath<Cubemap>(cubePath)==null,"HDR_ASSET_ALREADY_AUTHORED");AssetDatabase.ImportAsset(sourcePath,ImportAssetOptions.ForceSynchronousImport);var importer=(TextureImporter)AssetImporter.GetAtPath(sourcePath);Cubemap cube=null;
  try
  {
   // Read raw source bytes in a known color space, then convert explicitly to
   // linear HDR. The source importer is restored before any native build.
   importer.textureType=TextureImporterType.Default;importer.isReadable=true;importer.sRGBTexture=false;importer.textureCompression=TextureImporterCompression.Uncompressed;importer.maxTextureSize=1024;importer.wrapMode=TextureWrapMode.Repeat;importer.SaveAndReimport();var source=AssetDatabase.LoadAssetAtPath<Texture2D>(sourcePath);
   cube=new Cubemap(64,TextureFormat.RGBAHalf,true){name="Original service room HDR",filterMode=FilterMode.Trilinear,wrapMode=TextureWrapMode.Clamp};
   for(int face=0;face<6;face++)
   {
    var pixels=new Color[64*64];for(int y=0;y<64;y++)for(int x=0;x<64;x++)
    {
     float u=(x+.5f)/64*2-1,v=(y+.5f)/64*2-1;Vector3 d=face switch{0=>new(1,-v,-u),1=>new(-1,-v,u),2=>new(u,1,v),3=>new(u,-1,-v),4=>new(u,-v,1),_=>new(-u,-v,-1)};d.Normalize();
     var color=source.GetPixelBilinear(Mathf.Repeat(Mathf.Atan2(d.z,d.x)/(Mathf.PI*2)+.5f,1),Mathf.Asin(d.y)/Mathf.PI+.5f).linear;float luminance=Vector3.Dot(new Vector3(color.r,color.g,color.b),new Vector3(.2126f,.7152f,.0722f));color*=1+3*Mathf.SmoothStep(0,1,Mathf.InverseLerp(.60f,.95f,luminance));color.a=1;pixels[y*64+x]=color;
    }
    cube.SetPixels(pixels,(CubemapFace)face);
   }
   cube.Apply(true,false);AssetDatabase.CreateAsset(cube,cubePath);cube=null;AssetDatabase.SaveAssets();
  }
  finally
  {
   if(cube!=null)UnityEngine.Object.DestroyImmediate(cube);importer.isReadable=false;importer.sRGBTexture=true;importer.textureCompression=TextureImporterCompression.CompressedHQ;importer.mipmapEnabled=true;importer.filterMode=FilterMode.Trilinear;importer.SaveAndReimport();
  }
  PlayerSettings.colorSpace=ColorSpace.Linear;AssetDatabase.SaveAssets();ValidateLighting();
 }
 static void Require(bool valid,string reason){if(!valid)throw new InvalidOperationException("REPAIR_LIGHTING_STUDIO_"+reason);}
 public static void ValidateLighting()
 {
  Require(PlayerSettings.colorSpace==ColorSpace.Linear,"NEEDS_LINEAR_LIGHTING");var source=Resources.Load<Cubemap>("Art/ServiceRoomReflection-v1");Require(source!=null&&source.width==64&&source.mipmapCount==7&&source.format==TextureFormat.RGBAHalf,"ORIGINAL_HDR_ENVIRONMENT_MISSING");
  float low=float.PositiveInfinity,high=0;for(int face=0;face<6;face++)foreach(var color in source.GetPixels((CubemapFace)face)){Require(float.IsFinite(color.r)&&float.IsFinite(color.g)&&float.IsFinite(color.b),"HDR_DATA_NOT_FINITE");low=Mathf.Min(low,color.r,color.g,color.b);high=Mathf.Max(high,color.r,color.g,color.b);}Require(low<.2f&&high>1,"ROOM_ENVIRONMENT_NEEDS_REAL_LINEAR_HDR_RANGE "+low+".."+high);
  var root=new GameObject("Original HDR reflection owner fixture");Cubemap owned=null;
  try{owned=FixtureMaterials.Kit(root.transform).Environment();Require(owned!=null&&owned!=source&&owned.width==64&&!owned.isReadable,"SCENE_MUST_OWN_NONREADABLE_HDR_CLONE");}
  finally{UnityEngine.Object.DestroyImmediate(root);}
  Require(owned==null&&source!=null,"HDR_CLONE_OR_SHARED_ASSET_LIFETIME");Debug.Log("REPAIR_LIGHTING_HDR_PASS Linear; original64RGBAHalf/mips; shared prototype and owned non-readable scene clone");
 }
 public static void ValidateBackdrop()
 {
  var host=new GameObject("Concept portrait repair fixture");host.SetActive(false);var canvas=new GameObject("Concept repair canvas",typeof(Canvas));
  try
  {
   var region=new GameObject("Concept repair pane",typeof(RectTransform)).GetComponent<RectTransform>();region.SetParent(canvas.transform,false);region.anchorMin=region.anchorMax=Vector2.one*.5f;region.sizeDelta=new Vector2(393,852);
   var game=host.AddComponent<RepairGame>();game.Profile=new RepairProfile{ActiveJob="faucet",RepairPhase=1,ActiveTicket=1,Level=8,ToolMask=7};game.Interaction=new RepairInteraction(1,1,JobCatalog.Find("faucet").Presentation);typeof(RepairGame).GetField("<RepairOpen>k__BackingField",BindingFlags.Instance|BindingFlags.NonPublic).SetValue(game,true);
   var hud=host.AddComponent<RepairHud>();hud.Build(region,game);hud.RefreshProfile();Canvas.ForceUpdateCanvases();var modal=region.Find("TabletModal");var scene=modal.Find("ActualRepairScene")as RectTransform;
   Require(scene!=null&&scene.GetSiblingIndex()==0&&Mathf.Abs(scene.rect.width-393)<.1f&&Mathf.Abs(scene.rect.height-852)<.1f,"PORTRAIT_NEEDS_TRUE_SCENE_BACKDROP");Require(modal.Find("RepairActionShelf")!=null&&modal.Find("ServiceHeader")!=null,"BACKDROP_REPLACED_FIXED_INFO_OR_ACTIONS");
   var viewport=modal.Find("PageBody/ScrollViewport").GetComponent<UnityEngine.UI.Image>();Require(viewport.color.a==0&&viewport.raycastTarget,"OPAQUE_VIEWPORT_COVERS_MODELED_SCENE_OR_STOPS_TOUCH_SCROLL");
  }
  finally{UnityEngine.Object.DestroyImmediate(canvas);UnityEngine.Object.DestroyImmediate(host);}
  Debug.Log("REPAIR_LIGHTING_BACKDROP_PASS actual full portrait backdrop is behind existing header/actions");
 }
 public static void ValidateFraming()
 {
  var host=new GameObject("Actual component framing fixture");var cameraHost=new GameObject("Actual component framing camera",typeof(Camera));var camera=cameraHost.GetComponent<Camera>();camera.enabled=false;FixtureMaterials.Kit(host.transform);int cases=0,points=0;
  try
  {
   foreach(var job in JobCatalog.All)for(int phase=0;phase<3;phase++)foreach(int contacts in phase==1?new[]{0,2,3,4}:new[]{0})
   {
    var model=ServiceSceneArt.BuildFixture(host.transform,job.Id,phase,contacts);
    try
    {
     var pose=model.GetComponent<FixturePhotoPose>();var fixture=model.transform.Find("Service fixture");
     foreach(bool portrait in new[]{true,false})
     {
      camera.aspect=portrait?393f/852:3f;camera.fieldOfView=pose.FieldOfView;camera.transform.position=pose.Eye;camera.transform.LookAt(pose.Target);var clear=portrait?new Rect(.031f,.254f,.938f,.411f):new Rect(.05f,.05f,.90f,.90f);RepairSceneFraming.Fit(camera,fixture,clear);
      foreach(var renderer in RepairSceneFraming.Components(fixture))foreach(var vertex in renderer.GetComponent<MeshFilter>().sharedMesh.vertices)
      {
       var point=camera.WorldToViewportPoint(renderer.transform.TransformPoint(vertex));Require(point.z>camera.nearClipPlane&&clear.Contains(new Vector2(point.x,point.y)),"ACTUAL_COMPONENT_CLIPPED "+job.Id+" phase="+phase+" contacts="+contacts+" portrait="+portrait+" mesh="+renderer.name+" point="+point);points++;
      }
      cases++;
     }
    }
    finally{UnityEngine.Object.DestroyImmediate(model);}
   }
  }
  finally{UnityEngine.Object.DestroyImmediate(cameraHost);UnityEngine.Object.DestroyImmediate(host);}
  Debug.Log("REPAIR_COMPONENT_FRAMING_PASS actual24jobs/3phases/contactvariants/portrait-landscape cases="+cases+" real vertices="+points);
  var studioHost=new GameObject("Repair target replacement fixture");RenderTexture old=null,current=null;
  try
  {
   var studio=studioHost.AddComponent<ServiceSceneArt>();var clear=new Rect(.03f,.25f,.94f,.41f);old=(RenderTexture)studio.RepairImage("faucet",1,0,393f/852,clear);Require(old.height>old.width&&ReferenceEquals(old,studio.RepairImage("faucet",1,0,393f/852,clear)),"PORTRAIT_TARGET_OR_CACHE");current=(RenderTexture)studio.RepairImage("faucet",1,2,3,new Rect(.05f,.05f,.9f,.9f));Require(old==null&&current!=null&&current.width>current.height,"ORIENTATION_MUST_REPLACE_AND_DISPOSE_TARGET");
  }
  finally{UnityEngine.Object.DestroyImmediate(studioHost);}
  Require(current==null,"LIVE_REPAIR_TARGET_OWNER_LEAK");Debug.Log("REPAIR_TARGET_REPLACEMENT_PASS actual portrait aspect/cache/contact/wide replacement/owned disposal");
 }
 public static void Validate(){ValidateLighting();ValidateBackdrop();ValidateFraming();ValidateUnusualAspects();ValidateWideLayout();}
 public static void ValidateWideLayout()
 {
  var host=new GameObject("Short wide repair layout fixture");host.SetActive(false);var canvas=new GameObject("Short wide repair canvas",typeof(Canvas));
  try
  {
   var region=new GameObject("Actual short wide pane",typeof(RectTransform)).GetComponent<RectTransform>();region.SetParent(canvas.transform,false);region.anchorMin=region.anchorMax=Vector2.one*.5f;region.sizeDelta=new Vector2(1073.73f,306.56f);
   var game=host.AddComponent<RepairGame>();game.Profile=new RepairProfile{ActiveJob="faucet",RepairPhase=1,ActiveTicket=1,Level=8,ToolMask=7};game.Interaction=new RepairInteraction(1,1,JobCatalog.Find("faucet").Presentation);typeof(RepairGame).GetField("<RepairOpen>k__BackingField",BindingFlags.Instance|BindingFlags.NonPublic).SetValue(game,true);var hud=host.AddComponent<RepairHud>();hud.Build(region,game);hud.RefreshProfile();Canvas.ForceUpdateCanvases();var modal=region.Find("TabletModal");var scene=modal.Find("ActualRepairScene")as RectTransform;var body=modal.Find("PageBody")as RectTransform;
   Require(scene!=null&&scene.GetComponentInParent<UnityEngine.UI.ScrollRect>()==null&&Mathf.Abs(scene.rect.height-body.rect.height)<.1f,"WIDE_SCENE_MUST_USE_FIXED_UNCLIPPED_PANE");var shelf=modal.Find("RepairActionShelf");float? row=null;foreach(var button in shelf.GetComponentsInChildren<UnityEngine.UI.Button>()){float y=((RectTransform)button.transform).anchoredPosition.y;if(row.HasValue)Require(y==row.Value,"WIDE_FOUR_CONTACTS_NEED_ONE_ACCESSIBLE_ROW");row=y;}
  }
  finally{UnityEngine.Object.DestroyImmediate(canvas);UnityEngine.Object.DestroyImmediate(host);}
  Debug.Log("REPAIR_WIDE_FIXED_SCENE_PASS fixed image fills short body; four accessible contacts use one row");
 }
 public static void ValidateUnusualAspects()
 {
  var host=new GameObject("Short-wide and tall-portrait repair fixture");
  try
  {
   var studio=host.AddComponent<ServiceSceneArt>();foreach(float aspect in new[]{805f/150,280f/1100})
   {
    var clear=new Rect(.05f,.05f,.9f,.9f);var image=(RenderTexture)studio.RepairImage("faucet",1,2,aspect,clear);Require(Mathf.Abs(image.width/(float)image.height/aspect-1)<.01f,"UNUSUAL_ASPECT_CROPS_FITTED_COMPONENTS "+aspect+" target="+image.width+"x"+image.height);
    const BindingFlags flags=BindingFlags.Instance|BindingFlags.NonPublic;var camera=(Camera)typeof(ServiceSceneArt).GetField("camera",flags).GetValue(studio);var model=(GameObject)typeof(ServiceSceneArt).GetField("repairModel",flags).GetValue(studio);var sample=RepairSceneFraming.SampleViewport(aspect,image.width/(float)image.height);
    foreach(var renderer in RepairSceneFraming.Components(model.transform.Find("Service fixture")))foreach(var vertex in renderer.GetComponent<MeshFilter>().sharedMesh.vertices){var projected=camera.WorldToViewportPoint(renderer.transform.TransformPoint(vertex));var displayed=new Vector2((projected.x-sample.x)/sample.width,(projected.y-sample.y)/sample.height);Require(projected.z>camera.nearClipPlane&&clear.Contains(displayed),"UNUSUAL_ASPECT_LOSES_ACTUAL_MESH "+renderer.name+" displayed="+displayed);}
   }
  }
  finally{UnityEngine.Object.DestroyImmediate(host);}
  Debug.Log("REPAIR_UNUSUAL_ASPECT_PASS short-wide and tall-portrait targets preserve modeled framing");
 }
 public static void CaptureBaseline()
 {
  var failures=new System.Collections.Generic.List<string>();foreach(Action check in new Action[]{ValidateLighting,ValidateBackdrop})try{check();}catch(Exception e){failures.Add(e.Message);Debug.Log("REPAIR_LIGHTING_STUDIO_BASELINE_RED "+e.Message);}if(failures.Count>0)throw new InvalidOperationException(string.Join(";",failures));
 }
}
#endif
