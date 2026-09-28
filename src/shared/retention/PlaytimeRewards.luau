--!strict

local PlaytimeRewards = {}

PlaytimeRewards.Milestones = table.freeze({
	{ Seconds = 5 * 60, Cash = 150 },
	{ Seconds = 15 * 60, Cash = 300 },
	{ Seconds = 30 * 60, Cash = 500 },
	{ Seconds = 60 * 60, Cash = 900 },
	{ Seconds = 90 * 60, Cash = 1_400 },
})

function PlaytimeRewards.GetClaimable(playTimeSeconds: number, claimed: { [string]: boolean })
	local result = {}
	for index, reward in PlaytimeRewards.Milestones do
		local key = tostring(index)
		if playTimeSeconds >= reward.Seconds and claimed[key] ~= true then
			table.insert(result, {
				Index = index,
				Seconds = reward.Seconds,
				Cash = reward.Cash,
			})
		end
	end
	return result
end

function PlaytimeRewards.Next(playTimeSeconds: number, claimed: { [string]: boolean })
	for index, reward in PlaytimeRewards.Milestones do
		if claimed[tostring(index)] ~= true then
			return {
				Index = index,
				Seconds = reward.Seconds,
				Cash = reward.Cash,
				Ready = playTimeSeconds >= reward.Seconds,
				RemainingSeconds = math.max(0, reward.Seconds - playTimeSeconds),
			}
		end
	end
	return nil
end

return table.freeze(PlaytimeRewards)
