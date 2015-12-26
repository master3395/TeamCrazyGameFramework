-- Damping
-- Crazyman32
-- September 30, 2015


--[[
	
	local Damping = require(this)
	
	local damping = Damping.new()
	
	damping.P = NUMBER
	damping.D = NUMBER
	damping.Position = Vector3
	damping.Goal = Vector3
	
	damping:Update()  [Returns Vector3 position]
	
	
	
	EXAMPLE USE:
	
	-- Set D and P values:
	damping.P = 1
	damping.D = 0.1
	
	-- Set starting position:
	damping.Position = part.Position
	
	while (true) do
	
		wait()
		
		-- Update the goal:
		damping.Goal = mouse.Hit.p
		
		-- Calculate new position:
		local newPosition = damping:Update()
		part.Position = newPosition
		
	end
	
--]]


local Damping = {}
Damping.__index = Damping

local V3 = Vector3.new


local function CheckNAN(value, returnIfNan)
	return (value == value and value or returnIfNan)
end


function Damping.new()
	
	local damping = {
		P = 1;
		D = 0.1;
		Position = V3();
		Velocity = V3();
		Goal = V3();
		Last = tick();
	}
	
	return setmetatable(damping, Damping)
	
end


function Damping:CheckNAN()
	self.Velocity = V3(CheckNAN(self.Velocity.X, 0), CheckNAN(self.Velocity.Y, 0), CheckNAN(self.Velocity.Z, 0))
	self.Position = V3(CheckNAN(self.Position.X, self.Goal.X), CheckNAN(self.Position.Y, self.Goal.Y), CheckNAN(self.Position.Z, self.Goal.Z))
end


function Damping:Update()
	--[[
		
		velocity += P * ( (target - current) + D * -velocity );
		current += velocity * dt;
		
		Source: http://www.gamedev.net/topic/561981-smooth-value-damping/
	--]]
	local t = tick()
	local dt = (t - self.Last)
	self.Last = t
	self.Velocity = (self.Velocity + (self.P * ((self.Goal - self.Position) + (-self.Velocity * self.D))))
	self.Position = (self.Position + (self.Velocity * dt))
	self:CheckNAN()
	return self.Position
end


return Damping