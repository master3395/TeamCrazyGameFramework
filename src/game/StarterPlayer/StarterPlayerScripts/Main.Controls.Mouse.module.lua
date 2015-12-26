-- Mouse
-- Crazyman32
-- October 9, 2015

--[[
	
	local mouse = require(this)
	
	FIELDS:
	
		(X, Y, Ignore)
		
		Int    mouse.X
		Int    mouse.Y
		Table  mouse.Ignore
	
	
	METHODS:
	
		(IsDown, Project, ProjectFromCharacter)
		
		Boolean isDown:                           mouse:IsDown(UserInputType button)
		CFrame hit, Part target, Vector3 normal:  mouse:Project([Number maxDistance = 999, Table ignoreListOverride])
		CFrame hit, Part target, Vector3 normal:  mouse:ProjectFromCharacter([Number maxDistance = 999, Table ignoreListOverride])
		Ray mouseRay:                             mouse:Ray()
	
	
	EVENTS:
	
		(ButtonDown, ButtonUp, Moved, Scrolled)
		
		mouse.ButtonDown(UserInputType button, Vector3 position)
		mouse.ButtonUp(UserInputType button, Vector3 position)
		mouse.Moved(Int x, Int y)
		mouse.Scrolled(Int direction)
	
--]]


assert(game:GetService("RunService"):IsClient(), "Mouse can only be used from client")

local Mouse = {
	X = 0;
	Y = 0;
	Ignore = {};
}

local userInput = game:GetService("UserInputService")

local maxRayDistance = 999

-- Mouse button references:
local mButton1   = Enum.UserInputType.MouseButton1
local mButton2   = Enum.UserInputType.MouseButton2
local mButton3   = Enum.UserInputType.MouseButton3
local mWheel     = Enum.UserInputType.MouseWheel
local mMovement  = Enum.UserInputType.MouseMovement

local buttonDown = {
	[mButton1] = false;
	[mButton2] = false;
	[mButton3] = false;
}

-- Create events:
local onButtonDown  = Instance.new("BindableEvent")
local onButtonUp    = Instance.new("BindableEvent")
local onMoved       = Instance.new("BindableEvent")
local onScrolled    = Instance.new("BindableEvent")

-- Expose events:
Mouse.ButtonDown  = onButtonDown.Event
Mouse.ButtonUp    = onButtonUp.Event
Mouse.Moved       = onMoved.Event
Mouse.Scrolled    = onScrolled.Event


-- Projections:
do
	
	local player = game.Players.LocalPlayer
	local workspace = game.Workspace
	local findPartOnRayWithIgnoreList = workspace.FindPartOnRayWithIgnoreList
	local cam = game.Workspace.CurrentCamera
	local Ray = Ray.new
	local screenPointToRay = cam.ScreenPointToRay
	local CF = CFrame.new
	
	function Mouse:Ray()
		return screenPointToRay(cam, self.X, self.Y, 0)
	end
	
	function Mouse:Project(maxDistance, ignore)
		local ray = screenPointToRay(cam, self.X, self.Y, 0)
		ray = Ray(ray.Origin, (ray.Unit.Direction * (maxDistance or maxRayDistance)))
		local hit, hitPos, normal = findPartOnRayWithIgnoreList(workspace, ray, ignore or self.Ignore or {}, true, false)
		local cframe = CF(hitPos, (hitPos + ray.Unit.Direction))
		return cframe, hit, normal
	end
	
	function Mouse:ProjectFromCharacter(maxDistance, ignore)
		if (player.Character) then
			local head = player.Character:FindFirstChild("Head")
			if (head) then
				maxDistance = (maxDistance or maxRayDistance)
				local cframe, hit, normal = self:Project(nil, ignore)
				cframe = CF(cframe.p, cframe.p + CF(head.Position, cframe.p).lookVector)
				local dist = (head.Position - cframe.p).magnitude
				if (dist > maxDistance) then
					cframe = CF(head.Position + (cframe.lookVector * maxDistance), head.Position + (cframe.lookVector * maxDistance * 2))
				end
				return cframe, hit, normal
			end
		end
	end
	
	function Mouse:GetTarget()
		local cframe, hit, normal = self:Project()
		return hit
	end
	
	function Mouse:GetHitCFrame()
		local cframe, hit, normal = self:Project()
		return cframe
	end
	
end


function Mouse:IsDown(button)
	return buttonDown[button]
end


local function InputBegan(input, processed)
	if (processed) then return end
	local iType = input.UserInputType
	if (iType == mButton1 or iType == mButton2 or iType == mButton3) then
		buttonDown[iType] = true
		onButtonDown:Fire(iType, input.Position)
	end
end

local function InputEnded(input, processed)
	if (processed) then return end
	local iType = input.UserInputType
	if (iType == mButton1 or iType == mButton2 or iType == mButton3) then
		buttonDown[iType] = false
		onButtonUp:Fire(iType, input.Position)
	end
end

local function InputChanged(input, processed)
	if (processed) then return end
	local iType = input.UserInputType
	if (iType == mMovement) then
		Mouse.X = input.Position.X
		Mouse.Y = input.Position.Y
		onMoved:Fire(Mouse.X, Mouse.Y)
	elseif (iType == mWheel) then
		onScrolled:Fire(input.Position.Z)
	end
end


userInput.InputBegan:connect(InputBegan)
userInput.InputEnded:connect(InputEnded)
userInput.InputChanged:connect(InputChanged)


return Mouse