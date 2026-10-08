using System;
using System.IO;
namespace Kamilunavo.RepairEmpire.Core {
 public sealed class RepairSave {
  readonly string path;readonly Func<RepairProfile,string> encode;readonly Func<string,RepairProfile> decode;bool blocked;
  public RepairSave(string path,Func<RepairProfile,string> encode,Func<string,RepairProfile> decode){this.path=path;this.encode=encode;this.decode=decode;}
  public RepairProfile Load(){if(!File.Exists(path))return new RepairProfile();try{var p=decode(File.ReadAllText(path));if(p==null)throw new FormatException("Empty profile");blocked=!p.Supported;p.Normalize();return p;}catch{blocked=true;return new RepairProfile{Schema=-1};}}
  public bool Save(RepairProfile p){if(blocked||p==null||!p.Supported)return false;try{if(File.Exists(path)){var current=decode(File.ReadAllText(path));if(current==null||!current.Supported){blocked=true;return false;}}string folder=Path.GetDirectoryName(path);if(!string.IsNullOrEmpty(folder))Directory.CreateDirectory(folder);File.WriteAllText(path+".tmp",encode(p));if(File.Exists(path))File.Replace(path+".tmp",path,path+".bak");else File.Move(path+".tmp",path);return true;}catch{return false;}}
 }
}
