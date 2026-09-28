return function()
	local platform = require("../src/shared/config/PlatformConfig")

	assert(platform.EnvironmentForPlace(platform.ProductionStartPlaceId, false) == "production", "live production place must use production environment")
	assert(platform.EnvironmentForPlace(platform.ProductionStartPlaceId, true) == "development", "Studio must never write production DataStore")
	for _, placeId in platform.DevelopmentPlaceIds do
		assert(platform.EnvironmentForPlace(placeId, false) == "development", "development place must use development environment")
	end
	assert(platform.EnvironmentForPlace(0, true) == "development", "local Studio place must use development environment")
	assert(platform.EnvironmentForPlace(123456789, false) == "development", "unknown place must fail safe to development")
end
