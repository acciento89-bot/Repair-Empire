--!strict

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PrestigeConfig = require(ReplicatedStorage.RepairEmpire.Shared.prestige.PrestigeConfig)

local PrestigeService = {
	Name = "PrestigeService",
	Dependencies = { "PlayerDataService", "RetentionService", "SecurityService", "AnalyticsService" },
	_confirmations = {},
}

local function remote(name: string): RemoteFunction
	local instance = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild(name)
	assert(instance:IsA("RemoteFunction"), name .. " must be a RemoteFunction")
	return instance
end

function PrestigeService:IsEligible(profile): boolean
	return profile.Level >= PrestigeConfig.RequiredPlayerLevel
		and profile.CompanyLevel >= PrestigeConfig.RequiredCompanyLevel
		and profile.WorkshopTier >= PrestigeConfig.RequiredWorkshopTier
end

function PrestigeService:GetRewardMultiplier(player: Player): number
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	return PrestigeConfig.GetRewardMultiplier(profile.PrestigeLevel)
end

function PrestigeService:Preview(player: Player)
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	if not self:IsEligible(profile) then
		return { ok = false, error = "not_eligible" }
	end

	local analytics = require(script.Parent.AnalyticsService)
	analytics:LogOnce(player, "prestige_available", 1)

	local token = HttpService:GenerateGUID(false)
	self._confirmations[player.UserId] = {
		Token = token,
		ExpiresAt = os.clock() + PrestigeConfig.ConfirmationLifetimeSeconds,
	}

	return {
		ok = true,
		token = token,
		currentPrestige = profile.PrestigeLevel,
		nextPrestige = profile.PrestigeLevel + 1,
		nextRewardMultiplier = PrestigeConfig.GetRewardMultiplier(profile.PrestigeLevel + 1),
		resets = {
			"player_level",
			"company_level",
			"workshop_tier",
			"district_unlocks",
			"tools",
			"vehicles",
			"employees",
		},
		retains = {
			"cash",
			"game_passes",
			"developer_product_consumables",
			"active_paid_boosts",
			"achievements",
			"lifetime_stats",
		},
	}
end

function PrestigeService:Confirm(player: Player, token: any)
	if type(token) ~= "string" then
		return { ok = false, error = "invalid_confirmation" }
	end
	local confirmation = self._confirmations[player.UserId]
	if confirmation == nil or confirmation.Token ~= token or confirmation.ExpiresAt < os.clock() then
		return { ok = false, error = "confirmation_expired" }
	end

	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	if not self:IsEligible(profile) then
		return { ok = false, error = "not_eligible" }
	end

	profile.PrestigeLevel += 1
	profile.Stats.Prestiges += 1
	profile.Level = 1
	profile.XP = 0
	profile.CompanyPoints = 0
	profile.CompanyLevel = 1
	profile.CompanyXP = 0
	profile.WorkshopTier = 1
	profile.SkillPoints = 0
	profile.UnlockedDistricts = {
		residential = true,
	}
	profile.OwnedTools = {
		basic_wrench = true,
	}
	profile.EquippedTool = "basic_wrench"
	profile.OwnedVehicles = {
		old_compact_van = true,
	}
	profile.SelectedVehicle = "old_compact_van"
	profile.Employees = {}
	profile.LastPassiveTimestamp = DateTime.now().UnixTimestamp

	self._confirmations[player.UserId] = nil
	dataService:Publish(player)

	local retentionService = require(script.Parent.RetentionService)
	retentionService:RefreshAchievements(player)
	local analytics = require(script.Parent.AnalyticsService)
	analytics:LogCustom(player, "prestige_completed", profile.PrestigeLevel)
	analytics:LogOnce(player, "first_prestige_completed", 1)

	return {
		ok = true,
		prestigeLevel = profile.PrestigeLevel,
		rewardMultiplier = PrestigeConfig.GetRewardMultiplier(profile.PrestigeLevel),
	}
end

function PrestigeService:Handle(player: Player, payload: any)
	local security = require(script.Parent.SecurityService)
	if not security:Allow(player, "RequestPrestige") then
		return { ok = false, error = "rate_limited" }
	end
	if type(payload) ~= "table" or type(payload.action) ~= "string" then
		return { ok = false, error = "invalid_payload" }
	end
	if payload.action == "preview" then
		return self:Preview(player)
	elseif payload.action == "confirm" then
		return self:Confirm(player, payload.token)
	end
	return { ok = false, error = "invalid_action" }
end

function PrestigeService:Init()
	remote("RequestPrestige").OnServerInvoke = function(player, payload)
		return self:Handle(player, payload)
	end
end

function PrestigeService:Start() end

return PrestigeService
