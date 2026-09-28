--!strict

local definitions = {
	{ Name = "RequestPlayerState", Kind = "Function", RateLimitPerSecond = 3 },
	{ Name = "RecordFunnelEvent", Kind = "Function", RateLimitPerSecond = 2 },
	{ Name = "RequestJobOffers", Kind = "Function", RateLimitPerSecond = 2 },
	{ Name = "AcceptJob", Kind = "Function", RateLimitPerSecond = 2 },
	{ Name = "AbandonJob", Kind = "Function", RateLimitPerSecond = 2 },
	{ Name = "PerformJobAction", Kind = "Function", RateLimitPerSecond = 8 },
	{ Name = "UseInstantJobFinish", Kind = "Function", RateLimitPerSecond = 1 },

	{ Name = "CreateCoopContract", Kind = "Function", RateLimitPerSecond = 1 },
	{ Name = "JoinCoopContract", Kind = "Function", RateLimitPerSecond = 2 },
	{ Name = "LeaveCoopContract", Kind = "Function", RateLimitPerSecond = 2 },
	{ Name = "PerformCoopAction", Kind = "Function", RateLimitPerSecond = 8 },

	{ Name = "PurchaseUpgrade", Kind = "Function", RateLimitPerSecond = 3 },
	{ Name = "PurchaseTool", Kind = "Function", RateLimitPerSecond = 3 },
	{ Name = "EquipTool", Kind = "Function", RateLimitPerSecond = 4 },
	{ Name = "PurchaseVehicle", Kind = "Function", RateLimitPerSecond = 2 },
	{ Name = "SelectVehicle", Kind = "Function", RateLimitPerSecond = 3 },
	{ Name = "SpawnVehicle", Kind = "Function", RateLimitPerSecond = 2 },
	{ Name = "HireEmployee", Kind = "Function", RateLimitPerSecond = 2 },

	{ Name = "ClaimDailyReward", Kind = "Function", RateLimitPerSecond = 1 },
	{ Name = "RequestDailyJobs", Kind = "Function", RateLimitPerSecond = 2 },
	{ Name = "ClaimAchievement", Kind = "Function", RateLimitPerSecond = 2 },
	{ Name = "RequestPrestige", Kind = "Function", RateLimitPerSecond = 1 },

	{ Name = "PromptGamePass", Kind = "Function", RateLimitPerSecond = 1 },
	{ Name = "PromptDeveloperProduct", Kind = "Function", RateLimitPerSecond = 1 },

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
