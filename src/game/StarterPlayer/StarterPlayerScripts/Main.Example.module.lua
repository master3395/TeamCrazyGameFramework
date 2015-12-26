-- Crazyman32
-- Example
-- December 25, 2015

-- All 'main' modules must have a `Init(main)` and a `Start()` method


-- Note that only modules directly in the 'Main' LocalScript are
-- initialized as part of the 'Main' table. Modules within modules
-- must be required programmatically yourself.



local Example = {}
local main


function Example:TestExampleService()

	local msg = "hello!"

	-- Call the client AllCaps method in the ExampleService:
	msg = main.Services.ExampleService:AllCaps(msg)

	print(msg)

end


function Example:Start()
	-- Called after all modules within 'main' are initialized

	self:TestExampleService()

	-- Connect to ExampleService TestRemoteEvent:
	main.Services.ExampleService.TestRemoteEvent:connect(function(msg)
		print("Got message from server: " .. msg)
	end)

	-- Listen to mouse clicked events:
	main.Controls.Mouse.ButtonDown:connect(function(button)
		if (button == Enum.UserInputType.MouseButton1) then
			-- Left-clicked
		end
	end)

end


function Example:Init(_main)
	main = _main
	-- Initialization code
end

return Example