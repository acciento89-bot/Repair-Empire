return function()
	local rules = require("../src/shared/vehicles/VehicleInputRules")

	local valid = rules.Normalize({ throttle = 1, steer = -0.5 })
	assert(valid ~= nil, "valid vehicle input rejected")
	assert(valid.Throttle == 1 and valid.Steer == -0.5, "vehicle input changed unexpectedly")

	assert(rules.Normalize(nil) == nil, "nil vehicle input accepted")
	assert(rules.Normalize({ throttle = "1", steer = 0 }) == nil, "string throttle accepted")
	assert(rules.Normalize({ throttle = 0, steer = 1.01 }) == nil, "out-of-range steer accepted")
	assert(rules.Normalize({ throttle = 0 / 0, steer = 0 }) == nil, "NaN throttle accepted")
	assert(rules.Normalize({ throttle = math.huge, steer = 0 }) == nil, "infinite throttle accepted")
end
