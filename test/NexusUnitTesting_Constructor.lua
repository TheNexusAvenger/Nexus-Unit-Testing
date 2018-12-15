--[[
TheNexusAvenger

Unit tests for the NexusUnitTesting module. Since it is used for the 
Nexus Unit Testing plugin, it is not set up for the plugin.
This script tests the constructor.
--]]

local Tests = script.Parent
local Source = Tests.Parent:WaitForChild("Sources")
local NexusUnitTesting = require(Source:WaitForChild("NexusUnitTesting"))



--[[
Tests that the constructor works without failing.
--]]
NexusUnitTesting:RegisterUnitTest("Constructor",function(UnitTest)
	NexusUnitTesting.new()
end)



--Return true so there is no error with loading the ModuleScript.
return true