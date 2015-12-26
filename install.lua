-- Install the Team Crazy Game Framework
-- Copy & paste this code into the command line and run it


-- Crazyman32
-- December 25, 2015


local http = game:GetService("HttpService")
local originallyEnabled = http.HttpEnabled
http.HttpEnabled = true


local frameworkUrl = "https://api.github.com/repos/Sleitnick/TeamCrazyGameFramework"
local frameworkInfo = http:GetAsync(frameworkUrl)
frameworkInfo = http:JSONDecode(frameworkInfo)


http.HttpEnabled = originallyEnabled