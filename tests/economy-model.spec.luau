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
end
