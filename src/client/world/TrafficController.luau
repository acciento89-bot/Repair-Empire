--!strict

local RunService = game:GetService("RunService")

local TrafficController = {
	_models = {},
	_connection = nil,
}

local COLORS = {
	Color3.fromRGB(73, 118, 160),
	Color3.fromRGB(162, 78, 68),
	Color3.fromRGB(92, 132, 91),
	Color3.fromRGB(185, 151, 67),
	Color3.fromRGB(91, 94, 100),
}

local ROUTE_MIN_X = -180
local ROUTE_MAX_X = 1260
local LANE_Z = { -4.3, 4.3 }

local function part(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function buildCar(index: number, lane: number, direction: number)
	local model = Instance.new("Model")
	model.Name = ("AmbientTraffic_%02d"):format(index)
	model:SetAttribute("Direction", direction)
	model:SetAttribute("Speed", 22 + (index % 4) * 2.5)
	model:SetAttribute("Lane", lane)
	model.Parent = workspace

	local color = COLORS[((index - 1) % #COLORS) + 1]
	local cf = CFrame.new(0, 0, 0)

	local chassis = part(model, "Chassis", Vector3.new(5.6, 0.8, 10.2), cf * CFrame.new(0, 1.0, 0), Color3.fromRGB(45, 48, 51), Enum.Material.Metal)
	part(model, "Body", Vector3.new(5.2, 2.0, 8.8), cf * CFrame.new(0, 2.1, 0), color, Enum.Material.SmoothPlastic)
	local cabin = part(model, "Cabin", Vector3.new(4.6, 2.1, 4.2), cf * CFrame.new(0, 3.4, -0.4), color, Enum.Material.SmoothPlastic)
	local front = part(model, "Windscreen", Vector3.new(4.0, 1.25, 0.14), cabin.CFrame * CFrame.new(0, 0.25, -2.14), Color3.fromRGB(82, 142, 166), Enum.Material.Glass)
	front.Transparency = 0.18

	for _, side in { -1, 1 } do
		local window = part(model, "SideWindow", Vector3.new(0.12, 1.2, 2.5), cabin.CFrame * CFrame.new(side * 2.36, 0.2, 0), Color3.fromRGB(77, 132, 155), Enum.Material.Glass)
		window.Transparency = 0.2
		for _, z in { -3.2, 3.2 } do
			local wheel = part(model, "Wheel", Vector3.new(0.7, 1.55, 1.55), cf * CFrame.new(side * 2.65, 0.8, z), Color3.fromRGB(24, 26, 28))
			wheel.Shape = Enum.PartType.Cylinder
			wheel.Orientation = Vector3.new(0, 0, 90)
		end
	end

	for _, side in { -1, 1 } do
		local headlight = part(model, "Headlight", Vector3.new(1.0, 0.42, 0.12), cf * CFrame.new(side * 1.65, 1.7, -4.5), Color3.fromRGB(255, 234, 177), Enum.Material.Neon)
		headlight.Transparency = 0.05
		local tail = part(model, "TailLight", Vector3.new(0.85, 0.42, 0.12), cf * CFrame.new(side * 1.65, 1.7, 4.5), Color3.fromRGB(205, 59, 52), Enum.Material.Neon)
		tail.Transparency = 0.08
	end

	model.PrimaryPart = chassis
	return model
end

local function setCarPosition(entry, x: number)
	local z = LANE_Z[entry.Lane]
	local yaw = if entry.Direction > 0 then math.rad(90) else math.rad(-90)
	entry.Model:PivotTo(CFrame.new(x, 0.05, z) * CFrame.Angles(0, yaw, 0))
	entry.X = x
end

function TrafficController.Start()
	if TrafficController._connection then
		return
	end

	for index = 1, 5 do
		local direction = if index % 2 == 0 then -1 else 1
		local lane = if direction > 0 then 1 else 2
		local model = buildCar(index, lane, direction)
		local span = ROUTE_MAX_X - ROUTE_MIN_X
		local x = ROUTE_MIN_X + ((index - 1) / 5) * span
		local entry = {
			Model = model,
			Lane = lane,
			Direction = direction,
			Speed = model:GetAttribute("Speed") or 24,
			X = x,
		}
		setCarPosition(entry, x)
		table.insert(TrafficController._models, entry)
	end

	TrafficController._connection = RunService.RenderStepped:Connect(function(dt)
		for _, entry in TrafficController._models do
			if entry.Model.Parent == nil then
				continue
			end
			local nextX = entry.X + entry.Direction * entry.Speed * dt
			if entry.Direction > 0 and nextX > ROUTE_MAX_X then
				nextX = ROUTE_MIN_X
			elseif entry.Direction < 0 and nextX < ROUTE_MIN_X then
				nextX = ROUTE_MAX_X
			end
			setCarPosition(entry, nextX)
		end
	end)
end

return TrafficController
