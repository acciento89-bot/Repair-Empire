--!strict

local function employee(id, role, tier, cost, minWorkshopTier, minCompanyLevel, cashPerMinute)
	return {
		Id = id,
		Role = role,
		Tier = tier,
		Cost = cost,
		MinimumWorkshopTier = minWorkshopTier,
		MinimumCompanyLevel = minCompanyLevel,
		CashPerMinute = cashPerMinute,
	}
end

local Employees = {
	employee("apprentice_plumbing", "apprentice", 1, 1_200, 1, 1, 8),
	employee("apprentice_heating", "apprentice", 1, 1_400, 1, 2, 9),
	employee("apprentice_climate", "apprentice", 1, 1_600, 1, 3, 10),
	employee("apprentice_energy", "apprentice", 1, 1_800, 1, 4, 11),

	employee("technician_plumbing", "technician", 2, 4_500, 2, 3, 24),
	employee("technician_heating", "technician", 2, 5_000, 2, 4, 27),
	employee("technician_climate", "technician", 2, 5_500, 2, 5, 30),

	employee("specialist_energy", "specialist", 3, 6_000, 3, 6, 33),
	employee("specialist_plumbing", "specialist", 3, 12_000, 3, 7, 62),

	employee("senior_heating", "senior_technician", 4, 13_500, 4, 8, 70),
	employee("senior_climate", "senior_technician", 4, 15_000, 4, 9, 78),

	employee("crew_lead_energy", "crew_lead", 5, 22_000, 5, 10, 110),
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
