--!strict

local Types = {}

export type RawMetrics = {
	instance: Instance,
	name: string,
	className: string,
	descendants: number,
	parts: number,
	meshParts: number,
	scripts: number,
	models: number,
	unanchoredParts: number,
	constraints: number,
	lights: number,
	particles: number,
}

export type RiskType = "Render" | "Physics" | "Script" | "Scene" | "None"

export type Severity = "Low" | "Moderate" | "High" | "Critical"

export type ScanResult = {
	instance: Instance,
	name: string,
	className: string,
	score: number,
	riskType: RiskType,
	severity: Severity,
	isReportable: boolean,
	explanation: string,
	warnings: {string},
	suggestions: {string},
	metrics: RawMetrics,
}

export type UiRefs = {
	rootFrame: Frame,
	contentFrame: Frame,
	scanButton: TextButton,
	scanStatusLabel: TextLabel,
	selectionSummaryLabel: TextLabel,
	selectionWarningsLabel: TextLabel,
	selectionSuggestionsLabel: TextLabel,
	resultsContainer: Frame,
	resultsLayout: UIListLayout,
}

return Types