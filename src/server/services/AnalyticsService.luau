--!strict

local RobloxAnalytics = game:GetService("AnalyticsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BalanceConfig = require(ReplicatedStorage.RepairEmpire.Shared.config.BalanceConfig)

local AnalyticsService = {
	Name = "AnalyticsService",
	Dependencies = {},
}

function AnalyticsService:Init() end
function AnalyticsService:Start() end

local function safeCall(label: string, callback)
	local ok, err = pcall(callback)
	if not ok then
		warn(("[Repair Empire][Analytics] %s failed: %s"):format(label, tostring(err)))
	end
end

function AnalyticsService:LogCustom(player: Player, eventName: string, value: number?)
	safeCall("custom:" .. eventName, function()
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
