--!strict

print("Performance Inspector loaded!")

local Core = script.Parent:WaitForChild("Core")
local Services = script.Parent:WaitForChild("Services")
local Ui = script.Parent:WaitForChild("Ui")

local Constants = require(Core:WaitForChild("Constants"))
local Types = require(Core:WaitForChild("Types"))
local ScanService = require(Services:WaitForChild("ScanService"))
local AnalysisService = require(Services:WaitForChild("AnalysisService"))
local SelectionService = require(Services:WaitForChild("SelectionService"))
local UiFactory = require(Ui:WaitForChild("UiFactory"))

local toolbar = plugin:CreateToolbar(Constants.PluginToolbarName)
local toggleButton = toolbar:CreateButton(
	Constants.PluginButtonName,
	Constants.PluginButtonTooltip,
	Constants.PluginIconAsset
)

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Right,
	true,
	false,
	Constants.WidgetWidth,
	Constants.WidgetHeight,
	Constants.WidgetMinWidth,
	Constants.WidgetMinHeight
)

local widget = plugin:CreateDockWidgetPluginGuiAsync(Constants.WidgetId, widgetInfo)
widget.Title = Constants.WidgetTitle
widget.Enabled = true

local ui = UiFactory.createMainWidget(widget)

local allScanResults: {Types.ScanResult} = {}
local visibleScanResults: {Types.ScanResult} = {}
local currentSelectionResult: Types.ScanResult? = nil

local activeSeverityFilter: string = "Reportable"
local activeSortMode: string = "CostScore"

local function matchesSeverityFilter(result: Types.ScanResult): boolean
	if activeSeverityFilter == "All" then
		return true
	elseif activeSeverityFilter == "Reportable" then
		return result.isReportable
	elseif activeSeverityFilter == "ModerateAndAbove" then
		return result.severity == "Moderate" or result.severity == "High" or result.severity == "Critical"
	elseif activeSeverityFilter == "HighAndAbove" then
		return result.severity == "High" or result.severity == "Critical"
	elseif activeSeverityFilter == "CriticalOnly" then
		return result.severity == "Critical"
	end

	return result.isReportable
end

local function compareResults(a: Types.ScanResult, b: Types.ScanResult): boolean
	if activeSortMode == "CostScore" then
		if a.score == b.score then
			return a.name < b.name
		end

		return a.score > b.score
	elseif activeSortMode == "Descendants" then
		if a.metrics.descendants == b.metrics.descendants then
			return a.score > b.score
		end

		return a.metrics.descendants > b.metrics.descendants
	elseif activeSortMode == "Parts" then
		if a.metrics.parts == b.metrics.parts then
			return a.score > b.score
		end

		return a.metrics.parts > b.metrics.parts
	elseif activeSortMode == "Scripts" then
		if a.metrics.scripts == b.metrics.scripts then
			return a.score > b.score
		end

		return a.metrics.scripts > b.metrics.scripts
	elseif activeSortMode == "UnanchoredParts" then
		if a.metrics.unanchoredParts == b.metrics.unanchoredParts then
			return a.score > b.score
		end

		return a.metrics.unanchoredParts > b.metrics.unanchoredParts
	end

	if a.score == b.score then
		return a.name < b.name
	end

	return a.score > b.score
end

local function refreshVisibleResults()
	local filtered: {Types.ScanResult} = {}

	for _, result in ipairs(allScanResults) do
		if matchesSeverityFilter(result) then
			table.insert(filtered, result)
		end
	end

	table.sort(filtered, compareResults)

	visibleScanResults = filtered

	UiFactory.renderScanResults(ui, visibleScanResults, function(result: Types.ScanResult)
		SelectionService.selectInstance(result.instance)
		renderSelection(result.instance)
	end)
end

function renderSelection(instance: Instance?)
	if instance == nil then
		currentSelectionResult = nil
		UiFactory.renderSelectionDetails(ui, nil)
		return
	end

	local rawMetrics = ScanService.scanInstance(instance)
	local analyzed = AnalysisService.analyzeMetrics(rawMetrics)

	currentSelectionResult = analyzed
	UiFactory.renderSelectionDetails(ui, analyzed)
end

local function renderWorkspaceScan()
	UiFactory.setScanStatus(ui, "Scanning workspace...")

	local rawCandidates = ScanService.scanWorkspaceCandidates()
	local analyzedResults: {Types.ScanResult} = {}

	for _, rawMetrics in ipairs(rawCandidates) do
		table.insert(analyzedResults, AnalysisService.analyzeMetrics(rawMetrics))
	end

	allScanResults = analyzedResults
	refreshVisibleResults()

	if #visibleScanResults == 0 then
		UiFactory.setScanStatus(ui, "Scan complete • No medium or higher risk candidates found")
	else
		UiFactory.setScanStatus(
			ui,
			"Scan complete • "
				.. tostring(#visibleScanResults)
				.. " candidate"
				.. (#visibleScanResults == 1 and "" or "s")
				.. " found"
		)
	end
end

local function onSelectionChanged()
	local selected = SelectionService.getPrimarySelection()
	renderSelection(selected)
end

local function onToggleButtonClicked()
	widget.Enabled = not widget.Enabled
end

local function bindEvents()
	toggleButton.Click:Connect(onToggleButtonClicked)
	ui.scanButton.MouseButton1Click:Connect(renderWorkspaceScan)
	SelectionService.selectionChanged(onSelectionChanged)
end

local function initialize()
	bindEvents()
	onSelectionChanged()
	UiFactory.setScanStatus(ui, "Ready to scan workspace.")
end

initialize()