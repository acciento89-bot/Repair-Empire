--!strict

local CoopActionRules = {}

function CoopActionRules.Validate(params)
	local contract = params.contract
	if contract == nil or contract.Completing == true then
		return { ok = false, error = "contract_unavailable" }
	end
	if contract.Acting == true then
		return { ok = false, error = "action_in_progress" }
	end
	if contract.Participants[params.userId] ~= true then
		return { ok = false, error = "not_in_contract" }
	end
	if params.definition == nil or params.stage == nil then
		return { ok = false, error = "invalid_server_state" }
	end
	if params.action ~= params.stage.Action then
		return { ok = false, error = "wrong_action" }
	end
	if params.isNear ~= true then
		return { ok = false, error = "too_far_from_job" }
	end
	if params.toolTier < params.definition.RequiredToolTier then
		return { ok = false, error = "tool_tier_locked" }
	end
	if params.elapsed + 0.15 < params.effectiveSeconds then
		return { ok = false, error = "too_fast" }
	end
	return { ok = true }
end

function CoopActionRules.RestoreContribution(contract, userId: number): number
	local departed = contract.DepartedContribution
	if departed == nil then
		return 0
	end
	local amount = departed[userId] or 0
	departed[userId] = nil
	return amount
end

return table.freeze(CoopActionRules)
