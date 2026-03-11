local HighlightService = {}

local highlightDuration = 1.5

function HighlightService.flash(instance: Instance)
	if not instance then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 200, 80)
	highlight.OutlineColor = Color3.fromRGB(255, 160, 40)
	highlight.FillTransparency = 0.4
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee = instance
	highlight.Parent = instance

	task.delay(highlightDuration, function()
		if highlight then
			highlight:Destroy()
		end
	end)
end

return HighlightService