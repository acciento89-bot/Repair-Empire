local tests = {
	require("../tests/identifiers.spec"),
	require("../tests/service-order.spec"),
	require("../tests/job-rules.spec"),
	require("../tests/progression.spec"),
	require("../tests/content-catalog.spec"),
	require("../tests/company.spec"),
	require("../tests/world-config.spec"),
	require("../tests/coop.spec"),
	require("../tests/coop-rules.spec"),
	require("../tests/monetization-config.spec"),
	require("../tests/retention.spec"),
	require("../tests/prestige.spec"),
	require("../tests/prestige-rules.spec"),
	require("../tests/balance-guardrails.spec"),
	require("../tests/profile-migration.spec"),
	require("../tests/job-validator.spec"),
	require("../tests/tool-rules.spec"),
	require("../tests/economy-model.spec"),
	require("../tests/security-rules.spec"),
	require("../tests/mutation-guard.spec"),
	require("../tests/rate-limiter.spec"),
	require("../tests/receipt-rules.spec"),
	require("../tests/session-rules.spec"),
	require("../tests/ui-layout-rules.spec"),
	require("../tests/ui-contrast.spec"),
	require("../tests/menu-navigation.spec"),
	require("../tests/release-readiness.spec"),
	require("../tests/pass-rules.spec"),
	require("../tests/purchase-rules.spec"),
	require("../tests/skill-tree.spec"),
	require("../tests/onboarding-economy.spec"),
	require("../tests/platform-environment.spec"),
}

local passed = 0
for _, test in tests do
	test()
	passed += 1
end

print(("Repair Empire: %d pure Luau tests passed"):format(passed))
