#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using Kamilunavo.RepairEmpire.Gameplay;
using Kamilunavo.RepairEmpire.Visuals;

public static class RepairCityVisualValidation
{
 static int checks;
 static readonly string Output="/Volumes/SSK SSD/Kamilunavo/Builds/RisingExpansion-20261011/Repair/City";
 static void Check(bool condition,string label){checks++;if(!condition)throw new InvalidOperationException("Repair city art: "+label);}
 static string Collision(GameObject city){var entries=new List<string>();foreach(var collider in city.GetComponentsInChildren<BoxCollider>(true)){var p=collider.transform.position;var s=collider.size;var c=collider.center;entries.Add(collider.name+"|"+p.x.ToString("R",System.Globalization.CultureInfo.InvariantCulture)+","+p.y.ToString("R",System.Globalization.CultureInfo.InvariantCulture)+","+p.z.ToString("R",System.Globalization.CultureInfo.InvariantCulture)+"|"+s.x.ToString("R",System.Globalization.CultureInfo.InvariantCulture)+","+s.y.ToString("R",System.Globalization.CultureInfo.InvariantCulture)+","+s.z.ToString("R",System.Globalization.CultureInfo.InvariantCulture)+"|"+c.x.ToString("R",System.Globalization.CultureInfo.InvariantCulture)+","+c.y.ToString("R",System.Globalization.CultureInfo.InvariantCulture)+","+c.z.ToString("R",System.Globalization.CultureInfo.InvariantCulture));}entries.Sort(StringComparer.Ordinal);return string.Join("\n",entries);}
 public static void CaptureBaselineAndValidate(){Directory.CreateDirectory(Output);var root=new GameObject("CityColliderBaseline",typeof(CityBuilder));var sky=RenderSettings.skybox;try{root.GetComponent<CityBuilder>().Build();string file=Path.Combine(Output,"original-city-colliders.txt");if(!File.Exists(file))File.WriteAllText(file,Collision(root));Debug.Log("REPAIR_CITY_BASELINE_COLLIDERS "+root.GetComponentsInChildren<Collider>().Length);}finally{UnityEngine.Object.DestroyImmediate(root);RenderSettings.skybox=sky;}Validate();}
 public static void Validate(){checks=0;
  var van=new GameObject("HeroVanArtFixture",typeof(VanArt));try{
   van.GetComponent<VanArt>().Build();var shell=van.transform.Find("Bevelled service body").GetComponent<MeshFilter>().sharedMesh;
   Check(shell.vertexCount>=200,"hero van has densely sampled rounded roof/body cross sections");
   var skin=van.transform.Find("Bevelled service body").GetComponent<MeshFilter>();float cargoRoof=5-RepairVanGlassValidation.Hit(skin,new Ray(new Vector3(0,5,-1.72f),Vector3.down)),hoodRoof=5-RepairVanGlassValidation.Hit(skin,new Ray(new Vector3(0,5,1.92f),Vector3.down));
   Check(float.IsFinite(cargoRoof)&&float.IsFinite(hoodRoof)&&cargoRoof>2.35f&&hoodRoof>.9f&&cargoRoof-hoodRoof>1,"actual mesh rays show the cargo roof flowing into a visibly lower hood");
   int originalFilters=van.GetComponentsInChildren<MeshFilter>().Length;van.GetComponent<VanArt>().Build();Check(originalFilters==van.GetComponentsInChildren<MeshFilter>().Length,"repeated Build does not duplicate geometry or resources");
   var ownedMaterials=new HashSet<Material>();foreach(var renderer in van.GetComponentsInChildren<MeshRenderer>())if(renderer.sharedMaterial!=null&&renderer.sharedMaterial.name.StartsWith("Van",StringComparison.Ordinal))ownedMaterials.Add(renderer.sharedMaterial);
   Check(van.GetComponentsInChildren<Collider>(true).Length==0,"van art never changes vehicle collision");
   int active=0;foreach(var renderer in van.GetComponentsInChildren<MeshRenderer>())if(renderer.enabled)active++;
   Check(active<=32,"bounded moving-van renderer budget");
   var meshes=new HashSet<Mesh>();int vertices=0;foreach(var filter in van.GetComponentsInChildren<MeshFilter>()){if(meshes.Add(filter.sharedMesh))vertices+=filter.sharedMesh.vertexCount;foreach(var normal in filter.sharedMesh.normals)Check(normal.sqrMagnitude>.5f,"van valid lighting normals");}
   Check(vertices<70000,"bounded original plus combined hero-van geometry");
   var art=van.GetComponent<VanArt>();art.Apply(7,1);Check(van.transform.localScale==new Vector3(1,1.10f,1.06f),"vehicle upgrade visual scaling preserved");var livery=new List<Material>(ownedMaterials).Find(m=>m.name=="VanStyleLivery");Check(livery!=null&&livery.color==new Color(.89f,.30f,.67f),"style seven updates the batched livery material");art.Apply(0,0);
   var peer=new GameObject("IndependentVan",typeof(VanArt));try{peer.GetComponent<VanArt>().Build();foreach(var renderer in peer.GetComponentsInChildren<MeshRenderer>())Check(renderer.sharedMaterial!=livery,"vehicle livery ownership is isolated");}finally{UnityEngine.Object.DestroyImmediate(peer);}
   UnityEngine.Object.DestroyImmediate(van);foreach(var mesh in meshes)Check(mesh==null,"van original and combined meshes released");foreach(var material in ownedMaterials)Check(material==null,"van owned materials released");
   Debug.Log("REPAIR_HERO_VAN_BUDGET vertices="+vertices+" activeRenderers="+active);
  }finally{if(van!=null)UnityEngine.Object.DestroyImmediate(van);}
  var city=new GameObject("StreetArtFixture",typeof(CityBuilder));var previousSky=RenderSettings.skybox;
  try{
   city.GetComponent<CityBuilder>().Build();string baseline=Path.Combine(Output,"original-city-colliders.txt");Check(File.Exists(baseline),"root captured original collider baseline before implementation");Check(Collision(city)==File.ReadAllText(baseline),"all original road/building/workshop colliders retain exact position, center and size");
   var names=new HashSet<string>();Transform firstOffice=null,firstSetback=null;foreach(var node in city.GetComponentsInChildren<Transform>()){names.Add(node.name);if(node.name=="Recessed office facade"&&firstOffice==null)firstOffice=node;if(node.name=="Setback upper residence"&&firstSetback==null)firstSetback=node;}
   Check(firstOffice!=null&&firstOffice.Find("Deeply recessed urban glazing").localPosition.z<firstOffice.Find("Facade carved vertical pier").localPosition.z,"glazing is physically behind the masonry front");
   Check(firstSetback!=null&&firstSetback.localPosition.y==7&&firstSetback.localPosition.z<0,"modern upper volume steps back above a lower terrace");
   var ownedMaterials=new HashSet<Material>();var ownedTextures=new HashSet<Texture>();foreach(var renderer in city.GetComponentsInChildren<MeshRenderer>()){var mat=renderer.sharedMaterial;if(mat!=null&&mat.name!="UrbanGardenGrass"&&mat.name.StartsWith("Urban",StringComparison.Ordinal)){ownedMaterials.Add(mat);if(mat.mainTexture!=null)ownedTextures.Add(mat.mainTexture);}}
   Check(ownedTextures.Count==3,"finite shared district brick, plaster and leaf detail textures");foreach(var texture in ownedTextures)Check(texture.width*texture.height<=16384,"bounded district texture resolution");
   Check(names.Contains("Brick terrace facade")&&names.Contains("Recessed office facade")&&names.Contains("Stepped modern facade")&&names.Contains("Corner mansard facade"),"four distinct authored building/roof silhouettes");
   Check(names.Contains("Workshop hero gable")&&names.Contains("Workshop open service bay"),"workshop is an authored street landmark");
   Check(names.Contains("Sculpted urban leaf crown")&&names.Contains("Urban leaf clusters")&&!names.Contains("Rounded leaf crown"),"tree detail replaces identical oval crowns");
   var meshes=new HashSet<Mesh>();int vertices=0;foreach(var filter in city.GetComponentsInChildren<MeshFilter>()){if(meshes.Add(filter.sharedMesh))vertices+=filter.sharedMesh.vertexCount;foreach(var vertex in filter.sharedMesh.vertices)Check(float.IsFinite(vertex.x)&&float.IsFinite(vertex.y)&&float.IsFinite(vertex.z),"finite city geometry");}
   Check(vertices<1200000,"bounded original and static-batched district geometry");var ownedSky=RenderSettings.skybox;
   UnityEngine.Object.DestroyImmediate(city);foreach(var mesh in meshes)Check(mesh==null,"all original/static-batched city meshes released");Check(ownedSky==null,"generated city sky released");foreach(var material in ownedMaterials)Check(material==null,"owned district materials released");foreach(var texture in ownedTextures)Check(texture==null,"owned district textures released");
   Debug.Log("REPAIR_STREET_BUDGET uniqueVertices="+vertices);
  }finally{if(city!=null)UnityEngine.Object.DestroyImmediate(city);RenderSettings.skybox=previousSky;}
  Debug.Log("REPAIR_CITY_ART_PASS checks="+checks);
 }
}
#endif
