--!strict

local JobRules = {}

function JobRules.IsEligible(definition, profile): boolean
	if profile.Level < definition.MinimumLevel then
		return false
	end
	if profile.UnlockedDistricts[definition.District] ~= true then
		return false
	end
	return true
end

function JobRules.GetStage(definition, stageIndex: number)
	return definition.Stages[stageIndex]
end

function JobRules.IsComplete(definition, stageIndex: number): boolean
	return stageIndex > #definition.Stages
end

return JobRules
