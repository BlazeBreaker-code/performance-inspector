--!strict

local FocusService = {}

function FocusService.focusInstance(instance: Instance)
	local camera = workspace.CurrentCamera
	if camera == nil then
		return
	end

	local cframe: CFrame?
	local size: Vector3?

	if instance:IsA("BasePart") then
		cframe = instance.CFrame
		size = instance.Size
	elseif instance:IsA("Model") then
		local ok, modelCFrame, modelSize = pcall(function()
			return instance:GetBoundingBox()
		end)

		if ok then
			cframe = modelCFrame
			size = modelSize
		end
	end

	if cframe == nil or size == nil then
		return
	end

	local sizeVec = size :: Vector3
	local cframeVal = cframe :: CFrame

	local radius = math.max(sizeVec.X, sizeVec.Y, sizeVec.Z)
	local distance = math.max(radius * 2.5, 16)

	local focusPosition = cframeVal.Position
	local offset = Vector3.new(distance, distance * 0.6, distance)
	camera.CFrame = CFrame.new(focusPosition + offset, focusPosition)
end

return FocusService