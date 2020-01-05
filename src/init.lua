--[[
TheNexusAvenger

Base module for NexusUnitTesting.
--]]

local NexusUnitTesting = require(script:WaitForChild("NexusUnitTestingProject"))
local TestFinder = NexusUnitTesting:GetResource("Runtime.TestFinder")



--[[
Runs the tests for a given container,
or game if it isn't provided.
Not intended to be used by custom views for
unit tests since it doesn't provide visibility to the tests.
--]]
function NexusUnitTesting.RunTests(Container)
	--Get the tests.
	local Tests = TestFinder.GetTests(Container)
	for _,Test in pairs(Tests) do
		print(Test.Name)
	end
end



return NexusUnitTesting