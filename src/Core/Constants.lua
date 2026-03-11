--!strict

local Constants = {}

Constants.PluginToolbarName = "Creator Tools"
Constants.PluginButtonName = "PerfInspect"
Constants.PluginButtonTooltip = "Open Performance Inspector"
Constants.PluginIconAsset = "rbxassetid://73461933768641"

Constants.WidgetId = "PerformanceInspectorWidget"
Constants.WidgetTitle = "Performance Inspector"

Constants.WidgetWidth = 460
Constants.WidgetHeight = 560
Constants.WidgetMinWidth = 280
Constants.WidgetMinHeight = 320

Constants.Thresholds = {
	LargeHierarchyDescendants = 200,
	HighPartCount = 200,
	HighMeshPartCount = 50,
	HighScriptCount = 8,
	HighModelCount = 40,
	HighUnanchoredParts = 15,
	HighConstraintCount = 10,
	HighLightCount = 6,
	HighParticleCount = 5,
}

Constants.ScoreWeights = {
	Descendants = 0.04,
	Parts = 0.12,
	MeshParts = 0.3,
	Scripts = 3.0,
	Models = 0.4,
	UnanchoredParts = 1.5,
	Constraints = 2.0,
	Lights = 1.0,
	Particles = 1.0,
}

return Constants