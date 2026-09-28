return function()
	local identifiers = require("../src/shared/constants/Identifiers")
	assert(identifiers.Categories.Plumbing == "plumbing")
	assert(identifiers.Districts.Industrial == "industrial")
	assert(identifiers.Currencies.CompanyPoints == "company_points")
	assert(identifiers.Environments.Production == "production")
end
