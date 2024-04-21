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
            Module1.Parent = Folder
            local Module2 = Instance.new("ModuleScript")
            Module2.Name = "Module2"
            Module2.Source = "local NexusUnitTesting = require(\"NexusUnitTesting\") return true"
            Module2.Parent = Module1

            --Assert the tests are correct.
            local Tests = TestFinder.GetTests(Folder)
            expect(#Tests).to.equal(1)
            expect(Tests[1].Name).to.equal("Folder.Module1.spec")
        end)
    end)
end