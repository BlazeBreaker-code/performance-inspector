--!strict

local Selection = game:GetService("Selection")
local HighlightService = require(script.Parent:WaitForChild("HighlightService"))

local SelectionService = {}

function SelectionService.getPrimarySelection(): Instance?
	local selected = Selection:Get()

	if #selected == 0 then
		return nil
	end

	return selected[1]
end

function SelectionService.selectInstance(instance: Instance)
	Selection:Set({ instance })
	HighlightService.flash(instance)
end

function SelectionService.selectionChanged(callback: () -> ())
	Selection.SelectionChanged:Connect(callback)
end

return SelectionService