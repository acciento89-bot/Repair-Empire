--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProgressionConfig = require(ReplicatedStorage.RepairEmpire.Shared.config.ProgressionConfig)

local ProgressionService = {
	Name = "ProgressionService",
	Dependencies = { "PlayerDataService", "AnalyticsService" },
}

function ProgressionService:Init() end
function ProgressionService:Start() end

function ProgressionService:AddXP(player: Player, amount: number)
	assert(amount > 0 and amount < 10_000_000, "Invalid XP amount")
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)

	profile.XP += math.floor(amount)
	while profile.Level < ProgressionConfig.MaxPlayerLevel do
		local needed = ProgressionConfig.XpForNextLevel(profile.Level)
		if profile.XP < needed then
			break
		end
		profile.XP -= needed
		profile.Level += 1
	end

	for districtId, requiredLevel in ProgressionConfig.DistrictUnlockLevels do
		if profile.Level >= requiredLevel and profile.UnlockedDistricts[districtId] ~= true then
			profile.UnlockedDistricts[districtId] = true
			if districtId == "downtown" then
				local analytics = require(script.Parent.AnalyticsService)
				analytics:LogOnce(player, "district_2_unlocked", 1)
			end
		end
	end

	dataService:Publish(player)
	return profile.Level
end

function ProgressionService:AddCompanyPoints(player: Player, amount: number)
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	profile.CompanyPoints += math.floor(amount)

	local newLevel = 1
	for index, threshold in ProgressionConfig.CompanyLevelThresholds do
		if profile.CompanyPoints >= threshold then
			newLevel = index
		end
	end
	profile.CompanyLevel = newLevel
	dataService:Publish(player)
	return newLevel
end

return ProgressionService
