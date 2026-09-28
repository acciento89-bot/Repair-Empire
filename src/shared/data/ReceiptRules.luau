--!strict

local ReceiptRules = {}

function ReceiptRules.BuildCandidate(profile, receiptId: string, timestamp: number, clone, mutator)
	if #receiptId == 0 or #receiptId > 200 then
		return false, "invalid_receipt", profile, false, "invalid receipt id"
	end

	if profile.ProcessedReceipts[receiptId] ~= nil then
		return true, "already_processed", profile, false, nil
	end

	local candidate = clone(profile)
	local ok, err = pcall(mutator, candidate)
	if not ok then
		return false, "grant_failed", profile, false, tostring(err)
	end

	candidate.ProcessedReceipts[receiptId] = timestamp
	return true, "granted", candidate, true, nil
end

return ReceiptRules
