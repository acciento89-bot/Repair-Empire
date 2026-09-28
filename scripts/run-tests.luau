local tests = {
	require("../tests/identifiers.spec"),
	require("../tests/service-order.spec"),
}

local passed = 0
for _, test in tests do
	test()
	passed += 1
end

print(("Repair Empire: %d pure Luau tests passed"):format(passed))
