--!strict

local root = script.Parent.Parent
local Core = root:WaitForChild("Core")

local Types = require(Core:WaitForChild("Types"))

local UiFactory = {}

local function createPadding(parent: Instance, px: number)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, px)
	padding.PaddingBottom = UDim.new(0, px)
	padding.PaddingLeft = UDim.new(0, px)
	padding.PaddingRight = UDim.new(0, px)
	padding.Parent = parent
	return padding
end

local function createLabel(
	parent: Instance,
	text: string,
	height: number,
	bold: boolean?,
	textSize: number?,
	textColor: Color3?
): TextLabel
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, height)
	label.BackgroundTransparency = 1
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.TextWrapped = true
	label.Font = bold and Enum.Font.SourceSansBold or Enum.Font.SourceSans
	label.TextSize = textSize or 18
	label.TextColor3 = textColor or Color3.fromRGB(235, 235, 235)
	label.Text = text
	label.Parent = parent
	return label
end

local function createDivider(parent: Instance): Frame
	local divider = Instance.new("Frame")
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	divider.BorderSizePixel = 0
	divider.Parent = parent
	return divider
end

local function clearContainer(container: Instance)
	for _, child in ipairs(container:GetChildren()) do
		if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
			child:Destroy()
		end
	end
end

function UiFactory.createMainWidget(widget: PluginGui): Types.UiRefs
	local rootFrame = Instance.new("Frame")
	rootFrame.Size = UDim2.new(1, 0, 1, 0)
	rootFrame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
	rootFrame.BorderSizePixel = 0
	rootFrame.Parent = widget

	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.ScrollBarThickness = 8
	scrollingFrame.Parent = rootFrame

	local contentFrame = Instance.new("Frame")
	contentFrame.Size = UDim2.new(1, 0, 0, 0)
	contentFrame.AutomaticSize = Enum.AutomaticSize.Y
	contentFrame.BackgroundTransparency = 1
	contentFrame.Parent = scrollingFrame

	createPadding(contentFrame, 10)

	local contentLayout = Instance.new("UIListLayout")
	contentLayout.FillDirection = Enum.FillDirection.Vertical
	contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Padding = UDim.new(0, 8)
	contentLayout.Parent = contentFrame

	createLabel(contentFrame, "Performance Inspector", 28, true, 22)
	createLabel(contentFrame, "Find likely expensive content and narrow the search space fast.", 36, false, 17, Color3.fromRGB(180, 180, 180))

	createDivider(contentFrame)

	createLabel(contentFrame, "Selected Object", 24, true, 20)

	local selectionSummaryLabel = createLabel(contentFrame, "Nothing selected", 150, false, 17)
	local selectionWarningsLabel = createLabel(contentFrame, "Warnings: None", 50, false, 17, Color3.fromRGB(255, 220, 120))
	local selectionSuggestionsLabel = createLabel(contentFrame, "Suggestions: None", 100, false, 17, Color3.fromRGB(160, 220, 255))

	createDivider(contentFrame)

	createLabel(contentFrame, "Workspace Scan", 24, true, 20)

	local scanButton = Instance.new("TextButton")
	scanButton.Size = UDim2.new(1, 0, 0, 32)
	scanButton.BackgroundColor3 = Color3.fromRGB(70, 120, 210)
	scanButton.BorderSizePixel = 0
	scanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	scanButton.Font = Enum.Font.SourceSansBold
	scanButton.TextSize = 20
	scanButton.Text = "Scan Workspace"
	scanButton.Parent = contentFrame

	local scanStatusLabel = createLabel(contentFrame, "Ready to scan workspace.", 40, false, 17, Color3.fromRGB(180, 180, 180))

	local resultsContainer = Instance.new("Frame")
	resultsContainer.Size = UDim2.new(1, 0, 0, 0)
	resultsContainer.AutomaticSize = Enum.AutomaticSize.Y
	resultsContainer.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
	resultsContainer.BorderSizePixel = 0
	resultsContainer.Parent = contentFrame

	createPadding(resultsContainer, 8)

	local resultsLayout = Instance.new("UIListLayout")
	resultsLayout.FillDirection = Enum.FillDirection.Vertical
	resultsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	resultsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	resultsLayout.Padding = UDim.new(0, 8)
	resultsLayout.Parent = resultsContainer

	return {
		rootFrame = rootFrame,
		contentFrame = contentFrame,
		scanButton = scanButton,
		scanStatusLabel = scanStatusLabel,
		selectionSummaryLabel = selectionSummaryLabel,
		selectionWarningsLabel = selectionWarningsLabel,
		selectionSuggestionsLabel = selectionSuggestionsLabel,
		resultsContainer = resultsContainer,
		resultsLayout = resultsLayout,
	}
