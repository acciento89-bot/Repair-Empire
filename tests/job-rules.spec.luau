return function()
	local rules = require("../src/shared/jobs/JobRules")
	local definition = {
		MinimumLevel = 10,
		MinimumCompanyLevel = 2,
		District = "downtown",
		Weight = 10,
		Stages = {
			{ Id = "a" },
			{ Id = "b" },
		},
	}
	local lockedByLevel = {
		Level = 9,
		CompanyLevel = 2,
		UnlockedDistricts = { downtown = true },
	}
	local lockedByCompany = {
		Level = 10,
		CompanyLevel = 1,
		UnlockedDistricts = { downtown = true },
	}
	local eligible = {
		Level = 10,
		CompanyLevel = 2,
		UnlockedDistricts = { downtown = true },
	}
	assert(not rules.IsEligible(definition, lockedByLevel), "under-level profile must be ineligible")
	assert(not rules.IsEligible(definition, lockedByCompany), "under-company-level profile must be ineligible")
	assert(rules.IsEligible(definition, eligible), "eligible profile was rejected")
	assert(rules.GetStage(definition, 2).Id == "b", "wrong job stage returned")
	assert(rules.IsComplete(definition, 3), "stage index after final stage must be complete")

	local weighted = {
		{ Id = "heavy", Weight = 90 },
		{ Id = "light", Weight = 10 },
	}
	local pickedLow = rules.WeightedSampleWithoutReplacement(weighted, 1, function()
		return 0
	end)
	assert(pickedLow[1].Id == "heavy", "low weighted roll should select first heavy item")

	local pickedHigh = rules.WeightedSampleWithoutReplacement(weighted, 1, function()
		return 0.95
	end)
	assert(pickedHigh[1].Id == "light", "high weighted roll should reach later weighted item")

	local both = rules.WeightedSampleWithoutReplacement(weighted, 2, function()
		return 0
	end)
	assert(#both == 2 and both[1].Id ~= both[2].Id, "weighted sample must not repeat items")
end
