local model = require("../src/shared/balance/EconomyModel")
local jobs = require("../src/shared/jobs/JobDefinitions")
local tools = require("../src/shared/tools/ToolDefinitions")
local vehicles = require("../src/shared/vehicles/VehicleDefinitions")
local employees = require("../src/shared/company/EmployeeDefinitions")
local company = require("../src/shared/config/CompanyConfig")
local progression = require("../src/shared/config/ProgressionConfig")
local balance = require("../src/shared/config/BalanceConfig")

local totalXp = model.TotalXpToLevel(progression.MaxPlayerLevel, progression.XpForNextLevel)
local toolSpend = model.SumCatalogCosts(tools.List)
local vehicleSpend = model.SumCatalogCosts(vehicles.List)
local workshopSpend = model.SumWorkshopCosts(company.WorkshopUpgradeCosts)
local fastestTool = model.FastestToolMultiplier(tools.List)
local maxSlots = company.EmployeeSlotsByWorkshopTier[company.MaxWorkshopTier]
local passivePerMinute = model.MaxPassiveRate(employees.List, maxSlots)
local passiveOfflineCap = passivePerMinute * company.OfflinePassiveCapMinutes
local bestSoloRate, bestSoloJob = model.BestSoloCashPerMinute(jobs.List, fastestTool, 45)

print(("Repair Empire prelaunch economy report [%s]"):format(balance.Version))
print(("XP to level %d: %d"):format(progression.MaxPlayerLevel, totalXp))
print(("Tool catalog sink: $%d"):format(toolSpend))
print(("Vehicle catalog sink: $%d"):format(vehicleSpend))
print(("Workshop sink: $%d"):format(workshopSpend))
print(("Hard progression sink subtotal: $%d"):format(toolSpend + vehicleSpend + workshopSpend))
print(("Fastest tool timing multiplier: %.2f"):format(fastestTool))
print(("Modeled best solo job @45s travel: %s ($%.0f/min)"):format(bestSoloJob, bestSoloRate))
print(("Maximum employee passive rate: $%d/min"):format(passivePerMinute))
print(("Maximum %d-minute offline passive cap: $%d"):format(company.OfflinePassiveCapMinutes, passiveOfflineCap))
print(("Passive/active modeled rate ratio: %.1f%%"):format((passivePerMinute / bestSoloRate) * 100))

local bands = {
	{ Name = "early", Level = 5, ToolTier = 1, Districts = { residential = true } },
	{ Name = "mid", Level = 25, ToolTier = 2, Districts = { residential = true, downtown = true } },
	{ Name = "late", Level = 55, ToolTier = 4, Districts = { residential = true, downtown = true, industrial = true } },
}

local lateJob
for _, band in bands do
	local multiplier = model.FastestToolMultiplierAtTier(tools.List, band.ToolTier)
	local rate, job = model.BestEligibleSoloJob(jobs.List, band.Level, band.ToolTier, band.Districts, multiplier, 45)
	print(("%s band (Lv%d/T%d): %s at $%.0f/min"):format(band.Name, band.Level, band.ToolTier, job and job.Id or "none", rate))
	if band.Name == "late" then
		lateJob = job
	end
end

local maxSoloXp = model.MaxSoloXp(jobs.List)
local optimisticJobsToLevel100 = math.ceil(totalXp / maxSoloXp)
local companyPointTarget = progression.CompanyLevelThresholds[#progression.CompanyLevelThresholds]
local lateCompanyPointsPerJob = lateJob and math.max(1, math.floor(lateJob.BaseReward * 0.03)) or 1
local optimisticJobsToCompany10 = math.ceil(companyPointTarget / lateCompanyPointsPerJob)
print(("Optimistic lower-bound solo jobs to level 100: %d"):format(optimisticJobsToLevel100))
print(("Late-job equivalent jobs to company level 10: %d"):format(optimisticJobsToCompany10))
