#if UNITY_EDITOR
using Kamilunavo.RepairEmpire.Validation;
using UnityEditor;
using UnityEngine;
public static class RepairValidation {
 [MenuItem("Kamilunavo/Validate Repair Empire Rules")]
 public static void Run(){Debug.Log("REPAIR_EDITOR_RULE_PASS "+RepairRuleChecks.Run());}
}
#endif
