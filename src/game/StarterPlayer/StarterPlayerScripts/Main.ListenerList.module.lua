-- Listener List
-- Crazyman32
-- November 1, 2015

--[[
	
	local listeners = ListenerList.new()
	
	listeners:Connect(event, func)
	listeners:DisconnectAll()
	
--]]



local ListenerList = {}
ListenerList.__index = ListenerList


function ListenerList.new()
	local listenerList = {listeners = {}}
	return setmetatable(listenerList, ListenerList)
end


-- Connect a function to an event and store it in the list:
function ListenerList:Connect(event, func)
	local listener = event:connect(func)
	table.insert(self.listeners, listener)
	return listener
end


-- Disconnect all events in the list and clear the list:
function ListenerList:DisconnectAll()
	for _,l in pairs(self.listeners) do
		if (l.connected) then
			l:disconnect()
		end
	end
	self.listeners = {}
end


return ListenerList