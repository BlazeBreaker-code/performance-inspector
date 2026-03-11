--!strict

local Selection = game:GetService("Selection")

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
end

function SelectionService.selectionChanged(callback: () -> ())
	Selection.SelectionChanged:Connect(callback)
end

return SelectionService