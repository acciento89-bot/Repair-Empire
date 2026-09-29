--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.RepairEmpire.Shared
local EmployeeDefinitions = require(Shared.company.EmployeeDefinitions)
local CompanyConfig = require(Shared.config.CompanyConfig)
local PassRules = require(Shared.monetization.PassRules)
local MutationGuard = require(script.Parent.Parent.security.MutationGuard)

local CompanyService = {
	Name = "CompanyService",
	Dependencies = { "PlayerDataService", "EconomyService", "SecurityService", "EntitlementService", "AnalyticsService" },
}

local function remote(name: string): RemoteFunction
	local instance = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild(name)
	assert(instance:IsA("RemoteFunction"), name .. " must be a RemoteFunction")
	return instance
end

local function stateEvent(): RemoteEvent
	local instance = ReplicatedStorage:WaitForChild("RepairEmpireRemotes"):WaitForChild("StateUpdated")
	assert(instance:IsA("RemoteEvent"), "StateUpdated must be a RemoteEvent")
	return instance
end

local function employeeCount(profile): number
	local count = 0
	for _, ownedCount in profile.Employees do
		count += ownedCount
	end
	return count
end

local function passiveRate(profile): number
	local rate = 0
	for employeeId, ownedCount in profile.Employees do
		local definition = EmployeeDefinitions.ById[employeeId]
		if definition then
			rate += definition.CashPerMinute * ownedCount
		end
	end
	return rate
end

function CompanyService:GetEmployeeSlots(player: Player, profile): number
	local baseSlots = CompanyConfig.EmployeeSlotsByWorkshopTier[profile.WorkshopTier] or 0
	local entitlementService = require(script.Parent.EntitlementService)
	return PassRules.EmployeeSlots(baseSlots, entitlementService:HasPass(player, "extra_employee_slot"))
end

function CompanyService:UpgradeWorkshop(player: Player)
	local security = require(script.Parent.SecurityService)
	if not security:Allow(player, "PurchaseUpgrade") then
		return { ok = false, error = "rate_limited" }
	end

	local entered, result = MutationGuard.TryRun(player.UserId, "profile_value_mutation", function()
		local dataService = require(script.Parent.PlayerDataService)
		local economy = require(script.Parent.EconomyService)
		local profile = dataService:RequireProfile(player)

		if profile.WorkshopTier >= CompanyConfig.MaxWorkshopTier then
			return { ok = false, error = "max_tier" }
		end

		local nextTier = profile.WorkshopTier + 1
		local cost = CompanyConfig.WorkshopUpgradeCosts[nextTier]
		if cost == nil then
			return { ok = false, error = "invalid_tier" }
		end
		if not economy:Spend(player, "cash", cost, ("workshop_tier_%d"):format(nextTier)) then
			return { ok = false, error = "insufficient_funds" }
		end

		profile.WorkshopTier = nextTier
		dataService:Publish(player)
		return { ok = true, workshopTier = nextTier }
	end)
	if not entered then
		return { ok = false, error = "mutation_in_progress" }
	end
	if result and result.ok then
		stateEvent():FireClient(player, {
			kind = "company_changed",
			workshopTier = result.workshopTier,
		})
	end
	return result
end

function CompanyService:HireEmployee(player: Player, employeeId: any)
	local security = require(script.Parent.SecurityService)
	if not security:Allow(player, "HireEmployee") then
		return { ok = false, error = "rate_limited" }
	end
	if type(employeeId) ~= "string" then
		return { ok = false, error = "invalid_employee" }
	end

	local definition = EmployeeDefinitions.ById[employeeId]
	if definition == nil then
		return { ok = false, error = "invalid_employee" }
	end

	local entered, result = MutationGuard.TryRun(player.UserId, "profile_value_mutation", function()
		local dataService = require(script.Parent.PlayerDataService)
		local economy = require(script.Parent.EconomyService)
		local profile = dataService:RequireProfile(player)

		if profile.WorkshopTier < definition.MinimumWorkshopTier then
			return { ok = false, error = "workshop_locked" }
		end
		if profile.CompanyLevel < definition.MinimumCompanyLevel then
			return { ok = false, error = "company_level_locked" }
		end
		if employeeCount(profile) >= self:GetEmployeeSlots(player, profile) then
			return { ok = false, error = "employee_slots_full" }
		end
		if not economy:Spend(player, "cash", definition.Cost, "employee:" .. employeeId) then
			return { ok = false, error = "insufficient_funds" }
		end

		profile.Employees[employeeId] = (profile.Employees[employeeId] or 0) + 1
		dataService:Publish(player)
		local analytics = require(script.Parent.AnalyticsService)
		analytics:LogOnce(player, "first_employee_hired", 1)
		return { ok = true, slotsUsed = employeeCount(profile), slotsTotal = self:GetEmployeeSlots(player, profile) }
	end)
	if not entered then
		return { ok = false, error = "mutation_in_progress" }
	end
	if result and result.ok then
		stateEvent():FireClient(player, {
			kind = "company_changed",
			slotsUsed = result.slotsUsed,
			slotsTotal = result.slotsTotal,
		})
	end
	return result
end

function CompanyService:ApplyPassiveIncome(player: Player)
	local dataService = require(script.Parent.PlayerDataService)
	local economy = require(script.Parent.EconomyService)
	local profile = dataService:GetProfile(player)
	if profile == nil then
		return 0
	end

	local now = DateTime.now().UnixTimestamp
	if profile.LastPassiveTimestamp == 0 then
		profile.LastPassiveTimestamp = now
		return 0
	end

	local elapsedSeconds = math.max(0, now - profile.LastPassiveTimestamp)
	local eligibleMinutes = math.min(elapsedSeconds / 60, CompanyConfig.OfflinePassiveCapMinutes)
	local amount = math.floor(passiveRate(profile) * eligibleMinutes)
	profile.LastPassiveTimestamp = now

	if amount > 0 then
		economy:Grant(player, "cash", amount, "company_passive")
		profile.Stats.PassiveCashEarned += amount
		dataService:Publish(player)
	end

	return amount
end

function CompanyService:Init()
	remote("HireEmployee").OnServerInvoke = function(player, employeeId)
		return self:HireEmployee(player, employeeId)
	end
	remote("PurchaseUpgrade").OnServerInvoke = function(player, payload)
		if type(payload) ~= "table" or payload.kind ~= "workshop" then
			return { ok = false, error = "invalid_upgrade" }
		end
		return self:UpgradeWorkshop(player)
	end
end

function CompanyService:Start()
	task.spawn(function()
		while true do
			task.wait(CompanyConfig.PassiveTickSeconds)
			for _, player in Players:GetPlayers() do
				task.spawn(function()
					self:ApplyPassiveIncome(player)
				end)
			end
		end
	end)
end

return CompanyService
