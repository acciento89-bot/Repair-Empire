--!strict

local VALID_CATEGORIES = {
	plumbing = true,
	heating = true,
	climate = true,
	energy = true,
}

local VALID_DISTRICTS = {
	residential = true,
	downtown = true,
	industrial = true,
}

local JobValidator = {}

function JobValidator.Validate(definition): (boolean, string?)
	if type(definition.Id) ~= "string" or definition.Id == "" then
		return false, "missing_id"
	end
	if VALID_CATEGORIES[definition.Category] ~= true then
		return false, "invalid_category"
	end
	if VALID_DISTRICTS[definition.District] ~= true then
		return false, "invalid_district"
	end
	if type(definition.MinimumLevel) ~= "number" or definition.MinimumLevel < 1 then
		return false, "invalid_minimum_level"
	end
	if type(definition.MinimumCompanyLevel) ~= "number" or definition.MinimumCompanyLevel < 1 then
		return false, "invalid_minimum_company_level"
	end
	if type(definition.Weight) ~= "number" or definition.Weight <= 0 then
		return false, "invalid_weight"
	end
	if type(definition.ExpectedDurationSeconds) ~= "number" or definition.ExpectedDurationSeconds <= 0 then
		return false, "invalid_expected_duration"
	end
	if type(definition.CooldownSeconds) ~= "number" or definition.CooldownSeconds < 0 then
		return false, "invalid_cooldown"
	end
	if type(definition.BaseReward) ~= "number" or definition.BaseReward <= 0 then
		return false, "invalid_reward"
	end
	if type(definition.XP) ~= "number" or definition.XP <= 0 then
		return false, "invalid_xp"
	end
	if type(definition.RequiredToolTier) ~= "number" or definition.RequiredToolTier < 1 then
		return false, "invalid_tool_tier"
	end
	if type(definition.Stages) ~= "table" or #definition.Stages == 0 then
		return false, "missing_stages"
	end

	local stageIds = {}
	for _, stage in definition.Stages do
		if type(stage.Id) ~= "string" or stage.Id == "" or stageIds[stage.Id] then
			return false, "invalid_stage_id"
		end
		stageIds[stage.Id] = true
		if type(stage.Action) ~= "string" or stage.Action == "" then
			return false, "invalid_stage_action"
		end
		if type(stage.MinimumSeconds) ~= "number" or stage.MinimumSeconds < 0 then
			return false, "invalid_stage_timing"
		end
	end

	return true, nil
end

return JobValidator
