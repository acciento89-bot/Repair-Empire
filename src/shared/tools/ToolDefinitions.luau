--!strict

local function tool(id, family, tier, cost, minLevel, speedMultiplier)
	return {
		Id = id,
		Family = family,
		Tier = tier,
		Cost = cost,
		MinimumLevel = minLevel,
		SpeedMultiplier = speedMultiplier,
	}
end

local Tools = {
	tool("basic_wrench", "wrench", 1, 0, 1, 1.00),
	tool("service_wrench", "wrench", 2, 600, 8, 0.92),
	tool("pro_wrench", "wrench", 3, 2_400, 22, 0.84),
	tool("master_wrench", "wrench", 4, 8_500, 45, 0.76),

	tool("basic_screwdriver", "screwdriver", 1, 100, 1, 0.97),
	tool("service_screwdriver", "screwdriver", 2, 700, 9, 0.92),
	tool("pro_screwdriver", "screwdriver", 3, 2_700, 24, 0.84),
	tool("master_screwdriver", "screwdriver", 4, 9_000, 47, 0.76),

	tool("basic_pliers", "pliers", 1, 220, 3, 1.00),
	tool("service_pliers", "pliers", 2, 850, 10, 0.92),
	tool("pro_pliers", "pliers", 3, 3_100, 26, 0.84),
	tool("master_pliers", "pliers", 4, 9_800, 49, 0.76),

	tool("basic_drain_tool", "drain", 1, 300, 4, 1.00),
	tool("service_drain_tool", "drain", 2, 1_000, 12, 0.92),
	tool("pro_drain_tool", "drain", 3, 3_600, 28, 0.84),
	tool("master_drain_tool", "drain", 4, 10_800, 52, 0.76),

	tool("basic_diagnostic_kit", "diagnostic", 1, 450, 5, 1.00),
	tool("service_diagnostic_kit", "diagnostic", 2, 1_500, 14, 0.92),
	tool("pro_diagnostic_kit", "diagnostic", 3, 4_800, 32, 0.84),
	tool("master_diagnostic_kit", "diagnostic", 4, 13_500, 55, 0.76),
}

local byId = {}
for _, definition in Tools do
	assert(byId[definition.Id] == nil, "Duplicate tool ID: " .. definition.Id)
	byId[definition.Id] = definition
end

return table.freeze({
	List = table.freeze(Tools),
	ById = table.freeze(byId),
})
