--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Shared = ReplicatedStorage.RepairEmpire.Shared
local JobDefinitions = require(Shared.jobs.JobDefinitions)
local JobRules = require(Shared.jobs.JobRules)
local CoopContracts = require(Shared.coop.CoopContracts)

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
	},
	_contracts = {},
	_playerContract = {},
}

local function remote(name: string): RemoteFunction
	local instance = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild(name)
	assert(instance:IsA("RemoteFunction"), name .. " must be a RemoteFunction")
	return instance
end

function CoopService:_Allow(player: Player, name: string): boolean
	local security = require(script.Parent.SecurityService)
	return security:Allow(player, name)
end

local function participantCount(contract): number
	local count = 0
	for _ in contract.Participants do
		count += 1
	end
	return count
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
	self._contracts[contractId] = {
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
		Completing = false,
	}
	self._playerContract[player.UserId] = contractId

	return {
		ok = true,
		contractId = contractId,
		jobId = jobId,
		stage = definition.Stages[1],
		targetPosition = anchor.Position,
	}
end

function CoopService:Join(player: Player, contractId: any)
	if not self:_Allow(player, "JoinCoopContract") then
		return { ok = false, error = "rate_limited" }
	end
	if type(contractId) ~= "string" or self._playerContract[player.UserId] ~= nil then
		return { ok = false, error = "invalid_join" }
	end

	local contract = self._contracts[contractId]
	if contract == nil or contract.Completing then
		return { ok = false, error = "contract_unavailable" }
	end
	if participantCount(contract) >= MAX_PARTY_SIZE then
		return { ok = false, error = "party_full" }
	end

	local definition = JobDefinitions.ById[contract.DefinitionId]
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	if definition == nil or not JobRules.IsEligible(definition, profile) then
		return { ok = false, error = "not_eligible" }
	end

	contract.Participants[player.UserId] = true
	contract.Contribution[player.UserId] = 0
	self._playerContract[player.UserId] = contractId

	local worldService = require(script.Parent.WorldService)
	local anchor = worldService:GetAnchor(contract.AnchorId)
	return {
		ok = true,
		contractId = contractId,
		jobId = contract.DefinitionId,
		stage = definition.Stages[contract.StageIndex],
		targetPosition = if anchor then anchor.Position else nil,
	}
end

function CoopService:_RemovePlayer(player: Player)
	local contractId = self._playerContract[player.UserId]
	local contract = contractId and self._contracts[contractId]
	if contract == nil then
		return false
	end

	contract.Participants[player.UserId] = nil
	contract.Contribution[player.UserId] = nil
	self._playerContract[player.UserId] = nil

	if participantCount(contract) == 0 then
		self._contracts[contract.Id] = nil
	elseif contract.OwnerUserId == player.UserId then
		for userId in contract.Participants do
			contract.OwnerUserId = userId
			break
		end
	end
	return true
end

function CoopService:Leave(player: Player)
	if not self:_Allow(player, "LeaveCoopContract") then
		return { ok = false, error = "rate_limited" }
	end
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

	local totalContribution = 0
	for _, amount in contract.Contribution do
		totalContribution += amount
	end

	local partySize = participantCount(contract)
	local contractReward = math.floor(definition.BaseReward * math.min(1.25, 0.75 + partySize * 0.1))

	for userId in contract.Participants do
		local player = Players:GetPlayerByUserId(userId)
		local contribution = contract.Contribution[userId] or 0
		if player and contribution > 0 and totalContribution > 0 then
			local share = contribution / totalContribution
			local cash = math.max(1, math.floor(contractReward * share))
			local xp = math.max(1, math.floor(definition.XP * share))
			economy:Grant(player, "cash", cash, "coop:" .. definition.Id)
			progression:AddXP(player, xp)
			progression:AddCompanyPoints(player, math.max(1, math.floor(cash * 0.03)))
			local profile = dataService:RequireProfile(player)
			profile.Stats.JobsCompleted += 1
			dataService:Publish(player)
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
	if contract == nil or contract.Completing then
		return { ok = false, error = "contract_unavailable" }
	end

	local definition = JobDefinitions.ById[contract.DefinitionId]
	local stage = definition and definition.Stages[contract.StageIndex]
	if definition == nil or stage == nil then
		return { ok = false, error = "invalid_server_state" }
	end
	if payload.action ~= stage.Action then
		return { ok = false, error = "wrong_action" }
	end

	local worldService = require(script.Parent.WorldService)
	if not worldService:IsPlayerNearAnchor(player, contract.AnchorId) then
		return { ok = false, error = "too_far_from_job" }
	end

	if os.clock() - contract.StageStartedAt + 0.15 < stage.MinimumSeconds then
		return { ok = false, error = "too_fast" }
	end

	contract.Contribution[player.UserId] = (contract.Contribution[player.UserId] or 0) + 1
	contract.StageIndex += 1
	contract.StageStartedAt = os.clock()

	if contract.StageIndex > #definition.Stages then
		self:_Complete(contract, definition)
		return { ok = true, completed = true }
	end

	return {
		ok = true,
		completed = false,
		stage = definition.Stages[contract.StageIndex],
	}
end

function CoopService:Init()
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
