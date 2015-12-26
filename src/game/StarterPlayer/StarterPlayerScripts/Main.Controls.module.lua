-- Controls
-- Crazyman32
-- October 9, 2015

--[[
	
	Controls.Keyboard
	Controls.Mouse
	
--]]



local Controls = {
	Keyboard = require(script:WaitForChild("Keyboard"));
	Mouse = require(script:WaitForChild("Mouse"));
}

function Controls:Start() end
function Controls:Init(_main) end

return Controls