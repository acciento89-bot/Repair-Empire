--!strict

local MonetizationConfig = {
	GamePasses = {
		double_cash = {
			Id = nil :: number?,
			PriceHypothesis = 299,
			Effect = "double_cash",
		},
		vip = {
			Id = nil :: number?,
			PriceHypothesis = 399,
			Effect = "vip",
		},
		extra_employee_slot = {
			Id = nil :: number?,
			PriceHypothesis = 149,
			Effect = "extra_employee_slot",
		},
		extra_vehicle_slot = {
			Id = nil :: number?,
			PriceHypothesis = 149,
			Effect = "extra_vehicle_slot",
		},
		premium_workshop = {
			Id = nil :: number?,
			PriceHypothesis = 249,
			Effect = "premium_workshop",
		},
	},
	DeveloperProducts = {
		small_cash = {
			Id = nil :: number?,
			PriceHypothesis = 49,
			Grant = { Kind = "cash", Amount = 5_000 },
		},
		medium_cash = {
			Id = nil :: number?,
			PriceHypothesis = 149,
			Grant = { Kind = "cash", Amount = 20_000 },
		},
		large_cash = {
			Id = nil :: number?,
			PriceHypothesis = 399,
			Grant = { Kind = "cash", Amount = 65_000 },
		},
		boost_15 = {
			Id = nil :: number?,
			PriceHypothesis = 39,
			Grant = { Kind = "cash_boost", Seconds = 15 * 60 },
		},
		boost_60 = {
			Id = nil :: number?,
			PriceHypothesis = 99,
			Grant = { Kind = "cash_boost", Seconds = 60 * 60 },
		},
		instant_job_finish = {
			Id = nil :: number?,
			PriceHypothesis = 29,
			Grant = { Kind = "instant_job_finish", Amount = 1 },
		},
	},
}

return table.freeze(MonetizationConfig)
