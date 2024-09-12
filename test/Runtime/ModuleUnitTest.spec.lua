--[[
TheNexusAvenger

Tests the ModuleUnitTest class.
--]]
--!strict

local ModuleUnitTest = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusUnitTesting"):WaitForChild("Runtime"):WaitForChild("ModuleUnitTest"))

return function()
    describe("A module with TestEZ tests", function()
        it("should run correctly.", function()
            --Create the module.
            local Folder = Instance.new("Folder")
            Folder.Name = "TestFolder"
            local Module = Instance.new("ModuleScript")
            Module.Name = "TestModule.spec"
            Module.Source = "return function()"..
                "print(\"Test 1\")"..
                "describe(\"Test\", function()"..
                "    print(\"Test 2\")"..
                "    it(\"should work\", function()"..
                "        print(\"Test 3\")"..
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
            expect(TestModuleUnitTest.Output[1].Message).to.equal("Test 1")
            expect(#SubTests).to.equal(1)
            expect(SubTests[1].Name).to.equal("Test")
            expect(SubTests[1].State).to.equal("PASSED")
            expect(SubTests[1].CombinedState).to.equal("PASSED")
            expect(SubTests[1].Output[1].Message).to.equal("Test 2")
            expect(#SubTests[1].SubTests).to.equal(1)
            expect(SubTests[1].SubTests[1].Name).to.equal("should work")
            expect(SubTests[1].SubTests[1].State).to.equal("PASSED")
            expect(SubTests[1].SubTests[1].CombinedState).to.equal("PASSED")
            expect(SubTests[1].SubTests[1].CombinedState).to.equal("PASSED")
            expect(SubTests[1].SubTests[1].Output[1].Message).to.equal("Test 3")
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
                "    it(\"should fail with near.\", function()"..
                "        expect(Vector3.new()).to.be.near(Vector3.new())"..
                "    end)"..
                "    it(\"should fail with deepEqual.\", function()"..
                "        expect({}).to.deepEqual({})"..
                "    end)"..
                "    it(\"should fail with contains.\", function()"..
                "        expect(\"Test string\").to.contain(\"Test\")"..
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
            expect(#SubTests[1].SubTests).to.equal(3)
            expect(SubTests[1].SubTests[1].Name).to.equal("should fail with near.")
            expect(SubTests[1].SubTests[1].State).to.equal("FAILED")
            expect(SubTests[1].SubTests[1].CombinedState).to.equal("FAILED")
            expect(#SubTests[1].SubTests[1].SubTests).to.equal(0)
            expect(SubTests[1].SubTests[1].Output[1].Message).to.equal("TestEZ near with non-numbers is not supported in TestEZ. Add --$NexusUnitTestExtensions to the test script to enable Nexus Unit Testing to enable comparing non-numbers with near.")
            expect(SubTests[1].SubTests[2].Name).to.equal("should fail with deepEqual.")
            expect(SubTests[1].SubTests[2].State).to.equal("FAILED")
            expect(SubTests[1].SubTests[2].CombinedState).to.equal("FAILED")
            expect(#SubTests[1].SubTests[2].SubTests).to.equal(0)
            local HasError, _ = string.find(SubTests[1].SubTests[2].Output[1].Message, "TestEZ does not have deepEqual%. Add %-%-%$NexusUnitTestExtensions to the test script to enable Nexus Unit Testing to enable deep equals for tables%.")
            expect(HasError ~= nil).to.equal(true)
            HasError, _ = string.find(SubTests[1].SubTests[3].Output[1].Message, "TestEZ does not have contain%. Add %-%-%$NexusUnitTestExtensions to the test script to enable Nexus Unit Testing to enable table and string contains%.")
            expect(HasError ~= nil).to.equal(true)
        end)

        it("should use extension methods when specified.", function()
            --Create the module.
            local Folder = Instance.new("Folder")
            Folder.Name = "TestFolder"
            local Module = Instance.new("ModuleScript")
            Module.Name = "TestModuleNEW.spec"
            Module.Source = "--$NexusUnitTestExtensions\nreturn function()"..
                "describe(\"Test\", function()"..
                "    it(\"should pass with near.\", function()"..
                "        expect(Vector3.new()).to.be.near(Vector3.new())"..
                "        expect(Vector3.new()).to.never.be.near(Vector3.new(1, 1, 1))"..
                "    end)"..
                "    it(\"should fail with near.\", function()"..
                "        expect(Vector3.new(1, 1, 1)).to.be.near(Vector3.new(2, 2, 2))"..
                "    end)"..
                "    it(\"should pass with deepEqual.\", function()"..
                "        expect({1,2,3}).to.deepEqual({1,2,3})"..
                "        expect({1,2,3}).to.never.deepEqual({1,2,4})"..
                "    end)"..
                "    it(\"should fail with deepEqual.\", function()"..
                "        expect({1,2,3}).to.deepEqual({1,2,4})"..
                "    end)"..
                "    it(\"should fail with never deepEqual.\", function()"..
                "        expect({1,2,3}).to.never.deepEqual({1,2,3})"..
                "    end)"..
                "    it(\"should pass with contain.\", function()"..
                "        expect(\"Test string\").to.contain(\"Test\")"..
                "        expect(\"Test string\").to.never.contain(\"Error\")"..
                "        expect({1,2,3}).to.contain(2)"..
                "        expect({1,2,3}).to.never.contain(4)"..
                "    end)"..
                "    it(\"should fail with contain string.\", function()"..
                "        expect(\"Test\").to.contain(\"Error\")"..
                "    end)"..
                "    it(\"should fail with contain table.\", function()"..
                "        expect({1,2,3}).to.contain(4)"..
                "    end)"..
                "    it(\"should fail with never contain string.\", function()"..
                "        expect(\"Test string\").to.never.contain(\"Test\")"..
                "    end)"..
                "    it(\"should fail with never contain table.\", function()"..
                "        expect({1,2,3}).to.never.contain(3)"..
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
            expect(#SubTests[1].SubTests).to.equal(10)
            expect(SubTests[1].SubTests[1].Name).to.equal("should pass with near.")
            expect(SubTests[1].SubTests[1].State).to.equal("PASSED")
            expect(SubTests[1].SubTests[1].CombinedState).to.equal("PASSED")
            expect(#SubTests[1].SubTests[1].SubTests).to.equal(0)
            expect(SubTests[1].SubTests[2].Name).to.equal("should fail with near.")
            expect(SubTests[1].SubTests[2].State).to.equal("FAILED")
            expect(SubTests[1].SubTests[2].CombinedState).to.equal("FAILED")
            expect(#SubTests[1].SubTests[2].SubTests).to.equal(0)
            expect(SubTests[1].SubTests[3].Name).to.equal("should pass with deepEqual.")
            expect(SubTests[1].SubTests[3].State).to.equal("PASSED")
            expect(SubTests[1].SubTests[3].CombinedState).to.equal("PASSED")
            expect(#SubTests[1].SubTests[3].SubTests).to.equal(0)
            expect(SubTests[1].SubTests[4].Name).to.equal("should fail with deepEqual.")
            expect(SubTests[1].SubTests[4].State).to.equal("FAILED")
            expect(SubTests[1].SubTests[4].CombinedState).to.equal("FAILED")
            expect(#SubTests[1].SubTests[4].SubTests).to.equal(0)
            expect(SubTests[1].SubTests[5].Name).to.equal("should fail with never deepEqual.")
            expect(SubTests[1].SubTests[5].State).to.equal("FAILED")
            expect(SubTests[1].SubTests[5].CombinedState).to.equal("FAILED")
            expect(#SubTests[1].SubTests[5].SubTests).to.equal(0)
            expect(SubTests[1].SubTests[6].Name).to.equal("should pass with contain.")
            expect(SubTests[1].SubTests[6].State).to.equal("PASSED")
            expect(SubTests[1].SubTests[6].CombinedState).to.equal("PASSED")
            expect(#SubTests[1].SubTests[6].SubTests).to.equal(0)
            expect(SubTests[1].SubTests[7].Name).to.equal("should fail with contain string.")
            expect(SubTests[1].SubTests[7].State).to.equal("FAILED")
            expect(SubTests[1].SubTests[7].CombinedState).to.equal("FAILED")
            expect(#SubTests[1].SubTests[7].SubTests).to.equal(0)
            expect(SubTests[1].SubTests[8].Name).to.equal("should fail with contain table.")
            expect(SubTests[1].SubTests[8].State).to.equal("FAILED")
            expect(SubTests[1].SubTests[8].CombinedState).to.equal("FAILED")
            expect(#SubTests[1].SubTests[8].SubTests).to.equal(0)
            expect(SubTests[1].SubTests[9].Name).to.equal("should fail with never contain string.")
            expect(SubTests[1].SubTests[9].State).to.equal("FAILED")
            expect(SubTests[1].SubTests[9].CombinedState).to.equal("FAILED")
            expect(#SubTests[1].SubTests[9].SubTests).to.equal(0)
            expect(SubTests[1].SubTests[10].Name).to.equal("should fail with never contain table.")
            expect(SubTests[1].SubTests[10].State).to.equal("FAILED")
            expect(SubTests[1].SubTests[10].CombinedState).to.equal("FAILED")
            expect(#SubTests[1].SubTests[10].SubTests).to.equal(0)
        end)

        it("should handle contexts.", function()
            --Create the module.
            local Folder = Instance.new("Folder")
            Folder.Name = "TestFolder"
            local Module = Instance.new("ModuleScript")
            Module.Name = "TestModule.spec"
            Module.Source = "return function()"..
                "beforeAll(function(context)"..
                "    context.Value1 = \"test1\""..
                "end)"..
                "describe(\"Test\", function()"..
                "    beforeEach(function(context)"..
                "        context.Value2 = \"test2\""..
                "    end)"..
                "    it(\"should work\", function(context)"..
                "        expect(context.Value1).to.equal(\"test1\")"..
                "        expect(context.Value2).to.equal(\"test2\")"..
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
            expect(SubTests[1].SubTests[1].CombinedState).to.equal("PASSED")
            expect(#SubTests[1].SubTests[1].SubTests).to.equal(0)
        end)
    end)
end