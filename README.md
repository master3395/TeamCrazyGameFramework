# Team Crazy Game Framework
Team Crazy Game Framework for ROBLOX.

This framework was specifically designed to introduce ease of communication between your code, including server/client communication.
The big idea is to introduce a service-like approach server-side, so that services can be created using modules. These services
allow creation of server-side methods *and* client-side methods. The services can see each other, thus can invoke methods from
each other.

On the client, modules are used to help code modules stay in communication with each other. These modules also have access to the custom-built
server services. When a service exposes a client method, the client can invoke that method directly. No more fiddling with creating
and configuring RemoteFunctions and RemoteEvents! This framework takes care of all that messy work behind the scenes.

## Install & Update
Copy, paste, and run the code below into the command bar in ROBLOX Studio:
```lua
local h = game:GetService("HttpService")
local e = h.HttpEnabled
h.HttpEnabled = true
loadstring(h:GetAsync("https://raw.githubusercontent.com/Sleitnick/TeamCrazyGameFramework/master/install.min.lua"))()
h.HttpEnabled = e
```
Running this code again will download new code and update the source code of existing framework scripts to the newest versions.

## Services
Creating server-side services is easy. Navigate to the `ServerScriptService.Services` and create a new ModuleScript. The name of
the ModuleScript will be how others see it. A simple template of a blank service looks like this:
```lua
local MyService = {
	Client = {
		-- RemoteEvents:
		Events = {"ExampleRemoteEvent"};
	};
	-- Server-side events:
	Events = {"ExampleServerEvent"};
}

-- All other services in-game:
local services

function MyService:ServerSideMethod()
	print("Hi")
end

function MyService.Client:ClientSideMethod(player)
	print("Hello " .. player.Name)
	return "I am the server"
end

-- REQUIRED METHOD:
function MyService:Start()
	-- Invoked once all other services have been initialized
	
	-- Connect to server event:
	self.ExampleServerEvent:connect(function(msg)
		print("Got message:", msg)
	end)
	
	-- Fire server event:
	self.ExampleServerEvent:Fire("Hello event!")
	
	-- Connect to client event:
	self.Client.ExampleRemoteEvent.OnServerEvent:connect(function(player, msg)
		print("Got message from " .. player.Name .. ":", msg)
	end)
	
	-- Fire client event:
	self.Client.ExampleRemoteEvent:FireAllClients("Hello clients!")
	
end

-- REQUIRED METHOD:
function MyService:Init(otherServices)
	-- Initialize service
	services = otherServices
end

return MyService
```

## Client
Navigate to `StarterPlayer.StarterPlayerScripts.Main`. Modules within this LocalScript are automatically required and ran.

All modules have a `Init` method that is invoked with a table called `main` that contains all the other required modules referenced
by their script names.

A template for creating new modules here:
```lua
local ClientTest = {}
local main      -- Table of all client modules within the Main LocalScript (referenced by module name)
local services  -- Table of all server services (referenced by module name)

function ClientTest:RandomTest()
	return math.random()
end

-- REQUIRED METHOD:
function ClientTest:Start()
	-- Invoked after all other modules have been initialized
	
	-- Example mouse click capture:
	main.Controls.Mouse.ButtonDown:connect(function(btn)
		if (btn == Enum.UserInputType.MouseButton1) then
			print("Left clicekd")
		end
	end)
	
	-- Example service use:
	local kills = services.DataService:Get("kills") or 0
		-- That invokes the "Get" method in DataService.Client server-side
  
end

-- REQUIRED METHOD:
function ClientTest:Init(_main)
	main = _main
	services = main.Services
end

return ClientTest
```
