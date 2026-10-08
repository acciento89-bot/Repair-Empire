#if UNITY_EDITOR
using Kamilunavo.RepairEmpire.Validation;
using UnityEditor;
using UnityEngine;
using UnityEngine.EventSystems;
using Kamilunavo.RepairEmpire.Input;
using Kamilunavo.RepairEmpire.Gameplay;
public static class RepairValidation {
 [MenuItem("Kamilunavo/Validate Repair Empire Rules")]
 public static void Run(){Debug.Log("REPAIR_EDITOR_RULE_PASS "+RepairRuleChecks.Run());Debug.Log("REPAIR_INTERACTION_EDITOR_PASS "+RepairInteractionChecks.Run());}
 public static void RunAndValidateInput(){Run();ValidateInput();}
 public static void ValidateInput(){
  var holdObject=new GameObject("RepairHoldFixture");var hold=holdObject.AddComponent<HoldButton>();
  try{hold.OnPointerDown(new PointerEventData(null));if(!hold.Held)throw new System.Exception("pointer down should hold");holdObject.SetActive(false);typeof(HoldButton).GetMethod("OnDisable",System.Reflection.BindingFlags.Instance|System.Reflection.BindingFlags.NonPublic)?.Invoke(hold,null);if(hold.Held)throw new System.Exception("REPAIR_INPUT_FAIL disabled button retains gas/steer");}finally{Object.DestroyImmediate(holdObject);}
  var car=new GameObject("RepairPauseFixture",typeof(Rigidbody),typeof(VehicleController));
  try{var motor=car.GetComponent<VehicleController>();motor.SendMessage("Awake");motor.InputEnabled=false;var body=car.GetComponent<Rigidbody>();body.linearVelocity=new Vector3(3,0,8);motor.SendMessage("FixedUpdate");if(body.linearVelocity.sqrMagnitude>.00001f)throw new System.Exception("REPAIR_INPUT_FAIL paused van keeps driving");}finally{Object.DestroyImmediate(car);}
  Debug.Log("REPAIR_INPUT_PASS held reset and stationary pause");
 }
 public static void ValidateRepairBoundary(){
  var root=new GameObject("RepairBoundaryFixture");root.SetActive(false);var game=root.AddComponent<RepairGame>();var car=new GameObject("BoundaryVan",typeof(Rigidbody),typeof(VehicleController));var motor=car.GetComponent<VehicleController>();motor.SendMessage("Awake");game.Vehicle=motor;game.Profile=new Kamilunavo.RepairEmpire.Core.RepairProfile();long ticket=Kamilunavo.RepairEmpire.Core.RepairRules.BeginJob(game.Profile,"faucet");
  try{car.transform.position=new Vector3(20,0,284);if(game.BeginRepair())throw new System.Exception("REPAIR_BOUNDARY_FAIL distant lateral repair");car.transform.position=new Vector3(5.5f,0,284);car.GetComponent<Rigidbody>().linearVelocity=Vector3.forward*5;if(game.BeginRepair())throw new System.Exception("REPAIR_BOUNDARY_FAIL moving repair");motor.ResetMotion();if(!game.BeginRepair()||!game.Paused)throw new System.Exception("REPAIR_BOUNDARY_FAIL stopped van repair modal");if(game.AdvanceRepair(2)||game.Profile.RepairPhase!=0||game.Profile.ActiveTicket!=ticket)throw new System.Exception("REPAIR_BOUNDARY_FAIL skipped phase");game.CloseRepair();if(game.Paused)throw new System.Exception("REPAIR_BOUNDARY_FAIL repair close keeps driving paused");Debug.Log("REPAIR_BOUNDARY_PASS lateral/speed/ordered stages/modal");}finally{Object.DestroyImmediate(root);Object.DestroyImmediate(car);}
 }
}
#endif
