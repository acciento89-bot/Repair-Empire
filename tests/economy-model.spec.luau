return function()
	local model = require("../src/shared/balance/EconomyModel")
	local jobs = require("../src/shared/jobs/JobDefinitions")
	local tools = require("../src/shared/tools/ToolDefinitions")
	local vehicles = require("../src/shared/vehicles/VehicleDefinitions")
	local employees = require("../src/shared/company/EmployeeDefinitions")
	local company = require("../src/shared/config/CompanyConfig")
	local progression = require("../src/shared/config/ProgressionConfig")

	local totalXp = model.TotalXpToLevel(progression.MaxPlayerLevel, progression.XpForNextLevel)
	assert(totalXp == 344_296, "level-100 XP model changed; review pacing")

	local toolSpend = model.SumCatalogCosts(tools.List)
	local vehicleSpend = model.SumCatalogCosts(vehicles.List)
	local workshopSpend = model.SumWorkshopCosts(company.WorkshopUpgradeCosts)
	assert(toolSpend == 74_000, "tool sink total changed; review balance version")
	assert(vehicleSpend == 264_500, "vehicle sink total changed; review balance version")
	assert(workshopSpend == 166_000, "workshop sink total changed; review balance version")

	local fastestTool = model.FastestToolMultiplier(tools.List)
	local maxSlots = company.EmployeeSlotsByWorkshopTier[company.MaxWorkshopTier]
	local passivePerMinute = model.MaxPassiveRate(employees.List, maxSlots)
	local passiveOfflineCap = passivePerMinute * company.OfflinePassiveCapMinutes

	local bestSoloRate, bestSoloJob = model.BestSoloCashPerMinute(jobs.List, fastestTool, 45)
	assert(bestSoloJob ~= "", "economy model must identify a solo job")
	assert(passivePerMinute / bestSoloRate < 0.5, "maximum passive rate exceeds 50% of modeled late solo activity")
	assert(passiveOfflineCap < 200_000, "offline passive cap exceeds prelaunch guardrail")

	local earlyMultiplier = model.FastestToolMultiplierAtTier(tools.List, 1)
	local midMultiplier = model.FastestToolMultiplierAtTier(tools.List, 2)
	local lateMultiplier = model.FastestToolMultiplierAtTier(tools.List, 4)
	local earlyRate, earlyJob = model.BestEligibleSoloJob(jobs.List, 5, 1, { residential = true }, earlyMultiplier, 45)
	local midRate, midJob = model.BestEligibleSoloJob(jobs.List, 25, 2, { residential = true, downtown = true }, midMultiplier, 45)
	local lateRate, lateJob = model.BestEligibleSoloJob(jobs.List, 55, 4, { residential = true, downtown = true, industrial = true }, lateMultiplier, 45)
	assert(earlyJob ~= nil and earlyRate > 0, "early-game model has no viable solo job")
	assert(midJob ~= nil and midRate > earlyRate, "midgame active earning rate must improve over early game")
	assert(lateJob ~= nil and lateRate > midRate, "late-game active earning rate must improve over midgame")

	local maxSoloXp = model.MaxSoloXp(jobs.List)
	local optimisticJobsToLevel100 = math.ceil(totalXp / maxSoloXp)
	local companyPointTarget = progression.CompanyLevelThresholds[#progression.CompanyLevelThresholds]
	local lateCompanyPointsPerJob = math.max(1, math.floor(lateJob.BaseReward * 0.03))
	local optimisticJobsToCompany10 = math.ceil(companyPointTarget / lateCompanyPointsPerJob)
	assert(optimisticJobsToCompany10 <= optimisticJobsToLevel100, "company-level gate is modeled to block Prestige after player level 100")
end
