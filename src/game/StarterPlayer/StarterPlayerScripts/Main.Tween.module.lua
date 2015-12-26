-- Tween
-- Crazyman32
-- March 31, 2015



-- Documentation:
-- http://sleitnick.github.io/RobloxTweenAPI



local Tween = {}
Tween.__index = Tween


local renderSteppedUsable do
	local rs = game:GetService("RunService")
	renderSteppedUsable = pcall(function()
		rs.RenderStepped:wait()
	end)
end


local easingFunctions do
	local funcs = {}
	for funcName,func in pairs(require(script.Easing)) do
		funcs[funcName:lower()] = func
	end
	for _,funcName in pairs{"inlinear", "outlinear", "inoutlinear"} do
		funcs[funcName] = funcs.linear
	end
	easingFunctions = funcs
end

Tween.EasingFunctions = easingFunctions


function Tween.new(arg_duration, arg_easingFuncName, arg_callback)
	
	local tween = {}
	
	-- Private fields:
	local duration = 1.0
	local easingFuncName = "linear"
	local easingFunc = easingFunctions[easingFuncName]
	local callback = function(ratio) end
	
	local running = false
	local startTime = 0
	local tweenBindName = ("Tween_" .. tostring(math.random()) .. tostring(tick()))
	
	local function CreateEvent(eventName)
		local event = Instance.new("BindableEvent")
		local function Fire(...)
			event:Fire(...)
		end
		tween[eventName] = event.Event
		return Fire
	end
	
	-- Create events:
	local onBegin = CreateEvent("Begin")
	local onFinish = CreateEvent("Finish")
		CreateEvent = nil
	
	function tween:Start(doStep)
		assert(not running, "Tween system already running")
		running = true
		startTime = tick()
		onBegin(startTime) -- Fire Begin event
		if (doStep) then
			self:Step()
		end
	end
	
	function tween:Stop()
		if (running) then
			startTime = 0
			running = false
			onFinish(tick()) -- Fire Finish event
			if (renderSteppedUsable) then
				local rs = game:GetService("RunService")
				rs:UnbindFromRenderStep(tweenBindName)
			end
		end
	end
	
	function tween:Run(overrideCallback)
		if (overrideCallback) then
			assert(type(overrideCallback) == "function", "Override-Callback must be a function")
		else
			overrideCallback = function(ratio) end
		end
		self:Start(true)
		if (renderSteppedUsable) then
			local rs = game:GetService("RunService")
			rs:BindToRenderStep(tweenBindName, 0, function()
				local ratio, finished = self:Step()
				overrideCallback(ratio)
			end)
		else
			spawn(function()
				while (running) do
					self:Step()
					wait()
				end
			end)
		end
	end
	
	function tween:Step()
		if (not running) then
			return 1, true
		end
		local dur = (tick() - startTime)
		local finished = false
		if (dur >= duration) then
			dur = duration
			finished = true
		end
		local ratio = easingFunc(dur, 0, 1, duration)
		callback(ratio)
		if (finished) then
			self:Stop()
		end
		return ratio, finished
	end
	
	function tween:IsRunning()
		return running
	end
	
	-- Set/Get Duration:
	function tween:SetDuration(dur)
		dur = tonumber(dur)
		assert(dur ~= nil and dur >= 0, "Duration must be a number and >= 0")
		duration = dur
	end
	function tween:GetDuration()
		return duration
	end
	
	-- Set/Get Easing Function:
	function tween:SetEasingFunction(funcName)
		assert(type(funcName) == "string" and #funcName > 0, "Easing function name must be a string and have a length > 0")
		funcName = funcName:lower()
		local func = easingFunctions[funcName]
		assert(func ~= nil, "Easing function \"" .. funcName .. "\" does not exist")
		easingFuncName = funcName
		easingFunc = func
	end
	function tween:GetEasingFunction()
		return easingFuncName
	end
	
	-- Set/Get Callback:
	function tween:SetCallback(func)
		assert(type(func) == "function", "Callback must be a function")
		callback = func
	end
	function tween:GetCallback()
		return callback
	end
	
	-- Try to set constructor arguments:
	if (arg_duration ~= nil) then
		tween:SetDuration(arg_duration)
	end
	if (arg_easingFuncName ~= nil) then
		tween:SetEasingFunction(arg_easingFuncName)
	end
	if (arg_callback ~= nil) then
		tween:SetCallback(arg_callback)
	end
	
	return setmetatable(tween, Tween)
	
end


function Tween:Clone()
	local clone = Tween.new(self:GetDuration(), self:GetEasingFunction(), self:GetCallback())
	return clone
end


function Tween:Start() end
function Tween:Init(_main) end


return Tween