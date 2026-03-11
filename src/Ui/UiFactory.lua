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

local function createVerticalListLayout(parent: Instance, paddingPx: number?): UIListLayout
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, paddingPx or 0)
	layout.Parent = parent
	return layout
end

local function createLabel(
	parent: Instance,
	text: string,
	height: number?,
	bold: boolean?,
	textSize: number?,
	textColor: Color3?
): TextLabel
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, height or 20)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.TextWrapped = true
	label.RichText = false
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

local function trimText(text: string, maxLength: number): string
	if #text <= maxLength then
		return text
	end

	return string.sub(text, 1, maxLength - 3) .. "..."
end

local function getSeverityLabel(severity: Types.Severity): string
	return severity .. " Risk"
end

local function getSeverityColor(severity: Types.Severity): Color3
	if severity == "Critical" then
		return Color3.fromRGB(255, 95, 95)
	elseif severity == "High" then
		return Color3.fromRGB(255, 170, 60)
	elseif severity == "Moderate" then
		return Color3.fromRGB(255, 220, 100)
	else
		return Color3.fromRGB(120, 220, 140)
	end
end

local function getWarningsColor(result: Types.ScanResult): Color3
	return getSeverityColor(result.severity)
end

local function getPrimaryRiskText(riskType: Types.RiskType): string
	if riskType == "None" then
		return "None"
	end

	return riskType
end

local function formatSelectionSummary(result: Types.ScanResult): string
	local metrics = result.metrics

	return
		"Name: " .. result.name .. "\n" ..
		"Class: " .. result.className .. "\n" ..
		"Cost Score: " .. tostring(result.score) .. "\n" ..
		"Severity: " .. getSeverityLabel(result.severity) .. "\n" ..
		"Primary Risk: " .. getPrimaryRiskText(result.riskType) .. "\n\n" ..

		"Hierarchy\n" ..
		"Descendants: " .. tostring(metrics.descendants) .. "\n\n" ..

		"Geometry\n" ..
		"Parts: " .. tostring(metrics.parts) .. "\n" ..
		"MeshParts: " .. tostring(metrics.meshParts) .. "\n\n" ..

		"Scripts\n" ..
		"Scripts: " .. tostring(metrics.scripts) .. "\n\n" ..

		"Physics\n" ..
		"Unanchored Parts: " .. tostring(metrics.unanchoredParts) .. "\n" ..
		"Constraints: " .. tostring(metrics.constraints) .. "\n\n" ..

		"Effects\n" ..
		"Lights: " .. tostring(metrics.lights) .. "\n" ..
		"Particles: " .. tostring(metrics.particles) .. "\n\n" ..

		"Explanation\n" ..
		result.explanation
end

local function formatWarnings(result: Types.ScanResult): string
	if #result.warnings == 0 then
		return "Warnings: None"
	end

	return "Warnings: " .. table.concat(result.warnings, ", ")
end

local function formatSuggestions(result: Types.ScanResult): string
	if #result.suggestions == 0 then
		return "Suggestions: None"
	end

	return "Suggestions:\n" .. table.concat(result.suggestions, "\n")
end

local function formatRowExplanation(result: Types.ScanResult): string
	if #result.warnings > 0 then
		return trimText(table.concat(result.warnings, ". "), 110)
	end

	return trimText(result.explanation, 110)
end

local function formatRowTitle(index: number, result: Types.ScanResult): string
	return string.format(
		"%d. %s  |  %s  |  Cost Score %d  |  %s",
		index,
		result.name,
		getSeverityLabel(result.severity),
		result.score,
		getPrimaryRiskText(result.riskType)
	)
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
	createVerticalListLayout(contentFrame, 8)

	createLabel(contentFrame, "Performance Inspector", 28, true, 22)
	createLabel(
		contentFrame,
		"Find likely expensive content and narrow the search space fast.",
		36,
		false,
		17,
		Color3.fromRGB(180, 180, 180)
	)

	createDivider(contentFrame)

	createLabel(contentFrame, "Selected Object", 24, true, 20)

	local selectionSummaryLabel = createLabel(contentFrame, "Nothing selected", 150, false, 17)
	local selectionWarningsLabel = createLabel(
		contentFrame,
		"Warnings: None",
		50,
		false,
		17,
		Color3.fromRGB(255, 220, 120)
	)
	local selectionSuggestionsLabel = createLabel(
		contentFrame,
		"Suggestions: None",
		100,
		false,
		17,
		Color3.fromRGB(160, 220, 255)
	)

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

	local scanStatusLabel = createLabel(
		contentFrame,
		"Ready to scan workspace.",
		40,
		false,
		17,
		Color3.fromRGB(180, 180, 180)
	)

	local resultsContainer = Instance.new("Frame")
	resultsContainer.Size = UDim2.new(1, 0, 0, 0)
	resultsContainer.AutomaticSize = Enum.AutomaticSize.Y
	resultsContainer.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
	resultsContainer.BorderSizePixel = 0
	resultsContainer.Parent = contentFrame

	createPadding(resultsContainer, 8)

	local resultsLayout = createVerticalListLayout(resultsContainer, 8)

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
		ui.selectionWarningsLabel.TextColor3 = Color3.fromRGB(255, 220, 120)
		ui.selectionSuggestionsLabel.Text = "Suggestions: None"
		ui.selectionSuggestionsLabel.TextColor3 = Color3.fromRGB(160, 220, 255)
		return
	end

	ui.selectionSummaryLabel.Text = formatSelectionSummary(result)
	ui.selectionWarningsLabel.Text = formatWarnings(result)
	ui.selectionWarningsLabel.TextColor3 = getWarningsColor(result)
	ui.selectionSuggestionsLabel.Text = formatSuggestions(result)
	ui.selectionSuggestionsLabel.TextColor3 = Color3.fromRGB(160, 220, 255)
end

function UiFactory.renderScanResults(
	ui: Types.UiRefs,
	results: {Types.ScanResult},
	onRowClicked: (Types.ScanResult) -> ()
)
	clearContainer(ui.resultsContainer)

	if #results == 0 then
		createLabel(
			ui.resultsContainer,
			"No medium or higher risk candidates found.",
			30,
			false,
			17,
			Color3.fromRGB(180, 180, 180)
		)
		return
	end

	local limit = math.min(#results, 10)

	for i = 1, limit do
		local result = results[i]
		local severityColor = getSeverityColor(result.severity)

		local rowButton = Instance.new("TextButton")
		rowButton.Size = UDim2.new(1, 0, 0, 0)
		rowButton.AutomaticSize = Enum.AutomaticSize.Y
		rowButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		rowButton.BorderSizePixel = 0
		rowButton.AutoButtonColor = false
		rowButton.Text = ""
		rowButton.Parent = ui.resultsContainer

		createPadding(rowButton, 10)
		createVerticalListLayout(rowButton, 4)

		local titleLabel = createLabel(
			rowButton,
			formatRowTitle(i, result),
			22,
			true,
			18,
			severityColor
		)

		titleLabel.TextWrapped = false
		titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
		titleLabel.AutomaticSize = Enum.AutomaticSize.None
		titleLabel.Size = UDim2.new(1, 0, 0, 22)

		createLabel(
			rowButton,
			formatRowExplanation(result),
			36,
			false,
			16,
			Color3.fromRGB(200, 200, 200)
		)

		rowButton.MouseEnter:Connect(function()
			rowButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		end)

		rowButton.MouseLeave:Connect(function()
			rowButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		end)

		rowButton.MouseButton1Click:Connect(function()
			onRowClicked(result)
		end)
	end
end

return UiFactory