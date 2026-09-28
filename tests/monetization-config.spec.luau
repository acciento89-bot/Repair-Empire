return function()
	local config = require("../src/shared/config/MonetizationConfig")
	local passCount = 0
	local productCount = 0
	for _, pass in config.GamePasses do
		passCount += 1
		assert(pass.Id == nil, "real game pass IDs must not be invented in source")
	end
	for _, product in config.DeveloperProducts do
		productCount += 1
		assert(product.Id == nil, "real developer product IDs must not be invented in source")
	end
	assert(passCount == 5, "expected five launch pass hypotheses")
	assert(productCount == 6, "expected six launch developer products")
end
