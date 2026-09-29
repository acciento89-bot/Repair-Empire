--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage.RepairEmpire.Shared
local JobDefinitions = require(Shared.jobs.JobDefinitions)
local JobActionRules = require(Shared.jobs.JobActionRules)
local RepairSceneCatalog = require(Shared.jobs.RepairSceneCatalog)

local JobCatalogRuntimeProbe = {}

function JobCatalogRuntimeProbe.Run()
	assert(RunService:IsStudio(), "JobCatalogRuntimeProbe is Studio-only")

	local worldService = require(script.Parent.Parent.services.WorldService)
	local jobsChecked = 0
	local stagesChecked = 0
	local variants = {}

	for _, definition in JobDefinitions.List do
		jobsChecked += 1

		local anchor = worldService:AssignAnchor(definition.District, definition.Category)
		assert(anchor ~= nil, ("No runtime anchor for job %s (%s/%s)"):format(definition.Id, definition.District, definition.Category))
		assert(anchor:GetAttribute("DistrictId") == definition.District, definition.Id .. " runtime anchor district mismatch")
		assert(anchor:GetAttribute("CategoryId") == definition.Category, definition.Id .. " runtime anchor category mismatch")
		assert(type(anchor:GetAttribute("AnchorId")) == "string", definition.Id .. " runtime anchor has no stable id")

		local scene = RepairSceneCatalog.Get(definition.Id, definition.Category)
		assert(scene.Category == definition.Category, definition.Id .. " repair-scene category mismatch")
		assert(type(scene.Variant) == "string" and #scene.Variant > 0, definition.Id .. " has no runtime repair-scene variant")
		variants[scene.Variant] = true

		for stageIndex, stage in definition.Stages do
			stagesChecked += 1
			local instanceId = ("%s:%d"):format(definition.Id, stageIndex)
			local active = {
				InstanceId = instanceId,
				Completing = false,
			}
			local elapsed = stage.MinimumSeconds + 0.25

			local valid = JobActionRules.Validate({
				active = active,
				instanceId = instanceId,
				wasCompleted = false,
				definition = definition,
				stage = stage,
				action = stage.Action,
				isNear = true,
				elapsed = elapsed,
				effectiveSeconds = stage.MinimumSeconds,
			})
			assert(valid.ok, ("%s stage %d happy path rejected: %s"):format(definition.Id, stageIndex, tostring(valid.error)))

			local wrongAction = JobActionRules.Validate({
				active = active,
				instanceId = instanceId,
				wasCompleted = false,
				definition = definition,
				stage = stage,
				action = "__wrong_action__",
				isNear = true,
				elapsed = elapsed,
				effectiveSeconds = stage.MinimumSeconds,
			})
			assert(not wrongAction.ok and wrongAction.error == "wrong_action", definition.Id .. " wrong-action guard failed")

			local tooFar = JobActionRules.Validate({
				active = active,
				instanceId = instanceId,
				wasCompleted = false,
				definition = definition,
				stage = stage,
				action = stage.Action,
				isNear = false,
				elapsed = elapsed,
				effectiveSeconds = stage.MinimumSeconds,
			})
			assert(not tooFar.ok and tooFar.error == "too_far_from_job", definition.Id .. " spatial guard failed")

			local tooFast = JobActionRules.Validate({
				active = active,
				instanceId = instanceId,
				wasCompleted = false,
				definition = definition,
				stage = stage,
				action = stage.Action,
				isNear = true,
				elapsed = math.max(0, stage.MinimumSeconds - 0.3),
				effectiveSeconds = stage.MinimumSeconds,
			})
			assert(not tooFast.ok and tooFast.error == "too_fast", definition.Id .. " timing guard failed")
		end
	end

	local variantCount = 0
	for _ in variants do
		variantCount += 1
	end

	assert(jobsChecked == 30, ("Runtime job catalog expected 30 jobs, got %d"):format(jobsChecked))
	assert(variantCount >= 14, ("Runtime repair scene coverage too small: %d variants"):format(variantCount))

	print(
		("[Repair Empire] JobCatalogRuntimeProbe passed jobs=%d stages=%d sceneVariants=%d anchors=all securityGuards=all"):format(
			jobsChecked,
			stagesChecked,
			variantCount
		)
	)
end

return JobCatalogRuntimeProbe