#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using UnityEngine;
using Kamilunavo.RepairEmpire.Gameplay;
using Kamilunavo.RepairEmpire.Visuals;

public static class RepairStreetLayoutValidation
{
 public static void Validate()
 {
  var state=new RepairStreetCompositionValidation.EnvironmentState();var root=new GameObject("Actual compact street layout fixture",typeof(CityBuilder));
  try
  {
   root.GetComponent<CityBuilder>().Build();var colliders=root.GetComponentsInChildren<BoxCollider>(true);int frontage=0;
   if(colliders.Length!=54)throw new InvalidOperationException("REPAIR_STREET_LAYOUT_COLLISION_COUNT "+colliders.Length);
   foreach(var collider in colliders)if(collider.name=="Modeled masonry building core"&&Mathf.Abs(collider.transform.position.x)<30)
   {
    float inner=Mathf.Abs(collider.transform.position.x)-collider.size.x*.5f;
    if(Mathf.Abs(inner-10)>.001f)throw new InvalidOperationException("REPAIR_STREET_LAYOUT_FRONTAGE_TOO_REMOTE inner="+inner+" wanted=10");frontage++;
   }
   if(frontage<10)throw new InvalidOperationException("REPAIR_STREET_LAYOUT_FRONTAGES_MISSING");
   Physics.SyncTransforms();int destinations=0;
   var board=root.GetComponent<CityBuilder>().Destination.Find("Customer address board");var plate=board.Find("Modeled customer sign").GetComponent<MeshRenderer>();var post=board.Find("Customer sign post").GetComponent<MeshRenderer>();int signPoses=0;
   // Static scene bounds are sampled once. Only the sign changes during the sweep.
   var renderers=root.GetComponentsInChildren<MeshRenderer>();var frontageProps=new List<(string name,Bounds bounds)>();var furniture=new List<(string name,Bounds bounds)>();var cars=new List<MeshRenderer>();
   foreach(var prop in renderers)
   {
    if(prop.name=="Shop canvas awning"||prop.name=="Awning hanging valance"||prop.name=="Urban shop sign backing"||prop.name=="Shop continuous cornice"||prop.name=="Shop cornice dentil"||prop.name=="Window projecting stone sill"||prop.name=="Recessed residential balcony"||prop.name=="Return elevation sash surrounds"||prop.name=="Lamp pole"||prop.name=="Lamp housing"||prop.name=="Curved street lamp arm")frontageProps.Add((prop.name,prop.bounds));
    if(prop.name=="Planter"||prop.name=="Street bench seat"||prop.name=="Street bench back"||prop.name=="Litter bin"||prop.name=="Kiosk enclosure")furniture.Add((prop.name,prop.bounds));
    if(prop.name=="Sculpted passenger body")cars.Add(prop);
   }
   foreach(var job in JobCatalog.All)
   {
    var van=new Bounds(new Vector3(job.DestinationX,.85f,job.DestinationZ),new Vector3(2.2f,1.8f,4.6f));
    foreach(var collider in colliders)if(collider.name!="Continuous driveable ground"&&collider.bounds.Intersects(van))throw new InvalidOperationException("REPAIR_STREET_LAYOUT_CUSTOMER_BLOCKED "+job.Id+" "+collider.name);
    destinations++;
    root.GetComponent<CityBuilder>().Destination.position=new Vector3(job.DestinationX,2,job.DestinationZ);board.localPosition=new Vector3(Mathf.Sign(job.DestinationX)*2.5f,board.localPosition.y,0);
    for(int heading=0;heading<360;heading+=5)
    {
     board.rotation=Quaternion.Euler(0,heading,0);
     var signBounds=plate.bounds;var postBounds=post.bounds;
     foreach(var prop in frontageProps)if(signBounds.Intersects(prop.bounds))throw new InvalidOperationException("REPAIR_STREET_CUSTOMER_SIGN_FRONTAGE_OVERLAP "+job.Id+" "+prop.name+" heading="+heading);
     foreach(var car in cars)if(car.bounds.Intersects(postBounds))throw new InvalidOperationException("REPAIR_STREET_CUSTOMER_POST_PARKED_OVERLAP "+job.Id);
     signPoses++;
    }
   }
   int parked=0;
   foreach(var body in cars)
   {
    foreach(var prop in furniture)if(body.bounds.Intersects(prop.bounds))throw new InvalidOperationException("REPAIR_STREET_PARKED_PROP_OVERLAP car="+body.transform.parent.position+" prop="+prop.name+" at="+prop.bounds.center);
    parked++;
   }
   if(parked!=13)throw new InvalidOperationException("REPAIR_STREET_PARKED_CAR_COUNT "+parked);
   Debug.Log("REPAIR_STREET_LAYOUT_PASS actual compact frontages="+frontage+"; all"+destinations+" original customer parking volumes clear;54 collision volumes retained;13parked bodies clear of modeled pavement furniture;customer signs clear of actual projecting shop geometry poses="+signPoses);
  }
  finally{state.Restore();UnityEngine.Object.DestroyImmediate(root);}
  ValidateParkedCar();
 }
 static void ValidateParkedCar()
 {
  var root=new GameObject("Original passenger car geometry fixture");var material=new Material(Resources.Load<Material>("Materials/Surface"));ArtLifetime.Own(root,material);
  try
  {
   ParkedVehicleArt.Build(root.transform,material,material,material,material,material,material,material);int vertices=0,wheels=0;
   foreach(var filter in root.GetComponentsInChildren<MeshFilter>()){vertices+=filter.sharedMesh.vertexCount;foreach(var normal in filter.sharedMesh.normals)if(!float.IsFinite(normal.x)||!float.IsFinite(normal.y)||!float.IsFinite(normal.z)||normal.sqrMagnitude<.5f)throw new InvalidOperationException("REPAIR_PASSENGER_CAR_NORMAL "+filter.name);}
   foreach(var t in root.GetComponentsInChildren<Transform>())if(t.name=="Parked road wheel")wheels++;
   if(wheels!=4||vertices>6000||root.GetComponentsInChildren<Collider>().Length!=0)throw new InvalidOperationException("REPAIR_PASSENGER_CAR_BUDGET vertices="+vertices+" wheels="+wheels);
   Debug.Log("REPAIR_PASSENGER_CAR_PASS original curved body, glazing, fitted roof/pillars and4road wheels vertices="+vertices);
  }
  finally{UnityEngine.Object.DestroyImmediate(root);}
  if(material!=null)throw new InvalidOperationException("REPAIR_PASSENGER_CAR_OWNED_MATERIAL_LEAK");
 }
}
#endif
