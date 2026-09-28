--!strict

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MonetizationConfig = require(ReplicatedStorage.RepairEmpire.Shared.config.MonetizationConfig)

local EntitlementService = {
	Name = "EntitlementService",
	Dependencies = { "PlayerDataService" },
	_cache = {},
}

function EntitlementService:Init() end
function EntitlementService:Start() end

function EntitlementService:Invalidate(player: Player)
	self._cache[player.UserId] = nil
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
	local multiplier = 1
	if self:HasPass(player, "double_cash") then
		multiplier = 2
	end

	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	if profile.Boosts.CashMultiplierUntil > DateTime.now().UnixTimestamp then
		multiplier = math.max(multiplier, 2)
	end

	return math.min(multiplier, 2)
end

return EntitlementService
