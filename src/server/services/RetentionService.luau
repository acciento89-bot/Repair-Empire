--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.RepairEmpire.Shared
local JobDefinitions = require(Shared.jobs.JobDefinitions)
local RetentionConfig = require(Shared.retention.RetentionConfig)

local RetentionService = {
	Name = "RetentionService",
	Dependencies = { "PlayerDataService", "EconomyService", "ProgressionService" },
}

local function remote(name: string): RemoteFunction
	local instance = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild(name)
	assert(instance:IsA("RemoteFunction"), name .. " must be a RemoteFunction")
	return instance
end

local function eligibleDailyJobIds()
	local ids = {}
	for _, definition in JobDefinitions.List do
		if not definition.Coop then
			table.insert(ids, definition.Id)
		end
	end
	return ids
end

local DAILY_IDS = eligibleDailyJobIds()

function RetentionService:GetDailyJobIds(player: Player, dayNumber: number)
	local result = {}
	if #DAILY_IDS == 0 then
		return result
	end

	local seed = math.abs(player.UserId * 31 + dayNumber * 131)
	local used = {}
	for offset = 0, RetentionConfig.DailyJobCount - 1 do
		local index = ((seed + offset * 17) % #DAILY_IDS) + 1
		while used[index] do
			index = (index % #DAILY_IDS) + 1
		end
		used[index] = true
		table.insert(result, DAILY_IDS[index])
	end
	return result
end

function RetentionService:_EnsureDailyState(profile, dayNumber: number)
	if profile.Daily.ActiveJobDay ~= dayNumber then
		profile.Daily.ActiveJobDay = dayNumber
		profile.Daily.CompletedDailyJobs = {}
	end
end

function RetentionService:GetDailyJobs(player: Player)
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	local day = RetentionConfig.GetDayNumber()
	self:_EnsureDailyState(profile, day)

	local jobs = {}
	for _, jobId in self:GetDailyJobIds(player, day) do
		local definition = JobDefinitions.ById[jobId]
		table.insert(jobs, {
			Id = jobId,
			Category = definition.Category,
			District = definition.District,
			Completed = profile.Daily.CompletedDailyJobs[jobId] == true,
		})
	end

	return {
		ok = true,
		day = day,
		featuredCategory = RetentionConfig.GetFeaturedCategory(day),
		jobs = jobs,
	}
end

function RetentionService:OnJobCompleted(player: Player, definition)
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	local day = RetentionConfig.GetDayNumber()
	self:_EnsureDailyState(profile, day)

	local isDaily = false
	for _, jobId in self:GetDailyJobIds(player, day) do
		if jobId == definition.Id then
			isDaily = true
			break
		end
	end

	if isDaily and profile.Daily.CompletedDailyJobs[definition.Id] ~= true then
		profile.Daily.CompletedDailyJobs[definition.Id] = true
		local economy = require(script.Parent.EconomyService)
		local progression = require(script.Parent.ProgressionService)
		economy:Grant(player, "cash", RetentionConfig.DailyJobBonusCash, "daily_job:" .. definition.Id)
		progression:AddCompanyPoints(player, RetentionConfig.DailyJobBonusCompanyPoints)
	end

	self:RefreshAchievements(player)
end

function RetentionService:ClaimLoginReward(player: Player)
	local dataService = require(script.Parent.PlayerDataService)
	local economy = require(script.Parent.EconomyService)
	local profile = dataService:RequireProfile(player)
	local day = RetentionConfig.GetDayNumber()

	if profile.Daily.LastClaimDay == day then
		return { ok = false, error = "already_claimed" }
	end

	if profile.Daily.LastClaimDay == day - 1 then
		profile.Daily.ClaimStreak = math.min(profile.Daily.ClaimStreak + 1, #RetentionConfig.LoginRewards)
	else
		profile.Daily.ClaimStreak = 1
	end
	profile.Daily.LastClaimDay = day

	local reward = RetentionConfig.LoginRewards[profile.Daily.ClaimStreak]
	economy:Grant(player, "cash", reward, "daily_login")
	dataService:Publish(player)
	return { ok = true, streak = profile.Daily.ClaimStreak, reward = reward }
end

local function metricValue(profile, metric: string): number
	if metric == "JobsCompleted" then
		return profile.Stats.JobsCompleted
	elseif metric == "Level" then
		return profile.Level
	elseif metric == "CompanyLevel" then
		return profile.CompanyLevel
	elseif metric == "PrestigeLevel" then
		return profile.PrestigeLevel
	end
	return 0
end

function RetentionService:RefreshAchievements(player: Player)
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	for achievementId, definition in RetentionConfig.Achievements do
		if profile.Achievements[achievementId] == nil and metricValue(profile, definition.Metric) >= definition.Threshold then
			profile.Achievements[achievementId] = "unlocked"
		end
	end
	dataService:Publish(player)
end

function RetentionService:ClaimAchievement(player: Player, achievementId: any)
	if type(achievementId) ~= "string" then
		return { ok = false, error = "invalid_achievement" }
	end
	local definition = RetentionConfig.Achievements[achievementId]
	if definition == nil then
		return { ok = false, error = "invalid_achievement" }
	end

	self:RefreshAchievements(player)
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	if profile.Achievements[achievementId] ~= "unlocked" then
		return { ok = false, error = "not_claimable" }
	end

	profile.Achievements[achievementId] = "claimed"
	local economy = require(script.Parent.EconomyService)
	economy:Grant(player, "cash", definition.RewardCash, "achievement:" .. achievementId)
	dataService:Publish(player)
	return { ok = true, reward = definition.RewardCash }
end

function RetentionService:Init()
	remote("RequestDailyJobs").OnServerInvoke = function(player)
		return self:GetDailyJobs(player)
	end
	remote("ClaimDailyReward").OnServerInvoke = function(player)
		return self:ClaimLoginReward(player)
	end
	remote("ClaimAchievement").OnServerInvoke = function(player, achievementId)
		return self:ClaimAchievement(player, achievementId)
	end
end

function RetentionService:Start() end

return RetentionService
