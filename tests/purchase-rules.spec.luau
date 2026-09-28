return function()
	local config = require("../src/shared/config/MonetizationConfig")
	local ProfileSchema = require("../src/shared/data/ProfileSchema")
	local rules = require("../src/shared/monetization/PurchaseRules")

	local productKey, product = rules.ProductById(config, config.DeveloperProducts.small_cash.Id)
	assert(productKey == "small_cash" and product == config.DeveloperProducts.small_cash, "configured ProductId lookup failed")

	local missingKey, missingProduct = rules.ProductById(config, 999_999_999)
	assert(missingKey == nil and missingProduct == nil, "unknown ProductId must not resolve")

	local cashProfile = ProfileSchema.NewProfile()
	rules.ApplyGrant(cashProfile, { Kind = "cash", Amount = 500 }, 100)
	assert(cashProfile.Cash == 500, "cash product grant failed")
	assert(cashProfile.Stats.MoneyEarned == 500, "cash product must update lifetime earnings")

	local boostProfile = ProfileSchema.NewProfile()
	rules.ApplyGrant(boostProfile, { Kind = "cash_boost", Seconds = 900 }, 1_000)
	assert(boostProfile.Boosts.CashMultiplierUntil == 1_900, "fresh cash boost did not start at current timestamp")
	boostProfile.Boosts.CashMultiplierUntil = 2_000
	rules.ApplyGrant(boostProfile, { Kind = "cash_boost", Seconds = 900 }, 1_500)
	assert(boostProfile.Boosts.CashMultiplierUntil == 2_900, "stacked cash boost did not extend existing duration")

	local finishProfile = ProfileSchema.NewProfile()
	rules.ApplyGrant(finishProfile, { Kind = "instant_job_finish", Amount = 2 }, 100)
	assert(finishProfile.Consumables.InstantJobFinishes == 2, "instant-finish consumable grant failed")

	local unsupportedOk = pcall(function()
		rules.ApplyGrant(ProfileSchema.NewProfile(), { Kind = "unknown" }, 100)
	end)
	assert(not unsupportedOk, "unsupported product grants must fail closed")

	assert(rules.ShouldEmitGrantAnalytics("granted"), "new receipt must emit grant analytics")
	assert(not rules.ShouldEmitGrantAnalytics("already_processed"), "duplicate receipt must not duplicate grant analytics")
	assert(not rules.ShouldEmitGrantAnalytics("save_failed"), "failed receipt must not emit grant analytics")
end
