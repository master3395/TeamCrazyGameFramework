-- Fail Safe
-- Crazyman32
-- October 13, 2015

--[[
	
	local FailSafe = require(this)
	
	FailSafe:Add(safeDataStore, key, value)
	
	FailSafe.QueueFlushed()
	
--]]



local FailSafe = {}

local active = false

local queue = {}


local queueFlushed = Instance.new("BindableEvent")
FailSafe.QueueFlushed = queueFlushed.Event


function FailSafe:FlushQueue()
	if (active) then return end
	active = true
	wait(15)
	while (#queue > 0) do
		local item = queue[1]
		local success
		repeat
			success = select(2, item.SafeDataStore:SetAsync(item.Key, item.Value))
			if (not success) then
				wait(15)
			end
		until success
		table.remove(queue, 1)
	end
	active = false
	queueFlushed:Fire()
end


function FailSafe:Add(safeDataStore, key, value)
	local queueItem
	for _,item in pairs(queue) do
		if (item.SafeDataStore == safeDataStore and item.Key == key) then
			queueItem = item
			break
		end
	end
	if (queueItem) then
		queueItem.Value = value
	else
		queueItem = {
			SafeDataStore = safeDataStore;
			Key = key;
			Value = value;
		}
		table.insert(queue, queueItem)
	end
	spawn(function()
		self:FlushQueue()
	end)
end


return FailSafe