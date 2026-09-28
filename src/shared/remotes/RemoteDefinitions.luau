--!strict

local definitions = {
	{ Name = "RequestJobOffers", Kind = "Function", RateLimitPerSecond = 2 },
	{ Name = "AcceptJob", Kind = "Function", RateLimitPerSecond = 2 },
	{ Name = "AbandonJob", Kind = "Function", RateLimitPerSecond = 2 },
	{ Name = "PerformJobAction", Kind = "Function", RateLimitPerSecond = 8 },
	{ Name = "PurchaseUpgrade", Kind = "Function", RateLimitPerSecond = 3 },
	{ Name = "EquipTool", Kind = "Function", RateLimitPerSecond = 4 },
	{ Name = "SpawnVehicle", Kind = "Function", RateLimitPerSecond = 2 },
	{ Name = "HireEmployee", Kind = "Function", RateLimitPerSecond = 2 },
	{ Name = "ClaimDailyReward", Kind = "Function", RateLimitPerSecond = 1 },
	{ Name = "RequestPrestige", Kind = "Function", RateLimitPerSecond = 1 },
	{ Name = "StateUpdated", Kind = "Event", RateLimitPerSecond = 20 },
}

local byName = {}
for _, definition in definitions do
	assert(byName[definition.Name] == nil, "Duplicate remote: " .. definition.Name)
	byName[definition.Name] = definition
end

return table.freeze({
	List = table.freeze(definitions),
	ByName = table.freeze(byName),
})
