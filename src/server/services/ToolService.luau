--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.RepairEmpire.Shared
local ToolDefinitions = require(Shared.tools.ToolDefinitions)
local MutationGuard = require(script.Parent.Parent.security.MutationGuard)

local ToolService = {
	Name = "ToolService",
	Dependencies = { "PlayerDataService", "EconomyService", "SecurityService", "AnalyticsService", "TutorialService" },
}

local function remote(name: string): RemoteFunction
	local instance = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild(name)
	assert(instance:IsA("RemoteFunction"), name .. " must be a RemoteFunction")
	return instance
end

function ToolService:GetEquippedDefinition(player: Player)
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	return ToolDefinitions.ById[profile.EquippedTool]
end

function ToolService:GetEquippedTier(player: Player): number
	local definition = self:GetEquippedDefinition(player)
	return if definition then definition.Tier else 0
end

function ToolService:GetEquippedSpeedMultiplier(player: Player): number
	local definition = self:GetEquippedDefinition(player)
	return if definition then definition.SpeedMultiplier else 1
end

function ToolService:Purchase(player: Player, toolId: any)
	local security = require(script.Parent.SecurityService)
	if not security:Allow(player, "PurchaseTool") then
		return { ok = false, error = "rate_limited" }
	end
	if type(toolId) ~= "string" then
		return { ok = false, error = "invalid_tool" }
	end
	local definition = ToolDefinitions.ById[toolId]
	if definition == nil then
		return { ok = false, error = "invalid_tool" }
	end

	local entered, result = MutationGuard.TryRun(player.UserId, "profile_value_mutation", function()
		local dataService = require(script.Parent.PlayerDataService)
		local profile = dataService:RequireProfile(player)
		if profile.OwnedTools[toolId] then
			return { ok = false, error = "already_owned" }
		end
		if profile.Level < definition.MinimumLevel then
			return { ok = false, error = "level_locked" }
		end

		local economy = require(script.Parent.EconomyService)
		if not economy:Spend(player, "cash", definition.Cost, "tool:" .. toolId) then
			return { ok = false, error = "insufficient_funds" }
		end

		profile.OwnedTools[toolId] = true
		dataService:Publish(player)
		local analytics = require(script.Parent.AnalyticsService)
		analytics:LogOnce(player, "first_upgrade_bought", 1)
		local tutorial = require(script.Parent.TutorialService)
		tutorial:Advance(player, "first_upgrade")
		return { ok = true }
	end)
	if not entered then
		return { ok = false, error = "mutation_in_progress" }
	end
	return result
end

function ToolService:Equip(player: Player, toolId: any)
	local security = require(script.Parent.SecurityService)
	if not security:Allow(player, "EquipTool") then
		return { ok = false, error = "rate_limited" }
	end
	if type(toolId) ~= "string" then
		return { ok = false, error = "invalid_tool" }
	end
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	if profile.OwnedTools[toolId] ~= true or ToolDefinitions.ById[toolId] == nil then
		return { ok = false, error = "not_owned" }
	end
	profile.EquippedTool = toolId
	dataService:Publish(player)
	return { ok = true, toolId = toolId }
end

function ToolService:Init()
	remote("PurchaseTool").OnServerInvoke = function(player, toolId)
		return self:Purchase(player, toolId)
	end
	remote("EquipTool").OnServerInvoke = function(player, toolId)
		return self:Equip(player, toolId)
	end
end

function ToolService:Start() end

return ToolService
