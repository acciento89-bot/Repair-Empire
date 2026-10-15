using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
namespace Kamilunavo.RepairEmpire.Visuals
{
 public enum FixtureFinish { Ceramic,Chrome,Steel,Copper,Brass,Navy,Orange,Blue,Green,Dirt,Stone,Grout,Plaster,Wood,Concrete,Cloth,Lamp,Glass }
 // One original finite material/texture kit belongs to the studio or standalone model.
 [ExecuteAlways] public sealed class FixtureMaterials:MonoBehaviour
 {
  readonly Dictionary<FixtureFinish,Material> _materials=new();readonly Dictionary<int,Texture2D> _textures=new();Cubemap _environment;
  public static FixtureMaterials Kit(Transform parent)
  {
   var studio=parent.GetComponentInParent<ServiceSceneArt>();var inherited=parent.GetComponentInParent<FixtureMaterials>();var owner=studio!=null?studio.gameObject:inherited!=null?inherited.gameObject:parent.gameObject;
   return owner.GetComponent<FixtureMaterials>()??owner.AddComponent<FixtureMaterials>();
  }
  public static Material Get(Transform parent,FixtureFinish finish)=>Kit(parent).Material(finish);
  static float Hash(int x,int y){unchecked{uint n=(uint)(x*374761393+y*668265263);n=(n^(n>>13))*1274126177;return ((n^(n>>16))&65535)/65535f;}}
  Texture2D Texture(int kind)
  {
   if(_textures.TryGetValue(kind,out var existing))return existing;const int n=128;var pixels=new Color[n*n];
   for(int y=0;y<n;y++)for(int x=0;x<n;x++){
    float u=(float)x/n,v=(float)y/n,grain=Hash(x,y),coarse=Hash(x/7,y/7),value;
    if(kind==0)value=.86f+(grain-.5f)*.032f+(coarse-.5f)*.055f;
    else if(kind==1)value=.94f+(grain-.5f)*.035f+Mathf.Sin(y*.68f)*.009f;
    else if(kind==2){float fibers=Mathf.Sin(u*125.6637f+Mathf.Sin(v*6.28318f)*.55f);value=.86f+fibers*.048f+(grain-.5f)*.045f;}
    else value=.85f+((x%4==0||y%4==0)?-.025f:.018f)+(grain-.5f)*.018f;
    pixels[y*n+x]=new Color(value,value,value);
   }
   var tex=new Texture2D(n,n,TextureFormat.RGB24,true){name="FixturePBRTexture"+kind,wrapMode=TextureWrapMode.Repeat,filterMode=FilterMode.Bilinear,anisoLevel=2};tex.SetPixels(pixels);tex.Apply(true,true);ArtLifetime.Own(gameObject,tex);_textures.Add(kind,tex);return tex;
  }
  Material Material(FixtureFinish finish)
  {
   if(_materials.TryGetValue(finish,out var existing))return existing;var mat=new Material(Resources.Load<Material>("Materials/Surface")){name="FixturePBR"+finish};float metal=0,gloss=.25f;
   mat.color=finish switch {
    FixtureFinish.Ceramic=>new(.96f,.95f,.91f),FixtureFinish.Chrome=>new(.96f,.97f,.98f),FixtureFinish.Steel=>new(.55f,.60f,.61f),FixtureFinish.Copper=>new(.72f,.40f,.23f),FixtureFinish.Brass=>new(.69f,.51f,.23f),
    FixtureFinish.Navy=>new(.035f,.06f,.08f),FixtureFinish.Orange=>new(.96f,.31f,.055f),FixtureFinish.Blue=>new(.13f,.25f,.30f),FixtureFinish.Green=>new(.22f,.47f,.29f),FixtureFinish.Dirt=>new(.34f,.29f,.22f),
    FixtureFinish.Stone=>Color.white,FixtureFinish.Grout=>new(.62f,.58f,.50f),FixtureFinish.Plaster=>new(.80f,.79f,.72f),FixtureFinish.Wood=>new(.48f,.34f,.20f),FixtureFinish.Concrete=>new(.52f,.54f,.51f),
    FixtureFinish.Cloth=>Color.white,FixtureFinish.Lamp=>new(1,.90f,.68f),_=>new(.37f,.48f,.51f)};
   if(finish==FixtureFinish.Chrome||finish==FixtureFinish.Steel||finish==FixtureFinish.Copper||finish==FixtureFinish.Brass){metal=finish==FixtureFinish.Chrome?1f:.82f;gloss=finish==FixtureFinish.Chrome?.90f:finish==FixtureFinish.Steel?.61f:.67f;mat.mainTexture=Texture(1);}
   else if(finish==FixtureFinish.Ceramic)gloss=.73f;
   else if(finish==FixtureFinish.Stone){mat.mainTexture=Resources.Load<Texture2D>("Art/ServiceStone-v1");gloss=.34f;}
   else if(finish==FixtureFinish.Plaster||finish==FixtureFinish.Concrete){mat.mainTexture=Texture(0);gloss=.10f;}
   else if(finish==FixtureFinish.Wood){mat.mainTexture=Texture(2);gloss=.27f;}
   else if(finish==FixtureFinish.Cloth){mat.mainTexture=Resources.Load<Texture2D>("Art/ServiceCloth-v1");gloss=.08f;}
   else if(finish==FixtureFinish.Blue){metal=.30f;gloss=.43f;}
   else if(finish==FixtureFinish.Glass){metal=.30f;gloss=.78f;}
   if(finish==FixtureFinish.Lamp){mat.EnableKeyword("_EMISSION");mat.SetColor("_EmissionColor",mat.color*.45f);}
   mat.SetFloat("_Metallic",metal);mat.SetFloat("_Glossiness",gloss);ArtLifetime.Own(gameObject,mat);_materials.Add(finish,mat);return mat;
  }
  public Cubemap Environment()
  {
   if(_environment!=null)return _environment;const int n=64;var cube=new Cubemap(n,TextureFormat.RGBAHalf,true){name="FixturePBRStudioReflection",filterMode=FilterMode.Trilinear,wrapMode=TextureWrapMode.Clamp};
   for(int face=0;face<6;face++){
    var pixels=new Color[n*n];for(int y=0;y<n;y++)for(int x=0;x<n;x++){
     float u=(x+.5f)/n*2-1,v=(y+.5f)/n*2-1;Vector3 d=face switch {0=>new(1,-v,-u),1=>new(-1,-v,u),2=>new(u,1,v),3=>new(u,-1,-v),4=>new(u,-v,1),_=>new(-u,-v,-1)};d.Normalize();
     var color=Color.Lerp(new Color(.20f,.18f,.14f),new Color(.80f,.79f,.73f),Mathf.Clamp01(d.y*.65f+.52f));
     // Broad window and narrow softbox reflected on physical metal. HDR stores
     // real bright specular energy; no emission or scene-global environment changes.
     float panel=Panel(d,new Vector3(-.50f,.05f,-.86f),.22f,.90f);
     float strip=Panel(d,new Vector3(.64f,.10f,-.72f),.12f,.80f);
     color=Color.Lerp(color,new Color(3.1f,3.0f,2.78f),panel);
     color=Color.Lerp(color,new Color(2.25f,2.40f,2.55f),strip);
     if(Mathf.Abs(d.y)<.09f&&d.z>.45f)color*=.72f;color.a=1;pixels[y*n+x]=color;
    }cube.SetPixels(pixels,(CubemapFace)face);
   }
   cube.Apply(true,true);ArtLifetime.Own(gameObject,cube);_environment=cube;return cube;
  }
  static float Panel(Vector3 direction,Vector3 normal,float width,float height){normal.Normalize();var across=Vector3.Cross(Vector3.up,normal).normalized;var vertical=Vector3.Cross(normal,across).normalized;float forward=Vector3.Dot(direction,normal);if(forward<=.15f)return 0;float x=Mathf.Abs(Vector3.Dot(direction,across))/forward,y=Mathf.Abs(Vector3.Dot(direction,vertical))/forward;return (1-Mathf.SmoothStep(0,1,Mathf.InverseLerp(width-.06f,width+.06f,x)))*(1-Mathf.SmoothStep(0,1,Mathf.InverseLerp(height-.06f,height+.06f,y)));}
  public static void PrepareRenderers(GameObject model)
  {
   foreach(var renderer in model.GetComponentsInChildren<MeshRenderer>()){
    renderer.reflectionProbeUsage=ReflectionProbeUsage.Simple;renderer.lightProbeUsage=LightProbeUsage.Off;
    var material=renderer.sharedMaterial;if(material==null||!material.HasProperty("_Metallic")||material.GetFloat("_Metallic")<.7f)continue;
    var mesh=renderer.GetComponent<MeshFilter>()?.sharedMesh;if(mesh==null)continue;var vertices=mesh.vertices;var normals=mesh.normals;var groups=new Dictionary<(int,int,int),Vector3>();
    (int,int,int) Key(Vector3 point)=>(Mathf.RoundToInt(point.x*100000),Mathf.RoundToInt(point.y*100000),Mathf.RoundToInt(point.z*100000));
    for(int i=0;i<vertices.Length;i++){var key=Key(vertices[i]);groups.TryGetValue(key,out var sum);groups[key]=sum+normals[i];}
    for(int i=0;i<vertices.Length;i++){var sum=groups[Key(vertices[i])];if(sum.sqrMagnitude>.01f)normals[i]=sum.normalized;}mesh.normals=normals;
   }
  }
 }
}
