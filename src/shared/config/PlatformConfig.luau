--!strict

local PlatformConfig = {
	UniverseId = 10768475286,
	ProductionStartPlaceId = 79925227687072,
	DevelopmentPlaceIds = { 138882349802835 },
}

function PlatformConfig.EnvironmentForPlace(placeId: number, isStudio: boolean): string
	if isStudio then
		return "development"
	end

	if placeId == PlatformConfig.ProductionStartPlaceId then
		return "production"
	end

	for _, developmentPlaceId in PlatformConfig.DevelopmentPlaceIds do
		if placeId == developmentPlaceId then
			return "development"
		end
	end

	return "development"
end

return table.freeze(PlatformConfig)
