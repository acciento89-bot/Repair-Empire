using System;
using System.Collections.Generic;
namespace Kamilunavo.RepairEmpire.Monetization {
 public sealed class InterstitialBoundary {
  public bool RemoveAds,Tutorial,Parked,ResultModal,RepairOpen,Focused,ProviderBusy,Consent,Ready;
 }
 // Session-only: legacy counters/reloads never count as new paid work. A result is
 // consumed immediately, including no-fill/background/consent failures; no queue.
 public sealed class InterstitialPolicy {
  readonly HashSet<string> paidContracts=new HashSet<string>();
  long frontier,opportunity;int paidSinceAd;double lastOpened;
  public int PaidSinceAd=>paidSinceAd;
  public InterstitialPolicy(double sessionStart){lastOpened=Finite(sessionStart)?sessionStart:double.MaxValue;}
  public bool RecordPaid(long ticket,string contract){if(ticket<=frontier||string.IsNullOrWhiteSpace(contract)||paidContracts.Count>=24||!paidContracts.Add(contract))return false;frontier=ticket;opportunity=ticket;paidSinceAd++;return true;}
  public bool TryAtResult(long ticket,double now,InterstitialBoundary b){if(ticket<=0||ticket!=opportunity)return false;opportunity=0;
   return b!=null&&Finite(now)&&now>=lastOpened&&now-lastOpened>=180&&paidSinceAd>=3&&!b.RemoveAds&&!b.Tutorial&&b.Parked&&b.ResultModal&&!b.RepairOpen&&b.Focused&&!b.ProviderBusy&&b.Consent&&b.Ready;
  }
  public void MarkOpened(double now){if(!Finite(now)||now<lastOpened)return;lastOpened=now;paidSinceAd=0;}
  // Voluntary fullscreen views also delay the next ad, while keeping paid work.
  public void DelayAfterRewarded(double now){if(Finite(now)&&now>=lastOpened)lastOpened=now;}
  static bool Finite(double value){return !double.IsNaN(value)&&!double.IsInfinity(value);}
 }
 public sealed class NativePresentationGate {
  object owner;public bool Busy=>owner!=null;
  public bool TryAcquire(object value){if(value==null||owner!=null)return false;owner=value;return true;}
  public bool Release(object value){if(owner==null||!ReferenceEquals(owner,value))return false;owner=null;return true;}
 }
}
