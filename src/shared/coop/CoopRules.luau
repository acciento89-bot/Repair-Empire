--!strict

local CoopRules = {}

function CoopRules.ParticipantCount(participants): number
	local count = 0
	for _ in participants do
		count += 1
	end
	return count
end

function CoopRules.NextOwner(participants): number?
	local nextOwner = nil
	for userId in participants do
		if nextOwner == nil or userId < nextOwner then
			nextOwner = userId
		end
	end
	return nextOwner
end

function CoopRules.HasContribution(amount: number?): boolean
	return type(amount) == "number" and amount > 0
end

function CoopRules.RewardShare(contribution: number, totalContribution: number): number
	if contribution <= 0 or totalContribution <= 0 then
		return 0
	end
	return contribution / totalContribution
end

function CoopRules.CanJoin(participants, maxPartySize: number): boolean
	return CoopRules.ParticipantCount(participants) < maxPartySize
end

return table.freeze(CoopRules)
