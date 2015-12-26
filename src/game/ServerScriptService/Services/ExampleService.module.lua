-- Example Service
-- Crazyman32
-- December 25, 2015

-- Take a look at `StarterPlayer.StarterPlayerScripts.Main.Example`
--    That script will show how to consume this service


-- All services must have a `Init(otherServices)` and a `Start()` method

-- Methods with in the Client table of a service will be binded to the
-- client-side version of this service automatically.

-- Events tables can exist in both the service table and the service.Client table.
-- Events should be listed as string names. Events within the main service will
-- be populated directly into the service table. Events within the client table will
-- remain within the events table.

-- Example:    ExampleService.TestServerEvent:Fire(blah)
--             ExampleService.TestServerEvent:connect(function(...) end)
--             
--             ExampleService.Client.Events.TestRemoteEvent:FireAllClients(blah)
--             ExampleService.Client.Events.TestRemoteEvent.OnServerEvent:connect(function(player, ...) end)



local ExampleService = {
	Client = {
		-- Remote events:
		Events = {
			"TestRemoteEvent";
		};
	};
	-- Server-side events:
	Events = {
		"TestServerEvent";
	};
}

-- Table of other services:
local services


function ExampleService:ExampleAdd(a, b)
	self.TestServerEvent:Fire("Adding " .. a .. " + " .. b)
	return a + b
end


-- Clients can call this function as `ExampleService:AllCaps("foobar")`
function ExampleService.Client:AllCaps(player, message)
	return message:upper()
end


function ExampleService:Start()
	-- Fired after all services are initialized
	
	-- Example server-side event connection:
	self.TestServerEvent:connect(function(msg)
		print("TestServerEvent fired: " .. msg)
	end)
	
	-- Connect to client-side event:
	self.Client.Events.TestServerEvent.OnServerEvent:connect(function(player, msg)
		print("Got msg from " .. player.Name .. ": " .. msg)
	end)
	
	-- Fire client-side event periodically:
	while (true) do
		wait(5)
		self.Client.Events.TestServerEvent:FireAllClients("Hello")
	end
	
end


function ExampleService:Init(otherServices)
	services = otherServices
	-- Initialization code
end


return ExampleService