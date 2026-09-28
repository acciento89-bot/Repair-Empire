--!strict

local WorldConfig = {
	AnchorInteractionDistance = 28,
	Districts = {
		residential = {
			Center = Vector3.new(0, 0, 0),
			BuildingCount = 10,
			Spacing = 42,
		},
		downtown = {
			Center = Vector3.new(520, 0, 0),
			BuildingCount = 10,
			Spacing = 46,
		},
		industrial = {
			Center = Vector3.new(1_080, 0, 0),
			BuildingCount = 10,
			Spacing = 54,
		},
	},
}

return table.freeze(WorldConfig)
