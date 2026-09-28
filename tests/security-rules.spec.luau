return function()
	local rules = require("../src/shared/security/SecurityRules")
	local remotes = require("../src/shared/remotes/RemoteDefinitions")

	assert(rules.ValidateId("valid_id_123") == "valid_id_123", "valid machine ID rejected")
	assert(rules.ValidateId("") == nil, "empty ID must be rejected")
	assert(rules.ValidateId("UPPERCASE") == nil, "uppercase ID must be rejected")
	assert(rules.ValidateId("contains-dash") == nil, "dash must be rejected")
	assert(rules.ValidateId(string.rep("a", 101)) == nil, "oversized ID must be rejected")
	assert(rules.IsPayloadTable({}), "table payload must be accepted")
	assert(not rules.IsPayloadTable("payload"), "non-table payload must be rejected")

	for _, definition in remotes.List do
		assert(rules.IsValidRateLimit(definition.RateLimitPerSecond), "invalid rate limit for " .. definition.Name)
	end
end
