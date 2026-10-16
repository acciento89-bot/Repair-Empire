#if UNITY_EDITOR
using System;
using UnityEngine;
public static class RepairStreetFinishValidation
{
 static void Require(bool valid,string reason){if(!valid)throw new InvalidOperationException("REPAIR_STREET_FINISH_"+reason);}
 public static void ValidateHdrRamp(){var ramp=Kamilunavo.RepairEmpire.QA.WorldFinishRenderCheck.Run(Require);Debug.Log("REPAIR_WORLD_HDR_RAMP_PASS actual GPU finite neutral monotone output="+string.Join(",",ramp));}
 public static void Configure()
 {
  const string path="Assets/Resources/Art/StreetAsphalt-v2.png";UnityEditor.AssetDatabase.ImportAsset(path,UnityEditor.ImportAssetOptions.ForceSynchronousImport);var importer=(UnityEditor.TextureImporter)UnityEditor.AssetImporter.GetAtPath(path);importer.textureType=UnityEditor.TextureImporterType.Default;importer.maxTextureSize=512;importer.isReadable=false;importer.sRGBTexture=true;importer.mipmapEnabled=true;importer.wrapMode=TextureWrapMode.Repeat;importer.filterMode=FilterMode.Trilinear;importer.anisoLevel=4;importer.textureCompression=UnityEditor.TextureImporterCompression.CompressedHQ;importer.SaveAndReimport();ValidateHdrRamp();
 }
 public static void Validate(){ValidateHdrRamp();var asphalt=Resources.Load<Texture2D>("Art/StreetAsphalt-v2");Require(asphalt!=null&&asphalt.width==512&&asphalt.height==512&&!asphalt.isReadable&&asphalt.mipmapCount>1,"ORIGINAL_ROAD_SURFACE_MISSING");}
}
#endif
