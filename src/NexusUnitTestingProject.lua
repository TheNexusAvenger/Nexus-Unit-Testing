--[[
TheNexusAvenger

Base project for Nexus Unit Testing.
--]]

local NexusProject = require(script.Parent:WaitForChild("NexusProject"))



--Create the project.
local NexusUnitTestingProject = NexusProject.new(script.Parent)
NexusUnitTestingProject.TestState = {}
NexusUnitTestingProject.TestState.NotRun = "NOTRUN"
NexusUnitTestingProject.TestState.InProgress = "INPROGRESS"
NexusUnitTestingProject.TestState.Passed = "PASSED"
NexusUnitTestingProject.TestState.Failed = "FAILED"
NexusUnitTestingProject.TestState.Skipped = "SKIPPED"




--Return the project.
return NexusUnitTestingProject