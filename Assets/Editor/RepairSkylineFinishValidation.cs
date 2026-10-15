#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using Kamilunavo.RepairEmpire.Gameplay;
using Kamilunavo.RepairEmpire.Visuals;

public static class RepairSkylineFinishValidation
{
 static void Require(bool valid,string why){if(!valid)throw new InvalidOperationException("REPAIR_SKYLINE_"+why);}
 public static void ConfigureSky()
 {
  const string path="Assets/Resources/Art/ServiceDaySky-v1.png";UnityEditor.AssetDatabase.ImportAsset(path,UnityEditor.ImportAssetOptions.ForceSynchronousImport);var importer=(UnityEditor.TextureImporter)UnityEditor.AssetImporter.GetAtPath(path);importer.textureType=UnityEditor.TextureImporterType.Default;importer.isReadable=false;importer.sRGBTexture=true;importer.mipmapEnabled=true;importer.maxTextureSize=1024;importer.filterMode=FilterMode.Trilinear;importer.wrapModeU=TextureWrapMode.Repeat;importer.wrapModeV=TextureWrapMode.Clamp;importer.textureCompression=UnityEditor.TextureImporterCompression.CompressedHQ;importer.SaveAndReimport();Validate();
 }
 static (int vertices,int materials) ValidateAuthoredModel()
 {
  var host=new GameObject("Unbatched authored civic budget fixture");var owned=new HashSet<Mesh>();var shared=Resources.Load<Material>("Materials/Surface");int vertices=0;var materials=new HashSet<Material>();
  try
  {
   var kit=new UrbanArtKit(host.transform,shared,shared,shared);var landmark=DistrictCivicHall.Build(host.transform,kit);
   foreach(var renderer in landmark.GetComponentsInChildren<MeshRenderer>())
   {
    var mesh=renderer.GetComponent<MeshFilter>().sharedMesh;if(owned.Add(mesh)){vertices+=mesh.vertexCount;foreach(var point in mesh.vertices)Require(float.IsFinite(point.x)&&float.IsFinite(point.y)&&float.IsFinite(point.z),"AUTHORED_VERTEX_NOT_FINITE");if(renderer.name=="Carved civic arch"||renderer.name=="Arched civic glazing"||renderer.name=="Civic sculpted mansard roof")ValidateSolid(mesh);}
    materials.Add(renderer.sharedMaterial);
   }
   Require(vertices<=20000&&materials.Count<=8,"AUTHORED_LANDMARK_BUDGET vertices="+vertices+" materials="+materials.Count);
  }
  finally{UnityEngine.Object.DestroyImmediate(host);}
  foreach(var mesh in owned)Require(mesh==null,"UNBATCHED_LANDMARK_MESH_LEAK");Require(shared!=null,"BORROWED_MATERIAL_PROTOTYPE_DESTROYED");return(vertices,materials.Count);
 }
 // Read the actual recovery/collider declarations: the fixture must fail closed
 // when gameplay authority changes, rather than silently keeping a guessed limit.
 static float LegalVanNorthEnvelope()
 {
  var culture=System.Globalization.CultureInfo.InvariantCulture;
  string gameplay=System.IO.File.ReadAllText("Assets/Scripts/Gameplay/RepairGame.cs"),bootstrap=System.IO.File.ReadAllText("Assets/Scripts/Core/GameBootstrap.cs");
  var limit=System.Text.RegularExpressions.Regex.Match(gameplay,@"Vehicle\.transform\.position\.z\s*>\s*([0-9.]+)");
  var collider=System.Text.RegularExpressions.Regex.Match(bootstrap,@"collider\.size\s*=\s*new Vector3\(([0-9.]+)f?,([0-9.]+)f?,([0-9.]+)f?\)");
  Require(limit.Success&&collider.Success,"DRIVING_AUTHORITY_DECLARATIONS_CHANGED");
  float width=float.Parse(collider.Groups[1].Value,culture),length=float.Parse(collider.Groups[3].Value,culture);
  return float.Parse(limit.Groups[1].Value,culture)+Mathf.Sqrt(width*width+length*length)*.5f;
 }
 static bool TriangleHit(Ray ray,Vector3 a,Vector3 b,Vector3 c,out float distance)
 {
  distance=0;var e1=b-a;var e2=c-a;var cross=Vector3.Cross(ray.direction,e2);float determinant=Vector3.Dot(e1,cross);if(Mathf.Abs(determinant)<.000001f)return false;float inverse=1/determinant;var offset=ray.origin-a;float u=Vector3.Dot(offset,cross)*inverse;if(u<0||u>1)return false;var q=Vector3.Cross(offset,e1);float v=Vector3.Dot(ray.direction,q)*inverse;if(v<0||u+v>1)return false;distance=Vector3.Dot(e2,q)*inverse;return distance>=0;
 }
 static void ValidatePaneVisibility(Transform landmark)
 {
  var renderers=landmark.GetComponentsInChildren<MeshRenderer>();int checkedPanes=0;var hidden=new List<string>();
  foreach(var pane in renderers)if(pane.name=="Arched civic glazing")
  {
   // Offset from the central mullion/transom; test real triangles, including the
   // opaque stone behind the frame, rather than comparing authored coordinates.
   var target=pane.bounds.center+Vector3.right*pane.bounds.size.x*.18f;
   var ray=new Ray(target-Vector3.forward*3,Vector3.forward);float nearest=float.PositiveInfinity;MeshRenderer visible=null;
   foreach(var renderer in renderers)
   {
    if(!renderer.enabled||!renderer.bounds.IntersectRay(ray))continue;var mesh=renderer.GetComponent<MeshFilter>().sharedMesh;var points=mesh.vertices;var indices=mesh.triangles;
    for(int i=0;i<indices.Length;i+=3)if(TriangleHit(ray,renderer.transform.TransformPoint(points[indices[i]]),renderer.transform.TransformPoint(points[indices[i+1]]),renderer.transform.TransformPoint(points[indices[i+2]]),out float hit)&&hit<nearest){nearest=hit;visible=renderer;}
   }
   if(visible!=pane)hidden.Add(pane.transform.localPosition+" blocked by "+(visible==null?"nothing":visible.name));checkedPanes++;
  }
  Require(checkedPanes==25&&hidden.Count==0,"CIVIC_PANES_HIDDEN checked="+checkedPanes+" "+string.Join("; ",hidden));
 }
 static void ValidateAuthoredLamp(Transform host,Material shared,HashSet<Mesh> owned)
 {
  var root=new GameObject("Unbatched street lamp fixture").transform;root.SetParent(host,false);StreetLampArt.Build(root,shared,shared,shared);
  foreach(var filter in root.GetComponentsInChildren<MeshFilter>()){owned.Add(filter.sharedMesh);foreach(var point in filter.sharedMesh.vertices)Require(float.IsFinite(point.x)&&float.IsFinite(point.y)&&float.IsFinite(point.z),"LAMP_NONFINITE_VERTEX");foreach(var normal in filter.sharedMesh.normals)Require(float.IsFinite(normal.x)&&float.IsFinite(normal.y)&&float.IsFinite(normal.z)&&normal.sqrMagnitude>.5f,"LAMP_INVALID_NORMAL");}
  var arm=root.Find("Curved street lamp arm").GetComponent<MeshFilter>().sharedMesh;bool raisedMiddle=false;
  foreach(var point in arm.vertices)if(point.x>.4f&&point.x<.7f&&point.y>4.95f)raisedMiddle=true;
  Require(arm.vertexCount>=100&&arm.vertexCount<=300&&arm.bounds.size.x>1.3f&&arm.bounds.size.y>.75f&&arm.bounds.size.z<.12f&&raisedMiddle,"AUTHORED_LAMP_NOT_CURVED_TUBE");
 }
 public static void ValidateArchitectureContracts()
 {
  var host=new GameObject("Unbatched architecture regression fixture");var owned=new HashSet<Mesh>();var shared=Resources.Load<Material>("Materials/Surface");var failures=new List<string>();
  try
  {
   var kit=new UrbanArtKit(host.transform,shared,shared,shared);var landmark=DistrictCivicHall.Build(host.transform,kit);bool found=false;var bounds=new Bounds();
   foreach(var renderer in landmark.GetComponentsInChildren<MeshRenderer>()){owned.Add(renderer.GetComponent<MeshFilter>().sharedMesh);if(!found){bounds=renderer.bounds;found=true;}else bounds.Encapsulate(renderer.bounds);}
   try{Require(found&&bounds.min.z>LegalVanNorthEnvelope()+2,"HALL_INSIDE_LEGAL_VAN_ENVELOPE front="+bounds.min.z+" legalVanMax="+LegalVanNorthEnvelope());}catch(Exception e){failures.Add(e.Message);}
   try{ValidatePaneVisibility(landmark);}catch(Exception e){failures.Add(e.Message);}
   try{ValidateAuthoredLamp(host.transform,shared,owned);}catch(Exception e){failures.Add(e.Message);}
  }
  finally{UnityEngine.Object.DestroyImmediate(host);}
  foreach(var mesh in owned)Require(mesh==null,"ARCHITECTURE_REGRESSION_MESH_LEAK");Require(shared!=null,"ARCHITECTURE_SHARED_MATERIAL_DESTROYED");
  Require(failures.Count==0,string.Join("\n",failures));Debug.Log("REPAIR_SKYLINE_ARCHITECTURE_PASS actual465boundary+rotatedVan+2m;25first-visible panes;unbatched curved tube andownedcleanup");
 }
 static void ValidateSolid(Mesh mesh)
 {
  var points=mesh.vertices;var triangles=mesh.triangles;var ids=new Dictionary<Vector3Int,int>();var mapped=new int[points.Length];var edges=new Dictionary<(int,int),int>();double volume=0;
  for(int i=0;i<points.Length;i++){var p=points[i];var key=new Vector3Int(Mathf.RoundToInt(p.x*100000),Mathf.RoundToInt(p.y*100000),Mathf.RoundToInt(p.z*100000));if(!ids.TryGetValue(key,out int id)){id=ids.Count;ids.Add(key,id);}mapped[i]=id;}
  for(int i=0;i<triangles.Length;i+=3){int a=triangles[i],b=triangles[i+1],c=triangles[i+2];volume+=Vector3.Dot(points[a],Vector3.Cross(points[b],points[c]))/6.0;foreach(var pair in new[]{(mapped[a],mapped[b]),(mapped[b],mapped[c]),(mapped[c],mapped[a])}){var key=pair.Item1<pair.Item2?pair:(pair.Item2,pair.Item1);edges.TryGetValue(key,out int count);edges[key]=count+1;}}
  foreach(var edge in edges)Require(edge.Value==2,"OPEN_CIVIC_SOLID "+mesh.name+" edge="+edge.Key+" count="+edge.Value);Require(volume>0.00001,"INVERTED_CIVIC_SOLID "+mesh.name+" volume="+volume);
 }
 public static void Validate()
 {
  ValidateArchitectureContracts();
  var sky=RenderSettings.skybox;var mode=RenderSettings.ambientMode;var top=RenderSettings.ambientSkyColor;var middle=RenderSettings.ambientEquatorColor;var bottom=RenderSettings.ambientGroundColor;bool fog=RenderSettings.fog;var fogColor=RenderSettings.fogColor;var fogMode=RenderSettings.fogMode;float start=RenderSettings.fogStartDistance,end=RenderSettings.fogEndDistance;var random=UnityEngine.Random.state;
  var root=new GameObject("Skyline actual district fixture",typeof(CityBuilder));var meshes=new HashSet<Mesh>();Material ownedSky=null;Texture2D original=null;
  try
  {
   original=Resources.Load<Texture2D>("Art/ServiceDaySky-v1");Require(original!=null&&original.width==1024&&original.height==512&&!original.isReadable&&original.mipmapCount>1,"ORIGINAL_FULL_SPHERE_SKY_MISSING");root.GetComponent<CityBuilder>().Build();ownedSky=RenderSettings.skybox;Require(ownedSky.mainTexture==original,"SKY_NOT_BOUND_TO_ACTUAL_DISTRICT");
   var landmark=root.transform.Find("Authored static district/Original Riverside civic hall");Require(landmark!=null,"CIVIC_SILHOUETTE_MISSING");Require(landmark.GetComponentsInChildren<Collider>(true).Length==0,"LANDMARK_ADDS_COLLISION");bool found=false;var bounds=new Bounds();int windows=0;
   foreach(var renderer in landmark.GetComponentsInChildren<MeshRenderer>(true)){meshes.Add(renderer.GetComponent<MeshFilter>().sharedMesh);if(!found){bounds=renderer.bounds;found=true;}else bounds.Encapsulate(renderer.bounds);if(renderer.name=="Arched civic glazing")windows++;}
   var ground=root.transform.Find("Authored static district/Continuous driveable ground").GetComponent<MeshRenderer>();var plaza=landmark.Find("Civic distant paved square").GetComponent<MeshRenderer>();Require(plaza.bounds.min.z>=ground.bounds.max.z-.0001f,"PLAZA_OVERLAPS_EXISTING_GROUND");
   Require(found&&bounds.min.z>LegalVanNorthEnvelope()+2&&bounds.max.y>=38&&bounds.size.x>=28&&windows>=20,"LANDMARK_SILHOUETTE_OR_PLAYABLE_VOLUME");var authored=ValidateAuthoredModel();
   int lamps=0;foreach(var node in root.GetComponentsInChildren<Transform>())if(node.name=="Street light")
   {
    var arm=node.Find("Curved street lamp arm");Require(arm!=null&&arm.GetComponent<MeshRenderer>()!=null,"CURVED_LAMP_GEOMETRY_MISSING");Require(node.GetComponentsInChildren<Collider>().Length==0,"DECORATIVE_LAMP_ADDS_COLLISION");lamps++;
   }
   Require(lamps>=10,"STREET_LAMPS_MISSING");Debug.Log("REPAIR_SKYLINE_FINISH_PASS original1024x512sky; civic vertices="+authored.vertices+" materials="+authored.materials+" archedWindows="+windows+" bounds="+bounds+" curvedLamps="+lamps);
  }
  finally
  {
   UnityEngine.Object.DestroyImmediate(root);RenderSettings.skybox=sky;RenderSettings.ambientMode=mode;RenderSettings.ambientSkyColor=top;RenderSettings.ambientEquatorColor=middle;RenderSettings.ambientGroundColor=bottom;RenderSettings.fog=fog;RenderSettings.fogColor=fogColor;RenderSettings.fogMode=fogMode;RenderSettings.fogStartDistance=start;RenderSettings.fogEndDistance=end;UnityEngine.Random.state=random;
  }
  foreach(var mesh in meshes)Require(mesh==null,"LANDMARK_MESH_OWNER_LEAK");Require(ownedSky==null&&original!=null,"SKY_OWNED_MATERIAL_OR_SHARED_IMPORT_LIFETIME");
 }
}
#endif
