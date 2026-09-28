--!strict

local PlatformConfig = {
	Environment = "development",
	UniverseId = 10768475286,
	ProductionStartPlaceId = 79925227687072,
	DevelopmentPlaceIds = {} :: { number },
	GamePassIds = {} :: { [string]: number },
	DeveloperProductIds = {} :: { [string]: number },
}

return table.freeze(PlatformConfig)
