namespace Kamilunavo.RepairEmpire.Gameplay {
 public static class JobCatalog {
  public static readonly JobDefinition[] All=Create();
  public static JobDefinition Find(string id){foreach(var j in All)if(j.Id==id)return j;return null;}
  static JobDefinition[] Create(){var list=new System.Collections.Generic.List<JobDefinition>();
   Add(list,"faucet","Leaking Faucet","Tropfender Wasserhahn",0,"Riverside Apartments",120,100,284,0,1);
   Add(list,"toilet","Running Toilet","Laufende Toilette",0,"Maple Court",150,120,330,0,2);
   Add(list,"switch","Broken Light Switch","Defekter Lichtschalter",1,"Office Tower",120,90,370,1,3);
   Add(list,"sink","Clogged Sink","Verstopftes Waschbecken",0,"Harbor Lofts",180,140,410,0,2);
   string[][] en={new[]{"Pipe Leak","Shower Valve","Kitchen Mixer"},new[]{"Tripped Breaker","Loose Outlet","Hall Lighting","Doorbell Wiring","Fuse Replacement"},new[]{"Cold Radiator","Thermostat Setup","Valve Replacement","Heating Pump","Boiler Service","System Flush"},new[]{"AC Filter","Fan Service","Drain Cleaning","Airflow Balance","Cooling Check","Climate Service"}};
   string[][] de={new[]{"Undichtes Rohr","Duschventil","Küchenarmatur"},new[]{"Ausgelöste Sicherung","Lockere Steckdose","Flurbeleuchtung","Klingelleitung","Sicherungswechsel"},new[]{"Kalter Heizkörper","Thermostat einstellen","Ventilwechsel","Heizungspumpe","Heizungswartung","Systemspülung"},new[]{"Klimafilter","Lüfterwartung","Ablauf reinigen","Luftstrom einstellen","Kühlung prüfen","Klimawartung"}};
   for(int c=0;c<4;c++)for(int i=0;i<en[c].Length;i++)Add(list,"call-"+c+"-"+i,en[c][i],de[c][i],c,new[]{"Garden Residence","Central Offices","Oak Street","City Suites","Park Apartments","Workshop Annex"}[i%6],180+40*i,120+20*i,65+55*i+(c%2)*20,c==0?0:c==1?1:2,c==0?2:c==1?3:4);
   return list.ToArray();
  }
  static void Add(System.Collections.Generic.List<JobDefinition> list,string id,string en,string de,int c,string address,int reward,int xp,float z,int tool,int level){var j=new JobDefinition(id,en,new[]{"Plumbing","Electrical","Heating","Climate"}[c],address,reward,xp,z,new[]{"Basic Wrench","Voltage Tester","Professional Kit"}[tool]);j.TitleDe=de;j.CategoryIndex=c;j.ToolTier=tool;j.MinimumLevel=level;j.DestinationX=(list.Count%2==0?5.5f:-5.5f);list.Add(j);}
 }
}
