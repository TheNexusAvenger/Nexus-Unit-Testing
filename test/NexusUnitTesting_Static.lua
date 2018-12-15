--[[
TheNexusAvenger

Unit tests for the NexusUnitTesting module. Since it is used for the 
Nexus Unit Testing plugin, it is not set up for the plugin.
This script tests assertions being called staticly.
--]]

local Tests = script.Parent
local Source = Tests.Parent:WaitForChild("Sources")
local NexusUnitTesting = require(Source:WaitForChild("NexusUnitTesting"))



--Pass a few test assertions.
NexusUnitTesting:AssertTrue(true)
NexusUnitTesting:AssertFalse(false)
NexusUnitTesting:AssertNil(nil)

--Make the test pass.
NexusUnitTesting:Pass()



--Return true so there is no error with loading the ModuleScript.
return true