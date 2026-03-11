--!strict

local root = script.Parent.Parent
local Core = root:WaitForChild("Core")

local Types = require(Core:WaitForChild("Types"))

local RecommendationService = {}

function RecommendationService.getSuggestions(
	riskType: Types.RiskType,
	metrics: Types.RawMetrics
): {string}
	local suggestions: {string} = {}

	if riskType == "Render" then
		table.insert(suggestions, "Reduce repeated decorative detail in this hierarchy.")
		table.insert(suggestions, "Audit MeshPart density and simplify expensive assets.")
		table.insert(suggestions, "Collapse or simplify repeated small parts where possible.")
	elseif riskType == "Physics" then
		table.insert(suggestions, "Anchor non interactive parts.")
		table.insert(suggestions, "Reduce unnecessary constraints and moving physical pieces.")
		table.insert(suggestions, "Audit collision and remove physics from decorative assets.")
	elseif riskType == "Script" then
		table.insert(suggestions, "Consolidate duplicated scripts into shared modules.")
		table.insert(suggestions, "Audit per frame loops and event spam.")
		table.insert(suggestions, "Move repeated logic to centralized systems where possible.")
	elseif riskType == "Scene" then
		table.insert(suggestions, "Break this hierarchy into smaller logical chunks.")
		table.insert(suggestions, "Reduce nesting and overall descendant count.")
		table.insert(suggestions, "Consider streaming friendly organization for large content sets.")
	else
		table.insert(suggestions, "This hierarchy looks relatively healthy.")
		table.insert(suggestions, "Use profiling tools if you still observe runtime issues.")
	end

	if metrics.lights > 0 then
		table.insert(suggestions, "Review dynamic lights and keep only the ones that add real value.")
	end

	if metrics.particles > 0 then
		table.insert(suggestions, "Audit particle, trail, and beam effects for overuse.")
	end

	return suggestions
end

return RecommendationService