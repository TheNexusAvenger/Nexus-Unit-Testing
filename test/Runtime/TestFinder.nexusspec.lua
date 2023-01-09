--[[
TheNexusAvenger

Tests the TestFinder class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")

local TestFinder = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusUnitTesting"):WaitForChild("Runtime"):WaitForChild("TestFinder"))



--[[
Tests the GetTests method.
--]]
NexusUnitTesting:RegisterUnitTest("GetTests",function(UnitTest)
    --Create the modules.
    local Folder = Instance.new("Folder")
    Instance.new("Part",Folder)
    local Module1 = Instance.new("ModuleScript")
    Module1.Name = "Module1.spec"
    Module1.Source = "local NexusUnitTesting = require(\"NexusUnitTesting\") return true"
    Module1.Parent = Folder
    local Module2 = Instance.new("ModuleScript")
    Module2.Name = "Module2.nexusspec"
    Module2.Source = "local NexusUnitTesting = require(\"NexusUnitTesting\") return true"
    Module2.Parent = Folder
    local Module3 = Instance.new("ModuleScript")
    Module3.Name = "Module3"
    Module3.Source = "local NexusUnitTesting = require(\"NexusUnitTesting\") return true"
    Module3.Parent = Module2

    --Assert the tests are correct.
    local Tests = TestFinder.GetTests(Folder)
    UnitTest:AssertEquals(#Tests, 2, "Tests count is incorrect.")
    UnitTest:AssertEquals(Tests[1].Name, "Folder.Module1.spec", "Name is incorrect.")
    UnitTest:AssertEquals(Tests[2].Name, "Folder.Module2.nexusspec", "Name is incorrect.")
end)



return true