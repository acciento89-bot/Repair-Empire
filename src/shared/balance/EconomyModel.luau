--!strict

local EconomyModel = {}

function EconomyModel.SumCatalogCosts(definitions): number
	local total = 0
	for _, definition in definitions do
		total += definition.Cost or 0
	end
	return total
end

function EconomyModel.SumWorkshopCosts(costs): number
	local total = 0
	for _, cost in costs do
		total += cost
	end
	return total
end

function EconomyModel.TotalXpToLevel(maxLevel: number, xpForNextLevel): number
	local total = 0
	for level = 1, maxLevel - 1 do
		total += xpForNextLevel(level)
	end
	return total
end

function EconomyModel.FastestToolMultiplier(toolDefinitions): number
	local fastest = math.huge
	for _, definition in toolDefinitions do
		fastest = math.min(fastest, definition.SpeedMultiplier)
	end
	return fastest
end

function EconomyModel.MaxPassiveRate(employeeDefinitions, slots: number): number
	local maxRate = 0
	for _, definition in employeeDefinitions do
		maxRate = math.max(maxRate, definition.CashPerMinute)
	end
	return maxRate * slots
end

function EconomyModel.StageSeconds(job, toolMultiplier: number): number
	local total = 0
	for _, stage in job.Stages do
		total += stage.MinimumSeconds * toolMultiplier
	end
	return total
end

function EconomyModel.BestSoloCashPerMinute(jobDefinitions, toolMultiplier: number, assumedTravelSeconds: number)
	local bestRate = 0
	local bestJobId = ""
	for _, job in jobDefinitions do
		if not job.Coop then
			local cycleSeconds = assumedTravelSeconds + EconomyModel.StageSeconds(job, toolMultiplier)
			local rate = job.BaseReward * 60 / cycleSeconds
			if rate > bestRate then
				bestRate = rate
				bestJobId = job.Id
			end
		end
	end
	return bestRate, bestJobId
end

function EconomyModel.FastestToolMultiplierAtTier(toolDefinitions, maxTier: number): number
	local fastest = math.huge
	for _, definition in toolDefinitions do
		if definition.Tier <= maxTier then
			fastest = math.min(fastest, definition.SpeedMultiplier)
		end
	end
	return fastest
end

function EconomyModel.BestEligibleSoloJob(
	jobDefinitions,
	level: number,
	maxToolTier: number,
	unlockedDistricts,
	toolMultiplier: number,
	assumedTravelSeconds: number
)
	local bestRate = 0
	local bestJob = nil
	for _, job in jobDefinitions do
		if not job.Coop and job.MinimumLevel <= level and job.RequiredToolTier <= maxToolTier and unlockedDistricts[job.District] == true then
			local cycleSeconds = assumedTravelSeconds + EconomyModel.StageSeconds(job, toolMultiplier)
			local rate = job.BaseReward * 60 / cycleSeconds
			if rate > bestRate then
				bestRate = rate
				bestJob = job
			end
		end
	end
	return bestRate, bestJob
end

function EconomyModel.FastestEligibleTool(toolDefinitions, level: number)
	local fastest = 1
	local maxTier = 1
	for _, definition in toolDefinitions do
		if definition.MinimumLevel <= level then
			fastest = math.min(fastest, definition.SpeedMultiplier)
			maxTier = math.max(maxTier, definition.Tier)
		end
	end
	return fastest, maxTier
end

function EconomyModel.UnlockedDistrictsForLevel(progressionConfig, level: number)
	local unlocked = {}
	for district, requiredLevel in progressionConfig.DistrictUnlockLevels do
		if level >= requiredLevel then
			unlocked[district] = true
		end
	end
	return unlocked
end

function EconomyModel.BestSoloXpPerMinute(
	jobDefinitions,
	level: number,
	maxToolTier: number,
	unlockedDistricts,
	toolMultiplier: number,
	assumedTravelSeconds: number
): number
	local bestRate = 0
	for _, job in jobDefinitions do
		if not job.Coop and job.MinimumLevel <= level and job.RequiredToolTier <= maxToolTier and unlockedDistricts[job.District] == true then
			local cycleSeconds = assumedTravelSeconds + EconomyModel.StageSeconds(job, toolMultiplier)
			bestRate = math.max(bestRate, job.XP * 60 / cycleSeconds)
		end
	end
	return bestRate
end

function EconomyModel.EstimateLevelingMinutes(maxLevel: number, jobDefinitions, toolDefinitions, progressionConfig, assumedTravelSeconds: number): number
	local totalMinutes = 0
	for level = 1, maxLevel - 1 do
		local toolMultiplier, maxTier = EconomyModel.FastestEligibleTool(toolDefinitions, level)
		local districts = EconomyModel.UnlockedDistrictsForLevel(progressionConfig, level)
		local xpPerMinute =
			EconomyModel.BestSoloXpPerMinute(jobDefinitions, level, maxTier, districts, toolMultiplier, assumedTravelSeconds)
		if xpPerMinute <= 0 then
			return math.huge
		end
		totalMinutes += progressionConfig.XpForNextLevel(level) / xpPerMinute
	end
	return totalMinutes
end

function EconomyModel.MaxSoloXp(jobDefinitions): number
	local maxXp = 0
	for _, job in jobDefinitions do
		if not job.Coop then
			maxXp = math.max(maxXp, job.XP)
		end
	end
	return maxXp
end

return EconomyModel
