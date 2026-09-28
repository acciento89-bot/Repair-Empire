return function()
	local rules = require("../src/shared/monetization/PassRules")

	assert(rules.CashMultiplier(false, false) == 1, "free cash multiplier changed")
	assert(rules.CashMultiplier(true, false) == 2, "double cash pass must yield 2x")
	assert(rules.CashMultiplier(false, true) == 2, "active boost must yield 2x")
	assert(rules.CashMultiplier(true, true) == 2, "paid boost/pass must not stack above 2x")

	assert(rules.EmployeeSlots(4, false) == 4, "free employee slots changed")
	assert(rules.EmployeeSlots(4, true) == 5, "extra employee pass must add exactly one slot")

	assert(rules.VehicleSlots(false) == 1, "free vehicle spawn slot changed")
	assert(rules.VehicleSlots(true) == 2, "extra vehicle pass must add exactly one concurrent spawn")
end
