--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Shared = ReplicatedStorage.RepairEmpire.Shared
local JobDefinitions = require(Shared.jobs.JobDefinitions)
local JobRules = require(Shared.jobs.JobRules)
local CoopContracts = require(Shared.coop.CoopContracts)
local CoopRules = require(Shared.coop.CoopRules)
local CoopActionRules = require(Shared.coop.CoopActionRules)
local ToolRules = require(Shared.tools.ToolRules)

local MAX_PARTY_SIZE = 6

local CoopService = {
	Name = "CoopService",
	Dependencies = {
		"PlayerDataService",
		"EconomyService",
		"ProgressionService",
		"ToolService",
		"WorldService",
		"SecurityService",
		"AnalyticsService",
		"EntitlementService",
		"PrestigeService",
		"RetentionService",
		"SkillTreeService",
	},
	_contracts = {},
	_playerContract = {},
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

local function participantCount(contract): number
	return CoopRules.ParticipantCount(contract.Participants)
end

local function safeJob(definition)
	return {
		Id = definition.Id,
		Category = definition.Category,
		District = definition.District,
		BaseReward = definition.BaseReward,
		XP = definition.XP,
		MinimumLevel = definition.MinimumLevel,
		RequiredToolTier = definition.RequiredToolTier,
		StageCount = #definition.Stages,
		Coop = definition.Coop,
	}
end

function CoopService:_Allow(player: Player, name: string): boolean
	local security = require(script.Parent.SecurityService)
	return security:Allow(player, name)
end

function CoopService:_StageForPlayer(player: Player, definition, stage)
	local toolService = require(script.Parent.ToolService)
	local skillTree = require(script.Parent.SkillTreeService)
	local speedMultiplier = toolService:GetEquippedSpeedMultiplier(player)
		* skillTree:GetSpeedMultiplier(player, definition.Category)
	return ToolRules.ToClientStage(stage, speedMultiplier)
end

function CoopService:_FireStarted(player: Player, contract, definition)
	local worldService = require(script.Parent.WorldService)
	local anchor = worldService:GetAnchor(contract.AnchorId)
	stateEvent():FireClient(player, {
		kind = "coop_started",
		contractId = contract.Id,
		job = safeJob(definition),
		stage = self:_StageForPlayer(player, definition, definition.Stages[contract.StageIndex]),
		targetPosition = if anchor then anchor.Position else nil,
		participants = participantCount(contract),
	})
end

function CoopService:_BroadcastStage(contract, definition)
	for userId in contract.Participants do
		local player = Players:GetPlayerByUserId(userId)
		if player then
			stateEvent():FireClient(player, {
				kind = "coop_stage",
				contractId = contract.Id,
				stage = self:_StageForPlayer(player, definition, definition.Stages[contract.StageIndex]),
				participants = participantCount(contract),
			})
		end
	end
end

function CoopService:_BroadcastParty(contract)
	for userId in contract.Participants do
		local player = Players:GetPlayerByUserId(userId)
		if player then
			stateEvent():FireClient(player, {
				kind = "coop_party_updated",
				contractId = contract.Id,
				participants = participantCount(contract),
				ownerUserId = contract.OwnerUserId,
			})
		end
	end
end

function CoopService:GetAvailableContracts(player: Player)
	if not self:_Allow(player, "RequestCoopContracts") then
		return { ok = false, error = "rate_limited" }
	end

	local contracts = {}
	for _, contract in self._contracts do
		if not contract.Completing and participantCount(contract) < MAX_PARTY_SIZE then
			local definition = JobDefinitions.ById[contract.DefinitionId]
			if definition then
				local owner = Players:GetPlayerByUserId(contract.OwnerUserId)
				table.insert(contracts, {
					ContractId = contract.Id,
					Job = safeJob(definition),
					OwnerName = if owner then owner.DisplayName else "Player",
					Participants = participantCount(contract),
					MaxParticipants = MAX_PARTY_SIZE,
				})
			end
		end
	end

	table.sort(contracts, function(a, b)
		if a.Job.MinimumLevel == b.Job.MinimumLevel then
			return a.Job.Id < b.Job.Id
		end
		return a.Job.MinimumLevel < b.Job.MinimumLevel
	end)

	return {
		ok = true,
		contracts = contracts,
		currentContractId = self._playerContract[player.UserId],
	}
end

function CoopService:Create(player: Player, jobId: any)
	if not self:_Allow(player, "CreateCoopContract") then
		return { ok = false, error = "rate_limited" }
	end
	if type(jobId) ~= "string" or CoopContracts[jobId] ~= true then
		return { ok = false, error = "invalid_contract" }
	end
	if self._playerContract[player.UserId] ~= nil then
		return { ok = false, error = "already_in_contract" }
	end

	local definition = JobDefinitions.ById[jobId]
	if definition == nil then
		return { ok = false, error = "invalid_contract" }
	end

	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	if not JobRules.IsEligible(definition, profile) then
		return { ok = false, error = "not_eligible" }
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

	local contractId = HttpService:GenerateGUID(false)
	local contract = {
		Id = contractId,
		OwnerUserId = player.UserId,
		DefinitionId = jobId,
		AnchorId = anchor:GetAttribute("AnchorId"),
		StageIndex = 1,
		StageStartedAt = os.clock(),
		Participants = {
			[player.UserId] = true,
		},
		Contribution = {
			[player.UserId] = 0,
		},
		DepartedContribution = {},
		Completing = false,
		Acting = false,
	}
	self._contracts[contractId] = contract
	self._playerContract[player.UserId] = contractId

	self:_FireStarted(player, contract, definition)

	return {
		ok = true,
		contractId = contractId,
		job = safeJob(definition),
		stage = self:_StageForPlayer(player, definition, definition.Stages[1]),
		targetPosition = anchor.Position,
	}
end

function CoopService:Join(player: Player, contractId: any)
	if not self:_Allow(player, "JoinCoopContract") then
		return { ok = false, error = "rate_limited" }
	end
	if type(contractId) ~= "string" or #contractId > 80 or self._playerContract[player.UserId] ~= nil then
		return { ok = false, error = "invalid_join" }
	end

	local contract = self._contracts[contractId]
	if contract == nil or contract.Completing then
		return { ok = false, error = "contract_unavailable" }
	end
	if not CoopRules.CanJoin(contract.Participants, MAX_PARTY_SIZE) then
		return { ok = false, error = "party_full" }
	end

	local definition = JobDefinitions.ById[contract.DefinitionId]
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	if definition == nil or not JobRules.IsEligible(definition, profile) then
		return { ok = false, error = "not_eligible" }
	end

	local toolService = require(script.Parent.ToolService)
	if toolService:GetEquippedTier(player) < definition.RequiredToolTier then
		return { ok = false, error = "tool_tier_locked" }
	end

	contract.Participants[player.UserId] = true
	contract.Contribution[player.UserId] = CoopActionRules.RestoreContribution(contract, player.UserId)
	self._playerContract[player.UserId] = contractId

	self:_FireStarted(player, contract, definition)
	self:_BroadcastParty(contract)

	local worldService = require(script.Parent.WorldService)
	local anchor = worldService:GetAnchor(contract.AnchorId)
	return {
		ok = true,
		contractId = contractId,
		job = safeJob(definition),
		stage = self:_StageForPlayer(player, definition, definition.Stages[contract.StageIndex]),
		targetPosition = if anchor then anchor.Position else nil,
	}
end

function CoopService:_RemovePlayer(player: Player)
	local contractId = self._playerContract[player.UserId]
	local contract = contractId and self._contracts[contractId]
	if contract == nil then
		return false
	end

	local contribution = contract.Contribution[player.UserId] or 0
	contract.DepartedContribution = contract.DepartedContribution or {}
	contract.DepartedContribution[player.UserId] = contribution
	contract.Participants[player.UserId] = nil
	contract.Contribution[player.UserId] = nil
	self._playerContract[player.UserId] = nil

	if participantCount(contract) == 0 then
		self._contracts[contract.Id] = nil
	elseif contract.OwnerUserId == player.UserId then
		contract.OwnerUserId = CoopRules.NextOwner(contract.Participants)
		self:_BroadcastParty(contract)
	else
		self:_BroadcastParty(contract)
	end
	return true
end

function CoopService:Leave(player: Player)
	if not self:_Allow(player, "LeaveCoopContract") then
		return { ok = false, error = "rate_limited" }
	end
	if self._playerContract[player.UserId] == nil then
		return { ok = false, error = "not_in_contract" }
	end

	stateEvent():FireClient(player, { kind = "coop_left" })
	if not self:_RemovePlayer(player) then
		return { ok = false, error = "not_in_contract" }
	end
	return { ok = true }
end

function CoopService:_Complete(contract, definition)
	contract.Completing = true

	local economy = require(script.Parent.EconomyService)
	local progression = require(script.Parent.ProgressionService)
	local dataService = require(script.Parent.PlayerDataService)
	local entitlement = require(script.Parent.EntitlementService)
	local prestige = require(script.Parent.PrestigeService)
	local analytics = require(script.Parent.AnalyticsService)
	local retention = require(script.Parent.RetentionService)

	local totalContribution = 0
	for _, amount in contract.Contribution do
		totalContribution += amount
	end

	local partySize = participantCount(contract)
	local contractReward = math.floor(definition.BaseReward * math.min(1.25, 0.75 + partySize * 0.1))

	for userId in contract.Participants do
		local player = Players:GetPlayerByUserId(userId)
		local contribution = contract.Contribution[userId] or 0
		if player then
			local cash = 0
			local xp = 0
			if CoopRules.HasContribution(contribution) and totalContribution > 0 then
				local share = CoopRules.RewardShare(contribution, totalContribution)
				local rewardMultiplier = entitlement:GetCashMultiplier(player) * prestige:GetRewardMultiplier(player)
				cash = math.max(1, math.floor(contractReward * share * rewardMultiplier))
				xp = math.max(1, math.floor(definition.XP * share))
				economy:Grant(player, "cash", cash, "coop:" .. definition.Id)
				progression:AddXP(player, xp)
				progression:AddCompanyPoints(player, math.max(1, math.floor(cash * 0.03)))
				local profile = dataService:RequireProfile(player)
				profile.Stats.JobsCompleted += 1
				dataService:Publish(player)
				analytics:LogOnce(player, "first_coop_job_completed", 1)
				retention:RefreshAchievements(player)
			end

			stateEvent():FireClient(player, {
				kind = "coop_completed",
				contractId = contract.Id,
				reward = cash,
				xp = xp,
				contributed = CoopRules.HasContribution(contribution),
			})
		end
		self._playerContract[userId] = nil
	end

	self._contracts[contract.Id] = nil
end

function CoopService:PerformAction(player: Player, payload: any)
	if not self:_Allow(player, "PerformCoopAction") then
		return { ok = false, error = "rate_limited" }
	end
	if type(payload) ~= "table" or type(payload.action) ~= "string" then
		return { ok = false, error = "invalid_payload" }
	end

	local contractId = self._playerContract[player.UserId]
	local contract = contractId and self._contracts[contractId]
	local definition = contract and JobDefinitions.ById[contract.DefinitionId]
	local stage = definition and definition.Stages[contract.StageIndex]

	local worldService = require(script.Parent.WorldService)
	local isNear = contract ~= nil and worldService:IsPlayerNearAnchor(player, contract.AnchorId)

	local toolService = require(script.Parent.ToolService)
	local toolTier = toolService:GetEquippedTier(player)
	local skillTree = require(script.Parent.SkillTreeService)
	local speedMultiplier = if definition
		then toolService:GetEquippedSpeedMultiplier(player) * skillTree:GetSpeedMultiplier(player, definition.Category)
		else 1
	local effectiveSeconds = if stage
		then ToolRules.GetEffectiveStageSeconds(stage.MinimumSeconds, speedMultiplier)
		else math.huge
	local elapsed = if contract then os.clock() - contract.StageStartedAt else 0

	local decision = CoopActionRules.Validate({
		contract = contract,
		userId = player.UserId,
		definition = definition,
		stage = stage,
		action = payload.action,
		isNear = isNear,
		toolTier = toolTier,
		elapsed = elapsed,
		effectiveSeconds = effectiveSeconds,
	})
	if not decision.ok then
		return { ok = false, error = decision.error }
	end

	contract.Acting = true
	contract.Contribution[player.UserId] = (contract.Contribution[player.UserId] or 0) + 1
	contract.StageIndex += 1
	contract.StageStartedAt = os.clock()

	if contract.StageIndex > #definition.Stages then
		self:_Complete(contract, definition)
		return { ok = true, completed = true }
	end

	contract.Acting = false
	self:_BroadcastStage(contract, definition)
	return {
		ok = true,
		completed = false,
		stage = self:_StageForPlayer(player, definition, definition.Stages[contract.StageIndex]),
	}
end

function CoopService:Init()
	remote("RequestCoopContracts").OnServerInvoke = function(player)
		return self:GetAvailableContracts(player)
	end
	remote("CreateCoopContract").OnServerInvoke = function(player, jobId)
		return self:Create(player, jobId)
	end
	remote("JoinCoopContract").OnServerInvoke = function(player, contractId)
		return self:Join(player, contractId)
	end
	remote("LeaveCoopContract").OnServerInvoke = function(player)
		return self:Leave(player)
	end
	remote("PerformCoopAction").OnServerInvoke = function(player, payload)
		return self:PerformAction(player, payload)
	end

	Players.PlayerRemoving:Connect(function(player)
		if self._playerContract[player.UserId] then
			self:_RemovePlayer(player)
		end
	end)
end

function CoopService:Start() end

return CoopService
