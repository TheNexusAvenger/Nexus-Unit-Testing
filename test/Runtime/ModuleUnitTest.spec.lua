--[[
TheNexusAvenger

Tests the ModuleUnitTest class.
--]]
--!strict

local ModuleUnitTest = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusUnitTesting"):WaitForChild("Runtime"):WaitForChild("ModuleUnitTest"))

return function()
    describe("A module with no subtests", function()
        it("should run the assertions", function()
            --Create the module.
            local Folder = Instance.new("Folder")
            Folder.Name = "TestFolder"
            local Module = Instance.new("ModuleScript")
            Module.Name = "TestModule"
            Module.Source = "local NexusUnitTesting = require(\"NexusUnitTesting\") print(script.Name) warn(script.Name) NexusUnitTesting:AssertEquals(script:GetFullName(), \"TestFolder.TestModule\") return true"
            Module.Parent = Folder
            
            --Create the test.
            local TestModuleUnitTest = ModuleUnitTest.new(Module)
            local OutputInformation = {}
            TestModuleUnitTest.MessageOutputted:Connect(function(Message, Type)
                table.insert(OutputInformation, {Message = Message, Type = Type})
            end)

            --Assert the test is ran correctly.
            expect(TestModuleUnitTest.State).to.equal("NOTRUN")
            expect(TestModuleUnitTest.CombinedState).to.equal("NOTRUN")
            TestModuleUnitTest:RunTest()
            expect(TestModuleUnitTest.State).to.equal("PASSED")
            expect(TestModuleUnitTest.CombinedState).to.equal("PASSED")
            expect(#TestModuleUnitTest.SubTests).to.equal(0)
            expect(#OutputInformation).to.equal(2)
            expect(OutputInformation[1].Message).to.equal("TestModule")
            expect(OutputInformation[1].Type).to.equal(Enum.MessageType.MessageOutput)
            expect(OutputInformation[2].Message).to.equal("TestModule")
            expect(OutputInformation[2].Type).to.equal(Enum.MessageType.MessageWarning)
        end)
    end)

    describe("A module with Nexus Unit Testing tests", function()
        it("should pass when all subtests pass.", function()
            --Create the module.
            local Folder = Instance.new("Folder")
            Folder.Name = "TestFolder"
            local Module = Instance.new("ModuleScript")
            Module.Name = "TestModule"
            Module.Source = "local NexusUnitTesting = require(\"NexusUnitTesting\") "..
                "NexusUnitTesting:RegisterUnitTest(NexusUnitTesting.UnitTest.new(\"Test1\"):SetRun(function(self) self:AssertTrue(true) end)) "..
                "NexusUnitTesting:RegisterUnitTest(NexusUnitTesting.UnitTest.new(\"Test2\"):SetRun(function(self) self:AssertTrue(true) end)) "..
                "return true"
            Module.Parent = Folder
            
            --Create the test.
            local TestModuleUnitTest = ModuleUnitTest.new(Module)
            
            --Assert the test is ran correctly.
            local SubTests = TestModuleUnitTest.SubTests :: {any}
            expect(TestModuleUnitTest.State).to.equal("NOTRUN")
            expect(TestModuleUnitTest.CombinedState).to.equal("NOTRUN")
            TestModuleUnitTest:RunTest()
            expect(TestModuleUnitTest.State).to.equal("PASSED")
            expect(TestModuleUnitTest.CombinedState).to.equal("PASSED")
            expect(#SubTests).to.equal(2)
            expect(SubTests[1].Name).to.equal("Test1")
            expect(SubTests[1].State).to.equal("NOTRUN")
            expect(SubTests[1].CombinedState).to.equal("NOTRUN")
            expect(SubTests[2].Name).to.equal("Test2")
            expect(SubTests[2].State).to.equal("NOTRUN")
            expect(SubTests[2].CombinedState).to.equal("NOTRUN")
            
            --Assert the subtests are ran correctly.
            TestModuleUnitTest:RunSubtests()
            expect(TestModuleUnitTest.State).to.equal("PASSED")
            expect(TestModuleUnitTest.CombinedState).to.equal("PASSED")
            expect(SubTests[1].Name).to.equal("Test1")
            expect(SubTests[1].State).to.equal("PASSED")
            expect(SubTests[1].CombinedState).to.equal("PASSED")
            expect(SubTests[2].Name).to.equal("Test2")
            expect(SubTests[2].State).to.equal("PASSED")
            expect(SubTests[2].CombinedState).to.equal("PASSED")
        end)

        it("should fail with a failing subtest.", function()
            --Create the module.
            local Folder = Instance.new("Folder")
            Folder.Name = "TestFolder"
            local Module = Instance.new("ModuleScript")
            Module.Name = "TestModule"
            Module.Source = "local NexusUnitTesting = require(\"NexusUnitTesting\") "..
                "NexusUnitTesting:RegisterUnitTest(NexusUnitTesting.UnitTest.new(\"Test1\"):SetRun(function(self) self:Fail() end)) "..
                "NexusUnitTesting:RegisterUnitTest(NexusUnitTesting.UnitTest.new(\"Test2\"):SetRun(function(self) self:AssertTrue(true) end)) "..
                "return true"
            Module.Parent = Folder
            
            --Create the test.
            local TestModuleUnitTest = ModuleUnitTest.new(Module)
            local SubTests = TestModuleUnitTest.SubTests :: {any}
            
            --Assert the test is ran correctly.
            expect(TestModuleUnitTest.State).to.equal("NOTRUN")
            expect(TestModuleUnitTest.CombinedState).to.equal("NOTRUN")
            TestModuleUnitTest:RunTest()
            expect(TestModuleUnitTest.State).to.equal("PASSED")
            expect(TestModuleUnitTest.CombinedState).to.equal("PASSED")
            expect(#SubTests).to.equal(2)
            expect(SubTests[1].Name).to.equal("Test1")
            expect(SubTests[1].State).to.equal("NOTRUN")
            expect(SubTests[1].CombinedState).to.equal("NOTRUN")
            expect(SubTests[2].Name).to.equal("Test2")
            expect(SubTests[2].State).to.equal("NOTRUN")
            expect(SubTests[2].CombinedState).to.equal("NOTRUN")
            
            --Assert the subtests are ran correctly.
            TestModuleUnitTest:RunSubtests()
            expect(TestModuleUnitTest.State).to.equal("PASSED")
            expect(TestModuleUnitTest.CombinedState).to.equal("FAILED")
            expect(SubTests[1].Name).to.equal("Test1")
            expect(SubTests[1].State).to.equal("FAILED")
            expect(SubTests[1].CombinedState).to.equal("FAILED")
            expect(SubTests[2].Name).to.equal("Test2")
            expect(SubTests[2].State).to.equal("PASSED")
            expect(SubTests[2].CombinedState).to.equal("PASSED")
        end)

        it("should fail with all subtests failing.", function()
            --Create the module.
            local Folder = Instance.new("Folder")
            Folder.Name = "TestFolder"
            local Module = Instance.new("ModuleScript")
            Module.Name = "TestModule"
            Module.Source = "local NexusUnitTesting = require(\"NexusUnitTesting\") "..
                "NexusUnitTesting:RegisterUnitTest(NexusUnitTesting.UnitTest.new(\"Test1\"):SetRun(function(self) self:Fail() end)) "..
                "NexusUnitTesting:RegisterUnitTest(NexusUnitTesting.UnitTest.new(\"Test2\"):SetRun(function(self) self:Fail() end)) "..
                "return true"
            Module.Parent = Folder
            
            --Create the test.
            local TestModuleUnitTest = ModuleUnitTest.new(Module)
            local SubTests = TestModuleUnitTest.SubTests :: {any}
            
            --Assert the test is ran correctly.
            expect(TestModuleUnitTest.State).to.equal("NOTRUN")
            expect(TestModuleUnitTest.CombinedState).to.equal("NOTRUN")
            TestModuleUnitTest:RunTest()
            expect(TestModuleUnitTest.State).to.equal("PASSED")
            expect(TestModuleUnitTest.CombinedState).to.equal("PASSED")
            expect(#SubTests).to.equal(2)
            expect(SubTests[1].Name).to.equal("Test1")
            expect(SubTests[1].State).to.equal("NOTRUN")
            expect(SubTests[1].CombinedState).to.equal("NOTRUN")
            expect(SubTests[2].Name).to.equal("Test2")
            expect(SubTests[2].State).to.equal("NOTRUN")
            expect(SubTests[2].CombinedState).to.equal("NOTRUN")
            
            --Assert the subtests are ran correctly.
            TestModuleUnitTest:RunSubtests()
            expect(TestModuleUnitTest.State).to.equal("PASSED")
            expect(TestModuleUnitTest.CombinedState).to.equal("FAILED")
            expect(SubTests[1].Name).to.equal("Test1")
            expect(SubTests[1].State).to.equal("FAILED")
            expect(SubTests[1].CombinedState).to.equal("FAILED")
            expect(SubTests[2].Name).to.equal("Test2")
            expect(SubTests[2].State).to.equal("FAILED")
            expect(SubTests[2].CombinedState).to.equal("FAILED")
        end)

        it("should run tests returned in the function of the module.", function()
            --Create the module.
            local Folder = Instance.new("Folder")
            Folder.Name = "TestFolder"
            local Module = Instance.new("ModuleScript")
            Module.Name = "TestModule"
            Module.Source = "local NexusUnitTesting = require(\"NexusUnitTesting\") return function()"..
                "NexusUnitTesting:RegisterUnitTest(NexusUnitTesting.UnitTest.new(\"Test1\"):SetRun(function(self) self:AssertTrue(true) end)) "..
                "NexusUnitTesting:RegisterUnitTest(NexusUnitTesting.UnitTest.new(\"Test2\"):SetRun(function(self) self:AssertTrue(true) end)) "..
                "end"
            Module.Parent = Folder
            
            --Create the test.
            local TestModuleUnitTest = ModuleUnitTest.new(Module)
            local SubTests = TestModuleUnitTest.SubTests :: {any}
            
            --Assert the test is ran correctly.
            expect(TestModuleUnitTest.State).to.equal("NOTRUN")
            expect(TestModuleUnitTest.CombinedState).to.equal("NOTRUN")
            TestModuleUnitTest:RunTest()
            expect(TestModuleUnitTest.State).to.equal("PASSED")
            expect(TestModuleUnitTest.CombinedState).to.equal("PASSED")
            expect(#SubTests).to.equal(2)
            expect(SubTests[1].Name).to.equal("Test1")
            expect(SubTests[1].State).to.equal("NOTRUN")
            expect(SubTests[1].CombinedState).to.equal("NOTRUN")
            expect(SubTests[2].Name).to.equal("Test2")
            expect(SubTests[2].State).to.equal("NOTRUN")
            expect(SubTests[2].CombinedState).to.equal("NOTRUN")
            
            --Assert the subtests are ran correctly.
            TestModuleUnitTest:RunSubtests()
            expect(TestModuleUnitTest.State).to.equal("PASSED")
            expect(TestModuleUnitTest.CombinedState).to.equal("PASSED")
            expect(SubTests[1].Name).to.equal("Test1")
            expect(SubTests[1].State).to.equal("PASSED")
            expect(SubTests[1].CombinedState).to.equal("PASSED")
            expect(SubTests[2].Name).to.equal("Test2")
            expect(SubTests[2].State).to.equal("PASSED")
            expect(SubTests[2].CombinedState).to.equal("PASSED")
        end)
    end)

    describe("A module with TestEZ tests", function()
        it("should run correctly.", function()
            --Create the module.
            local Folder = Instance.new("Folder")
            Folder.Name = "TestFolder"
            local Module = Instance.new("ModuleScript")
            Module.Name = "TestModule.spec"
            Module.Source = "return function()"..
                "describe(\"Test\", function()"..
                "    it(\"should work\", function()"..
                "        expect(script.Parent ~= nil).to.equal(true)"..
                "    end)"..
                "end)"..
                "end"
            Module.Parent = Folder
            
            --Create the test.
            local TestModuleUnitTest = ModuleUnitTest.new(Module)
            local SubTests = TestModuleUnitTest.SubTests :: {any}
            
            --Assert the test is ran correctly.
            expect(TestModuleUnitTest.State).to.equal("NOTRUN")
            expect(TestModuleUnitTest.CombinedState).to.equal("NOTRUN")
            TestModuleUnitTest:RunTest()
            expect(TestModuleUnitTest.State).to.equal("PASSED")
            expect(TestModuleUnitTest.CombinedState).to.equal("PASSED")
            expect(#SubTests).to.equal(1)
            expect(SubTests[1].Name).to.equal("Test")
            expect(SubTests[1].State).to.equal("PASSED")
            expect(SubTests[1].CombinedState).to.equal("PASSED")
            expect(#SubTests[1].SubTests).to.equal(1)
            expect(SubTests[1].SubTests[1].Name).to.equal("should work")
            expect(SubTests[1].SubTests[1].State).to.equal("PASSED")
            expect(SubTests[1].SubTests[1].CombinedState).to.equal("PASSED")
            expect(#SubTests[1].SubTests[1].SubTests).to.equal(0)
        end)

        it("should not use extension methods by default.", function()
            --Create the module.
            local Folder = Instance.new("Folder")
            Folder.Name = "TestFolder"
            local Module = Instance.new("ModuleScript")
            Module.Name = "TestModule.spec"
            Module.Source = "return function()"..
                "describe(\"Test\", function()"..
                "    it(\"should fail\", function()"..
                "        expect(Vector3.new()).to.be.near(Vector3.new())"..
                "    end)"..
                "end)"..
                "end"
            Module.Parent = Folder
            
            --Create the test.
            local TestModuleUnitTest = ModuleUnitTest.new(Module)
            local SubTests = TestModuleUnitTest.SubTests :: {any}
            
            --Assert the test is ran correctly.
            expect(TestModuleUnitTest.State).to.equal("NOTRUN")
            expect(TestModuleUnitTest.CombinedState).to.equal("NOTRUN")
            TestModuleUnitTest:RunTest()
            expect(#SubTests).to.equal(1)
            expect(SubTests[1].Name).to.equal("Test")
            expect(#SubTests[1].SubTests).to.equal(1)
            expect(SubTests[1].SubTests[1].Name).to.equal("should fail")
            expect(SubTests[1].SubTests[1].State).to.equal("FAILED")
            expect(SubTests[1].SubTests[1].CombinedState).to.equal("FAILED")
            expect(#SubTests[1].SubTests[1].SubTests).to.equal(0)
            expect(SubTests[1].SubTests[1].Output[1].Message).to.equal("TestEZ near with non-numbers is not supported in TestEZ. Add --$NexusUnitTestExtensions to the test script to enable Nexus Unit Testing to enable comparing non-numbers with near.")
        end)

        it("should use extension methods when specified.", function()
            --Create the module.
            local Folder = Instance.new("Folder")
            Folder.Name = "TestFolder"
            local Module = Instance.new("ModuleScript")
            Module.Name = "TestModule.spec"
            Module.Source = "--$NexusUnitTestExtensions\nreturn function()"..
                "describe(\"Test\", function()"..
                "    it(\"should pass with extensions\", function()"..
                "        expect(Vector3.new()).to.be.near(Vector3.new())"..
                "        expect(Vector3.new()).to.never.be.near(Vector3.new(1, 1, 1))"..
                "    end)"..
                "    it(\"should fail with extensions\", function()"..
                "        expect(Vector3.new(1, 1, 1)).to.be.near(Vector3.new(2, 2, 2))"..
                "    end)"..
                "end)"..
                "end"
            Module.Parent = Folder
            
            --Create the test.
            local TestModuleUnitTest = ModuleUnitTest.new(Module)
            local SubTests = TestModuleUnitTest.SubTests :: {any}
            
            --Assert the test is ran correctly.
            expect(TestModuleUnitTest.State).to.equal("NOTRUN")
            expect(TestModuleUnitTest.CombinedState).to.equal("NOTRUN")
            TestModuleUnitTest:RunTest()
            expect(#SubTests).to.equal(1)
            expect(SubTests[1].Name).to.equal("Test")
            expect(#SubTests[1].SubTests).to.equal(2)
            expect(SubTests[1].SubTests[1].Name).to.equal("should pass with extensions")
            expect(SubTests[1].SubTests[1].State).to.equal("PASSED")
            expect(SubTests[1].SubTests[1].CombinedState).to.equal("PASSED")
            expect(#SubTests[1].SubTests[1].SubTests).to.equal(0)
            expect(SubTests[1].SubTests[2].Name).to.equal("should fail with extensions")
            expect(SubTests[1].SubTests[2].State).to.equal("FAILED")
            expect(SubTests[1].SubTests[2].CombinedState).to.equal("FAILED")
            expect(#SubTests[1].SubTests[2].SubTests).to.equal(0)
        end)
    end)
end