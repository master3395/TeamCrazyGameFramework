-- Services
-- Crazyman32
-- September 17, 2015



local Services = {}
script.Parent:WaitForChild("ServicesReady")



function ConstructService(serviceFolder, serviceName)
	local service = {}
	for _,v in pairs(serviceFolder:GetChildren()) do
		if (v:IsA("RemoteFunction")) then
			service[v.Name] = function(self, ...)
				return v:InvokeServer(...)
			end
		elseif (v:IsA("RemoteEvent")) then
			local event = {}
			local listeners = {}
			function event:Fire(...)
				v:FireServer(...)
			end
			function event:connect(func)
				local listener = {connected = true}
				table.insert(listeners, listener)
				function listener:disconnect()
					self.connected = false
					for i,v in pairs(listeners) do
						if (v == self) then
							table.remove(listeners, i)
							break
						end
					end
				end
				function listener.Fire(...)
					func(...)
				end
				return listener
			end
			v.OnClientEvent:connect(function(...)
				local args = {...}
				for _,listener in pairs(listeners) do
					spawn(function()
						listener.Fire(unpack(args))
					end)
				end
			end)
			service[v.Name] = event
		end
	end
	Services[serviceName] = service
end

-- Initiate:
for _,v in pairs(script.Parent:GetChildren()) do
	if (v:IsA("Folder")) then
		ConstructService(v, v.Name)
	end
end


return Services