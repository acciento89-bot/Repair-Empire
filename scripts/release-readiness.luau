local rules = require("../src/shared/release/ReadinessRules")
local platform = require("../src/shared/config/PlatformConfig")
local monetization = require("../src/shared/config/MonetizationConfig")

local result = rules.Evaluate(platform, monetization)

print("Repair Empire release-readiness report")
print(("Sandbox-ready: %s"):format(if result.ReadyForSandbox then "yes" else "no"))

if #result.Blockers == 0 then
	print("No configuration blockers detected.")
else
	print(("External configuration blockers: %d"):format(#result.Blockers))
	for index, blocker in result.Blockers do
		print(("%02d. %s — %s"):format(index, blocker.Code, blocker.Detail))
	end
end
