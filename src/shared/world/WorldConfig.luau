--!strict

local WorldConfig = {
	AnchorInteractionDistance = 28,
	Districts = {
		residential = {
			Center = { 0, 0, 0 },
			BuildingCount = 10,
			Spacing = 42,
		},
		downtown = {
			Center = { 520, 0, 0 },
			BuildingCount = 10,
			Spacing = 46,
		},
		industrial = {
			Center = { 1_080, 0, 0 },
			BuildingCount = 10,
			Spacing = 54,
		},
	},
}

return table.freeze(WorldConfig)
