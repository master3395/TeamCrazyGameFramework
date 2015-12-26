-- Install the Team Crazy Game Framework
-- Copy & paste this code into the command line and run it


-- Crazyman32
-- December 25, 2015


local http = game:GetService("HttpService")
local originallyEnabled = http.HttpEnabled
http.HttpEnabled = true


local filelistUrl = "https://raw.githubusercontent.com/Sleitnick/TeamCrazyGameFramework/master/filelist.txt"
local filelistStr = http:GetAsync(filelistUrl)
local filelist = {}

local function SplitString(str, sep)
	local fields = {}
	local pattern = string.format("([^%s]+)", sep)
	str:gsub(pattern, function(c) fields[#fields + 1] = c end)
	return fields
end

filelist = SplitString(filelistStr, "\n")


table.sort(filelist, function(a, b)
	return (#a < #b)
end)

print(("\nDownloading %i file%s...\n"):format(#filelist, #filelist == 1 and "" or "s"))



local function CreateScript(path)
	local serviceName, objectPath, filePath = path:match("src/game/(.-)/(.+/)(.+)")
	local service = game:GetService(serviceName)
	local lastParent = service
	for folderName in objectPath:gmatch("(.-)/") do
		local parent = lastParent:FindFirstChild(folderName)
		if (not parent) then
			parent = Instance.new("Folder", lastParent)
			parent.Name = folderName
		end
		lastParent = parent
	end
	local fileParents, fileName, classType = filePath:match("(.+)%.(.-)%.(.-).lua$")
	if (not fileParents) then
		fileName, classType = filePath:match("(.-)%.(.-).lua$")
	else
		for _,objName in pairs(SplitString(fileParents, "%.")) do
			local parent = lastParent:FindFirstChild(objName)
			assert(parent, "Could not find " .. lastParent:GetFullName() .. "." .. objName)
			lastParent = parent
		end
	end
	classType = classType:lower()
	local class = (classType == "module" and "ModuleScript" or classType == "local" and "LocalScript" or "Script")
	local s = lastParent:FindFirstChild(fileName)
	if (not s) then
		s = Instance.new(class, lastParent)
		s.Name = fileName
	end
	return s
end


local function DownloadSource(s, path)
	local sourceUrl = ("https://raw.githubusercontent.com/Sleitnick/TeamCrazyGameFramework/master/%s"):format(path)
	local source = http:GetAsync(sourceUrl)
	s.Source = source
end


local numFiles = #filelist
for i,path in pairs(filelist) do
	local s = CreateScript(path)
	print(("[%i / %i] %s"):format(i, numFiles, s:GetFullName()))
	DownloadSource(s, path)
end


http.HttpEnabled = originallyEnabled

print("Team Crazy Game Framework downloaded")