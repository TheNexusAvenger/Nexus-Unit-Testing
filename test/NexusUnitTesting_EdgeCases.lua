--[[
TheNexusAvenger

Unit tests for the NexusUnitTesting module. Since it is used for the 
Nexus Unit Testing plugin, it is not set up for the plugin.
This script tests various edge cases.
--]]

local Tests = script.Parent
local Source = Tests.Parent:WaitForChild("Sources")
local NexusUnitTesting = require(Source:WaitForChild("NexusUnitTesting"))

local PassPartWayThroughFinished = false



--[[
Tests that an empty test passes.
--]]
NexusUnitTesting:RegisterUnitTest("EmptyTest",function(UnitTest)
	
end)

--[[
Tests that yields passes and doesn't yield the other tests.
--]]
NexusUnitTesting:RegisterUnitTest("YieldingTest",function(UnitTest)
	wait(1)
	UnitTest:AssertTrue(PassPartWayThroughFinished,"Unit test caused other to yield.")
end)

--[[
Tests that a test with a pass call doesn't fail.
--]]
NexusUnitTesting:RegisterUnitTest("PassPartWayThrough",function(UnitTest)
	PassPartWayThroughFinished = true
	
	UnitTest:Pass()
	UnitTest:Fail("Pass doesn't stop test")
end)

--[[
Tests that failing won't work after calling pass in a seperate co-routine.
--]]
NexusUnitTesting:RegisterUnitTest("ThreadingPassAndFail",function(UnitTest)
	coroutine.wrap(function()
		UnitTest:Pass()
	end)()
	
	wait(0.1)
	UnitTest:Fail("Pass doesn't stop test in a thread")
end)

--[[
Tests that passing won't happen twice. The output does need to be
checked manually.
--]]
NexusUnitTesting:RegisterUnitTest("ThreadingDuplicatePass",function(UnitTest)
	coroutine.wrap(function()
		UnitTest:Pass()
	end)()
	
	wait(0.1)
end)

--Return true so there is no error with loading the ModuleScript.
return true