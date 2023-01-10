--[[
TheNexusAvenger

Tests the TestFinder class.
--]]
--!strict

local TestFinder = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusUnitTesting"):WaitForChild("Runtime"):WaitForChild("TestFinder"))

return function()
    describe("The test finder", function()
        it("should find and create tests in a folder.", function()
            --Create the modules.
            local Folder = Instance.new("Folder")
            Instance.new("Part", Folder)
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
            expect(#Tests).to.equal(2)
            expect(Tests[1].Name).to.equal("Folder.Module1.spec")
            expect(Tests[2].Name).to.equal("Folder.Module2.nexusspec")
        end)
    end)
end