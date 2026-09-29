--!strict

local WorldLayoutRules = {}

local CATEGORY_X_OFFSETS = table.freeze({ -7, -2.3, 2.3, 7 })

function WorldLayoutRules.GetBuildingPosition(config, index: number): (number, number)
	local col = (index - 1) % 5
	local row = math.floor((index - 1) / 5)
	local x = config.Center[1] + (col - 2) * config.Spacing
	local z = config.Center[3] + (row * 2 - 1) * config.Spacing
	return x, z
end

function WorldLayoutRules.IsReservedBuildingSlot(districtId: string, index: number, reservedIndex: number, reservedSlots: number): boolean
	return districtId == "residential" and index >= reservedIndex and index < reservedIndex + reservedSlots
end

function WorldLayoutRules.GetWorkshopCenter(config, reservedIndex: number, reservedSlots: number): (number, number)
	local firstX, firstZ = WorldLayoutRules.GetBuildingPosition(config, reservedIndex)
	local lastX, lastZ = WorldLayoutRules.GetBuildingPosition(config, reservedIndex + reservedSlots - 1)
	return (firstX + lastX) / 2, (firstZ + lastZ) / 2
end

function WorldLayoutRules.GetJobAnchorPosition(config, buildingX: number, buildingZ: number, categoryIndex: number): (number, number)
	local centerZ = config.Center[3]
	local frontDirection = if buildingZ > centerZ then -1 else 1
	local xOffset = CATEGORY_X_OFFSETS[categoryIndex] or 0
	local frontDistance = config.BuildingSize[2] / 2 + 6.5
	return buildingX + xOffset, buildingZ + frontDirection * frontDistance
end

function WorldLayoutRules.GetServiceWalkway(config, buildingZ: number): (number, number)
	local centerZ = config.Center[3]
	local side = if buildingZ > centerZ then 1 else -1
	local frontDirection = -side
	local buildingFrontZ = buildingZ + frontDirection * (config.BuildingSize[2] / 2 + 0.4)
	local sidewalkZ = centerZ + side * (config.RoadWidth / 2 + 2.5)
	local center = (buildingFrontZ + sidewalkZ) / 2
	local length = math.max(4, math.abs(buildingFrontZ - sidewalkZ))
	return center, length
end

return table.freeze(WorldLayoutRules)
