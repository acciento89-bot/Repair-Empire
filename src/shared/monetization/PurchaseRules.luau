--!strict

local PurchaseRules = {}

function PurchaseRules.ProductById(monetizationConfig, productId: number)
	for key, config in monetizationConfig.DeveloperProducts do
		if config.Id == productId then
			return key, config
		end
	end
	return nil, nil
end

function PurchaseRules.ApplyGrant(profile, grant, timestamp: number)
	if grant.Kind == "cash" then
		profile.Cash += grant.Amount
		profile.Stats.MoneyEarned += grant.Amount
	elseif grant.Kind == "cash_boost" then
		local base = math.max(profile.Boosts.CashMultiplierUntil, timestamp)
		profile.Boosts.CashMultiplierUntil = base + grant.Seconds
	elseif grant.Kind == "instant_job_finish" then
		profile.Consumables.InstantJobFinishes += grant.Amount
	else
		error("Unsupported product grant: " .. tostring(grant.Kind))
	end
end

function PurchaseRules.ShouldEmitGrantAnalytics(receiptReason: string): boolean
	return receiptReason == "granted"
end

return table.freeze(PurchaseRules)
