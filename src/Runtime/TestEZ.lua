--[[
TheNexusAvenger

Wraps methods in TestEZ for improved
integration with Nexus Unit Testing.
--]]

local NexusUnitTesting = require(script.Parent.Parent:WaitForChild("NexusUnitTestingProject"))
local UnitTest = NexusUnitTesting:GetResource("UnitTest.UnitTest")

return NexusUnitTesting:GetResource("TestEZ")