#if UNITY_EDITOR
using Kamilunavo.RepairEmpire.Validation;
using UnityEditor;
using UnityEngine;
using UnityEngine.EventSystems;
using Kamilunavo.RepairEmpire.Input;
using Kamilunavo.RepairEmpire.Gameplay;
public static class RepairValidation {
 [MenuItem("Kamilunavo/Validate Repair Empire Rules")]
 public static void Run(){Debug.Log("REPAIR_EDITOR_RULE_PASS "+RepairRuleChecks.Run());}
 public static void RunAndValidateInput(){Run();ValidateInput();}
 public static void ValidateInput(){
  var holdObject=new GameObject("RepairHoldFixture");var hold=holdObject.AddComponent<HoldButton>();
  try{hold.OnPointerDown(new PointerEventData(null));if(!hold.Held)throw new System.Exception("pointer down should hold");holdObject.SetActive(false);if(hold.Held)throw new System.Exception("REPAIR_INPUT_FAIL disabled button retains gas/steer");}finally{Object.DestroyImmediate(holdObject);}
  var car=new GameObject("RepairPauseFixture",typeof(Rigidbody),typeof(VehicleController));
  try{var motor=car.GetComponent<VehicleController>();motor.SendMessage("Awake");motor.InputEnabled=false;var body=car.GetComponent<Rigidbody>();body.linearVelocity=new Vector3(3,0,8);motor.SendMessage("FixedUpdate");if(body.linearVelocity.sqrMagnitude>.00001f)throw new System.Exception("REPAIR_INPUT_FAIL paused van keeps driving");}finally{Object.DestroyImmediate(car);}
  Debug.Log("REPAIR_INPUT_PASS held reset and stationary pause");
 }
}
#endif
