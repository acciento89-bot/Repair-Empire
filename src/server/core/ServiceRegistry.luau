--!strict

type Service = {
	Name: string,
	Dependencies: { string }?,
	Init: ((self: Service) -> ())?,
	Start: ((self: Service) -> ())?,
}

local ServiceRegistry = {}
ServiceRegistry.__index = ServiceRegistry

function ServiceRegistry.new()
	return setmetatable({
		_services = {} :: { [string]: Service },
		_order = {} :: { Service },
	}, ServiceRegistry)
end

function ServiceRegistry:Register(service: Service)
	assert(self._services[service.Name] == nil, "Duplicate service: " .. service.Name)
	self._services[service.Name] = service
	table.insert(self._order, service)
end

function ServiceRegistry:Get(name: string): Service
	local service = self._services[name]
	assert(service ~= nil, "Unknown service: " .. name)
	return service
end

local function visit(registry, service: Service, temporary, permanent, output)
	if permanent[service.Name] then
		return
	end
	assert(not temporary[service.Name], "Circular service dependency at " .. service.Name)
	temporary[service.Name] = true
	for _, dependencyName in service.Dependencies or {} do
		visit(registry, registry:Get(dependencyName), temporary, permanent, output)
	end
	temporary[service.Name] = nil
	permanent[service.Name] = true
	table.insert(output, service)
end

function ServiceRegistry:_ResolveOrder(): { Service }
	local output = {}
	local temporary = {}
	local permanent = {}
	for _, service in self._order do
		visit(self, service, temporary, permanent, output)
	end
	return output
end

function ServiceRegistry:InitAll()
	for _, service in self:_ResolveOrder() do
		if service.Init then
			service:Init()
		end
	end
end

function ServiceRegistry:StartAll()
	for _, service in self:_ResolveOrder() do
		if service.Start then
			service:Start()
		end
	end
end

return ServiceRegistry
