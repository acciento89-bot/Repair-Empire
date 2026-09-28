--!strict

local BalanceGuardrails = {}

function BalanceGuardrails.IsStrictlyIncreasing(values: { number }): boolean
	for index = 2, #values do
		if values[index] <= values[index - 1] then
			return false
		end
	end
	return true
end

function BalanceGuardrails.Sum(values: { number }): number
	local total = 0
	for _, value in values do
		total += value
	end
	return total
end

function BalanceGuardrails.PassiveCapValue(cashPerMinute: number, capMinutes: number): number
	return math.floor(cashPerMinute * capMinutes)
end

return BalanceGuardrails
