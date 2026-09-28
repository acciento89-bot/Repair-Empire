--!strict

local RobloxAnalytics = game:GetService("AnalyticsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BalanceConfig = require(ReplicatedStorage.RepairEmpire.Shared.config.BalanceConfig)

local AnalyticsService = {
	Name = "AnalyticsService",
	Dependencies = { "SecurityService" },
}

local UI_FUNNEL_EVENTS = {
	company_system_opened = true,
	shop_opened = true,
}

function AnalyticsService:Init()
	local root = game:GetService("ReplicatedStorage"):WaitForChild("RepairEmpireRemotes")
	local remote = root:WaitForChild("RecordFunnelEvent")
	assert(remote:IsA("RemoteFunction"), "RecordFunnelEvent must be a RemoteFunction")
	remote.OnServerInvoke = function(player, eventName)
		local security = require(script.Parent.SecurityService)
		if not security:Allow(player, "RecordFunnelEvent") then
			return { ok = false, error = "rate_limited" }
		end
		if type(eventName) ~= "string" or UI_FUNNEL_EVENTS[eventName] ~= true then
			security:RecordAnomaly(player, "invalid_funnel_event", tostring(eventName))
			return { ok = false, error = "invalid_event" }
		end
		self:LogOnce(player, eventName, 1)
		return { ok = true }
	end
end

function AnalyticsService:Start() end

local function safeCall(label: string, callback): boolean
	local ok, err = pcall(callback)
	if not ok then
		warn(("[Repair Empire][Analytics] %s failed: %s"):format(label, tostring(err)))
	end
	return ok
end

function AnalyticsService:LogOnce(player: Player, eventName: string, value: number?)
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:GetProfile(player)
	if profile == nil or profile.AnalyticsFlags[eventName] == true then
		return false
	end
	if not self:LogCustom(player, eventName, value) then
		return false
	end
	profile.AnalyticsFlags[eventName] = true
	return true
end

function AnalyticsService:LogCustom(player: Player, eventName: string, value: number?): boolean
	return safeCall("custom:" .. eventName, function()
		RobloxAnalytics:LogCustomEvent(player, eventName, value or 1, {})
	end)
end

function AnalyticsService:LogEconomy(
	player: Player,
	isSource: boolean,
	currencyType: string,
	amount: number,
	endingBalance: number,
	transactionType: string,
	itemSku: string
)
	local flow = if isSource then Enum.AnalyticsEconomyFlowType.Source else Enum.AnalyticsEconomyFlowType.Sink
	safeCall("economy:" .. transactionType, function()
		RobloxAnalytics:LogEconomyEvent(player, flow, currencyType, amount, endingBalance, transactionType, itemSku, {})
	end)
end

function AnalyticsService:LogOnboardingStep(player: Player, step: number, stepName: string)
	safeCall("onboarding:" .. stepName, function()
		RobloxAnalytics:LogOnboardingFunnelStepEvent(player, step, stepName, {})
	end)
end

function AnalyticsService:LogProgressionComplete(player: Player, pathName: string, level: number, levelName: string)
	safeCall("progression:" .. pathName, function()
		RobloxAnalytics:LogProgressionCompleteEvent(player, pathName, level, levelName, {})
	end)
end

function AnalyticsService:GetBalanceVersion(): string
	return BalanceConfig.Version
end

return AnalyticsService
