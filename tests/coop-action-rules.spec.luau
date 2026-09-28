return function()
	local rules = require("../src/shared/coop/CoopActionRules")

	local contract = {
		Participants = { [1] = true, [2] = true },
		Completing = false,
		Acting = false,
		DepartedContribution = { [2] = 3 },
	}
	local definition = { RequiredToolTier = 2 }
	local stage = { Action = "repair" }

	local function decide(overrides)
		local params = {
			contract = contract,
			userId = 1,
			definition = definition,
			stage = stage,
			action = "repair",
			isNear = true,
			toolTier = 2,
			elapsed = 4,
			effectiveSeconds = 4,
		}
		for key, value in overrides or {} do
			params[key] = value
		end
		return rules.Validate(params)
	end

	assert(decide().ok, "valid co-op action must pass")
	assert(decide({ userId = 99 }).error == "not_in_contract", "non-member action must reject")
	assert(decide({ action = "skip" }).error == "wrong_action", "out-of-order action must reject")
	assert(decide({ isNear = false }).error == "too_far_from_job", "position spoof must reject")
	assert(decide({ toolTier = 1 }).error == "tool_tier_locked", "under-tier tool must reject")
	assert(decide({ elapsed = 3.84 }).error == "too_fast", "latency/replay cannot bypass server timing")
	assert(decide({ elapsed = 3.85 }).ok, "timing tolerance boundary changed")

	local racing = {
		Participants = { [1] = true },
		Completing = false,
		Acting = true,
	}
	assert(decide({ contract = racing }).error == "action_in_progress", "parallel stage request must reject")

	local completing = {
		Participants = { [1] = true },
		Completing = true,
		Acting = false,
	}
	assert(decide({ contract = completing }).error == "contract_unavailable", "completion replay must reject")

	assert(rules.RestoreContribution(contract, 2) == 3, "rejoining player contribution must restore")
	assert(rules.RestoreContribution(contract, 2) == 0, "restored contribution must be consumed once")
end
