return function()
	local rules = require("../src/shared/jobs/JobRules")
	local definition = {
		MinimumLevel = 10,
		District = "downtown",
		Stages = {
			{ Id = "a" },
			{ Id = "b" },
		},
	}
	local locked = {
		Level = 9,
		UnlockedDistricts = { downtown = true },
	}
	local eligible = {
		Level = 10,
		UnlockedDistricts = { downtown = true },
	}
	assert(not rules.IsEligible(definition, locked), "under-level profile must be ineligible")
	assert(rules.IsEligible(definition, eligible), "eligible profile was rejected")
	assert(rules.GetStage(definition, 2).Id == "b", "wrong job stage returned")
	assert(rules.IsComplete(definition, 3), "stage index after final stage must be complete")
end
