-- Run Services
-- Crazyman32
-- September 17, 2015



local clientRemoteParent = game:GetService("ReplicatedStorage"):WaitForChild("RemoteServices")


function SetupRemoteService(serviceName, service)
	local folder = Instance.new("Folder", clientRemoteParent)
	folder.Name = serviceName
	for name,value in pairs(service) do
		if (type(value) == "function") then
			local remoteFunc = Instance.new("RemoteFunction", folder)
			remoteFunc.Name = name
			function remoteFunc.OnServerInvoke(player, ...)
				return value(service, player, ...)
			end
		end
	end
	local events = service.Events
	if (type(events) == "table") then
		local actualEvents = {}
		for _,eventName in pairs(events) do
			local remoteEvent = Instance.new("RemoteEvent", folder)
			remoteEvent.Name = eventName
			actualEvents[eventName] = remoteEvent
		end
		service.Events = actualEvents
	end
end


function RunServices()
	
	local services = {}
	
	-- Load service modules:
	for _,v in pairs(script.Parent:GetChildren()) do
		if (v:IsA("ModuleScript")) then
			local service = require(v)
			services[v.Name] = service
			if (type(service.Client) == "table") then
				local clientService = service.Client
				SetupRemoteService(v.Name, clientService)
			end
			-- Load server-side events:
			if (type(service.Events) == "table") then
				for _,eventName in pairs(service.Events) do
					local bindableEvent = Instance.new("BindableEvent")
					local event = {}
					function event:connect(func)
						return bindableEvent.Event:connect(func)
					end
					function event:Fire(...)
						bindableEvent:Fire(...)
					end
					if (service[eventName]) then
						warn(("Event %q overriding existing item in service %q"):format(eventName, v.Name))
					end
					service[eventName] = event
				end
				service.Events = nil
			end
		end
	end
	
	-- Initiate service modules:
	for _,service in pairs(services) do
		if (type(service.Init) == "function") then
			spawn(function()
				service:Init(services)
			end)
		end
	end
	
	-- Start service modules:
	for _,service in pairs(services) do
		if (type(service.Start) == "function") then
			spawn(function()
				service:Start()
			end)
		end
	end
	
	-- Mark as ready:
	local ready = Instance.new("ObjectValue")
	ready.Name = "ServicesReady"
	ready.Parent = clientRemoteParent
	
end


RunServices()