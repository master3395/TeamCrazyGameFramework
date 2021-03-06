-- Main
-- Crazyman32
-- October 13, 2015



game.StarterGui.ResetPlayerGuiOnSpawn = false

local main = {
	Services = require(game:GetService("ReplicatedStorage"):WaitForChild("RemoteServices"):WaitForChild("Services"));
}


function LoadModules()
	local modules = {}
	for _,v in pairs(script:GetChildren()) do
		if (v:IsA("ModuleScript")) then
			local module = require(v)
			main[v.Name] = module
			modules[v.Name] = module
		end
	end
	for _,module in pairs(modules) do
		if (type(module.Init) == "function") then
			module:Init(main)
		end
	end
	for _,module in pairs(modules) do
		if (type(module.Start) == "function") then
			spawn(function()
				module:Start()
			end)
		end
	end
	modules = nil
end


LoadModules()