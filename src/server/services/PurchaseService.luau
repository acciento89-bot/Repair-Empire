--!strict

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MonetizationConfig = require(ReplicatedStorage.RepairEmpire.Shared.config.MonetizationConfig)

local PurchaseService = {
	Name = "PurchaseService",
	Dependencies = { "PlayerDataService", "EntitlementService", "SecurityService", "AnalyticsService" },
}

local function remote(name: string): RemoteFunction
	local instance = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild(name)
	assert(instance:IsA("RemoteFunction"), name .. " must be a RemoteFunction")
	return instance
end

local function productById(productId: number)
	for key, config in MonetizationConfig.DeveloperProducts do
		if config.Id == productId then
			return key, config
		end
	end
	return nil, nil
end

local function applyGrant(profile, grant)
	if grant.Kind == "cash" then
		profile.Cash += grant.Amount
		profile.Stats.MoneyEarned += grant.Amount
	elseif grant.Kind == "cash_boost" then
		local now = DateTime.now().UnixTimestamp
		local base = math.max(profile.Boosts.CashMultiplierUntil, now)
		profile.Boosts.CashMultiplierUntil = base + grant.Seconds
	elseif grant.Kind == "instant_job_finish" then
		profile.Consumables.InstantJobFinishes += grant.Amount
	else
		error("Unsupported product grant: " .. tostring(grant.Kind))
	end
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
		local productKey, config = productById(receiptInfo.ProductId)
		if productKey == nil or config == nil then
			warn(("[Repair Empire] Unconfigured Developer Product ID %d"):format(receiptInfo.ProductId))
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if player == nil then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local dataService = require(script.Parent.PlayerDataService)
		local ok = dataService:ApplyReceipt(player, tostring(receiptInfo.PurchaseId), function(profile)
			applyGrant(profile, config.Grant)
		end)

		if ok then
			local analytics = require(script.Parent.AnalyticsService)
			if config.Grant.Kind == "cash" then
				local profile = dataService:RequireProfile(player)
				analytics:LogEconomy(player, true, "cash", config.Grant.Amount, profile.Cash, "developer_product:" .. productKey, productKey)
			end
			analytics:LogCustom(player, "purchase_granted", 1)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

function PurchaseService:Start() end

return PurchaseService
