#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using Kamilunavo.RepairEmpire.Gameplay;
using Kamilunavo.RepairEmpire.Visuals;

public static class RepairStreetCompositionValidation
{
 [Serializable] sealed class CitySnapshot { public string[] colliders;public string randomState; }
 static string Baseline=>Path.GetFullPath(Path.Combine(Application.dataPath,"../docs/QA/repair-street-collision-baseline-20261015.json"));
 static void Require(bool value,string reason){if(!value)throw new InvalidOperationException("REPAIR_STREET_"+reason);}
 static string V(Vector3 value)=>value.x.ToString("R",CultureInfo.InvariantCulture)+","+value.y.ToString("R",CultureInfo.InvariantCulture)+","+value.z.ToString("R",CultureInfo.InvariantCulture);
 internal sealed class EnvironmentState
 {
  readonly Material sky=RenderSettings.skybox;readonly AmbientMode mode=RenderSettings.ambientMode;
  readonly Color top=RenderSettings.ambientSkyColor,middle=RenderSettings.ambientEquatorColor,bottom=RenderSettings.ambientGroundColor,fogColor=RenderSettings.fogColor;
  readonly bool fog=RenderSettings.fog;readonly FogMode fogMode=RenderSettings.fogMode;readonly float start=RenderSettings.fogStartDistance,end=RenderSettings.fogEndDistance,density=RenderSettings.fogDensity;
  readonly UnityEngine.Random.State random=UnityEngine.Random.state;
  public void Restore(){RenderSettings.skybox=sky;RenderSettings.ambientMode=mode;RenderSettings.ambientSkyColor=top;RenderSettings.ambientEquatorColor=middle;RenderSettings.ambientGroundColor=bottom;RenderSettings.fog=fog;RenderSettings.fogColor=fogColor;RenderSettings.fogMode=fogMode;RenderSettings.fogStartDistance=start;RenderSettings.fogEndDistance=end;RenderSettings.fogDensity=density;UnityEngine.Random.state=random;}
 }
 static CitySnapshot Snapshot()
 {
  var state=new EnvironmentState();var root=new GameObject("Street collision authority fixture",typeof(CityBuilder));
  try {root.GetComponent<CityBuilder>().Build();var entries=new List<string>();foreach(var collider in root.GetComponentsInChildren<BoxCollider>(true))entries.Add(collider.name+"|"+V(collider.transform.position)+"|"+V(collider.transform.eulerAngles)+"|"+V(collider.transform.lossyScale)+"|"+V(collider.center)+"|"+V(collider.size)+"|"+collider.isTrigger);entries.Sort(StringComparer.Ordinal);return new CitySnapshot{colliders=entries.ToArray(),randomState=JsonUtility.ToJson(UnityEngine.Random.state)};}
  finally {state.Restore();UnityEngine.Object.DestroyImmediate(root);}
 }
 public static void CaptureAndValidate()
 {
  Require(!File.Exists(Baseline),"BASELINE_ALREADY_EXISTS");var before=Snapshot();Directory.CreateDirectory(Path.GetDirectoryName(Baseline));File.WriteAllText(Baseline,JsonUtility.ToJson(before,true)+"\n");Debug.Log("REPAIR_STREET_BASELINE_CAPTURED colliders="+before.colliders.Length);Validate();
 }
 public static void Validate()
 {
  Require(File.Exists(Baseline),"MISSING_ORIGINAL_COLLISION_BASELINE");var expected=JsonUtility.FromJson<CitySnapshot>(File.ReadAllText(Baseline));var actual=Snapshot();Require(string.Join("\n",actual.colliders)==string.Join("\n",expected.colliders),"COLLISION_AUTHORITY_CHANGED");Require(actual.randomState==expected.randomState,"HEIGHT_RANDOM_SEQUENCE_CHANGED");
  var root=new GameObject("Original street canopy fixture");var owned=new HashSet<UnityEngine.Object>();Texture2D brick=null,leaves=null;
  try
  {
   var surface=new Material(Resources.Load<Material>("Materials/Surface"));ArtLifetime.Own(root,surface);owned.Add(surface);var kit=new UrbanArtKit(root.transform,surface,surface,surface);kit.Tree(Vector3.zero,surface);
   bool hasBounds=false;var canopy=new Bounds();foreach(var renderer in root.GetComponentsInChildren<MeshRenderer>())if(renderer.sharedMaterial==kit.Leaves||renderer.sharedMaterial==kit.LeafMass||renderer.sharedMaterial.name=="UrbanGoldenCrown"){if(!hasBounds){canopy=renderer.bounds;hasBounds=true;}else canopy.Encapsulate(renderer.bounds);}
   Require(hasBounds&&canopy.size.y<Mathf.Max(canopy.size.x,canopy.size.z)*.95f,"CROWN_TOO_TALL width="+canopy.size.x+" height="+canopy.size.y);
   brick=Resources.Load<Texture2D>("Art/StreetBrick-v1");leaves=Resources.Load<Texture2D>("Art/StreetLeafSprigs-v1");Require(brick!=null&&leaves!=null&&kit.Brick.mainTexture==brick&&kit.Leaves.mainTexture==leaves,"ORIGINAL_SURFACES_NOT_BOUND");Require(brick.width==512&&leaves.width==512,"ORIGINAL_SURFACE_RESOLUTION");Require(root.GetComponentsInChildren<Collider>().Length==0,"TREE_ADDED_COLLISION");
   foreach(var filter in root.GetComponentsInChildren<MeshFilter>())owned.Add(filter.sharedMesh);foreach(var renderer in root.GetComponentsInChildren<MeshRenderer>()){var material=renderer.sharedMaterial;if(!AssetDatabase.Contains(material))owned.Add(material);if(material.mainTexture!=null&&!AssetDatabase.Contains(material.mainTexture))owned.Add(material.mainTexture);}
  }
  finally {UnityEngine.Object.DestroyImmediate(root);}
  foreach(var asset in owned)Require(asset==null,"OWNED_CANOPY_RESOURCE_LEAK");Require(brick!=null&&leaves!=null,"SHARED_ORIGINAL_TEXTURE_DESTROYED");Debug.Log("REPAIR_STREET_COMPOSITION_PASS exact collider/random authority, broad canopy, original shared textures and owned cleanup");
 }
}
#endif
