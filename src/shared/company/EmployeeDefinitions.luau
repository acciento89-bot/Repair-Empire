--!strict

local function employee(id, tier, cost, minWorkshopTier, minCompanyLevel, cashPerMinute)
	return {
		Id = id,
		Tier = tier,
		Cost = cost,
		MinimumWorkshopTier = minWorkshopTier,
		MinimumCompanyLevel = minCompanyLevel,
		CashPerMinute = cashPerMinute,
	}
end

local Employees = {
	employee("apprentice_plumbing", 1, 1_200, 1, 1, 8),
	employee("apprentice_heating", 1, 1_400, 1, 2, 9),
	employee("apprentice_climate", 1, 1_600, 1, 3, 10),
	employee("apprentice_energy", 1, 1_800, 1, 4, 11),

	employee("technician_plumbing", 2, 4_500, 2, 3, 24),
	employee("technician_heating", 2, 5_000, 2, 4, 27),
	employee("technician_climate", 2, 5_500, 2, 5, 30),
	employee("technician_energy", 2, 6_000, 2, 6, 33),

	employee("specialist_plumbing", 3, 12_000, 3, 6, 62),
	employee("specialist_heating", 3, 13_500, 3, 7, 70),
	employee("specialist_climate", 3, 15_000, 3, 8, 78),
	employee("crew_lead_energy", 4, 22_000, 4, 9, 110),
}

local byId = {}
for _, definition in Employees do
	assert(byId[definition.Id] == nil, "Duplicate employee ID: " .. definition.Id)
	byId[definition.Id] = definition
end

return table.freeze({
	List = table.freeze(Employees),
	ById = table.freeze(byId),
})
