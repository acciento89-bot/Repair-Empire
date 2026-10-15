#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using Kamilunavo.RepairEmpire.Visuals;
public static class RepairResidentialModelValidation {
 static void Require(bool ok,string why){if(!ok)throw new InvalidOperationException("REPAIR_RESIDENTIAL: "+why);}
 public static void Validate(){var root=new GameObject("Residential modeling fixture");var meshes=new HashSet<Mesh>();var materials=new HashSet<Material>();var textures=new HashSet<Texture>();try{
  var stone=new Material(Resources.Load<Material>("Materials/Surface"));var glass=new Material(stone);var metal=new Material(stone);foreach(var m in new[]{stone,glass,metal})ArtLifetime.Own(root,m);var kit=new UrbanArtKit(root.transform,stone,glass,metal);kit.Facade(18,40,15,10,17,-1,0);kit.Facade(-18,70,24,10,17,1,3);kit.Tree(new Vector3(25,0,100),metal);
  Require(root.GetComponentsInChildren<Collider>().Length==0,"decorative townhouses add no physics");int awnings=0,frames=0,dormers=0;foreach(var filter in root.GetComponentsInChildren<MeshFilter>()){
   var mesh=filter.sharedMesh;meshes.Add(mesh);if(filter.name=="Shop canvas awning")awnings++;if(filter.name=="Recessed sash stone jamb")frames++;if(filter.name=="Dormer inset glazing"){dormers++;Require(filter.transform.localPosition.z>5.4f,"dormer glazing projects in front of the roof end wall");}
   foreach(var vertex in mesh.vertices){var p=filter.transform.TransformPoint(vertex);Require(float.IsFinite(p.x)&&float.IsFinite(p.y)&&float.IsFinite(p.z),"finite authored model buffers");Require(Mathf.Abs(p.x)>=11.45f,"shop projections leave the original driving corridor clear");}
  }
  Require(awnings==4&&frames>=32&&dormers==6,"actual storefront, deep sash surrounds and visible dormers modeled");int vertices=0;foreach(var mesh in meshes)vertices+=mesh.vertexCount;Require(vertices<40000,"two complete original townhouses and one tree retain bounded mesh buffers actual="+vertices);
  foreach(var renderer in root.GetComponentsInChildren<MeshRenderer>()){var m=renderer.sharedMaterial;if(m.name.StartsWith("Urban")){materials.Add(m);if(m.mainTexture!=null)textures.Add(m.mainTexture);}}
  var textureNames=new List<string>();foreach(var texture in textures)textureNames.Add(texture.name);textureNames.Sort(StringComparer.Ordinal);Debug.Log("REPAIR_RESIDENTIAL_ACTUAL_FINISH_COUNTS materials="+materials.Count+" textures="+textures.Count+" names="+string.Join(",",textureNames));Require(textures.Count==4&&materials.Count<=14,"finite original shared masonry/plaster/sprig/canopy texture and material kit: materials="+materials.Count+" textures="+textures.Count);var shader=Resources.Load<Shader>("RepairResidentialMasonry");Require(shader!=null&&!ShaderUtil.ShaderHasError(shader)&&kit.Brick.shader==shader,"original masonry shader imported and bound to production brick");
  foreach(var filter in root.GetComponentsInChildren<MeshFilter>())if(filter.GetComponent<MeshRenderer>().sharedMaterial==kit.Brick){Require(filter.sharedMesh.tangents.Length==filter.sharedMesh.vertexCount,"brick mortar normal response has an authored tangent basis");}
  Debug.Log("REPAIR_RESIDENTIAL_MODEL_BUDGET vertices="+vertices+" materials="+materials.Count+" textures="+textures.Count);
 }finally{UnityEngine.Object.DestroyImmediate(root);}foreach(var mesh in meshes)Require(mesh==null,"owned modeled geometry disposed");foreach(var m in materials)Require(m==null,"owned district finishes disposed");int shared=0;foreach(var t in textures){if(t!=null&&AssetDatabase.Contains(t)){Require(t==Resources.Load<Texture2D>("Art/StreetBrick-v1")||t==Resources.Load<Texture2D>("Art/StreetLeafSprigs-v1")||t==Resources.Load<Texture2D>("Art/StreetCanopy-v1"),"only the three original imported street surfaces survive owner disposal");shared++;}else Require(t==null,"owned generated plaster texture disposed");}Require(shared==3,"all three original shared street textures remain alive");Debug.Log("REPAIR_RESIDENTIAL_MODELS_PASS actualConceptRender=PENDING");}
}
#endif
