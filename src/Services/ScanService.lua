--!strict

local root = script.Parent.Parent
local Core = root:WaitForChild("Core")

local Types = require(Core:WaitForChild("Types"))

local ScanService = {}

local function countIf(root: Instance, predicate: (Instance) -> boolean): number
	local count = 0

	for _, descendant in ipairs(root:GetDescendants()) do
		if predicate(descendant) then
			count += 1
		end
	end

	return count
end

local function isScriptLike(instance: Instance): boolean
	return instance:IsA("Script") or instance:IsA("LocalScript") or instance:IsA("ModuleScript")
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
		lights = countIf(instance, function(descendant)
			return descendant:IsA("PointLight")
				or descendant:IsA("SpotLight")
				or descendant:IsA("SurfaceLight")
		end),
		particles = countIf(instance, function(descendant)
			return descendant:IsA("ParticleEmitter")
				or descendant:IsA("Beam")
				or descendant:IsA("Trail")
		end),
	}

	return metrics
end

function ScanService.scanWorkspaceCandidates(): {Types.RawMetrics}
	local results: {Types.RawMetrics} = {}

	for _, child in ipairs(workspace:GetChildren()) do
		if child:IsA("Model") or child:IsA("BasePart") then
			table.insert(results, ScanService.scanInstance(child))
		end
	end

	return results
end

return ScanService