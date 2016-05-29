-- Install the Team Crazy Game Framework
-- Copy & paste this code into the command line and run it


-- Crazyman32
-- December 25, 2015

-- Updated May 29, 2016
	-- Added GUI progress screen


local http = game:GetService("HttpService")
local originallyEnabled = http.HttpEnabled
http.HttpEnabled = true


local loadingGui = Instance.new("ScreenGui")
	loadingGui.Name = "TeamCrazyGameFrameworkLoadingGui"
	loadingGui.Archivable = false
	local frameGui = Instance.new("Frame", loadingGui)
	frameGui.Position = UDim2.new(0.5, -125, 0, 20)
	frameGui.Size = UDim2.new(0, 250, 0, 50)
	frameGui.Style = Enum.FrameStyle.DropShadow
	local labelGui = Instance.new("TextLabel", frameGui)
	labelGui.Name = "Label"
	labelGui.BackgroundTransparency = 1
	labelGui.Position = UDim2.new(0, 0, 0, -4)
	labelGui.Size = UDim2.new(1, -40, 0.5, 0)
	labelGui.Font = Enum.Font.SourceSans
	labelGui.FontSize = Enum.FontSize.Size14
	labelGui.TextColor3 = Color3.new(1, 1, 1)
	labelGui.TextXAlignment = Enum.TextXAlignment.Left
	labelGui.ClipsDescendants = true
	labelGui.Text = "Initializing..."
	local percentGui = Instance.new("TextLabel", frameGui)
	percentGui.Name = "Percent"
	percentGui.BackgroundTransparency = 1
	percentGui.Position = UDim2.new(0, 0, 0, -4)
	percentGui.Size = UDim2.new(1, 0, 0.5, 0)
	percentGui.Font = Enum.Font.SourceSansBold
	percentGui.FontSize = Enum.FontSize.Size14
	percentGui.TextColor3 = Color3.new(1, 1, 1)
	percentGui.TextXAlignment = Enum.TextXAlignment.Right
	percentGui.Text = "0%"
	local progressGui = Instance.new("Frame", frameGui)
	progressGui.Name = "Progress"
	progressGui.BackgroundColor3 = Color3.new(1, 1, 1)
	progressGui.BorderSizePixel = 0
	progressGui.Position = UDim2.new(0, 0, 0.5, 0)
	progressGui.Size = UDim2.new(1, 0, 0.5, 0)
	local barGui = Instance.new("Frame", progressGui)
	barGui.Name = "Bar"
	barGui.BackgroundColor3 = Color3.new(0, (2 / 3), 0.5)
	barGui.BorderSizePixel = 0
	barGui.Position = UDim2.new(0, 0, 0, 0)
	barGui.Size = UDim2.new(0, 0, 1, 0)
	
loadingGui.Parent = game:GetService("CoreGui")


local filelistUrl = "https://raw.githubusercontent.com/Sleitnick/TeamCrazyGameFramework/master/filelist.txt"
local filelistStr = http:GetAsync(filelistUrl, true)
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

--print(("\nDownloading %i file%s...\n"):format(#filelist, #filelist == 1 and "" or "s"))
labelGui.Text = ("Downloading %i file%s...\n"):format(#filelist, #filelist == 1 and "" or "s")



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
	local source = http:GetAsync(sourceUrl, true)
	s.Source = source
end


local numFiles = #filelist
for i,path in pairs(filelist) do
	local s = CreateScript(path)
	local completed = (i / numFiles)
	--print(("[%i / %i] %s"):format(i, numFiles, s:GetFullName()))
	labelGui.Text = ("[%i / %i] %s..."):format(i, numFiles, s.Name)
	percentGui.Text = ("%.i%%"):format(completed * 100)
	barGui.Size = UDim2.new(completed, 0, 1, 0)
	DownloadSource(s, path)
end


http.HttpEnabled = originallyEnabled

--print("Team Crazy Game Framework downloaded")
labelGui.Text = "Download & installation completed."
percentGui.Text = ""
wait(3)
loadingGui:Destroy()