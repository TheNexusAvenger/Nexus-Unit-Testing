--[[
TheNexusAvenger

Tests the TestFinder class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")

local NexusUnitTestingProject = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusUnitTesting"):WaitForChild("NexusUnitTestingProject"))
local TestFinder = NexusUnitTestingProject:GetResource("Runtime.TestFinder")



--[[
Tests the ScriptContainsTests method.
--]]
NexusUnitTesting:RegisterUnitTest("ScriptContainsTests",function(UnitTest)
    --Assert that random scripts return false.
    UnitTest:AssertFalse(TestFinder.ScriptContainsTests("print(\"Not a test\")"),"Script without require registers as test.")
    UnitTest:AssertFalse(TestFinder.ScriptContainsTests("require(game.Workspace:WaitForChild(\"Module\"))"),"Script with random require registers as test.")
    UnitTest:AssertFalse(TestFinder.ScriptContainsTests("local NexusUnitTesting = true"),"Script with NexusUnitTesting as varaibles registers as test.")
    UnitTest:AssertFalse(TestFinder.ScriptContainsTests("require(game.Workspace.NexusUnitTestingFork)"),"Script with non-Nexus Unit Testing require registers as test.")
    
    --Assert that unit test scripts return true.
    UnitTest:AssertTrue(TestFinder.ScriptContainsTests("require(\"NexusUnitTesting\")"),"NexusUnitTesting test not detected.")
    UnitTest:AssertTrue(TestFinder.ScriptContainsTests("require('NexusUnitTesting')"),"NexusUnitTesting test not detected.")
    UnitTest:AssertTrue(TestFinder.ScriptContainsTests("require(game.TestService.NexusUnitTesting)"),"NexusUnitTesting test not detected.")
    UnitTest:AssertTrue(TestFinder.ScriptContainsTests("require(game.TestService:WaitForChild(\"NexusUnitTesting\")"),"NexusUnitTesting test not detected.")
    UnitTest:AssertTrue(TestFinder.ScriptContainsTests("require(game.Workspace.Module) require(game.TestService:WaitForChild(\"NexusUnitTesting\")"),"NexusUnitTesting test with other module not detected.")
end)
    
--[[
Tests the GetTests method.
--]]
NexusUnitTesting:RegisterUnitTest("GetTests",function(UnitTest)
    --Create the modules.
    local Folder = Instance.new("Folder")
    Instance.new("Part",Folder)
    local Module1 = Instance.new("ModuleScript")
    Module1.Name = "Module1"
    Module1.Source = "local NexusUnitTesting = require(\"NexusUnitTesting\") return true"
    Module1.Parent = Folder
    local Module2 = Instance.new("ModuleScript")
    Module2.Name = "Module2"
    Module2.Source = "local NexusUnitTesting = require(\"NexusUnitTesting\") return true"
    Module2.Parent = Folder
    local Module3 = Instance.new("ModuleScript")
    Module3.Name = "Module3"
    Module3.Source = "local NexusUnitTesting = require(\"NexusUnitTesting\") return true"
    Module3.Parent = Module2
    local Module4 = Instance.new("ModuleScript")
    Module4.Name = "Module4"
    Module4.Source = "local NexusUnitTesting = require(\"NexusUnitTestingFork\") return true"
    Module4.Parent = Module2
    local Module5 = Instance.new("ModuleScript")
    Module5.Name = "Module5.spec"
    Module5.Source = "return function() end"
    Module5.Parent = Module2
    
    --Assert the tests are correct.
    local Tests = TestFinder.GetTests(Folder)
    UnitTest:AssertEquals(#Tests,4,"Tests count is incorrect.")
    UnitTest:AssertEquals(Tests[1].Name,"Folder.Module1","Name is incorrectt.")
    UnitTest:AssertEquals(Tests[2].Name,"Folder.Module2","Name is incorrectt.")
    UnitTest:AssertEquals(Tests[3].Name,"Folder.Module2.Module3","Name is incorrectt.")
    UnitTest:AssertEquals(Tests[4].Name,"Folder.Module2.Module5.spec","Name is incorrectt.")
end)



return true