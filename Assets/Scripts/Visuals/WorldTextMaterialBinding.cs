using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
namespace Kamilunavo.RepairEmpire.Visuals {
 // World labels share an owned atlas material; UI keeps the imported font material.
 [ExecuteAlways] public sealed class WorldTextMaterialBinding:MonoBehaviour {
  sealed class Entry { public Material Material; public int Users; }
  static readonly Dictionary<Font,Entry> entries=new();
  Font font;Entry entry;
  public static void Bind(TextMesh text){
   if(text.font==null)return;
   var binding=text.GetComponent<WorldTextMaterialBinding>()??text.gameObject.AddComponent<WorldTextMaterialBinding>();
   binding.Release();binding.font=text.font;
   if(!entries.TryGetValue(binding.font,out binding.entry)){
    var shader=Resources.Load<Shader>("WorldText");
    if(shader==null)throw new System.InvalidOperationException("Missing world text shader");
    var material=new Material(shader){name="WorldText "+binding.font.name,mainTexture=binding.font.material.mainTexture,hideFlags=HideFlags.HideAndDontSave};
    material.SetFloat("_ZTest",(float)CompareFunction.LessEqual);material.SetFloat("_ZWrite",0);
    binding.entry=new Entry{Material=material};
    if(entries.Count==0)Font.textureRebuilt+=RefreshAtlas;
    entries.Add(binding.font,binding.entry);
   }
   binding.entry.Users++;text.GetComponent<MeshRenderer>().sharedMaterial=binding.entry.Material;
  }
  static void RefreshAtlas(Font changed){if(entries.TryGetValue(changed,out var shared)&&shared.Material!=null)shared.Material.mainTexture=changed.material.mainTexture;}
  void OnDestroy(){Release();}
  void Release(){
   if(entry==null)return;
   if(--entry.Users==0){
    entries.Remove(font);
    if(entries.Count==0)Font.textureRebuilt-=RefreshAtlas;
    if(entry.Material!=null){if(Application.isPlaying)Destroy(entry.Material);else DestroyImmediate(entry.Material);}
   }
   font=null;entry=null;
  }
 }
}
