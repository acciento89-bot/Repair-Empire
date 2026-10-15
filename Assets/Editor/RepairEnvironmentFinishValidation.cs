#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using Kamilunavo.RepairEmpire.Visuals;

public static class RepairEnvironmentFinishValidation
{
 const string CanopyPath="Assets/Resources/Art/StreetCanopy-v1.png";
 public static void ConfigureOriginalAssets()
 {
  AssetDatabase.ImportAsset(CanopyPath,ImportAssetOptions.ForceSynchronousImport);
  var importer=(TextureImporter)AssetImporter.GetAtPath(CanopyPath);importer.textureType=TextureImporterType.Default;importer.sRGBTexture=true;importer.isReadable=false;importer.mipmapEnabled=true;importer.wrapMode=TextureWrapMode.Repeat;importer.filterMode=FilterMode.Trilinear;importer.anisoLevel=2;importer.alphaSource=TextureImporterAlphaSource.None;importer.alphaIsTransparency=false;importer.maxTextureSize=512;importer.npotScale=TextureImporterNPOTScale.None;importer.textureCompression=TextureImporterCompression.CompressedHQ;importer.SaveAndReimport();Validate();
 }
 static void Require(bool valid,string reason){if(!valid)throw new InvalidOperationException("REPAIR_ENVIRONMENT_"+reason);}
 public static void ValidateReflections()
 {
  var root=new GameObject("Original city reflection lifecycle fixture");var sky=RenderSettings.skybox;var active=RenderTexture.active;Cubemap reflection=null;
  try
  {
   var first=CitySceneReflections.Capture(root.transform);reflection=first.Reflection;var again=CitySceneReflections.Capture(root.transform);
   Require(first==again&&first.CaptureCount==1&&first.Captured,"CITY_REFLECTION_NOT_CAPTURED_ONCE");Require(reflection!=null&&reflection.width==64&&first.Probe!=null&&first.Probe.customBakedTexture==reflection,"CITY_REFLECTION_NOT_BOUND");
   Require(first.Probe.mode==UnityEngine.Rendering.ReflectionProbeMode.Custom&&first.Probe.importance==10&&first.Probe.cullingMask==0,"CITY_PROBE_SCOPE_CHANGED");Require(first.Probe.bounds.max.y<100&&first.Probe.bounds.min.y> -100,"CITY_PROBE_INCLUDES_ISOLATED_STUDIO");
   Require(root.GetComponentsInChildren<Camera>(true).Length==0&&GameObject.Find("One-time district reflection capture")==null,"CITY_CAPTURE_CAMERA_RETAINED");Require(RenderSettings.skybox==sky&&RenderTexture.active==active,"CITY_CAPTURE_CHANGED_GLOBAL_RENDER_STATE");
  }
  finally{UnityEngine.Object.DestroyImmediate(root);}
  Require(reflection==null,"OWNED_CITY_CUBEMAP_LEAK");Debug.Log("REPAIR_CITY_REFLECTION_PASS one64px actual capture/custom district probe; no retained camera, target or global mutation; owned cubemap disposed");
 }
 public static void Validate()
 {
  var root=new GameObject("Detailed street canopy fixture");var owned=new HashSet<UnityEngine.Object>();var source=Resources.Load<Texture2D>("Art/StreetCanopy-v1");
  try
  {
   var material=new Material(Resources.Load<Material>("Materials/Surface"));ArtLifetime.Own(root,material);owned.Add(material);var kit=new UrbanArtKit(root.transform,material,material,material);kit.Tree(new Vector3(8.65f,0,37),material);
   Require(source!=null&&kit.LeafMass.mainTexture==source,"ORIGINAL_CANOPY_NOT_BOUND_TO_REAL_CROWN");var shader=Resources.Load<Shader>("CanopySurface");Require(shader!=null&&!ShaderUtil.ShaderHasError(shader)&&kit.LeafMass.shader==shader,"ORIGINAL_CANOPY_SHADER_NOT_BOUND");Require(source.width==512&&source.height==512&&!source.isReadable&&source.mipmapCount>1,"CANOPY_IMPORT_BUDGET");
   int vertices=0,cards=0,branches=0;foreach(var filter in root.GetComponentsInChildren<MeshFilter>())
   {
    var mesh=filter.sharedMesh;owned.Add(mesh);vertices+=mesh.vertexCount;if(filter.name=="Urban leaf clusters")cards+=mesh.vertexCount/6;if(filter.name=="Fine secondary canopy branch")branches++;
    foreach(var normal in mesh.normals)Require(float.IsFinite(normal.x)&&float.IsFinite(normal.y)&&float.IsFinite(normal.z)&&normal.sqrMagnitude>.5f,"CANOPY_INVALID_NORMAL");
   }
   Require(cards>=560&&branches>=10,"CANOPY_INSUFFICIENT_REAL_LEAF_AND_BRANCH_DETAIL cards="+cards+" branches="+branches);Require(vertices<=6000,"CANOPY_GEOMETRY_BUDGET "+vertices);Require(root.GetComponentsInChildren<Collider>().Length==0,"FOLIAGE_CHANGED_COLLISION");
   foreach(var renderer in root.GetComponentsInChildren<MeshRenderer>()){var mat=renderer.sharedMaterial;if(mat!=null&&!AssetDatabase.Contains(mat))owned.Add(mat);if(mat!=null&&mat.mainTexture!=null&&!AssetDatabase.Contains(mat.mainTexture))owned.Add(mat.mainTexture);}
   Debug.Log("REPAIR_ENVIRONMENT_FOLIAGE_PASS original512canopy bound; real folded sprigs="+cards+" fineBranches="+branches+" vertices="+vertices);
  }
  finally{UnityEngine.Object.DestroyImmediate(root);}
  foreach(var asset in owned)Require(asset==null,"OWNED_CANOPY_RESOURCE_LEAK");Require(source!=null,"SHARED_ORIGINAL_CANOPY_DESTROYED");
 }
}
#endif
