-- Game Closing
-- Crazyman32
-- October 12, 2015



local onClose = Instance.new("BindableEvent")


function game.OnClose()
	
	-- Fire any connected listeners:
	onClose:Fire()
	
	-- Arbitrary yielding to wait for any connected listeners to be completed:
	if (game:GetService("RunService"):IsStudio()) then
		wait(game.PlaceId == 0 and 0.5 or 1)
	else
		wait(8)
	end
	
end


_G.OnClose = onClose.Event