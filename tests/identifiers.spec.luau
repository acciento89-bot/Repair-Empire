return function()
	local identifiers = require("../src/shared/constants/Identifiers")
	assert(identifiers.Categories.Plumbing == "plumbing", "plumbing category ID changed")
	assert(identifiers.Districts.Industrial == "industrial", "industrial district ID changed")
	assert(identifiers.Currencies.CompanyPoints == "company_points", "company_points ID changed")
	assert(identifiers.Environments.Production == "production", "production environment ID changed")
end
