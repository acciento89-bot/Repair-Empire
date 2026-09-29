--!strict

local WorldConfig = {
	AnchorInteractionDistance = 28,
	RoadWidth = 20,
	ConnectorRoadWidth = 24,
	WorkshopReservedBuildingIndex = 6,
	LegacyWorkspaceRoots = table.freeze({
		"Billboards",
		"Cabins",
		"ConstructionZone",
		"Foliage",
		"Props",
		"Tools",
		"Baseplate",
		"SpawnLocation",
	}),
	Districts = {
		residential = {
			DisplayName = "Residential",
			Center = { 0, 0, 0 },
			BuildingCount = 10,
			Spacing = 42,
			GroundSize = { 270, 190 },
			BuildingSize = { 26, 26 },
			HeightBase = 18,
			HeightVariance = 18,
			AnchorRadius = 18,
		},
		downtown = {
			DisplayName = "Downtown",
			Center = { 520, 0, 0 },
			BuildingCount = 10,
			Spacing = 46,
			GroundSize = { 300, 210 },
			BuildingSize = { 32, 32 },
			HeightBase = 34,
			HeightVariance = 34,
			AnchorRadius = 22,
		},
		industrial = {
			DisplayName = "Industrial",
			Center = { 1_080, 0, 0 },
			BuildingCount = 10,
			Spacing = 54,
			GroundSize = { 340, 230 },
			BuildingSize = { 40, 36 },
			HeightBase = 18,
			HeightVariance = 16,
			AnchorRadius = 28,
		},
	},
	DistrictOrder = {
		"residential",
		"downtown",
		"industrial",
	},
}

return table.freeze(WorldConfig)
