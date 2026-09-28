--!strict

local CompanyConfig = {
	MaxWorkshopTier = 5,
	WorkshopUpgradeCosts = {
		[2] = 5_000,
		[3] = 18_000,
		[4] = 48_000,
		[5] = 95_000,
	},
	EmployeeSlotsByWorkshopTier = {
		[1] = 2,
		[2] = 3,
		[3] = 4,
		[4] = 5,
		[5] = 6,
	},
	OfflinePassiveCapMinutes = 240,
	PassiveTickSeconds = 60,
}

return table.freeze(CompanyConfig)
