--!strict

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage.RepairEmpire.Shared
local MonetizationConfig = require(Shared.config.MonetizationConfig)
local PassRules = require(Shared.monetization.PassRules)

local EntitlementService = {
	Name = "EntitlementService",
	Dependencies = { "PlayerDataService" },
	_cache = {},
}

function EntitlementService:Init() end

function EntitlementService:RefreshAttributes(player: Player)
	player:SetAttribute("HasDoubleCash", self:HasPass(player, "double_cash"))
	player:SetAttribute("HasVIP", self:HasPass(player, "vip"))
	player:SetAttribute("HasExtraEmployeeSlot", self:HasPass(player, "extra_employee_slot"))
	player:SetAttribute("HasExtraVehicleSlot", self:HasPass(player, "extra_vehicle_slot"))
	player:SetAttribute("HasPremiumWorkshop", self:HasPass(player, "premium_workshop"))
end

function EntitlementService:Start()
	Players.PlayerAdded:Connect(function(player)
		task.spawn(function()
			self:RefreshAttributes(player)
		end)
	end)

	for _, player in Players:GetPlayers() do
		task.spawn(function()
			self:RefreshAttributes(player)
		end)
	end
end

function EntitlementService:Invalidate(player: Player)
	self._cache[player.UserId] = nil
	self:RefreshAttributes(player)
end

function EntitlementService:HasPass(player: Player, passKey: string): boolean
	local config = MonetizationConfig.GamePasses[passKey]
	if config == nil or config.Id == nil then
		return false
	end

	self._cache[player.UserId] = self._cache[player.UserId] or {}
	local cache = self._cache[player.UserId]
	if cache[passKey] ~= nil then
		return cache[passKey]
	end

	local ok, owns = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, player.UserId, config.Id)
	if not ok then
		warn(("[Repair Empire] Failed entitlement check for %s"):format(passKey))
		return false
	end

	cache[passKey] = owns == true
	return cache[passKey]
end

function EntitlementService:GetCashMultiplier(player: Player): number
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	local boostActive = profile.Boosts.CashMultiplierUntil > DateTime.now().UnixTimestamp
	return PassRules.CashMultiplier(self:HasPass(player, "double_cash"), boostActive)
end

return EntitlementService
