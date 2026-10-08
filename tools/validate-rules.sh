#!/bin/sh
set -eu
MONO_BIN='/Applications/Unity/Hub/Editor/6000.6.4f1/Unity.app/Contents/Resources/Scripting/MonoBleedingEdge/bin'
"$MONO_BIN/mcs" -define:REPAIR_RULE_EXE -out:/private/tmp/repair-rules.exe Assets/Scripts/Core/RepairProfile.cs Assets/Scripts/Core/RepairRules.cs Assets/Scripts/Core/RepairSave.cs Assets/Scripts/Gameplay/JobDefinition.cs Assets/Scripts/Gameplay/JobCatalog.cs Assets/Editor/Validation/RepairRuleChecks.cs
"$MONO_BIN/mono" /private/tmp/repair-rules.exe
