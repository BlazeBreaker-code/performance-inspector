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
	LargeHierarchyDescendants = 2000,
	HighPartCount = 1000,
	HighMeshPartCount = 250,
	HighScriptCount = 15,
	HighModelCount = 100,
	HighUnanchoredParts = 150,
	HighConstraintCount = 40,
	HighLightCount = 20,
	HighParticleCount = 20,
}

Constants.ScoreWeights = {
	Descendants = 0.02,
	Parts = 0.08,
	MeshParts = 0.18,
	Scripts = 2.5,
	Models = 0.25,
	UnanchoredParts = 0.12,
	Constraints = 0.75,
	Lights = 0.8,
	Particles = 0.8,
}

return Constants