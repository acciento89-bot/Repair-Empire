return function()
	local jobs = require("../src/shared/jobs/JobDefinitions")
	local tools = require("../src/shared/tools/ToolDefinitions")
	local vehicles = require("../src/shared/vehicles/VehicleDefinitions")

	assert(#jobs.List == 30, "launch job catalog must contain 30 jobs")
	assert(#tools.List == 20, "launch tool catalog must contain 20 tools")
	local toolFamilies = {}
	for _, definition in tools.List do
		toolFamilies[definition.Family] = true
	end
	local familyCount = 0
	for _ in toolFamilies do
		familyCount += 1
	end
	assert(familyCount == 9, "launch tool catalog must cover nine approved tool families")
	assert(#vehicles.List == 8, "launch vehicle catalog must contain 8 vehicles")
	local vehicleStyles = {}
	for _, definition in vehicles.List do
		assert(definition.BodySize[1] > 0 and definition.BodySize[2] > 0 and definition.BodySize[3] > 0, "vehicle body dimensions must be positive")
		if definition.Id == "old_compact_van" then
			assert(definition.BodySize[2] >= 4.0, "starter van must not regress to a vertically squashed silhouette")
			assert(definition.BodySize[1] / definition.BodySize[2] <= 1.7, "starter van width/height ratio is too flat")
		end
		assert(definition.Axles >= 2, "launch vehicles must define at least two axles")
		assert(definition.Seats >= 2, "launch vehicles must support driver plus passenger")
		assert(vehicleStyles[definition.Style] == nil, "launch vehicle styles must be visually distinct")
		vehicleStyles[definition.Style] = true
	end
end
