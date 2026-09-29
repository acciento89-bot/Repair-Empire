return function()
	local jobs = require("../src/shared/jobs/JobDefinitions")
	local tools = require("../src/shared/tools/ToolDefinitions")
	local vehicles = require("../src/shared/vehicles/VehicleDefinitions")

	local supportedTrades = {
		plumbing = true,
		heating = true,
		climate = true,
		energy = true,
	}
	for _, job in jobs.List do
		assert(supportedTrades[job.Category] == true, "missing production-art trade scene for " .. job.Category)
	end

	local supportedToolFamilies = {
		wrench = true,
		screwdriver = true,
		pliers = true,
		drain = true,
		diagnostic_meter = true,
		heating_service = true,
		pressure_service = true,
		climate_service = true,
		energy_diagnostic = true,
	}
	for _, definition in tools.List do
		assert(supportedToolFamilies[definition.Family] == true, "missing production tool visual for " .. definition.Family)
	end

	local styles = {}
	for _, definition in vehicles.List do
		assert(type(definition.Style) == "string" and #definition.Style > 0, definition.Id .. " missing visual style")
		assert(styles[definition.Style] == nil, "vehicle production styles must remain distinct")
		styles[definition.Style] = true
	end
	assert(#vehicles.List == 8, "production vehicle catalog unexpectedly changed")
end
