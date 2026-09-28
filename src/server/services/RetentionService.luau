--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.RepairEmpire.Shared
local JobDefinitions = require(Shared.jobs.JobDefinitions)
local RetentionConfig = require(Shared.retention.RetentionConfig)
local PlaytimeRewards = require(Shared.retention.PlaytimeRewards)
local MutationGuard = require(script.Parent.Parent.security.MutationGuard)

local RetentionService = {
	Name = "RetentionService",
	Dependencies = { "PlayerDataService", "EconomyService", "ProgressionService", "SecurityService" },
}

local function remote(name: string): RemoteFunction
	local instance = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild(name)
	assert(instance:IsA("RemoteFunction"), name .. " must be a RemoteFunction")
	return instance
end

local function stateEvent(): RemoteEvent
	local instance = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild("StateUpdated")
	assert(instance:IsA("RemoteEvent"), "StateUpdated must be a RemoteEvent")
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
	profile.Daily.PlaytimeClaims = profile.Daily.PlaytimeClaims or {}
end

function RetentionService:GetDailyJobs(player: Player)
	local security = require(script.Parent.SecurityService)
	if not security:Allow(player, "RequestDailyJobs") then
		return { ok = false, error = "rate_limited" }
	end
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
			RewardCash = RetentionConfig.DailyJobBonusCash,
			RewardCompanyPoints = RetentionConfig.DailyJobBonusCompanyPoints,
		})
	end

	return {
		ok = true,
		day = day,
		featuredCategory = RetentionConfig.GetFeaturedCategory(day),
		jobs = jobs,
	}
end

function RetentionService:GetRetentionStatus(player: Player)
	local security = require(script.Parent.SecurityService)
	if not security:Allow(player, "RequestRetentionStatus") then
		return { ok = false, error = "rate_limited" }
	end

	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	local day = RetentionConfig.GetDayNumber()
	self:_EnsureDailyState(profile, day)

	local claimedToday = profile.Daily.LastClaimDay == day
	local previewStreak
	if claimedToday then
		previewStreak = profile.Daily.ClaimStreak
	elseif profile.Daily.LastClaimDay == day - 1 then
		previewStreak = math.min(profile.Daily.ClaimStreak + 1, #RetentionConfig.LoginRewards)
	else
		previewStreak = 1
	end

	local playTimeSeconds = dataService:GetCurrentPlayTime(player)
	local milestones = {}
	for index, reward in PlaytimeRewards.Milestones do
		local claimed = profile.Daily.PlaytimeClaims[tostring(index)] == true
		table.insert(milestones, {
			Index = index,
			Seconds = reward.Seconds,
			Cash = reward.Cash,
			Claimed = claimed,
			Ready = not claimed and playTimeSeconds >= reward.Seconds,
			RemainingSeconds = math.max(0, reward.Seconds - playTimeSeconds),
		})
	end

	return {
		ok = true,
		login = {
			ClaimedToday = claimedToday,
			Streak = profile.Daily.ClaimStreak,
			PreviewStreak = previewStreak,
			Reward = RetentionConfig.LoginRewards[previewStreak],
		},
		playTimeSeconds = playTimeSeconds,
		playtimeRewards = milestones,
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
		stateEvent():FireClient(player, {
			kind = "daily_job_completed",
			jobId = definition.Id,
			reward = RetentionConfig.DailyJobBonusCash,
			companyPoints = RetentionConfig.DailyJobBonusCompanyPoints,
		})
	end

	self:RefreshAchievements(player)
end

function RetentionService:ClaimLoginReward(player: Player)
	local security = require(script.Parent.SecurityService)
	if not security:Allow(player, "ClaimDailyReward") then
		return { ok = false, error = "rate_limited" }
	end

	local entered, result = MutationGuard.TryRun(player.UserId, "profile_value_mutation", function()
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
	end)
	if not entered then
		return { ok = false, error = "mutation_in_progress" }
	end
	if result and result.ok then
		stateEvent():FireClient(player, {
			kind = "daily_reward",
			reward = result.reward,
			streak = result.streak,
		})
	end
	return result
end

function RetentionService:ClaimPlaytimeReward(player: Player, rewardIndex: any)
	local security = require(script.Parent.SecurityService)
	if not security:Allow(player, "ClaimPlaytimeReward") then
		return { ok = false, error = "rate_limited" }
	end
	if type(rewardIndex) ~= "number" or rewardIndex % 1 ~= 0 then
		return { ok = false, error = "invalid_reward" }
	end

	local definition = PlaytimeRewards.Milestones[rewardIndex]
	if definition == nil then
		return { ok = false, error = "invalid_reward" }
	end

	local entered, result = MutationGuard.TryRun(player.UserId, "profile_value_mutation", function()
		local dataService = require(script.Parent.PlayerDataService)
		local economy = require(script.Parent.EconomyService)
		local profile = dataService:RequireProfile(player)
		profile.Daily.PlaytimeClaims = profile.Daily.PlaytimeClaims or {}

		local key = tostring(rewardIndex)
		if profile.Daily.PlaytimeClaims[key] == true then
			return { ok = false, error = "already_claimed" }
		end

		local playTimeSeconds = dataService:GetCurrentPlayTime(player)
		if playTimeSeconds < definition.Seconds then
			return {
				ok = false,
				error = "not_ready",
				remainingSeconds = definition.Seconds - playTimeSeconds,
			}
		end

		profile.Daily.PlaytimeClaims[key] = true
		economy:Grant(player, "cash", definition.Cash, "playtime_reward:" .. key)
		dataService:Publish(player)
		return {
			ok = true,
			index = rewardIndex,
			reward = definition.Cash,
			playTimeSeconds = playTimeSeconds,
		}
	end)
	if not entered then
		return { ok = false, error = "mutation_in_progress" }
	end
	if result and result.ok then
		stateEvent():FireClient(player, {
			kind = "playtime_reward",
			reward = result.reward,
			index = result.index,
		})
	end
	return result
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
	local security = require(script.Parent.SecurityService)
	if not security:Allow(player, "ClaimAchievement") then
		return { ok = false, error = "rate_limited" }
	end
	if type(achievementId) ~= "string" then
		return { ok = false, error = "invalid_achievement" }
	end
	local definition = RetentionConfig.Achievements[achievementId]
	if definition == nil then
		return { ok = false, error = "invalid_achievement" }
	end

	local entered, result = MutationGuard.TryRun(player.UserId, "profile_value_mutation", function()
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
		return { ok = true, reward = definition.RewardCash, achievementId = achievementId }
	end)
	if not entered then
		return { ok = false, error = "mutation_in_progress" }
	end
	if result and result.ok then
		stateEvent():FireClient(player, {
			kind = "achievement_claimed",
			reward = result.reward,
			achievementId = result.achievementId,
		})
	end
	return result
end

function RetentionService:Init()
	remote("RequestDailyJobs").OnServerInvoke = function(player)
		return self:GetDailyJobs(player)
	end
	remote("RequestRetentionStatus").OnServerInvoke = function(player)
		return self:GetRetentionStatus(player)
	end
	remote("ClaimDailyReward").OnServerInvoke = function(player)
		return self:ClaimLoginReward(player)
	end
	remote("ClaimPlaytimeReward").OnServerInvoke = function(player, rewardIndex)
		return self:ClaimPlaytimeReward(player, rewardIndex)
	end
	remote("ClaimAchievement").OnServerInvoke = function(player, achievementId)
		return self:ClaimAchievement(player, achievementId)
	end
end

function RetentionService:Start() end

return RetentionService
