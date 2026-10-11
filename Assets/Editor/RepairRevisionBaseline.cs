#if UNITY_EDITOR
using System;
using UnityEngine;
public static class RepairRevisionBaseline
{
 public static void Validate(){int failures=0;try{RepairCityVisualValidation.CaptureBaselineAndValidate();}catch(Exception e){failures++;Debug.Log("BASELINE_CITY_FAILURE "+e.Message);}try{RepairHudRegression.Validate();}catch(Exception e){failures++;Debug.Log("BASELINE_HUD_FAILURE "+e.Message);}if(failures>0)throw new InvalidOperationException("Repair revision failing contracts="+failures);}
}
#endif
