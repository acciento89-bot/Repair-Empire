--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Shared = ReplicatedStorage.RepairEmpire.Shared
local JobDefinitions = require(Shared.jobs.JobDefinitions)
local JobRules = require(Shared.jobs.JobRules)
local ToolRules = require(Shared.tools.ToolRules)

local OFFER_COUNT = 4
local OFFER_TTL_SECONDS = 120
local COMPLETION_MEMORY_SECONDS = 300

local JobService = {
	Name = "JobService",
	Dependencies = {
		"PlayerDataService",
		"EconomyService",
		"ProgressionService",
		"ToolService",
		"WorldService",
		"EntitlementService",
		"PrestigeService",
		"RetentionService",
		"SecurityService",
		"AnalyticsService",
	},
	_offers = {},
	_active = {},
	_completed = {},
}

local function getRemoteFunction(name: string): RemoteFunction
	local root = ReplicatedStorage:WaitForChild("RepairEmpireRemotes")
	local remote = root:WaitForChild(name)
	assert(remote:IsA("RemoteFunction"), name .. " must be a RemoteFunction")
	return remote
end

local function getStateEvent(): RemoteEvent
	local root = ReplicatedStorage:WaitForChild("RepairEmpireRemotes")
	local remote = root:WaitForChild("StateUpdated")
	assert(remote:IsA("RemoteEvent"), "StateUpdated must be a RemoteEvent")
	return remote
end

local function safeDefinition(definition)
	return {
		Id = definition.Id,
		Category = definition.Category,
		District = definition.District,
		MinimumLevel = definition.MinimumLevel,
		BaseReward = definition.BaseReward,
		XP = definition.XP,
		RequiredToolTier = definition.RequiredToolTier,
		StageCount = #definition.Stages,
		Coop = definition.Coop,
	}
end

function JobService:_Allow(player: Player, remoteName: string): boolean
	local security = require(script.Parent.SecurityService)
	return security:Allow(player, remoteName)
end

function JobService:_CleanupCompletions(userId: number)
	local completions = self._completed[userId]
	if completions == nil then
		return
	end
	local now = os.clock()
	for instanceId, completedAt in completions do
		if now - completedAt > COMPLETION_MEMORY_SECONDS then
			completions[instanceId] = nil
		end
	end
end

