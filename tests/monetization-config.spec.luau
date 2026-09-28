return function()
	local config = require("../src/shared/config/MonetizationConfig")
	local passCount = 0
	local productCount = 0
	local ids = {}

	for _, pass in config.GamePasses do
		passCount += 1
		assert(type(pass.Id) == "number" and pass.Id > 0, "game pass ID must be configured")
		assert(type(pass.PriceRobux) == "number" and pass.PriceRobux > 0, "game pass price must be configured")
		assert(ids[pass.Id] == nil, "duplicate monetization ID")
		ids[pass.Id] = true
	end

	for _, product in config.DeveloperProducts do
		productCount += 1
		assert(type(product.Id) == "number" and product.Id > 0, "developer product ID must be configured")
		assert(type(product.PriceRobux) == "number" and product.PriceRobux > 0, "developer product price must be configured")
		assert(ids[product.Id] == nil, "duplicate monetization ID")
		ids[product.Id] = true
	end

	assert(passCount == 5, "expected five launch game passes")
	assert(productCount == 6, "expected six launch developer products")
end
