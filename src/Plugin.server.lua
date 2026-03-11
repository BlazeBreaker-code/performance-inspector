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
local FocusService = require(Services:WaitForChild("FocusService"))
local UiFactory = require(Ui:WaitForChild("UiFactory"))
local RecommendationService = require(Services:WaitForChild("RecommendationService"))

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

local currentScanResults: {Types.ScanResult} = {}
local currentSelectionResult: Types.ScanResult? = nil

local function renderSelection(instance: Instance?)
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

	table.sort(analyzedResults, function(a: Types.ScanResult, b: Types.ScanResult)
		return a.score > b.score
	end)

	currentScanResults = analyzedResults

	UiFactory.renderScanResults(ui, analyzedResults, function(result: Types.ScanResult)
		SelectionService.selectInstance(result.instance)
		FocusService.focusInstance(result.instance)
		renderSelection(result.instance)
	end)

	UiFactory.setScanStatus(ui, "Scan complete. Candidates scanned: " .. tostring(#analyzedResults))
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