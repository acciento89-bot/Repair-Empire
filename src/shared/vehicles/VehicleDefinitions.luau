--!strict

local function vehicle(id, tier, cost, minLevel, speed, seats, style, width, height, length, axles)
	return {
		Id = id,
		Tier = tier,
		Cost = cost,
		MinimumLevel = minLevel,
		Speed = speed,
		Seats = seats,
		Style = style,
		BodySize = { width, height, length },
		Axles = axles,
	}
end

local Vehicles = {
	vehicle("old_compact_van", 1, 0, 1, 34, 2, "compact_van", 6.4, 2.4, 10.5, 2),
	vehicle("service_van", 2, 3_500, 10, 40, 2, "service_van", 6.8, 2.6, 11.8, 2),
	vehicle("long_wheelbase_van", 3, 8_000, 18, 42, 3, "long_van", 7.0, 2.8, 14.0, 2),
	vehicle("premium_service_van", 4, 16_000, 28, 46, 3, "premium_van", 7.1, 2.9, 13.0, 2),
	vehicle("utility_pickup", 5, 27_000, 36, 49, 4, "pickup", 7.4, 2.5, 13.2, 2),
	vehicle("crew_van", 6, 42_000, 44, 45, 6, "crew_van", 7.4, 3.0, 14.6, 2),
	vehicle("heavy_service_truck", 7, 68_000, 55, 41, 3, "truck", 8.3, 3.5, 16.5, 3),
	vehicle("elite_company_vehicle", 8, 100_000, 70, 54, 4, "elite", 7.6, 2.6, 12.8, 2),
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
