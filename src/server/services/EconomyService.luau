--!strict

local EconomyService = {
	Name = "EconomyService",
	Dependencies = { "PlayerDataService", "AnalyticsService" },
}

local VALID_CURRENCIES = {
	cash = true,
	company_points = true,
}

function EconomyService:Init() end
function EconomyService:Start() end

function EconomyService:GetBalance(player: Player, currencyId: string): number
	assert(VALID_CURRENCIES[currencyId] == true, "Invalid currency")
	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	if currencyId == "cash" then
		return profile.Cash
	end
	return profile.CompanyPoints
end

function EconomyService:Grant(player: Player, currencyId: string, amount: number, reason: string): boolean
	assert(VALID_CURRENCIES[currencyId] == true, "Invalid currency")
	assert(amount > 0 and amount < 1_000_000_000, "Invalid grant amount")
	assert(#reason > 0, "Reason required")

	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	local rounded = math.floor(amount)

	if currencyId == "cash" then
		profile.Cash += rounded
		profile.Stats.MoneyEarned += rounded
	else
		profile.CompanyPoints += rounded
	end

	dataService:Publish(player)

	local analytics = require(script.Parent.AnalyticsService)
	analytics:LogEconomy(player, true, currencyId, rounded, self:GetBalance(player, currencyId), reason, "")
	return true
end

function EconomyService:Spend(player: Player, currencyId: string, amount: number, reason: string): boolean
	assert(VALID_CURRENCIES[currencyId] == true, "Invalid currency")
	assert(amount > 0 and amount < 1_000_000_000, "Invalid spend amount")
	assert(#reason > 0, "Reason required")

	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	local field = if currencyId == "cash" then "Cash" else "CompanyPoints"
	local rounded = math.floor(amount)
	local balance = profile[field]
	if balance < rounded then
		return false
	end

	profile[field] = balance - rounded
	if currencyId == "cash" then
		profile.Stats.MoneySpent += rounded
	end
	dataService:Publish(player)

	local analytics = require(script.Parent.AnalyticsService)
	analytics:LogEconomy(player, false, currencyId, rounded, self:GetBalance(player, currencyId), reason, "")
	return true
end

return EconomyService
