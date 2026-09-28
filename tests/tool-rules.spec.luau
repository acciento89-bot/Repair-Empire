return function()
	local rules = require("../src/shared/tools/ToolRules")

	assert(rules.GetEffectiveStageSeconds(4, 1) == 4, "base tool timing changed")
	assert(rules.GetEffectiveStageSeconds(4, 0.75) == 3, "speed multiplier must reduce stage time")

	local stage = rules.ToClientStage({ Id = "repair", Action = "replace", MinimumSeconds = 5 }, 0.8)
	assert(stage.Id == "repair", "stage id must be preserved")
	assert(stage.Action == "replace", "stage action must be preserved")
	assert(stage.MinimumSeconds == 4, "client stage must expose effective timing")
end
