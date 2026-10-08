#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;
public static class RepairArtImports {
 public static void Ensure(){foreach(string path in new[]{"Assets/Resources/Art/RepairAtlas.png","Assets/Resources/Art/SkyPanorama.png","Assets/Resources/Art/RepairEmpireIcon.png"}){var texture=AssetImporter.GetAtPath(path) as TextureImporter;if(texture==null)continue;texture.textureShape=TextureImporterShape.Texture2D;texture.maxTextureSize=2048;texture.mipmapEnabled=true;texture.anisoLevel=4;texture.textureCompression=TextureImporterCompression.Compressed;texture.wrapMode=path.Contains("Atlas")?TextureWrapMode.Clamp:TextureWrapMode.Repeat;texture.SaveAndReimport();}var icon=AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/Resources/Art/RepairEmpireIcon.png");if(icon!=null)PlayerSettings.SetIconsForTargetGroup(BuildTargetGroup.Unknown,new[]{icon});AssetDatabase.SaveAssets();}
}
#endif
