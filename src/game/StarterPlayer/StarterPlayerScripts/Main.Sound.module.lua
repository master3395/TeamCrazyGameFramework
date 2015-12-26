-- Sound
-- Crazyman32
-- October 16, 2015

--[[
	
	Sound:Play(soundName)
	Sound:PlayCharacter(soundName)
	
--]]



local Sound = {}

local player = game.Players.LocalPlayer
local main


local soundParent do
	local plrGui = player:WaitForChild("PlayerGui")
	soundParent = plrGui:FindFirstChild("Sound")
	if (not soundParent) then
		soundParent = Instance.new("ScreenGui", plrGui)
		soundParent.Name = "Sound"
	end
end


local sounds = {
	Click = {ID = 306955252; Volume = 1.0};
	ChaChing = {ID = 133647588; Volume = 0.5};
}

local characterSounds = {}

local function GetCharacterSound(soundName)
	local sound = characterSounds[soundName]
	if (not sound or not sound.Parent) then
		sound = nil
		if (player.Character) then
			local s = (player.Character:FindFirstChild("Torso") and player.Character.Torso:FindFirstChild(soundName))
			if (s and s:IsA("Sound")) then
				sound = s
			end
		end
		characterSounds[soundName] = sound
	end
	return sound
end



function Sound:Play(soundName)
	sounds[soundName]:Play()
end


function Sound:PlayCharacter(soundName)
	local s = GetCharacterSound(soundName)
	if (s) then
		s:Play()
	end
end


function Sound:Start()
	
end


function Sound:Init(_main)
	main = _main
	local contentProvider = game:GetService("ContentProvider")
	for name,info in pairs(sounds) do
		local s = Instance.new("Sound", soundParent)
		s.SoundId = ("rbxassetid://%i"):format(info.ID)
		s.Volume = info.Volume
		contentProvider:Preload(s.SoundId)
		sounds[name] = s
	end
end

return Sound