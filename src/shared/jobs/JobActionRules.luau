--!strict

local JobActionRules = {}

export type Decision = {
	ok: boolean,
	error: string?,
}

function JobActionRules.Validate(params): Decision
	if params.active == nil or params.active.InstanceId ~= params.instanceId then
		return { ok = false, error = "stale_job" }
	end
	if params.wasCompleted == true then
		return { ok = false, error = "already_completed" }
	end
	if params.active.Completing == true then
		return { ok = false, error = "completion_in_progress" }
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
	if params.elapsed + 0.15 < params.effectiveSeconds then
		return { ok = false, error = "too_fast" }
	end
	return { ok = true }
end

return table.freeze(JobActionRules)
