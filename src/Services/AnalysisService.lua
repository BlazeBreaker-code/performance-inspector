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
		return "None"
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

local function getSeverity(score: number, warningCount: number): Types.Severity
	if score >= 80 or warningCount >= 4 then
		return "Critical"
	elseif score >= 50 or warningCount >= 2 then
		return "High"
	elseif score >= 20 or warningCount >= 1 then
		return "Moderate"
	else
		return "Low"
	end
end

local function buildExplanation(
	riskType: Types.RiskType,
	severity: Types.Severity,
	metrics: Types.RawMetrics
): string
	if riskType == "Render" then
		if severity == "Low" then
			return string.format(
				"Detected %d parts, %d mesh parts, %d lights, and %d particle emitters.",
				metrics.parts,
				metrics.meshParts,
				metrics.lights,
				metrics.particles
			)
		end

		return string.format(
			"Visual cost may be elevated. Found %d parts, %d mesh parts, %d lights, and %d particle emitters.",
			metrics.parts,
			metrics.meshParts,
			metrics.lights,
			metrics.particles
		)
	elseif riskType == "Physics" then
		if severity == "Low" then
			return string.format(
				"Detected %d unanchored parts and %d constraints in this hierarchy.",
				metrics.unanchoredParts,
				metrics.constraints
			)
		end

		return string.format(
			"Physics cost may be elevated. Found %d unanchored parts and %d constraints.",
			metrics.unanchoredParts,
			metrics.constraints
		)
	elseif riskType == "Script" then
		if severity == "Low" then
			return string.format(
				"Detected %d scripts in this hierarchy.",
				metrics.scripts
			)
		end

		return string.format(
			"Script activity may be elevated. Found %d scripts in this hierarchy.",
			metrics.scripts
		)
	elseif riskType == "Scene" then
		if severity == "Low" then
			return string.format(
				"Detected %d descendants including %d parts.",
				metrics.descendants,
				metrics.parts
			)
		end

		return string.format(
			"Hierarchy complexity may be elevated. Found %d descendants including %d parts.",
			metrics.descendants,
			metrics.parts
		)
	else
		return "No dominant performance risk detected under the current heuristics."
	end
end

local function buildWarnings(metrics: Types.RawMetrics): {string}
	local warnings: {string} = {}
	local thresholds = Constants.Thresholds

	if metrics.descendants >= thresholds.LargeHierarchyDescendants then
		table.insert(warnings, string.format("Large hierarchy with %d descendants", metrics.descendants))
	end

	if metrics.parts >= thresholds.HighPartCount then
		table.insert(warnings, string.format("High part count: %d", metrics.parts))
	end

	if metrics.meshParts >= thresholds.HighMeshPartCount then
		table.insert(warnings, string.format("Mesh heavy content: %d mesh parts", metrics.meshParts))
	end

	if metrics.scripts >= thresholds.HighScriptCount then
		table.insert(warnings, string.format("High script count: %d", metrics.scripts))
	end

	if metrics.models >= thresholds.HighModelCount then
		table.insert(warnings, string.format("Deep model nesting: %d models", metrics.models))
	end

	if metrics.unanchoredParts >= thresholds.HighUnanchoredParts then
		table.insert(warnings, string.format("Many unanchored parts: %d", metrics.unanchoredParts))
	end

	if metrics.constraints >= thresholds.HighConstraintCount then
		table.insert(warnings, string.format("High constraint count: %d", metrics.constraints))
	end

	if metrics.lights >= thresholds.HighLightCount then
		table.insert(warnings, string.format("Many lights: %d", metrics.lights))
	end

	if metrics.particles >= thresholds.HighParticleCount then
		table.insert(warnings, string.format("Heavy effects usage: %d particle emitters", metrics.particles))
	end

	return warnings
end

local function sortWarnings(warnings: {string}): {string}
	table.sort(warnings, function(a, b)
		return a < b
	end)

	return warnings
end

local function isReportable(severity: Types.Severity, riskType: Types.RiskType): boolean
	if severity == "Low" then
		return false
	end

	if riskType == "None" then
		return false
	end

	return true
end

function AnalysisService.analyzeMetrics(metrics: Types.RawMetrics): Types.ScanResult
	local score = computeScore(metrics)
	local riskType = getRiskType(metrics)
	local warnings = sortWarnings(buildWarnings(metrics))
	local severity = getSeverity(score, #warnings)
	local explanation = buildExplanation(riskType, severity, metrics)
	local suggestions = RecommendationService.getSuggestions(riskType, metrics)

	local result: Types.ScanResult = {
		instance = metrics.instance,
		name = metrics.name,
		className = metrics.className,
		score = score,
		riskType = riskType,
		severity = severity,
		isReportable = isReportable(severity, riskType),
		explanation = explanation,
		warnings = warnings,
		suggestions = suggestions,
		metrics = metrics,
	}

	return result
end

return AnalysisService