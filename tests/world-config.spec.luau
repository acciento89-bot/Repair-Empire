return function()
	local world = require("../src/shared/world/WorldConfig")
	local count = 0
	for _ in world.Districts do
		count += 1
	end
	assert(count == 3, "V1 must define three districts")
	assert(world.Districts.residential ~= nil, "residential district missing")
	assert(world.Districts.downtown ~= nil, "downtown district missing")
	assert(world.Districts.industrial ~= nil, "industrial district missing")
	assert(world.AnchorInteractionDistance >= 20, "interaction distance is too strict for mobile/network play")
end
