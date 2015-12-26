-- Safe Data Store
-- Crazyman32
-- October 12, 2015

--[[
	
	local SafeDataStore = require(this)
	
	local safeDs = SafeDataStore.new(name, scope)
		> Will return 'nil' if failed to get DataStore
	
	safeDs.AccessTries    = 3  (Number of tries to access DataStore)
	safeDs.AccessInterval = 5  (Seconds between each access try)
	
	safeDs:GetAsync(key)
	safeDs:SetAsync(key, value)
	safeDs:IncrementAsync(key, inc)
	safeDs:UpdateAsync(key, func)
	safeDs:OnUpdate(key, func)
	
	safeDs.Failed( {SafeDataStore, Method, Key, Value, Message} )
	
	
	NOTE: Methods will return 'nil' if failed!
	
--]]



local SafeDataStore = {}
SafeDataStore.__index = SafeDataStore

local dataStoreService = game:GetService("DataStoreService")
if (game.PlaceId == 0) then
	dataStoreService = require(script:WaitForChild("MockDataStoreService"))
end


local function Try(tries, intervalTime, tryFunc)
	local success, returnVal
	for i = 1,tries do
		success, returnVal = pcall(tryFunc)
		if (success) then
			break
		else
			wait(intervalTime)
		end
	end
	return success, returnVal
end


local function OnFail(self, method, key, value, errMsg)
	local msg = (method .. " failed: " .. tostring(errMsg))
	self.dataStoreFail:Fire {
		SafeDataStore = self;
		Method = method;
		Key = key;
		Value = value;
		Message = msg;
	}
end


local function TryAccess(self, method, key, value)
	local success, returnVal = Try(self.AccessTries, self.AccessInterval, function()
		local actualMethod = self.dataStore[method]
		return actualMethod(self.dataStore, key, value)
	end)
	if (success) then
		return returnVal, true
	else
		OnFail(self, method, key, value, returnVal)
		return nil, false
	end
end


function SafeDataStore.new(name, scope)
	
	local dsFail = Instance.new("BindableEvent")
	
	--local dataStore = dataStoreService:GetDataStore(name, scope)
	local dataStore
	do
		local success
		success, dataStore = Try(3, 5, function()
			return dataStoreService:GetDataStore(name, scope)
		end)
		if (not success) then
			return nil, dataStore
		end
	end
	
	local safeDataStore = {
		
		-- For internal use:
		dataStore = dataStore;
		dataStoreFail = dsFail;
		
		-- For external use:
		AccessTries = 3;
		AccessInterval = 5;
		Failed = dsFail.Event;
		
	}
	
	return setmetatable(safeDataStore, SafeDataStore)
	
end


function SafeDataStore:GetAsync(key)
	return TryAccess(self, "GetAsync", key)
end


function SafeDataStore:SetAsync(key, value)
	return TryAccess(self, "SetAsync", key, value)
end


function SafeDataStore:UpdateAsync(key, func)
	return TryAccess(self, "UpdateAsync", key, func)
end


function SafeDataStore:IncrementAsync(key, inc)
	return TryAccess(self, "IncrementAsync", key, inc)
end


function SafeDataStore:OnUpdate(key, func)
	return TryAccess(self, "OnUpdate", key, func)
end


return SafeDataStore