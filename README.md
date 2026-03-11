Performance Inspector

Performance Inspector is a Roblox Studio plugin that helps developers quickly identify potentially expensive content in their workspace.

Instead of manually searching through large hierarchies, the plugin scans the workspace, analyzes objects using lightweight heuristics, and surfaces candidates that may impact performance.

The goal is to narrow the search space and help creators quickly focus on areas that may require optimization.


Features

Workspace Performance Scan
Scans the workspace and surfaces objects that may contribute to performance issues.

Object Risk Scoring
Assigns a heuristic score based on factors like hierarchy size, physics complexity, and script density.

Selection Analysis
Displays metrics for the currently selected object including descendant count, physics load, and script usage.

Actionable Warnings
Flags potential issues such as large hierarchies, heavy physics assemblies, or excessive object counts.

Optimization Suggestions
Provides simple recommendations to help improve performance.

Viewport Navigation
Clicking a scan result focuses the camera on the relevant object for quick inspection.


Example Metrics Collected

The plugin analyzes several characteristics of objects including:

Descendant count
Part count
MeshPart count
Script count
Unanchored physics parts
Constraints
Lights
Particle emitters

These metrics are combined into a lightweight heuristic score to help surface potentially expensive objects.


Architecture

The plugin is structured using small service modules to keep responsibilities clear and maintainable.

ScanService
Traverses the workspace and collects candidate objects.

AnalysisService
Computes metrics such as descendant counts and physics complexity.

RecommendationService
Generates warnings and optimization suggestions based on analysis results.

FocusService
Moves the Studio camera to objects selected from scan results.

SelectionService
Tracks the currently selected instance in Studio.

UiFactory
Constructs the plugin interface and renders scan results.


Development Setup

This project uses Rojo to sync filesystem code into Roblox Studio.

Install dependencies:

Rojo
Roblox Studio
Rojo Studio Plugin

Start the development server:

rojo serve

Connect the Rojo plugin in Roblox Studio and the source will appear in the DataModel.

The plugin can then be saved as a local plugin for testing.


Project Structure

src
  Plugin.server.lua
  Services
    AnalysisService.lua
    ScanService.lua
    RecommendationService.lua
    FocusService.lua
    SelectionService.lua
  Ui
    UiFactory.lua
  Constants.lua
  Types.lua


Motivation

Large Roblox experiences often contain thousands of objects. Identifying the specific assets contributing to performance issues can be time consuming.

Performance Inspector aims to reduce that friction by quickly highlighting objects that are worth investigating.