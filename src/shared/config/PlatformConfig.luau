--!strict

local PlatformConfig = {
	Environment = "development",
	UniverseId = nil :: number?,
	ProductionStartPlaceId = nil :: number?,
	DevelopmentPlaceIds = {} :: { number },
	GamePassIds = {} :: { [string]: number },
	DeveloperProductIds = {} :: { [string]: number },
}

return table.freeze(PlatformConfig)
