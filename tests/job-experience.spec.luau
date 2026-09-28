return function()
	local jobs = require("../src/shared/jobs/JobDefinitions")

	assert(#jobs.List >= 30, "launch job catalog unexpectedly shrank")

	local categories = {}
	local districts = {}
	local early = false
	local mid = false
	local late = false

	for _, job in jobs.List do
		assert(type(job.Id) == "string" and #job.Id > 0, "job needs a stable id")
		assert(type(job.Category) == "string" and #job.Category > 0, job.Id .. " missing category")
		assert(type(job.District) == "string" and #job.District > 0, job.Id .. " missing district")
		assert(job.BaseReward > 0, job.Id .. " must reward cash")
		assert(job.XP > 0, job.Id .. " must reward XP")
		assert(job.RequiredToolTier >= 1, job.Id .. " must require a valid tool tier")
		assert(#job.Stages >= 2, job.Id .. " must have a meaningful multi-step repair")

		categories[job.Category] = true
		districts[job.District] = true
		early = early or job.MinimumLevel <= 5
		mid = mid or (job.MinimumLevel >= 18 and job.MinimumLevel <= 30)
		late = late or job.MinimumLevel >= 40

		local ids = {}
		local duration = 0
		for _, stage in job.Stages do
			assert(type(stage.Id) == "string" and #stage.Id > 0, job.Id .. " has an unnamed stage")
			assert(type(stage.Action) == "string" and #stage.Action > 0, job.Id .. " has an unnamed action")
			assert(ids[stage.Id] == nil, job.Id .. " repeats stage id " .. stage.Id)
			assert(stage.MinimumSeconds > 0, job.Id .. " has a zero-duration stage")
			ids[stage.Id] = true
			duration += stage.MinimumSeconds
		end
		assert(duration == job.ExpectedDurationSeconds, job.Id .. " duration summary drifted from stages")
	end

	for _, category in { "plumbing", "heating", "climate", "energy" } do
		assert(categories[category] == true, "missing launch trade " .. category)
	end
	for _, district in { "residential", "downtown", "industrial" } do
		assert(districts[district] == true, "missing launch district " .. district)
	end
	assert(early and mid and late, "catalog must cover early, mid and late progression")
end
