local fs = require("@lune/fs")

return function()
	local source = fs.readFile("src/server/services/VehicleService.luau")

	assert(string.find(source, "collisionHull = createVehiclePart(", 1, true), "vehicle needs one explicit physics collision hull")
	assert(string.find(source, 'weld.Name = "DriveWeld"', 1, true), "vehicle visuals must be welded into one assembly")
	assert(string.find(source, "descendant.Anchored = false", 1, true), "drive assembly must be unanchored for physics interpolation")
	assert(string.find(source, "chassis:SetNetworkOwner(nil)", 1, true), "vehicle simulation must remain server-authoritative")
	assert(string.find(source, "chassis.AssemblyLinearVelocity", 1, true), "vehicle travel must use physical assembly velocity")
	assert(string.find(source, 'steering.Name = "DriveOrientation"', 1, true), "vehicle needs a stable physical steering orientation constraint")

	local stepStart = assert(string.find(source, "function VehicleService:_Step", 1, true))
	local stepEnd = assert(string.find(source, "function VehicleService:Init", stepStart, true))
	local stepSource = string.sub(source, stepStart, stepEnd - 1)
	assert(not string.find(stepSource, "model:PivotTo", 1, true), "live driving must not teleport the entire anchored model every heartbeat")
	assert(not string.find(stepSource, "GetPartBoundsInBox", 1, true), "live driving must not run an overlap-box sweep every heartbeat")
end
