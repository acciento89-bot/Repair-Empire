[Reading 324 lines from start (total: 324 lines, 0 remaining)]

--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local MenuController = require(script.Parent.Parent.ui.MenuController)

local StudioPlayerJourneyProbe = {}

local function remote(name: string): RemoteFunction
	local instance = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild(name)
	assert(instance:IsA("RemoteFunction"), name .. " must be a RemoteFunction")
	return instance
end

local function remoteEvent(name: string): RemoteEvent
	local instance = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild(name)
	assert(instance:IsA("RemoteEvent"), name .. " must be a RemoteEvent")
	return instance
end

local function pass(step: string)
	print("[Repair Empire E2E] PASS " .. step)
end

local function waitAttribute(player: Player, name: string, expected: any)
	for _ = 1, 150 do
		if player:GetAttribute(name) == expected then
			return
		end
		task.wait(0.1)
	end
	error(("Timed out waiting for %s=%s"):format(name, tostring(expected)))
end

local function findOwnedVehicle(player: Player): Model?
	for _, child in Workspace:GetChildren() do
		if child:IsA("Model") and child:GetAttribute("OwnerUserId") == player.UserId then
			return child
		end
	end
	return nil
end

local function moveToTarget(player: Player, target: Vector3)
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart")
	assert(root:IsA("BasePart"), "HumanoidRootPart missing")
	root.CFrame = CFrame.new(target + Vector3.new(0, 3, 3))
	task.wait(0.8)
end

local function completeJob(instanceId: string, firstStage, target: Vector3)
	local stage = firstStage
	for _ = 1, 8 do
		assert(stage ~= nil, "Job stage missing")
		task.wait((stage.MinimumSeconds or 0) + 0.45)
		local result = remote("PerformJobAction"):InvokeServer({
			instanceId = instanceId,
			action = stage.Action,
		})
		if type(result) == "table" and not result.ok and result.error == "too_far" then
			moveToTarget(Players.LocalPlayer, target)
			result = remote("PerformJobAction"):InvokeServer({
				instanceId = instanceId,
				action = stage.Action,
			})
		end
		assert(type(result) == "table" and result.ok, "Job action failed: " .. tostring(result and result.error))
		if result.completed == true then
			return
		end
		stage = result.stage
	end
	error("Job did not complete within 8 stages")
end

local function testCoreUi(player: Player)
	local playerGui = player:WaitForChild("PlayerGui")
	assert(playerGui:FindFirstChild("RepairEmpireHUD") ~= nil, "HUD missing")
	assert(playerGui:FindFirstChild("RepairEmpireNavigation") ~= nil, "Navigation UI missing")
	assert(playerGui:FindFirstChild("RepairEmpireInteraction") ~= nil, "Interaction UI missing")
	assert(playerGui:FindFirstChild("RepairEmpireMenu") ~= nil, "Main menu UI missing")
	pass("core UI mounted")
end

