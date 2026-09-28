return function()
	local rules = require("../src/shared/jobs/JobActionRules")
	local active = {
		InstanceId = "job-a",
		Completing = false,
	}
	local definition = { Id = "leaking_faucet" }
	local stage = { Action = "tighten" }

	local function decide(overrides)
		local params = {
			active = active,
			instanceId = "job-a",
			wasCompleted = false,
			definition = definition,
			stage = stage,
			action = "tighten",
			isNear = true,
			elapsed = 2,
			effectiveSeconds = 2,
		}
		for key, value in overrides or {} do
			params[key] = value
		end
		return rules.Validate(params)
	end

	assert(decide().ok, "valid action must pass")
	local missingActive = rules.Validate({
		active = nil,
		instanceId = "job-a",
		wasCompleted = false,
		definition = definition,
		stage = stage,
		action = "tighten",
		isNear = true,
		elapsed = 2,
		effectiveSeconds = 2,
	})
	assert(missingActive.error == "stale_job", "missing active job must reject")
	assert(decide({ instanceId = "job-b" }).error == "stale_job", "foreign/stale instance must reject")
	assert(decide({ wasCompleted = true }).error == "already_completed", "replayed completion must reject")

	local completing = {
		InstanceId = "job-a",
		Completing = true,
	}
	assert(decide({ active = completing }).error == "completion_in_progress", "concurrent finalization must reject")
	local missingDefinition = rules.Validate({
		active = active,
		instanceId = "job-a",
		wasCompleted = false,
		definition = nil,
		stage = stage,
		action = "tighten",
		isNear = true,
		elapsed = 2,
		effectiveSeconds = 2,
	})
	assert(missingDefinition.error == "invalid_server_state", "missing definition must fail closed")
	local missingStage = rules.Validate({
		active = active,
		instanceId = "job-a",
		wasCompleted = false,
		definition = definition,
		stage = nil,
		action = "tighten",
		isNear = true,
		elapsed = 2,
		effectiveSeconds = 2,
	})
	assert(missingStage.error == "invalid_server_state", "missing stage must fail closed")
	assert(decide({ action = "remove" }).error == "wrong_action", "out-of-order action must reject")
	assert(decide({ isNear = false }).error == "too_far_from_job", "position spoof must reject")
	assert(decide({ elapsed = 1.84 }).error == "too_fast", "too-early request must reject")
	assert(decide({ elapsed = 1.85 }).ok, "configured timing tolerance boundary must pass")
end
