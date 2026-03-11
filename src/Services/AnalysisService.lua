--!strict

local root = script.Parent.Parent
local Core = root:WaitForChild("Core")

local Types = require(Core:WaitForChild("Types"))
local Constants = require(Core:WaitForChild("Constants"))
local RecommendationService = require(script.Parent:WaitForChild("RecommendationService"))

local AnalysisService = {}

local function computeScore(metrics: Types.RawMetrics): number
	local weights = Constants.ScoreWeights

	local score = 0
	score += metrics.descendants * weights.Descendants
	score += metrics.parts * weights.Parts
	score += metrics.meshParts * weights.MeshParts
	score += metrics.scripts * weights.Scripts
	score += metrics.models * weights.Models
	score += metrics.unanchoredParts * weights.UnanchoredParts
	score += metrics.constraints * weights.Constraints
	score += metrics.lights * weights.Lights
	score += metrics.particles * weights.Particles

	return math.floor(score + 0.5)
end

local function getRiskType(metrics: Types.RawMetrics): Types.RiskType
	local renderRisk = metrics.parts + (metrics.meshParts * 3) + (metrics.lights * 2) + (metrics.particles * 2)
	local physicsRisk = (metrics.unanchoredParts * 3) + (metrics.constraints * 4)
	local scriptRisk = metrics.scripts * 5
	local sceneRisk = metrics.descendants + (metrics.models * 5)

	local highest = math.max(renderRisk, physicsRisk, scriptRisk, sceneRisk)

	if highest == 0 then
		return "Balanced"
	elseif highest == renderRisk then
		return "Render"
	elseif highest == physicsRisk then
		return "Physics"
	elseif highest == scriptRisk then
		return "Script"
	else
		return "Scene"
	end
end

local function buildExplanation(riskType: Types.RiskType, metrics: Types.RawMetrics): string
	if riskType == "Render" then
		return string.format(
			"Likely render heavy because it contains %d parts, %d mesh parts, %d lights, and %d visual effects.",
			metrics.parts,
			metrics.meshParts,
			metrics.lights,
			metrics.particles
		)
	elseif riskType == "Physics" then
		return string.format(
			"Likely physics heavy because it contains %d unanchored parts and %d constraints.",
			metrics.unanchoredParts,
			metrics.constraints
		)
	elseif riskType == "Script" then
		return string.format(
			"Likely script heavy because it contains %d scripts in this hierarchy.",
			metrics.scripts
		)
	elseif riskType == "Scene" then
		return string.format(
			"Likely scene complexity heavy because it contains %d descendants across %d nested models.",
			metrics.descendants,
			metrics.models
		)
	else
		return "This hierarchy looks reasonably balanced based on current heuristics."
	end
end

local function buildWarnings(metrics: Types.RawMetrics): {string}
	local warnings: {string} = {}
	local thresholds = Constants.Thresholds

	if metrics.descendants >= thresholds.LargeHierarchyDescendants then
		table.insert(warnings, "Large hierarchy")
	end

	if metrics.parts >= thresholds.HighPartCount then
		table.insert(warnings, "High part count")
	end

	if metrics.meshParts >= thresholds.HighMeshPartCount then
		table.insert(warnings, "Mesh heavy")
	end

	if metrics.scripts >= thresholds.HighScriptCount then
		table.insert(warnings, "High script count")
	end

	if metrics.models >= thresholds.HighModelCount then
		table.insert(warnings, "Deep model nesting")
	end

	if metrics.unanchoredParts >= thresholds.HighUnanchoredParts then
		table.insert(warnings, "Many unanchored parts")
	end

	if metrics.constraints >= thresholds.HighConstraintCount then
		table.insert(warnings, "High constraint count")
	end

	if metrics.lights >= thresholds.HighLightCount then
		table.insert(warnings, "Many lights")
	end

	if metrics.particles >= thresholds.HighParticleCount then
		table.insert(warnings, "Heavy effects usage")
	end

	return warnings
end

function AnalysisService.analyzeMetrics(metrics: Types.RawMetrics): Types.ScanResult
	local score = computeScore(metrics)
	local riskType = getRiskType(metrics)
	local explanation = buildExplanation(riskType, metrics)
	local warnings = buildWarnings(metrics)
	local suggestions = RecommendationService.getSuggestions(riskType, metrics)

	local result: Types.ScanResult = {
		instance = metrics.instance,
		name = metrics.name,
		className = metrics.className,
		score = score,
		riskType = riskType,
		explanation = explanation,
		warnings = warnings,
		suggestions = suggestions,
		metrics = metrics,
	}

	return result
end

return AnalysisService