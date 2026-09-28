--!strict

local MonetizationConfig = {
	GamePasses = {
		double_cash = {
			Id = 1997847285,
			PriceRobux = 299,
			Effect = "double_cash",
		},
		vip = {
			Id = 1998201387,
			PriceRobux = 399,
			Effect = "vip",
		},
		extra_employee_slot = {
			Id = 1998489332,
			PriceRobux = 149,
			Effect = "extra_employee_slot",
		},
		extra_vehicle_slot = {
			Id = 1997979360,
			PriceRobux = 149,
			Effect = "extra_vehicle_slot",
		},
		premium_workshop = {
			Id = 1999077322,
			PriceRobux = 249,
			Effect = "premium_workshop",
		},
	},
	DeveloperProducts = {
		small_cash = {
			Id = 3715317811,
			PriceRobux = 49,
			Grant = { Kind = "cash", Amount = 5_000 },
		},
		medium_cash = {
			Id = 3715317874,
			PriceRobux = 149,
			Grant = { Kind = "cash", Amount = 20_000 },
		},
		large_cash = {
			Id = 3715318066,
			PriceRobux = 399,
			Grant = { Kind = "cash", Amount = 65_000 },
		},
		boost_15 = {
			Id = 3715318201,
			PriceRobux = 39,
			Grant = { Kind = "cash_boost", Seconds = 15 * 60 },
		},
		boost_60 = {
			Id = 3715318256,
			PriceRobux = 99,
			Grant = { Kind = "cash_boost", Seconds = 60 * 60 },
		},
		instant_job_finish = {
			Id = 3715318304,
			PriceRobux = 29,
			Grant = { Kind = "instant_job_finish", Amount = 1 },
		},
	},
}

return table.freeze(MonetizationConfig)
