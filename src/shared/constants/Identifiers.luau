--!strict

local Identifiers = {
	Categories = {
		Plumbing = "plumbing",
		Heating = "heating",
		Climate = "climate",
		Energy = "energy",
	},
	Districts = {
		Residential = "residential",
		Downtown = "downtown",
		Industrial = "industrial",
	},
	Currencies = {
		Cash = "cash",
		CompanyPoints = "company_points",
	},
	Environments = {
		Development = "development",
		Production = "production",
	},
}

return table.freeze(Identifiers)
