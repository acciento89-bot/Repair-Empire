return function()
	local employees = require("../src/shared/company/EmployeeDefinitions")
	local company = require("../src/shared/config/CompanyConfig")

	assert(#employees.List == 12, "launch employee catalog must contain 12 definitions")
	assert(company.EmployeeSlotsByWorkshopTier[1] == 2, "workshop tier 1 slot count changed")
	assert(company.EmployeeSlotsByWorkshopTier[5] == 6, "workshop tier 5 slot count changed")
	assert(company.OfflinePassiveCapMinutes <= 240, "offline passive cap must remain bounded")
end
