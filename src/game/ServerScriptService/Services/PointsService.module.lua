-- Points Service
-- Crazyman32
-- December 1, 2015

--[[
	
	Server:
		
		PointsService:GetPoints(player)
		PointsService:SetPoints(player, points)
		PointsService:AddPoints(player, deltaPoints)
	
	
	Client:
		
		PointsService:GetPoints()
		
		PointsService.PointsChanged(points)
	
--]]



local PointsService = {
	Client = {
		Events = {
			"PointsChanged";
		};
	};
}

local services

local ptsService = game:GetService("PointsService")
local realPoints = {}


local POINTS_KEY = "points"


function PointsService:GetPoints(player)
	return (services.DataService:Get(player, POINTS_KEY) or 0)
end


function PointsService:SetPoints(player, points)
	points = math.floor(points)
	local difference = (points - self:GetPoints(player))
	if (difference ~= 0) then
		services.DataService:Set(player, POINTS_KEY, points)
		self.Client.Events.PointsChanged:FireClient(player, points)
		if (player.UserId > 0) then
			local awardSuccess, err = pcall(function()
				ptsService:AwardPoints(player.UserId, difference)
			end)
			if (not awardSuccess) then
				warn("Failed to award points: " .. tostring(err))
			end
		end
	end
end


function PointsService:AddPoints(player, pts)
	local points = (self:GetPoints(player) + pts)
	self:SetPoints(player, points)
end


function PointsService.Client:GetPoints(player)
	return PointsService:GetPoints(player)
end


function PointsService:Start()
	local function PlayerAdded(player)
		local pts = self:GetPoints(player)
		realPoints[player] = pts
		if (player.UserId > 0) then
			local realPts = ptsService:GetGamePointBalance(player.UserId)
			if (realPts ~= pts) then
				local awardSuccess, err = pcall(function()
					ptsService:AwardPoints(player.UserId, (pts - realPts))
				end)
				if (not awardSuccess) then
					warn("Failed to award points: " .. tostring(err))
				end
			end
		end
	end
	game.Players.PlayerAdded:connect(PlayerAdded)
	for _,p in pairs(game.Players:GetPlayers()) do
		spawn(function()
			PlayerAdded(p)
		end)
	end
end


function PointsService:Init(otherServices)
	services = otherServices
end


return PointsService