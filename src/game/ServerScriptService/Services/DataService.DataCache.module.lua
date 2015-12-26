-- Data Cache
-- Crazyman32
-- October 12, 2015

--[[
	
	local DataCache = require(this)
	
	local cache = DataCache.new()
	
	cache:Set(String key, Any value)
	cache:Get(String key)
	cache:GetKeys()
	cache:CopyData()
	cache:Contains(String key)
	cache:Save(String key)
	cache:SaveAll(eachThreaded)
	
--]]



local DataCache = {}
DataCache.__index = DataCache


local function CopyTable(tbl)
	local copy = {}
	local function Copy(src, dst)
		for k,v in pairs(src) do
			if (type(v) == "table") then
				local sub = {}
				dst[k] = sub
				Copy(v, sub)
			else
				dst[k] = v
			end
		end
	end
	Copy(tbl, copy)
	return copy
end


function DataCache.new(dataStore)
	
	local cache = {
		data = {};
		dataStore = dataStore;
	}
	
	return setmetatable(cache, DataCache)
	
end


function DataCache:Set(key, value)
	self.data[key] = value
end


function DataCache:Get(key)
	local value = self.data[key]
	-- Load from DataStore if needed:
	if (value == nil and self.dataStore) then
		value = self.dataStore:GetAsync(key)
		if (value ~= nil) then
			self.data[key] = value
		end
	end
	return value
end


function DataCache:GetKeys()
	local keys = {}
	for key,value in pairs(self.data) do
		keys[#keys + 1] = key
	end
	return keys
end


function DataCache:CopyData()
	local data = CopyTable(self.data)
	return data
end


function DataCache:Contains(key)
	return (self.data[key] ~= nil)
end


function DataCache:Save(key)
	local value = self.data[key]
	if (value ~= nil and self.dataStore) then
		self.dataStore:SetAsync(key, value)
	end
end


function DataCache:SaveAll(eachThreaded)
	if (not self.dataStore) then return end
	for key,value in pairs(self.data) do
		if (eachThreaded) then
			spawn(function()
				self.dataStore:SetAsync(key, value)
			end)
		else
			self.dataStore:SetAsync(key, value)
		end
	end
end


return DataCache