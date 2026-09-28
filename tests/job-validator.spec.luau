return function()
	local validator = require("../src/shared/jobs/JobValidator")
	local jobs = require("../src/shared/jobs/JobDefinitions")

	for _, definition in jobs.List do
		local ok, reason = validator.Validate(definition)
		assert(ok, ("invalid launch job %s: %s"):format(definition.Id, tostring(reason)))
	end

	local broken = {
		Id = "broken",
		Category = "invalid",
		District = "residential",
		MinimumLevel = 1,
		BaseReward = 1,
		XP = 1,
		RequiredToolTier = 1,
		Stages = { { Id = "x", Action = "x", MinimumSeconds = 0 } },
	}
	local ok = validator.Validate(broken)
	assert(not ok, "validator must reject invalid category")
end
