-- Data Service
-- Crazyman32
-- October 12, 2015

-- Updated: December 31, 2016
--    Implemented SetCustom and GetCustom

--[[
	
	Server:
	
		DataService:Set(player, key, value)
		DataService:Get(player, key)
		DataService:Save(player, key)
		DataService:SaveAll(player)
		DataService:SetCustom(name, scope, key, value)
		DataService:GetCustom(name, scope, key)
		DataService:SaveCustom(name, scope, key)
		DataService:SaveCustomAll(name, scope)
		
		DataService.DataStoreFail(failMesage)
		DataService.DataStoreWorking()
	
	
	Client:
		
		DataService:Get(key)
		DataService:CanSave()
		
		DataService.Save:Fire(key)
		DataService.SaveAll:Fire()
		
		DataService.DataStoreFail(failMesage)
		DataService.DataStoreWorking()
	
--]]



local DataService = {Client = {}}
local services

local autoSaveInterval = 60 * 3


local SafeDataStore = require(script:WaitForChild("SafeDataStore"))
local DataCache = require(script:WaitForChild("DataCache"))

local failSafe = require(script:WaitForChild("FailSafe"))


local dataStores = {}
local dataCaches = {}

local customDataStores = {}
local customDataCaches = {}


local function GetDataStoreName(player)
	return tostring(player.UserId)
end


local function DataStoreFail(data)
	warn("[DataStore Error] :: [Key: \"" .. data.Key .. "\"] " .. data.Message)
	DataService.DataStoreFail:Fire(data.Message)
	-- Fail-safe for SetAsync:
	if (data.Method == "SetAsync") then
		failSafe:Add(data.SafeDataStore, data.Key, data.Value)
	end
end


local function GetDataStore(player)
	local dataStore = dataStores[player]
	if (not dataStore) then
		dataStore = SafeDataStore.new(GetDataStoreName(player), "PlayerData")
		dataStores[player] = dataStore
		if (dataStore) then
			dataStore.Failed:connect(DataStoreFail)
			dataStore.Failed:connect(function(data)
				DataService.Client.Events.DataStoreFail:FireClient(player, data.Message)
			end)
		end
	end
	return dataStore
end


local function GetCustomDataStore(name, scope)
	local id = (name .. scope)
	local dataStore = customDataStores[id]
	if (not dataStore) then
		dataStore = SafeDataStore.new(name, scope)
		customDataStores[id] = dataStore
		if (dataStore) then
			dataStore.Failed:connect(DataStoreFail)
		end
	end
	return dataStore
end


local function GetDataCache(player)
	local dataCache = dataCaches[player]
	if (not dataCache) then
		if (player.UserId > 0) then
			local dataStore = GetDataStore(player)
			if (dataStore) then
				dataCache = DataCache.new(dataStore)
				dataCaches[player] = dataCache
			end
		else
			-- For guests:
			dataCache = DataCache.new()
			dataCaches[player] = dataCache
		end
	end
	return dataCache
end


local function GetCustomDataCache(name, scope)
	local id = (name .. scope)
	local dataCache = customDataCaches[id]
	if (not dataCache) then
		local dataStore = GetCustomDataStore(name, scope)
		if (dataStore) then
			dataCache = DataCache.new(dataStore)
			customDataCaches[id] = dataCache
		end
	end
	return dataCache
end


local function FailSafeQueueFlushed()
	DataService.Client.Events.DataStoreWorking:FireAllClients()
	DataService.DataStoreWorking:Fire()
end



DataService.Events = {
	"DataStoreFail";
	"DataStoreWorking";
}

DataService.Client.Events = {
	"DataStoreFail";
	"DataStoreWorking";
	"Save";
	"SaveAll";
}


function DataService:Set(player, key, value)
	local dataCache = GetDataCache(player)
	if (dataCache) then
		dataCache:Set(key, value)
	end
end


function DataService:Get(player, key)
	local dataCache = GetDataCache(player)
	if (dataCache) then
		return dataCache:Get(key)
	end
end


function DataService:SetCustom(name, scope, key, value)
	local dataCache = GetCustomDataCache(name, scope)
	if (dataCache) then
		dataCache:Set(key, value)
	end
end


function DataService:GetCustom(name, scope, key)
	local dataCache = GetCustomDataCache(name, scope)
	if (dataCache) then
		return dataCache:Get(key)
	end
end


function DataService:SaveCustom(name, scope, key)
	local dataCache = GetCustomDataCache(name, scope)
	if (dataCache) then
		dataCache:Save(key)
	end
end


function DataService:SaveCustomAll(name, scope)
	local dataCache = GetCustomDataCache(name, scope)
	if (dataCache) then
		dataCache:SaveAll()
	end
end


function DataService:Save(player, key)
	local dataCache = GetDataCache(player)
	if (dataCache) then
		dataCache:Save(key)
	end
end


function DataService:SaveAll(player)
	local dataCache = GetDataCache(player)
	if (dataCache) then
		dataCache:SaveAll()
	end
end


------------------------------------------------------------------------------------------------------
-- Client:

--[[
function DataService.Client:Set(player, key, value)
	DataService:Set(player, key, value)
end
--]]

local lastClientSaves = {}
local clientSaveInterval = 15

local function CanClientSave(player)
	local t = tick()
	local last = (lastClientSaves[player] or 0)
	return ((t - last) >= clientSaveInterval)
end


function DataService.Client:Get(player, key)
	return DataService:Get(player, key)
end

function DataService.Client:CanSave(player)
	return CanClientSave(player)
end

local function ClientSave(player, key)
	if (CanClientSave(player)) then
		lastClientSaves[player] = tick()
		DataService:Save(player, key)
	end
end

local function ClientSaveAll(player)
	if (CanClientSave(player)) then
		lastClientSaves[player] = tick()
		DataService:SaveAll(player)
	end
end

------------------------------------------------------------------------------------------------------
-- Player handling:

do
	
	-- Auto-save when player leaves:
	local function PlayerRemoving(player)
		DataService:SaveAll(player)
		wait(5)
		lastClientSaves[player] = nil
		dataCaches[player] = nil
		dataStores[player] = nil
	end
	
	local function AutoSaveForAll(eachThreaded)
		for _,player in pairs(game.Players:GetPlayers()) do
			if (eachThreaded) then
				spawn(function()
					DataService:SaveAll(player)
				end)
			else
				DataService:SaveAll(player)
			end
		end
		for _,dataCache in pairs(customDataCaches) do
			if (eachThreaded) then
				spawn(function()
					dataCache:SaveAll()
				end)
			else
				dataCache:SaveAll()
			end
		end
	end
	
	game.Players.PlayerRemoving:connect(PlayerRemoving)
	
	-- Auto-save on server shutdown:
	game:BindToClose(function()
		gameClosing = true
		AutoSaveForAll(true)
	end)
	
	-- Auto-save:
	spawn(function()
		while (true) do
			wait(autoSaveInterval)
			if (gameClosing) then break end
			AutoSaveForAll(false)
		end
	end)
	
end

------------------------------------------------------------------------------------------------------



function DataService:Start()
	
end


function DataService:Init(otherServices)
	services = otherServices
	self.Client.Events.Save.OnServerEvent:connect(ClientSave)
	self.Client.Events.SaveAll.OnServerEvent:connect(ClientSaveAll)
	failSafe.QueueFlushed:connect(FailSafeQueueFlushed)
end



return DataService