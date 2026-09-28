return function()
	local jobs = require("../src/shared/jobs/JobDefinitions")
	local tools = require("../src/shared/tools/ToolDefinitions")
	local vehicles = require("../src/shared/vehicles/VehicleDefinitions")

	assert(#jobs.List == 30, "launch job catalog must contain 30 jobs")
	assert(#tools.List == 20, "launch tool catalog must contain 20 tools")
	assert(#vehicles.List == 8, "launch vehicle catalog must contain 8 vehicles")
end
