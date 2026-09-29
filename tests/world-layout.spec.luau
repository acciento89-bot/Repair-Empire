return function()
	local world = require("../src/shared/world/WorldConfig")
	local layout = require("../src/shared/world/WorldLayoutRules")

	for districtId, config in world.Districts do
		for index = 1, config.BuildingCount do
			if
				layout.IsReservedBuildingSlot(
					districtId,
					index,
					world.WorkshopReservedBuildingIndex,
					world.WorkshopReservedBuildingSlots
				)
			then
				continue
			end

			local x, z = layout.GetBuildingPosition(config, index)
			assert(math.abs(x - config.Center[1]) <= config.GroundSize[1] / 2, districtId .. " building escaped district X bounds")
			assert(math.abs(z - config.Center[3]) <= config.GroundSize[2] / 2, districtId .. " building escaped district Z bounds")

			for categoryIndex = 1, 4 do
				local anchorX, anchorZ = layout.GetJobAnchorPosition(config, x, z, categoryIndex)
				local outsideFront = math.abs(anchorZ - z) > config.BuildingSize[2] / 2
				assert(outsideFront, districtId .. " job anchor must be outside the solid building shell")
				assert(math.abs(anchorX - x) < config.BuildingSize[1] / 2, districtId .. " job anchor must remain in front of the facade")
				assert(math.abs(anchorX - config.Center[1]) <= config.GroundSize[1] / 2, districtId .. " job anchor escaped district X bounds")
				assert(math.abs(anchorZ - config.Center[3]) <= config.GroundSize[2] / 2, districtId .. " job anchor escaped district Z bounds")
			end

			local walkwayZ, walkwayLength = layout.GetServiceWalkway({
				Center = config.Center,
				BuildingSize = config.BuildingSize,
				RoadWidth = world.RoadWidth,
			}, z)
			assert(walkwayLength >= 4, districtId .. " service walkway is too short")
			assert(math.abs(walkwayZ - config.Center[3]) < math.abs(z - config.Center[3]), districtId .. " service walkway must lead toward the road")
		end
	end
end
