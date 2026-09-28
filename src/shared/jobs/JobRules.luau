--!strict

local JobRules = {}

function JobRules.IsEligible(definition, profile): boolean
	if profile.Level < definition.MinimumLevel then
		return false
	end
	if profile.CompanyLevel < (definition.MinimumCompanyLevel or 1) then
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

function JobRules.WeightedSampleWithoutReplacement(definitions, count: number, nextNumber)
	local pool = {}
	for _, definition in definitions do
		table.insert(pool, definition)
	end

	local selected = {}
	while #selected < count and #pool > 0 do
		local totalWeight = 0
		for _, definition in pool do
			totalWeight += definition.Weight
		end
		if totalWeight <= 0 then
			break
		end

		local roll = math.clamp(nextNumber(), 0, 0.999999999) * totalWeight
		local cumulative = 0
		local selectedIndex = #pool
		for index, definition in pool do
			cumulative += definition.Weight
			if roll < cumulative then
				selectedIndex = index
				break
			end
		end

		table.insert(selected, table.remove(pool, selectedIndex))
	end

	return selected
end

return JobRules
