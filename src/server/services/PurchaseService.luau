--!strict

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.RepairEmpire.Shared
local MonetizationConfig = require(Shared.config.MonetizationConfig)
local PurchaseRules = require(Shared.monetization.PurchaseRules)

local PurchaseService = {
	Name = "PurchaseService",
	Dependencies = { "PlayerDataService", "EntitlementService", "SecurityService", "AnalyticsService" },
}

local function remote(name: string): RemoteFunction
	local instance = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild(name)
	assert(instance:IsA("RemoteFunction"), name .. " must be a RemoteFunction")
	return instance
end

function PurchaseService:PromptGamePass(player: Player, passKey: any)
	local security = require(script.Parent.SecurityService)
	if not security:Allow(player, "PromptGamePass") then
		return { ok = false, error = "rate_limited" }
	end
	if type(passKey) ~= "string" then
		return { ok = false, error = "invalid_pass" }
	end
	local config = MonetizationConfig.GamePasses[passKey]
	if config == nil then
		return { ok = false, error = "invalid_pass" }
	end
	if config.Id == nil then
		return { ok = false, error = "not_configured" }
	end

	MarketplaceService:PromptGamePassPurchase(player, config.Id)
	local analytics = require(script.Parent.AnalyticsService)
	analytics:LogCustom(player, "gamepass_prompted", 1)
	return { ok = true }
end

function PurchaseService:PromptProduct(player: Player, productKey: any)
	local security = require(script.Parent.SecurityService)
	if not security:Allow(player, "PromptDeveloperProduct") then
		return { ok = false, error = "rate_limited" }
	end
	if type(productKey) ~= "string" then
		return { ok = false, error = "invalid_product" }
	end
	local config = MonetizationConfig.DeveloperProducts[productKey]
	if config == nil then
		return { ok = false, error = "invalid_product" }
	end
	if config.Id == nil then
		return { ok = false, error = "not_configured" }
	end

	MarketplaceService:PromptProductPurchase(player, config.Id)
	local analytics = require(script.Parent.AnalyticsService)
	analytics:LogCustom(player, "product_prompted", 1)
	return { ok = true }
end

function PurchaseService:Init()
	remote("PromptGamePass").OnServerInvoke = function(player, passKey)
		return self:PromptGamePass(player, passKey)
	end
	remote("PromptDeveloperProduct").OnServerInvoke = function(player, productKey)
		return self:PromptProduct(player, productKey)
	end

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, _passId, wasPurchased)
		if wasPurchased then
			local entitlementService = require(script.Parent.EntitlementService)
			entitlementService:Invalidate(player)
		end
	end)

	MarketplaceService.ProcessReceipt = function(receiptInfo)
		local productKey, config = PurchaseRules.ProductById(MonetizationConfig, receiptInfo.ProductId)
		if productKey == nil or config == nil then
			warn(("[Repair Empire] Unconfigured Developer Product ID %d"):format(receiptInfo.ProductId))
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if player == nil then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local dataService = require(script.Parent.PlayerDataService)
		local ok, reason = dataService:ApplyReceipt(player, tostring(receiptInfo.PurchaseId), function(profile)
			PurchaseRules.ApplyGrant(profile, config.Grant, DateTime.now().UnixTimestamp)
		end)

		if ok then
			if PurchaseRules.ShouldEmitGrantAnalytics(reason) then
				local analytics = require(script.Parent.AnalyticsService)
				if config.Grant.Kind == "cash" then
					local profile = dataService:RequireProfile(player)
					analytics:LogEconomy(player, true, "cash", config.Grant.Amount, profile.Cash, "developer_product:" .. productKey, productKey)
				end
				analytics:LogCustom(player, "purchase_granted", 1)
			end
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

function PurchaseService:Start() end

return PurchaseService
