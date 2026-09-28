--!strict

local ToolRules = {}

function ToolRules.GetEffectiveStageSeconds(baseSeconds: number, speedMultiplier: number): number
	assert(baseSeconds >= 0, "baseSeconds must be non-negative")
	assert(speedMultiplier > 0, "speedMultiplier must be positive")
	return math.max(0, baseSeconds * speedMultiplier)
end

function ToolRules.ToClientStage(stage, speedMultiplier: number)
	return {
		Id = stage.Id,
		Action = stage.Action,
		MinimumSeconds = ToolRules.GetEffectiveStageSeconds(stage.MinimumSeconds, speedMultiplier),
	}
end

return ToolRules
