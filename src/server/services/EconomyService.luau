--!strict

local EconomyService = {
	Name = "EconomyService",
	Dependencies = { "PlayerDataService" },
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

	if currencyId == "cash" then
		profile.Cash += math.floor(amount)
		profile.Stats.MoneyEarned += math.floor(amount)
	else
		profile.CompanyPoints += math.floor(amount)
	end

	dataService:Publish(player)
	return true
end

function EconomyService:Spend(player: Player, currencyId: string, amount: number, reason: string): boolean
	assert(VALID_CURRENCIES[currencyId] == true, "Invalid currency")
	assert(amount > 0 and amount < 1_000_000_000, "Invalid spend amount")
	assert(#reason > 0, "Reason required")

	local dataService = require(script.Parent.PlayerDataService)
	local profile = dataService:RequireProfile(player)
	local field = if currencyId == "cash" then "Cash" else "CompanyPoints"
	local balance = profile[field]
	if balance < amount then
		return false
	end

	profile[field] = balance - math.floor(amount)
	if currencyId == "cash" then
		profile.Stats.MoneySpent += math.floor(amount)
	end
	dataService:Publish(player)
	return true
end

return EconomyService
