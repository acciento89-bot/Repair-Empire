return function()
	local jobs = require("../src/shared/jobs/JobDefinitions")
	local tools = require("../src/shared/tools/ToolDefinitions")
	local progression = require("../src/shared/config/ProgressionConfig")

	local firstJob = jobs.ById.leaking_faucet
	local secondJob = jobs.ById.running_toilet
	local firstUpgrade = tools.ById.basic_screwdriver

	assert(firstJob.MinimumLevel == 1, "first tutorial job must be available at level 1")
	assert(firstJob.XP >= progression.XpForNextLevel(1), "first tutorial job must reach level 2")
	assert(firstUpgrade.MinimumLevel <= 2, "first tutorial upgrade must be level-accessible")
	assert(firstUpgrade.Cost <= firstJob.BaseReward, "first tutorial job must fund the first upgrade")
	assert(firstUpgrade.SpeedMultiplier < 1, "first tutorial upgrade must provide a meaningful benefit")
	assert(secondJob.MinimumLevel <= 2, "second tutorial job must be available after the first job")
	assert(secondJob.Id ~= firstJob.Id, "second tutorial job must introduce different content")
end
