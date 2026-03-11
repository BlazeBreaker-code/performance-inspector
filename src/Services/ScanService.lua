--!strict

local root = script.Parent.Parent
local Core = root:WaitForChild("Core")

local Types = require(Core:WaitForChild("Types"))

local ScanService = {}

local function countIf(rootInstance: Instance, predicate: (Instance) -> boolean): number
	local count = 0

	for _, descendant in ipairs(rootInstance:GetDescendants()) do
		if predicate(descendant) then
			count += 1
		end
	end

	return count
end

local function isScriptLike(instance: Instance): boolean
	return instance:IsA("Script") or instance:IsA("LocalScript") or instance:IsA("ModuleScript")
end

local function isLightLike(instance: Instance): boolean
	return instance:IsA("PointLight")
		or instance:IsA("SpotLight")
		or instance:IsA("SurfaceLight")
end

local function isParticleLike(instance: Instance): boolean
	return instance:IsA("ParticleEmitter")
		or instance:IsA("Beam")
		or instance:IsA("Trail")
end

local function isCandidateRoot(instance: Instance): boolean
	return instance:IsA("Folder")
		or instance:IsA("Model")
		or instance:IsA("BasePart")
end

local function hasMeaningfulContent(instance: Instance): boolean
	if instance:IsA("BasePart") then
		return true
	end

	for _, descendant in ipairs(instance:GetDescendants()) do
		if descendant:IsA("BasePart")
			or descendant:IsA("MeshPart")
			or descendant:IsA("Model")
			or descendant:IsA("Constraint")
			or isScriptLike(descendant)
			or isLightLike(descendant)
			or isParticleLike(descendant)
		then
			return true
		end
	end

	return false
end

function ScanService.scanInstance(instance: Instance): Types.RawMetrics
	local metrics: Types.RawMetrics = {
		instance = instance,
		name = instance.Name,
		className = instance.ClassName,
		descendants = #instance:GetDescendants(),
		parts = countIf(instance, function(descendant)
			return descendant:IsA("BasePart")
		end),
		meshParts = countIf(instance, function(descendant)
			return descendant:IsA("MeshPart")
		end),
		scripts = countIf(instance, isScriptLike),
		models = countIf(instance, function(descendant)
			return descendant:IsA("Model")
		end),
		unanchoredParts = countIf(instance, function(descendant)
			return descendant:IsA("BasePart") and not descendant.Anchored
		end),
		constraints = countIf(instance, function(descendant)
			return descendant:IsA("Constraint")
		end),
		lights = countIf(instance, isLightLike),
		particles = countIf(instance, isParticleLike),
	}

	return metrics
end

function ScanService.scanWorkspaceCandidates(): {Types.RawMetrics}
	local results: {Types.RawMetrics} = {}

	for _, child in ipairs(workspace:GetChildren()) do
		if isCandidateRoot(child) and hasMeaningfulContent(child) then
			table.insert(results, ScanService.scanInstance(child))
		end
	end

	return results
end

return ScanService