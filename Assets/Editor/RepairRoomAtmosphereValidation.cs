#if UNITY_EDITOR
using System;
using UnityEditor;
using UnityEngine;
using Kamilunavo.RepairEmpire.Visuals;
public static class RepairRoomAtmosphereValidation
{
 static void Require(bool value,string why){if(!value)throw new InvalidOperationException("Repair room atmosphere: "+why);}
 public static void Validate()
 {
  var source=Resources.Load<Cubemap>("Art/ServiceRoomReflection-v4");var stone=Resources.Load<Texture2D>("Art/ServiceStone-v2");Require(source!=null&&stone!=null,"Original new environment/limestone resources missing");Require(source.width==64&&source.format==TextureFormat.RGBAHalf&&source.mipmapCount==7,"Original small HDR range/mip budget");var previous=Resources.Load<Cubemap>("Art/ServiceRoomReflection-v2");
  float Mean(Cubemap cube){float sum=0;for(int mip=0;mip<cube.mipmapCount;mip++)foreach(CubemapFace face in new[]{CubemapFace.PositiveX,CubemapFace.NegativeX,CubemapFace.PositiveY,CubemapFace.NegativeY,CubemapFace.PositiveZ,CubemapFace.NegativeZ})foreach(var c in cube.GetPixels(face,mip)){Require(float.IsFinite(c.r)&&float.IsFinite(c.g)&&float.IsFinite(c.b)&&c.a==1,"Finite opaque HDR reflection texels across every mip");if(mip==0)sum+=c.r*.2126f+c.g*.7152f+c.b*.0722f;}return sum/(6*64*64);}
  float oldMean=Mean(previous),mean=Mean(source);Require(mean<oldMean*.8f,"Actual room midtones must be meaningfully deeper than preceding ivory environment "+oldMean+" -> "+mean);var importer=(TextureImporter)AssetImporter.GetAtPath("Assets/Resources/Art/ServiceStone-v2.png");Require(stone.width==256&&stone.height==256&&stone.mipmapCount>1&&!stone.isReadable&&importer.sRGBTexture&&stone.wrapMode==TextureWrapMode.Repeat,"Shared256pxoriginal albedo must retain sRGB/mips/nonreadable/repeat");
  var host=new GameObject("Actual room material binding fixture");Cubemap owned=null;Material material=null;
  try{var kit=FixtureMaterials.Kit(host.transform);owned=kit.Environment();material=FixtureMaterials.Get(host.transform,FixtureFinish.Stone);Require(owned!=source&&owned.width==64&&!owned.isReadable&&owned.name=="FixturePBRStudioReflection","Scene owns the nonreadable original reflection clone");Require(material.mainTexture==stone,"Actual wall/counter stone uses the original medium greige source");}
  finally{UnityEngine.Object.DestroyImmediate(host);}
  Require(owned==null&&material==null&&stone!=null&&source!=null,"Studio teardown releases its material/cube and preserves immutable source assets");Debug.Log("REPAIR_ROOM_ATMOSPHERE_PASS source64RGBAHalf/mips stone256 meanLuminance="+oldMean+" -> "+mean+" ownedCloneAndMaterialCleanup=true");
 }
}
#endif
