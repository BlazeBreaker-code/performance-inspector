--!strict

local root = script.Parent.Parent
local Core = root:WaitForChild("Core")

local Types = require(Core:WaitForChild("Types"))

local RecommendationService = {}

local function addSuggestion(suggestions: {string}, text: string)
	table.insert(suggestions, text)
end

function RecommendationService.getSuggestions(
	riskType: Types.RiskType,
	metrics: Types.RawMetrics
): {string}
	local suggestions: {string} = {}

	if riskType == "Render" then
		addSuggestion(suggestions, "Reduce repeated decorative detail in this hierarchy.")
		addSuggestion(suggestions, "Audit MeshPart density and simplify expensive visual assets.")
		addSuggestion(suggestions, "Merge or remove repeated small parts where possible.")
	elseif riskType == "Physics" then
		addSuggestion(suggestions, "Anchor non interactive parts.")
		addSuggestion(suggestions, "Reduce unnecessary moving assemblies and physical pieces.")
		addSuggestion(suggestions, "Audit collision and remove physics from decorative assets.")
	elseif riskType == "Script" then
		addSuggestion(suggestions, "Consolidate duplicated scripts into shared modules.")
		addSuggestion(suggestions, "Audit per frame loops, heartbeat usage, and event spam.")
		addSuggestion(suggestions, "Move repeated logic into centralized systems where possible.")
	elseif riskType == "Scene" then
		addSuggestion(suggestions, "Break this hierarchy into smaller logical chunks.")
		addSuggestion(suggestions, "Reduce nesting and overall descendant count.")
		addSuggestion(suggestions, "Consider streaming friendly organization for large content sets.")
	elseif riskType == "None" then
		addSuggestion(suggestions, "No dominant risk detected from the current heuristics.")
		addSuggestion(suggestions, "Use runtime profiling if you still observe performance issues.")
	end

	if metrics.unanchoredParts >= 20 then
		addSuggestion(suggestions, "Review dynamic assemblies and keep only the parts that truly need physics.")
	end

	if metrics.constraints >= 8 then
		addSuggestion(suggestions, "Simplify constraint networks where possible.")
	end

	if metrics.scripts >= 8 then
		addSuggestion(suggestions, "Audit script ownership and remove duplicated behavior across similar objects.")
	end

	if metrics.descendants >= 500 then
		addSuggestion(suggestions, "Split large hierarchies into smaller authoring units.")
	end

	if metrics.models >= 40 then
		addSuggestion(suggestions, "Flatten deeply nested model structures where possible.")
	end

	if metrics.meshParts >= 25 then
		addSuggestion(suggestions, "Review mesh complexity, collision fidelity, and repeated mesh usage.")
	end

	if metrics.lights > 0 then
		addSuggestion(suggestions, "Review dynamic lights and keep only the ones that add real value.")
	end

	if metrics.particles > 0 then
		addSuggestion(suggestions, "Audit particle, trail, and beam effects for overuse.")
	end

	if #suggestions == 0 then
		addSuggestion(suggestions, "Use profiling tools if you still observe runtime issues.")
	end

	return suggestions
end

return RecommendationService