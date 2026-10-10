using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
namespace Kamilunavo.RepairEmpire.Visuals
{
 public static class MeshArt
 {
  private static readonly Dictionary<string,Material> Materials=new();
  public static Material Mat(string key,Color color,int atlas=-1,bool glow=false){if(Materials.TryGetValue(key,out var cached)&&cached!=null)return cached;Materials.Remove(key);var m=new Material(Resources.Load<Material>(glow?"Materials/Glow":"Materials/Surface")){name=key,color=color};m.SetFloat("_Glossiness",.28f);
   if(atlas>=0){m.mainTexture=Resources.Load<Texture2D>("Art/TerrainAtlas");m.mainTextureScale=Vector2.one*.49f;m.mainTextureOffset=new Vector2((atlas%2)*.5f+.005f,atlas<2?.505f:.005f);}
   if(glow){m.EnableKeyword("_EMISSION");m.SetColor("_EmissionColor",color*2.5f);}Materials.Add(key,m);return m;}
  public static GameObject Mesh(Transform parent,string name,Vector3[] v,int[] t,Vector2[] uv,Material material,bool collide=false,Color[] colors=null){var go=new GameObject(name,typeof(MeshFilter),typeof(MeshRenderer));go.transform.SetParent(parent,false);var valid=new List<int>();for(int i=0;i<t.Length;i+=3)if(Vector3.Cross(v[t[i+1]]-v[t[i]],v[t[i+2]]-v[t[i]]).sqrMagnitude>1e-18f)valid.AddRange(new[]{t[i],t[i+1],t[i+2]});t=valid.ToArray();var used=new Dictionary<int,int>();var compact=new List<Vector3>();var cuv=uv!=null?new List<Vector2>():null;var cc=colors!=null?new List<Color>():null;for(int i=0;i<t.Length;i++){int old=t[i];if(!used.TryGetValue(old,out int index)){index=compact.Count;used.Add(old,index);compact.Add(v[old]);if(cuv!=null)cuv.Add(uv[old]);if(cc!=null)cc.Add(colors[old]);}t[i]=index;}v=compact.ToArray();uv=cuv?.ToArray();colors=cc?.ToArray();var mesh=new Mesh{name=name};mesh.vertices=v;mesh.triangles=t;if(uv!=null)mesh.uv=uv;if(colors!=null)mesh.colors=colors;mesh.RecalculateNormals();bool invalid=false;foreach(var normal in mesh.normals)if(normal.sqrMagnitude<.01f){invalid=true;break;}
   if(invalid){var expanded=new Vector3[t.Length];var tex=uv!=null?new Vector2[t.Length]:null;var indices=new int[t.Length];for(int i=0;i<t.Length;i++){expanded[i]=v[t[i]];if(tex!=null)tex[i]=uv[t[i]];indices[i]=i;}mesh.Clear();mesh.vertices=expanded;mesh.triangles=indices;if(tex!=null)mesh.uv=tex;mesh.RecalculateNormals();}mesh.RecalculateBounds();go.GetComponent<MeshFilter>().sharedMesh=mesh;go.GetComponent<MeshRenderer>().sharedMaterial=material;
   ArtLifetime.Own(go,mesh);if(collide)go.AddComponent<MeshCollider>().sharedMesh=mesh;return go;}
  public static void Batch(GameObject root){StaticBatchingUtility.Combine(root);foreach(var filter in root.GetComponentsInChildren<MeshFilter>())ArtLifetime.Own(root,filter.sharedMesh);}
  // Authored surface of revolution; each ring supplies its own silhouette radius and elevation.
  public static GameObject Lathe(Transform parent,string name,float[] y,float[] radius,int sides,Material material,Vector3 scale,bool faceted=false){var v=new List<Vector3>();var uv=new List<Vector2>();var t=new List<int>();
   for(int j=0;j<y.Length;j++)for(int i=0;i<=sides;i++){float a=i*Mathf.PI*2/sides;v.Add(Vector3.Scale(new Vector3(Mathf.Cos(a)*radius[j],y[j],Mathf.Sin(a)*radius[j]),scale));uv.Add(new Vector2((float)i/sides,(float)j/(y.Length-1)));}
   for(int j=0;j<y.Length-1;j++)for(int i=0;i<sides;i++){int a=j*(sides+1)+i,b=a+sides+1;t.AddRange(new[]{a,b,a+1,a+1,b,b+1});}
   if(faceted){var fv=new Vector3[t.Count];var fu=new Vector2[t.Count];var ft=new int[t.Count];for(int i=0;i<t.Count;i++){fv[i]=v[t[i]];fu[i]=uv[t[i]];ft[i]=i;}return Mesh(parent,name,fv,ft,fu,material);}
   return Mesh(parent,name,v.ToArray(),t.ToArray(),uv.ToArray(),material);
  }
  public static GameObject Oval(Transform parent,string name,Vector3 position,Vector3 scale,Material material,int sides=16){var y=new float[13];var r=new float[13];for(int i=0;i<13;i++){float a=Mathf.PI*i/12;y[i]=-Mathf.Cos(a)*.5f;r[i]=Mathf.Sin(a)*.5f;}var go=Lathe(parent,name,y,r,sides,material,scale);go.transform.localPosition=position;return go;}
  public static GameObject Box(Transform parent,string name,Vector3 position,Vector3 scale,Material mat){var v=new[]{new Vector3(-.5f,-.5f,-.5f),new Vector3(.5f,-.5f,-.5f),new Vector3(.5f,.5f,-.5f),new Vector3(-.5f,.5f,-.5f),new Vector3(-.5f,-.5f,.5f),new Vector3(.5f,-.5f,.5f),new Vector3(.5f,.5f,.5f),new Vector3(-.5f,.5f,.5f)};int[] t={0,2,1,0,3,2,4,5,6,4,6,7,0,4,7,0,7,3,1,2,6,1,6,5,3,7,6,3,6,2,0,1,5,0,5,4};var outv=new Vector3[t.Length];var uv=new Vector2[t.Length];var tris=new int[t.Length];for(int i=0;i<t.Length;i++){outv[i]=Vector3.Scale(v[t[i]],scale);uv[i]=new Vector2(i%3==1?1:0,i%3==2?1:0);tris[i]=i;}var go=Mesh(parent,name,outv,tris,uv,mat);go.transform.localPosition=position;return go;}
  // Six rounded face grids: bevel belongs to geometry, not a painted silhouette.
  public static GameObject BevelBox(Transform parent,string name,Vector3 position,Vector3 scale,float bevel,Material mat){
   var verts=new List<Vector3>();var tris=new List<int>();var uv=new List<Vector2>();var half=scale*.5f;bevel=Mathf.Clamp(bevel,.001f,Mathf.Min(half.x,Mathf.Min(half.y,half.z))*.9f);var core=half-Vector3.one*bevel;
   Vector3[] normals={Vector3.right,Vector3.left,Vector3.up,Vector3.down,Vector3.forward,Vector3.back};
   foreach(var normal in normals){var u=Mathf.Abs(normal.y)>.5f?Vector3.right:Vector3.Cross(Vector3.up,normal);var v=Vector3.Cross(normal,u);float hu=Vector3.Dot(new Vector3(Mathf.Abs(u.x),Mathf.Abs(u.y),Mathf.Abs(u.z)),half),hv=Vector3.Dot(new Vector3(Mathf.Abs(v.x),Mathf.Abs(v.y),Mathf.Abs(v.z)),half);float[] xs={-hu,-hu+bevel,hu-bevel,hu},ys={-hv,-hv+bevel,hv-bevel,hv};int first=verts.Count;
    for(int y=0;y<4;y++)for(int x=0;x<4;x++){var point=Vector3.Scale(normal,half)+u*xs[x]+v*ys[y];var nearest=new Vector3(Mathf.Clamp(point.x,-core.x,core.x),Mathf.Clamp(point.y,-core.y,core.y),Mathf.Clamp(point.z,-core.z,core.z));verts.Add(nearest+(point-nearest).normalized*bevel);uv.Add(new Vector2(x/3f,y/3f));}
    for(int y=0;y<3;y++)for(int x=0;x<3;x++){int a=first+y*4+x;tris.AddRange(new[]{a,a+1,a+4,a+1,a+5,a+4});}
   }
   var go=Mesh(parent,name,verts.ToArray(),tris.ToArray(),uv.ToArray(),mat);go.transform.localPosition=position;return go;
  }
  public static GameObject Tube(Transform parent,string name,Vector3[] path,float radius,Material mat,int sides=16){var verts=new List<Vector3>();var tris=new List<int>();
   for(int ring=0;ring<path.Length;ring++){var tangent=(path[Mathf.Min(path.Length-1,ring+1)]-path[Mathf.Max(0,ring-1)]).normalized;var axis=Vector3.Cross(tangent,Mathf.Abs(tangent.y)>.9f?Vector3.forward:Vector3.up).normalized;var second=Vector3.Cross(tangent,axis);for(int side=0;side<=sides;side++){float angle=side*Mathf.PI*2/sides;verts.Add(path[ring]+radius*(axis*Mathf.Cos(angle)+second*Mathf.Sin(angle)));if(ring>0&&side<sides){int a=ring*(sides+1)+side,b=a-sides-1;tris.AddRange(new[]{a,b,a+1,a+1,b,b+1});}}}
   return Mesh(parent,name,verts.ToArray(),tris.ToArray(),null,mat);
  }
  public static GameObject Ring(Transform parent,string name,float radius,float width,float y,Material mat,int sides=64,float arc=360){var v=new Vector3[(sides+1)*2];var t=new int[sides*6];for(int i=0;i<=sides;i++){float a=i*arc/sides*Mathf.Deg2Rad;v[i*2]=new Vector3(Mathf.Cos(a)*radius,y,Mathf.Sin(a)*radius);v[i*2+1]=new Vector3(Mathf.Cos(a)*(radius-width),y,Mathf.Sin(a)*(radius-width));if(i<sides){int k=i*6,a0=i*2;t[k]=a0;t[k+1]=a0+1;t[k+2]=a0+2;t[k+3]=a0+2;t[k+4]=a0+1;t[k+5]=a0+3;}}return Mesh(parent,name,v,t,null,mat);}
 }
}
