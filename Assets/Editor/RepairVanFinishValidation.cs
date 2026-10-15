#if UNITY_EDITOR
using System;
using UnityEngine;
using Kamilunavo.RepairEmpire.Visuals;

public static class RepairVanFinishValidation
{
 public static void ValidateWheelhouses()
 {
  var host=new GameObject("Wheelhouse clearance regression",typeof(VanArt));
  try
  {
   host.GetComponent<VanArt>().Build();var shell=host.transform.Find("Bevelled service body").GetComponent<MeshFilter>();int rays=0;
   foreach(int side in new[]{-1,1})foreach(float axle in new[]{-1.42f,1.38f})foreach(float dz in new[]{-.28f,-.20f,.20f,.28f})
   {
    var ray=new Ray(new Vector3(side*.76f,-.4f,axle+dz),Vector3.up);float at=RepairVanGlassValidation.Hit(shell,ray),wanted=.22f+Mathf.Sqrt(.375f*.375f-dz*dz);rays++;
    if(!float.IsFinite(at)||ray.GetPoint(at).y<wanted-.006f)throw new InvalidOperationException("REPAIR_WHEELHOUSE_SHELL_INTRUDES side="+side+" axle="+axle+" dz="+dz+" surfaceY="+ray.GetPoint(at).y+" requiredY="+wanted);
   }
   Debug.Log("REPAIR_WHEELHOUSE_CLEARANCE_PASS actual body shell clears all four full tire-width cavities rays="+rays);
  }
  finally{UnityEngine.Object.DestroyImmediate(host);}
 }
 public static void ConfigureSurfaceAssets()
 {
  const string texturePath="Assets/Resources/Art/VanMoldedGrain-v1.png",materialPath="Assets/Resources/Materials/VanMoldedSurface.mat";
  UnityEditor.AssetDatabase.ImportAsset(texturePath);var importer=(UnityEditor.TextureImporter)UnityEditor.AssetImporter.GetAtPath(texturePath);
  importer.textureType=UnityEditor.TextureImporterType.NormalMap;importer.convertToNormalmap=true;importer.heightmapScale=.035f;importer.sRGBTexture=false;importer.isReadable=false;importer.mipmapEnabled=true;importer.wrapMode=TextureWrapMode.Repeat;importer.filterMode=FilterMode.Trilinear;importer.anisoLevel=2;importer.maxTextureSize=512;importer.textureCompression=UnityEditor.TextureImporterCompression.CompressedHQ;importer.SaveAndReimport();
  var material=UnityEditor.AssetDatabase.LoadAssetAtPath<Material>(materialPath);
  if(material==null){material=new Material(Resources.Load<Material>("Materials/Surface")){name="VanMoldedSurface"};UnityEditor.AssetDatabase.CreateAsset(material,materialPath);}
  material.SetTexture("_BumpMap",UnityEditor.AssetDatabase.LoadAssetAtPath<Texture2D>(texturePath));material.SetFloat("_BumpScale",.24f);material.EnableKeyword("_NORMALMAP");UnityEditor.EditorUtility.SetDirty(material);UnityEditor.AssetDatabase.SaveAssets();
  Debug.Log("REPAIR_MOLDED_SURFACE_ASSET_CONFIGURED shared imported normal texture and serialized Standard variant");
 }
 public static void ValidateSurfaces()
 {
  var host=new GameObject("Molded surface ownership fixture",typeof(VanArt));var normal=Resources.Load<Texture2D>("Art/VanMoldedGrain-v1");
  if(normal==null||normal.isReadable||normal.width>512||normal.wrapMode!=TextureWrapMode.Repeat)throw new InvalidOperationException("REPAIR_MOLDED_SURFACE_IMPORT");
  try
  {
   host.GetComponent<VanArt>().Build();int buffers=0;
   foreach(var filter in host.GetComponentsInChildren<MeshFilter>(true))
   {
    var renderer=filter.GetComponent<MeshRenderer>();if(renderer==null||!renderer.enabled)continue;var material=renderer.sharedMaterial;
    if(material==null||(material.name!="VanNavy"&&material.name!="VanTyre"))continue;
    if(!material.IsKeywordEnabled("_NORMALMAP")||material.GetTexture("_BumpMap")!=normal)throw new InvalidOperationException("REPAIR_MOLDED_SURFACE_VARIANT "+material.name);
    var mesh=filter.sharedMesh;if(mesh.uv.Length!=mesh.vertexCount||mesh.tangents.Length!=mesh.vertexCount)throw new InvalidOperationException("REPAIR_MOLDED_SURFACE_UV "+filter.name);
    foreach(var tangent in mesh.tangents)if(!float.IsFinite(tangent.x)||!float.IsFinite(tangent.y)||!float.IsFinite(tangent.z)||new Vector3(tangent.x,tangent.y,tangent.z).sqrMagnitude<.5f)throw new InvalidOperationException("REPAIR_MOLDED_SURFACE_TANGENT "+filter.name);
    buffers++;
   }
   if(buffers<5)throw new InvalidOperationException("REPAIR_MOLDED_SURFACE_MISSING");
   Debug.Log("REPAIR_MOLDED_SURFACE_PASS actual active buffers="+buffers+" finite metric UV/tangents, shared non-readable normal and serialized variant");
  }
  finally{UnityEngine.Object.DestroyImmediate(host);}
  if(normal==null)throw new InvalidOperationException("REPAIR_MOLDED_SURFACE_SHARED_ASSET_DISPOSED");
 }
 public static void InspectWheelhouse()
 {
  var host=new GameObject("Wheelhouse visibility inspection",typeof(VanArt));var view=new GameObject("Wheelhouse inspection camera",typeof(Camera));
  try
  {
   host.GetComponent<VanArt>().Build();var camera=view.GetComponent<Camera>();camera.enabled=false;camera.fieldOfView=30;camera.aspect=4f/3f;camera.transform.position=new Vector3(2.5f,.90f,2.0f);camera.transform.LookAt(new Vector3(.81f,.38f,1.38f));
   foreach(int x in new[]{310,340,370})foreach(int y in new[]{280,310,340})
   {
    var ray=camera.ViewportPointToRay(new Vector3(x/1024f,1-y/768f));float distance=float.PositiveInfinity;MeshFilter nearest=null;
    foreach(var filter in host.GetComponentsInChildren<MeshFilter>(true)){var renderer=filter.GetComponent<MeshRenderer>();if(renderer==null||!renderer.enabled)continue;float at=RepairVanGlassValidation.Hit(filter,ray);if(at<distance){distance=at;nearest=filter;}}
    Debug.Log("REPAIR_WHEELHOUSE_INSPECT pixel="+x+","+y+" material="+nearest?.GetComponent<MeshRenderer>().sharedMaterial.name+" mesh="+nearest?.name+" point="+ray.GetPoint(distance).ToString("F5"));
   }
  }
  finally{UnityEngine.Object.DestroyImmediate(view);UnityEngine.Object.DestroyImmediate(host);}
 }
}
#endif
