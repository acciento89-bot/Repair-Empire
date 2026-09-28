--!strict

local function vehicle(id, tier, cost, minLevel, speed, seats)
	return {
		Id = id,
		Tier = tier,
		Cost = cost,
		MinimumLevel = minLevel,
		Speed = speed,
		Seats = seats,
	}
end

local Vehicles = {
	vehicle("old_compact_van", 1, 0, 1, 34, 2),
	vehicle("service_van", 2, 3_500, 10, 40, 2),
	vehicle("long_wheelbase_van", 3, 8_000, 18, 42, 3),
	vehicle("premium_service_van", 4, 16_000, 28, 46, 3),
	vehicle("utility_pickup", 5, 27_000, 36, 49, 4),
	vehicle("crew_van", 6, 42_000, 44, 45, 6),
	vehicle("heavy_service_truck", 7, 68_000, 55, 41, 3),
	vehicle("elite_company_vehicle", 8, 100_000, 70, 54, 4),
}

local byId = {}
for _, definition in Vehicles do
	assert(byId[definition.Id] == nil, "Duplicate vehicle ID: " .. definition.Id)
	byId[definition.Id] = definition
end

return table.freeze({
	List = table.freeze(Vehicles),
	ById = table.freeze(byId),
})