function JobService:GetOffers(player: Player)
	if not self:_Allow(player, "RequestJobOffers") then
		return { ok = false, error = "rate_limited" }
	end

	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	local eligible = {}
	local toolService = require(script.Parent.ToolService)
	local equippedToolTier = toolService:GetEquippedTier(player)
	for _, definition in JobDefinitions.List do
		if JobRules.IsEligible(definition, profile) and definition.RequiredToolTier <= equippedToolTier and not definition.Coop then
			table.insert(eligible, definition)
		end
	end

	local random = Random.new()
	for index = #eligible, 2, -1 do
		local swap = random:NextInteger(1, index)
		eligible[index], eligible[swap] = eligible[swap], eligible[index]
	end

	local offers = {}
	local response = {}
	for index = 1, math.min(OFFER_COUNT, #eligible) do
		local definition = eligible[index]
		local offerId = HttpService:GenerateGUID(false)
		offers[offerId] = {
			DefinitionId = definition.Id,
			ExpiresAt = os.clock() + OFFER_TTL_SECONDS,
		}
		table.insert(response, {
			OfferId = offerId,
			Job = safeDefinition(definition),
		})
	end

	self._offers[player.UserId] = offers
	return { ok = true, offers = response }
end

function JobService:Accept(player: Player, offerId: any)
	if not self:_Allow(player, "AcceptJob") then
		return { ok = false, error = "rate_limited" }
	end
	if type(offerId) ~= "string" or #offerId > 80 then
		return { ok = false, error = "invalid_offer" }
	end
	if self._active[player.UserId] ~= nil then
		return { ok = false, error = "job_already_active" }
	end

	local offer = self._offers[player.UserId] and self._offers[player.UserId][offerId]
	if offer == nil or offer.ExpiresAt < os.clock() then
		return { ok = false, error = "offer_expired" }
	end

	local definition = JobDefinitions.ById[offer.DefinitionId]
	if definition == nil then
		return { ok = false, error = "invalid_job" }
	end

	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	if not JobRules.IsEligible(definition, profile) then
		return { ok = false, error = "no_longer_eligible" }
	end

	local toolService = require(script.Parent.ToolService)
	if toolService:GetEquippedTier(player) < definition.RequiredToolTier then
		return { ok = false, error = "tool_tier_locked" }
	end

	local worldService = require(script.Parent.WorldService)
	local anchor = worldService:AssignAnchor(definition.District, definition.Category)
	if anchor == nil then
		return { ok = false, error = "no_world_anchor" }
	end

	local instanceId = HttpService:GenerateGUID(false)
	self._active[player.UserId] = {
		InstanceId = instanceId,
		DefinitionId = definition.Id,
		AnchorId = anchor:GetAttribute("AnchorId"),
		StageIndex = 1,
		StageStartedAt = os.clock(),
		Completing = false,
	}
	self._offers[player.UserId] = nil

	local speedMultiplier = toolService:GetEquippedSpeedMultiplier(player)
	local payload = {
		kind = "job_started",
		instanceId = instanceId,
		job = safeDefinition(definition),
		stage = ToolRules.ToClientStage(definition.Stages[1], speedMultiplier),
		targetPosition = anchor.Position,
	}
	getStateEvent():FireClient(player, payload)
	local analytics = require(script.Parent.AnalyticsService)
	analytics:LogCustom(player, "job_accepted", 1)
	analytics:LogOnce(player, "first_job_accepted", 1)
	return {
		ok = true,
		instanceId = instanceId,
		job = payload.job,
		stage = payload.stage,
		targetPosition = anchor.Position,
	}
end

function JobService:Abandon(player: Player)
	if not self:_Allow(player, "AbandonJob") then
		return { ok = false, error = "rate_limited" }
	end
	if self._active[player.UserId] == nil then
		return { ok = false, error = "no_active_job" }
	end
	self._active[player.UserId] = nil
	local analytics = require(script.Parent.AnalyticsService)
	analytics:LogCustom(player, "job_abandoned", 1)
	getStateEvent():FireClient(player, { kind = "job_abandoned" })
	return { ok = true }
end

function JobService:PerformAction(player: Player, payload: any)
	if not self:_Allow(player, "PerformJobAction") then
		return { ok = false, error = "rate_limited" }
	end
	if type(payload) ~= "table" or type(payload.instanceId) ~= "string" or type(payload.action) ~= "string" then
		return { ok = false, error = "invalid_payload" }
	end

	local active = self._active[player.UserId]
	if active == nil or active.InstanceId ~= payload.instanceId then
		return { ok = false, error = "stale_job" }
	end

	self:_CleanupCompletions(player.UserId)
	local completed = self._completed[player.UserId]
	if completed and completed[active.InstanceId] then
		return { ok = false, error = "already_completed" }
	end
	if active.Completing then
		return { ok = false, error = "completion_in_progress" }
	end

	local definition = JobDefinitions.ById[active.DefinitionId]
	local stage = definition and definition.Stages[active.StageIndex]
	if definition == nil or stage == nil then
		return { ok = false, error = "invalid_server_state" }
	end
	if payload.action ~= stage.Action then
		return { ok = false, error = "wrong_action" }
	end

	local worldService = require(script.Parent.WorldService)
	if type(active.AnchorId) ~= "string" or not worldService:IsPlayerNearAnchor(player, active.AnchorId) then
		return { ok = false, error = "too_far_from_job" }
	end

	local toolService = require(script.Parent.ToolService)
	local effectiveSeconds = ToolRules.GetEffectiveStageSeconds(stage.MinimumSeconds, toolService:GetEquippedSpeedMultiplier(player))
	local elapsed = os.clock() - active.StageStartedAt
	if elapsed + 0.15 < effectiveSeconds then
		return { ok = false, error = "too_fast" }
	end

	active.StageIndex += 1
	active.StageStartedAt = os.clock()
	if active.StageIndex <= #definition.Stages then
		local nextStage = ToolRules.ToClientStage(definition.Stages[active.StageIndex], toolService:GetEquippedSpeedMultiplier(player))
		getStateEvent():FireClient(player, {
			kind = "job_stage",
			instanceId = active.InstanceId,
			stage = nextStage,
		})
		return {
			ok = true,
			completed = false,
			stage = nextStage,
		}
	end

	active.Completing = true
	local economyService = require(script.Parent.EconomyService)
	local progressionService = require(script.Parent.ProgressionService)
	local dataService = require(script.Parent.PlayerDataService)
	local entitlementService = require(script.Parent.EntitlementService)
	local prestigeService = require(script.Parent.PrestigeService)
	local retentionService = require(script.Parent.RetentionService)

	local rewardMultiplier = entitlementService:GetCashMultiplier(player) * prestigeService:GetRewardMultiplier(player)
	local cashReward = math.floor(definition.BaseReward * rewardMultiplier)
	economyService:Grant(player, "cash", cashReward, "job:" .. definition.Id)
	progressionService:AddXP(player, definition.XP)
	progressionService:AddCompanyPoints(player, math.max(1, math.floor(cashReward * 0.03)))

	local profile = dataService:RequireProfile(player)
	profile.Stats.JobsCompleted += 1
	retentionService:OnJobCompleted(player, definition)

	if self._completed[player.UserId] == nil then
		self._completed[player.UserId] = {}
	end
	self._completed[player.UserId][active.InstanceId] = os.clock()
	self._active[player.UserId] = nil
	dataService:Publish(player)

	local analytics = require(script.Parent.AnalyticsService)
	analytics:LogCustom(player, "job_completed", 1)
	analytics:LogOnce(player, "first_job_completed", 1)
	getStateEvent():FireClient(player, {
		kind = "job_completed",
		reward = cashReward,
		xp = definition.XP,
	})

	return {
		ok = true,
		completed = true,
		reward = cashReward,
		xp = definition.XP,
	}
end

function JobService:UseInstantFinish(player: Player)
	if not self:_Allow(player, "UseInstantJobFinish") then
		return { ok = false, error = "rate_limited" }
	end

	local active = self._active[player.UserId]
	if active == nil or active.Completing then
		return { ok = false, error = "no_active_job" }
	end

	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	if profile.Consumables.InstantJobFinishes <= 0 then
		return { ok = false, error = "no_consumable" }
	end

	local definition = JobDefinitions.ById[active.DefinitionId]
	if definition == nil then
		return { ok = false, error = "invalid_server_state" }
	end

	local worldService = require(script.Parent.WorldService)
	if type(active.AnchorId) ~= "string" or not worldService:IsPlayerNearAnchor(player, active.AnchorId) then
		return { ok = false, error = "too_far_from_job" }
	end

	profile.Consumables.InstantJobFinishes -= 1
	active.StageIndex = #definition.Stages
	active.StageStartedAt = -math.huge

	local finalStage = definition.Stages[#definition.Stages]
	local result = self:PerformAction(player, {
		instanceId = active.InstanceId,
		action = finalStage.Action,
	})
	if type(result) ~= "table" or result.ok ~= true then
		profile.Consumables.InstantJobFinishes += 1
		dataService:Publish(player)
	end
	return result
end

function JobService:Init()
	getRemoteFunction("RequestJobOffers").OnServerInvoke = function(player)
		return self:GetOffers(player)
	end
	getRemoteFunction("AcceptJob").OnServerInvoke = function(player, offerId)
		return self:Accept(player, offerId)
	end
	getRemoteFunction("AbandonJob").OnServerInvoke = function(player)
		return self:Abandon(player)
	end
	getRemoteFunction("PerformJobAction").OnServerInvoke = function(player, payload)
		return self:PerformAction(player, payload)
	end
	getRemoteFunction("UseInstantJobFinish").OnServerInvoke = function(player)
		return self:UseInstantFinish(player)
	end

	Players.PlayerRemoving:Connect(function(player)
		self._offers[player.UserId] = nil
		self._active[player.UserId] = nil
		self._completed[player.UserId] = nil
	end)
end

function JobService:Start() end

return JobService