local function testMenu(player: Player)
	local playerGui = player:WaitForChild("PlayerGui")
	local menuGui = playerGui:WaitForChild("RepairEmpireMenu")
	local openButton = menuGui:FindFirstChild("OpenMenu")
	local panel = menuGui:FindFirstChild("Panel")
	assert(openButton and openButton:IsA("TextButton") and openButton.Visible, "Work Tablet button missing")
	assert(panel and panel:IsA("Frame"), "Menu panel missing")

	local camera = Workspace.CurrentCamera
	assert(camera ~= nil, "Camera unavailable for menu layout test")
	local viewport = camera.ViewportSize
	local buttonRight = openButton.AbsolutePosition.X + openButton.AbsoluteSize.X
	local buttonBottom = openButton.AbsolutePosition.Y + openButton.AbsoluteSize.Y
	assert(openButton.AbsolutePosition.X >= 0 and openButton.AbsolutePosition.Y >= 80, "Work Tablet overlaps top CoreGui zone")
	assert(buttonRight <= viewport.X + 2 and buttonBottom <= viewport.Y + 2, "Work Tablet outside viewport")

	MenuController.Open(false)
	assert(panel.Visible, "Work Tablet did not open menu")

	for _, tab in { "Jobs", "Co-op", "Tools", "Skills", "Vehicles", "Workshop", "Employees", "Daily", "Achievements", "Prestige", "Shop" } do
		MenuController.Render(tab)
		task.wait(0.05)
		local content = panel:FindFirstChild("Content")
		assert(content and content:IsA("Frame"), tab .. " content frame missing")
		local scroll = content:FindFirstChildOfClass("ScrollingFrame")
		assert(scroll ~= nil, tab .. " scrolling content missing")
		assert(#scroll:GetChildren() > 2, tab .. " rendered empty")
	end

	MenuController.Close()
	assert(not panel.Visible, "Work Tablet did not close")
	pass("work tablet placement + all menu tabs render")
end

local function testNavigation(player: Player, accepted)
	task.wait(1.8)
	local marker = Workspace:FindFirstChild("RepairEmpireJobSiteMarker")
	assert(marker ~= nil, "Job waypoint marker missing")
	local route = Workspace:FindFirstChild("RepairEmpireNavigationRoute")
	assert(route ~= nil and #route:GetChildren() >= 3, "Ground arrow route missing")

	local tutorialGui = player.PlayerGui:FindFirstChild("RepairEmpireHUD")
	local tutorial = tutorialGui and tutorialGui:FindFirstChild("Tutorial")
	assert(tutorial and tutorial:IsA("TextLabel"), "Tutorial label missing")
	local tutorialText = string.lower(tutorial.Text)
	assert(string.find(tutorialText, "arrow") ~= nil, "Tutorial does not explain the route arrows")
	assert(string.find(tutorialText, "job site") ~= nil, "Tutorial does not mention the job site waypoint")

	pass("waypoint + ground arrows + navigation tutorial")
	print(("[Repair Empire E2E] NAV target=%s routeParts=%d tutorial=%q"):format(tostring(accepted.targetPosition), #route:GetChildren(), tutorial.Text))
end

local function testTool(player: Player)
	local purchase = remote("PurchaseTool"):InvokeServer("basic_screwdriver")
	assert(type(purchase) == "table" and purchase.ok, "Basic screwdriver purchase failed: " .. tostring(purchase and purchase.error))
	local equip = remote("EquipTool"):InvokeServer("basic_screwdriver")
	assert(type(equip) == "table" and equip.ok, "Basic screwdriver equip failed")
	task.wait(0.2)
	assert(player:GetAttribute("EquippedTool") == "basic_screwdriver", "Equipped tool attribute did not update")
	pass("tool purchase + equip")
end

local function testSecondTutorialJob(player: Player)
	assert(player:GetAttribute("TutorialStep") == "second_job", "Tutorial did not advance to second_job after tool purchase")

	local offers = remote("RequestJobOffers"):InvokeServer()
	assert(type(offers) == "table" and offers.ok, "Second-job offers unavailable")

	local chosen = nil
	for _, offer in offers.offers or {} do
		if offer.Job and offer.Job.Id == "running_toilet" then
			chosen = offer
			break
		end
	end
	assert(chosen ~= nil, "Running Toilet tutorial job was not offered")

	local accepted = remote("AcceptJob"):InvokeServer(chosen.OfferId)
	assert(type(accepted) == "table" and accepted.ok, "Running Toilet accept failed: " .. tostring(accepted and accepted.error))
	task.wait(0.8)
	assert(Workspace:FindFirstChild("RepairEmpireJobSiteMarker") ~= nil, "Second-job waypoint missing")
	assert(Workspace:FindFirstChild("RepairEmpireNavigationRoute") ~= nil, "Second-job ground arrows missing")

	moveToTarget(player, accepted.targetPosition)
	completeJob(accepted.instanceId, accepted.stage, accepted.targetPosition)
	task.wait(0.7)

	assert(player:GetAttribute("TutorialStep") == "company_intro", "Tutorial did not advance through second repair")
	assert(Workspace:FindFirstChild("RepairEmpireJobSiteMarker") == nil, "Second-job waypoint remained after completion")
	assert(Workspace:FindFirstChild("RepairEmpireNavigationRoute") == nil, "Second-job route remained after completion")
	pass("second tutorial job + route + completion")
end

local function testVehicle(player: Player)
	local selectResult = remote("SelectVehicle"):InvokeServer("old_compact_van")
	assert(type(selectResult) == "table" and selectResult.ok, "Vehicle selection failed")
	local spawnResult = remote("SpawnVehicle"):InvokeServer()
	assert(type(spawnResult) == "table" and spawnResult.ok, "Vehicle spawn failed")
	task.wait(0.5)

	local model = findOwnedVehicle(player)
	assert(model and model.PrimaryPart, "Spawned vehicle model missing")
	assert(model:FindFirstChild("DriverSeat", true) ~= nil, "Driver seat missing")
	waitAttribute(player, "StudioE2EVehicleSeated", true)

	local before = model:GetPivot().Position
	for _ = 1, 14 do
		remoteEvent("UpdateVehicleInput"):FireServer({ throttle = 1, steer = 0 })
		task.wait(0.1)
	end
	remoteEvent("UpdateVehicleInput"):FireServer({ throttle = 0, steer = 0 })
	task.wait(0.25)
	local distance = (model:GetPivot().Position - before).Magnitude
	assert(distance > 5, ("Vehicle did not travel far enough: %.2f"):format(distance))
	pass(("vehicle spawn + seat + drive %.1f studs"):format(distance))

	local despawn = remote("DespawnVehicle"):InvokeServer()
	assert(type(despawn) == "table" and despawn.ok and (despawn.removed or 0) >= 1, "Vehicle despawn failed")
	task.wait(0.2)
	assert(findOwnedVehicle(player) == nil, "Vehicle model remained after despawn")
	pass("vehicle despawn")
end

local function testCompany(player: Player)
	local upgrade = remote("PurchaseUpgrade"):InvokeServer({ kind = "workshop" })
	assert(type(upgrade) == "table" and upgrade.ok and upgrade.workshopTier == 2, "Workshop upgrade failed: " .. tostring(upgrade and upgrade.error))
	task.wait(0.2)
	assert(player:GetAttribute("WorkshopTier") == 2, "Workshop tier attribute did not update")
	pass("workshop upgrade")

	local hire = remote("HireEmployee"):InvokeServer("apprentice_plumbing")
	assert(type(hire) == "table" and hire.ok, "Employee hire failed: " .. tostring(hire and hire.error))
	pass("employee hire")
end

local function testRespawnAndCamera(player: Player, previousCharacter: Model?)
	waitAttribute(player, "StudioE2ERespawned", true)
	local character = player.Character
	assert(character ~= nil and character ~= previousCharacter, "Character did not respawn")
	local humanoid = character:WaitForChild("Humanoid")
	local root = character:WaitForChild("HumanoidRootPart")
	assert(humanoid:IsA("Humanoid"), "Respawn humanoid missing")
	assert(root:IsA("BasePart"), "Respawn root missing")

	task.wait(0.8)
	local camera = Workspace.CurrentCamera
	assert(camera ~= nil and camera.CameraSubject == humanoid, "Camera did not rebind after respawn")
	local cameraBefore = camera.CFrame.Position
	root.CFrame = root.CFrame * CFrame.new(18, 0, 0)
	task.wait(0.8)
	local cameraAfter = camera.CFrame.Position
	assert((cameraAfter - cameraBefore).Magnitude > 10, "Camera did not follow moved character")
	assert((cameraAfter - root.Position).Magnitude < 30, "Camera detached too far from character")

	assert(player:GetAttribute("EquippedTool") == "basic_screwdriver", "Equipped tool did not survive respawn")
	assert(player:GetAttribute("WorkshopTier") == 2, "Workshop tier did not survive respawn")
	pass("respawn + camera follow + in-session state persistence")
end

local function run()
	local player = Players.LocalPlayer
	waitAttribute(player, "StudioE2EReady", true)
	testCoreUi(player)
	testMenu(player)

	assert(player:GetAttribute("TutorialStep") == "first_job", "Fresh tutorial did not start at first_job")
	pass("fresh profile + tutorial start")

	local startCash = player:GetAttribute("Cash") or 0
	local startLevel = player:GetAttribute("Level") or 1
	local startXP = player:GetAttribute("XP") or 0

	local offers = remote("RequestJobOffers"):InvokeServer()
	assert(type(offers) == "table" and offers.ok and #(offers.offers or {}) > 0, "Job offers unavailable")

	local chosen = offers.offers[1]
	for _, offer in offers.offers do
		if offer.Job and offer.Job.Id == "leaking_faucet" then
			chosen = offer
			break
		end
	end

	local accepted = remote("AcceptJob"):InvokeServer(chosen.OfferId)
	assert(type(accepted) == "table" and accepted.ok, "Job accept failed: " .. tostring(accepted and accepted.error))
	pass("job offer + accept")

	testNavigation(player, accepted)
	moveToTarget(player, accepted.targetPosition)
	completeJob(accepted.instanceId, accepted.stage, accepted.targetPosition)
	task.wait(0.7)

	local rewardedLevel = player:GetAttribute("Level") or 1
	local rewardedXP = player:GetAttribute("XP") or 0
	assert(rewardedLevel > startLevel or rewardedXP > startXP, "Job progression reward missing")
	assert((player:GetAttribute("Cash") or 0) > startCash, "Job cash reward missing")
	assert(Workspace:FindFirstChild("RepairEmpireJobSiteMarker") == nil, "Waypoint remained after job completion")
	assert(Workspace:FindFirstChild("RepairEmpireNavigationRoute") == nil, "Route remained after job completion")
	pass("job stages + completion + rewards + navigation cleanup")

	waitAttribute(player, "StudioE2ECashReady", true)
	assert((player:GetAttribute("Cash") or 0) >= 20_000, "Studio E2E cash fixture missing")

	testTool(player)
	testSecondTutorialJob(player)
	testVehicle(player)

	local characterBeforeCompany = player.Character
	testCompany(player)
	testRespawnAndCamera(player, characterBeforeCompany)

	local state = remote("RequestPlayerState"):InvokeServer()
	assert(type(state) == "table" and state.ok, "Final player state request failed")
	assert(state.state.EquippedTool == "basic_screwdriver", "Server state lost equipped tool")
	assert(state.state.WorkshopTier == 2, "Server state lost workshop tier")
	assert((state.state.Employees.apprentice_plumbing or 0) == 1, "Server state lost employee")
	assert((state.state.Stats.JobsCompleted or 0) >= 2, "Server state lost completed job stats")
	pass("authoritative final state")

	print("[Repair Empire E2E] COMPLETE player journey passed")
end

function StudioPlayerJourneyProbe.Start()
	if not RunService:IsStudio() or Workspace:GetAttribute("RepairEmpireE2E") ~= true then
		return
	end

	task.spawn(function()
		local ok, err = pcall(run)
		if not ok then
			warn("[Repair Empire E2E] FAIL " .. tostring(err))
		end
	end)
end

return StudioPlayerJourneyProbe

[executed on device: MacBookPro.fritz.box (eb87a35b-7c3f-490b-a79a-9556613a3bcc)]