end

function UiFactory.setScanStatus(ui: Types.UiRefs, statusText: string)
	ui.scanStatusLabel.Text = statusText
end

function UiFactory.renderSelectionDetails(ui: Types.UiRefs, result: Types.ScanResult?)
	if result == nil then
		ui.selectionSummaryLabel.Text = "Nothing selected"
		ui.selectionWarningsLabel.Text = "Warnings: None"
		ui.selectionSuggestionsLabel.Text = "Suggestions: None"
		return
	end

	local metrics = result.metrics
	ui.selectionSummaryLabel.Text =
		"Name: " .. result.name .. "\n" ..
		"Class: " .. result.className .. "\n" ..
		"Score: " .. tostring(result.score) .. "\n" ..
		"Risk: " .. result.riskType .. "\n" ..
		"Descendants: " .. tostring(metrics.descendants) .. "\n" ..
		"Parts: " .. tostring(metrics.parts) .. "\n" ..
		"MeshParts: " .. tostring(metrics.meshParts) .. "\n" ..
		"Scripts: " .. tostring(metrics.scripts) .. "\n" ..
		"Unanchored Parts: " .. tostring(metrics.unanchoredParts) .. "\n" ..
		"Constraints: " .. tostring(metrics.constraints) .. "\n" ..
		"Lights: " .. tostring(metrics.lights) .. "\n" ..
		"Particles: " .. tostring(metrics.particles) .. "\n" ..
		"Explanation: " .. result.explanation

	local warningsText = "Warnings: None"
	if #result.warnings > 0 then
		warningsText = "Warnings: " .. table.concat(result.warnings, ", ")
	end
	ui.selectionWarningsLabel.Text = warningsText

	local suggestionsText = "Suggestions: None"
	if #result.suggestions > 0 then
		suggestionsText = "Suggestions:\n" .. table.concat(result.suggestions, "\n")
	end
	ui.selectionSuggestionsLabel.Text = suggestionsText
end

function UiFactory.renderScanResults(
	ui: Types.UiRefs,
	results: {Types.ScanResult},
	onRowClicked: (Types.ScanResult) -> ()
)
	clearContainer(ui.resultsContainer)

	if #results == 0 then
		createLabel(ui.resultsContainer, "No candidates found.", 30, false, 17)
		return
	end

	local limit = math.min(#results, 10)

	for i = 1, limit do
		local result = results[i]

		local rowButton = Instance.new("TextButton")
		rowButton.Size = UDim2.new(1, 0, 0, 82)
		rowButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		rowButton.BorderSizePixel = 0
		rowButton.AutoButtonColor = true
		rowButton.Text = ""
		rowButton.Parent = ui.resultsContainer

		createPadding(rowButton, 8)

		createLabel(
			rowButton,
			string.format("%d. %s  |  Score %d  |  %s Risk", i, result.name, result.score, result.riskType),
			22,
			true,
			18
		)

		createLabel(rowButton, result.explanation, 42, false, 16, Color3.fromRGB(200, 200, 200))

		rowButton.MouseButton1Click:Connect(function()
			onRowClicked(result)
		end)
	end
end

return UiFactory