return function()
	local order = {}
	local services = {
		A = { deps = {} },
		B = { deps = { "A" } },
		C = { deps = { "B" } },
	}
	local visited = {}
	local function visit(name)
		if visited[name] then
			return
		end
		for _, dep in services[name].deps do
			visit(dep)
		end
		visited[name] = true
		table.insert(order, name)
	end
	visit("C")
	assert(table.concat(order, ",") == "A,B,C", "service dependency order is invalid")
end
