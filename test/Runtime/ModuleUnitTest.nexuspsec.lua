--[[
TheNexusAvenger

Tests the UnitTest class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")

local NexusUnitTestingProject = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusUnitTesting"))
local ModuleUnitTest = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusUnitTesting"):WaitForChild("Runtime"):WaitForChild("ModuleUnitTest"))



--[[
Tests requiring a module without subtests.
--]]
NexusUnitTesting:RegisterUnitTest("RequireNoSubtests",function(UnitTest)
    --Create the module.
    local Folder = Instance.new("Folder")
    Folder.Name = "TestFolder"
    local Module = Instance.new("ModuleScript")
    Module.Name = "TestModule"
    Module.Source = "local NexusUnitTesting = require(\"NexusUnitTesting\") print(script.Name) warn(script.Name) NexusUnitTesting:AssertEquals(script:GetFullName(),\"TestFolder.TestModule\") return true"
    Module.Parent = Folder
    
    --Create the component under testing.
    local CuT = ModuleUnitTest.new(Module)
    local OutputInformation = {}
    CuT.MessageOutputted:Connect(function(Message,Type)
        table.insert(OutputInformation,{Message,Type})
    end)
    
    --Assert the test is ran correctly.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(#CuT.SubTests,0,"Total subtests are not correct.")
    UnitTest:AssertEquals(OutputInformation[1][1],"TestModule")
    UnitTest:AssertEquals(OutputInformation[1][2],Enum.MessageType.MessageOutput)
    UnitTest:AssertEquals(OutputInformation[2][1],"TestModule")
    UnitTest:AssertEquals(OutputInformation[2][2],Enum.MessageType.MessageWarning)
    UnitTest:AssertNil(OutputInformation[3],"Too many messages were outputted.")
end)

--[[
Tests requiring a module with passing subtests.
--]]
NexusUnitTesting:RegisterUnitTest("RequirePassingSubtests",function(UnitTest)
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
    
    --Create the component under testing.
    local CuT = ModuleUnitTest.new(Module)
    
    --Assert the test is ran correctly.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(#CuT.SubTests,2,"Total subtests is not correct.")
    UnitTest:AssertEquals(CuT.SubTests[1].Name,"Test1","Subtest name is incorrect.")
    UnitTest:AssertEquals(CuT.SubTests[1].State,NexusUnitTestingProject.TestState.NotRun,"Subtest ran.")
    UnitTest:AssertEquals(CuT.SubTests[1].CombinedState,NexusUnitTestingProject.TestState.NotRun,"Subtest ran.")
    UnitTest:AssertEquals(CuT.SubTests[2].Name,"Test2","Subtest name is incorrect.")
    UnitTest:AssertEquals(CuT.SubTests[2].State,NexusUnitTestingProject.TestState.NotRun,"Subtest ran.")
    UnitTest:AssertEquals(CuT.SubTests[2].CombinedState,NexusUnitTestingProject.TestState.NotRun,"Subtest ran.")
    
    --Assert the subtests are ran correctly.
    CuT:RunSubtests()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.SubTests[1].Name,"Test1","Subtest name is incorrect.")
    UnitTest:AssertEquals(CuT.SubTests[1].State,NexusUnitTestingProject.TestState.Passed,"Subtest not passed.")
    UnitTest:AssertEquals(CuT.SubTests[1].CombinedState,NexusUnitTestingProject.TestState.Passed,"Subtest not passed.")
    UnitTest:AssertEquals(CuT.SubTests[2].Name,"Test2","Subtest name is incorrect.")
    UnitTest:AssertEquals(CuT.SubTests[2].State,NexusUnitTestingProject.TestState.Passed,"Subtest not passed.")
    UnitTest:AssertEquals(CuT.SubTests[2].CombinedState,NexusUnitTestingProject.TestState.Passed,"Subtest not passed.")
end)

--[[
Tests requiring a module with one failing subtest.
--]]
NexusUnitTesting:RegisterUnitTest("RequireOneFailingSubtests",function(UnitTest)
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
    
    --Create the component under testing.
    local CuT = ModuleUnitTest.new(Module)
    
    --Assert the test is ran correctly.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(#CuT.SubTests,2,"Total subtests is not correct.")
    UnitTest:AssertEquals(CuT.SubTests[1].Name,"Test1","Subtest name is incorrect.")
    UnitTest:AssertEquals(CuT.SubTests[1].State,NexusUnitTestingProject.TestState.NotRun,"Subtest ran.")
    UnitTest:AssertEquals(CuT.SubTests[1].CombinedState,NexusUnitTestingProject.TestState.NotRun,"Subtest ran.")
    UnitTest:AssertEquals(CuT.SubTests[2].Name,"Test2","Subtest name is incorrect.")
    UnitTest:AssertEquals(CuT.SubTests[2].State,NexusUnitTestingProject.TestState.NotRun,"Subtest ran.")
    UnitTest:AssertEquals(CuT.SubTests[2].CombinedState,NexusUnitTestingProject.TestState.NotRun,"Subtest ran.")
    
    --Assert the subtests are ran correctly.
    CuT:RunSubtests()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Failed,"Test not failed.")
    UnitTest:AssertEquals(CuT.SubTests[1].Name,"Test1","Subtest name is incorrect.")
    UnitTest:AssertEquals(CuT.SubTests[1].State,NexusUnitTestingProject.TestState.Failed,"Subtest not failed.")
    UnitTest:AssertEquals(CuT.SubTests[1].CombinedState,NexusUnitTestingProject.TestState.Failed,"Subtest not failed.")
    UnitTest:AssertEquals(CuT.SubTests[2].Name,"Test2","Subtest name is incorrect.")
    UnitTest:AssertEquals(CuT.SubTests[2].State,NexusUnitTestingProject.TestState.Passed,"Subtest not passed.")
    UnitTest:AssertEquals(CuT.SubTests[2].CombinedState,NexusUnitTestingProject.TestState.Passed,"Subtest not passed.")
end)

--[[
Tests requiring a module with all failing subtest.
--]]
NexusUnitTesting:RegisterUnitTest("RequireAllFailingSubtests",function(UnitTest)
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
    
    --Create the component under testing.
    local CuT = ModuleUnitTest.new(Module)
    
    --Assert the test is ran correctly.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(#CuT.SubTests,2,"Total subtests is not correct.")
    UnitTest:AssertEquals(CuT.SubTests[1].Name,"Test1","Subtest name is incorrect.")
    UnitTest:AssertEquals(CuT.SubTests[1].State,NexusUnitTestingProject.TestState.NotRun,"Subtest ran.")
    UnitTest:AssertEquals(CuT.SubTests[1].CombinedState,NexusUnitTestingProject.TestState.NotRun,"Subtest ran.")
    UnitTest:AssertEquals(CuT.SubTests[2].Name,"Test2","Subtest name is incorrect.")
    UnitTest:AssertEquals(CuT.SubTests[2].State,NexusUnitTestingProject.TestState.NotRun,"Subtest ran.")
    UnitTest:AssertEquals(CuT.SubTests[2].CombinedState,NexusUnitTestingProject.TestState.NotRun,"Subtest ran.")
    
    --Assert the subtests are ran correctly.
    CuT:RunSubtests()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Failed,"Test not failed.")
    UnitTest:AssertEquals(CuT.SubTests[1].Name,"Test1","Subtest name is incorrect.")
    UnitTest:AssertEquals(CuT.SubTests[1].State,NexusUnitTestingProject.TestState.Failed,"Subtest not failed.")
    UnitTest:AssertEquals(CuT.SubTests[1].CombinedState,NexusUnitTestingProject.TestState.Failed,"Subtest not failed.")
    UnitTest:AssertEquals(CuT.SubTests[2].Name,"Test2","Subtest name is incorrect.")
    UnitTest:AssertEquals(CuT.SubTests[2].State,NexusUnitTestingProject.TestState.Failed,"Subtest not failed.")
    UnitTest:AssertEquals(CuT.SubTests[2].CombinedState,NexusUnitTestingProject.TestState.Failed,"Subtest not failed.")
end)

--[[
Tests requiring a module with passing subtests in a return function.
--]]
NexusUnitTesting:RegisterUnitTest("RequirePassingSubtestsReturnSubfunction",function(UnitTest)
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
    
    --Create the component under testing.
    local CuT = ModuleUnitTest.new(Module)
    
    --Assert the test is ran correctly.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(#CuT.SubTests,2,"Total subtests is not correct.")
    UnitTest:AssertEquals(CuT.SubTests[1].Name,"Test1","Subtest name is incorrect.")
    UnitTest:AssertEquals(CuT.SubTests[1].State,NexusUnitTestingProject.TestState.NotRun,"Subtest ran.")
    UnitTest:AssertEquals(CuT.SubTests[1].CombinedState,NexusUnitTestingProject.TestState.NotRun,"Subtest ran.")
    UnitTest:AssertEquals(CuT.SubTests[2].Name,"Test2","Subtest name is incorrect.")
    UnitTest:AssertEquals(CuT.SubTests[2].State,NexusUnitTestingProject.TestState.NotRun,"Subtest ran.")
    UnitTest:AssertEquals(CuT.SubTests[2].CombinedState,NexusUnitTestingProject.TestState.NotRun,"Subtest ran.")
    
    --Assert the subtests are ran correctly.
    CuT:RunSubtests()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.SubTests[1].Name,"Test1","Subtest name is incorrect.")
    UnitTest:AssertEquals(CuT.SubTests[1].State,NexusUnitTestingProject.TestState.Passed,"Subtest not passed.")
    UnitTest:AssertEquals(CuT.SubTests[1].CombinedState,NexusUnitTestingProject.TestState.Passed,"Subtest not passed.")
    UnitTest:AssertEquals(CuT.SubTests[2].Name,"Test2","Subtest name is incorrect.")
    UnitTest:AssertEquals(CuT.SubTests[2].State,NexusUnitTestingProject.TestState.Passed,"Subtest not passed.")
    UnitTest:AssertEquals(CuT.SubTests[2].CombinedState,NexusUnitTestingProject.TestState.Passed,"Subtest not passed.")
end)

--[[
Tests requiring a module with passing subtests in a return function using TestEZ.
--]]
NexusUnitTesting:RegisterUnitTest("RequirePassingSubtestsTestEZ",function(UnitTest)
    --Create the module.
    local Folder = Instance.new("Folder")
    Folder.Name = "TestFolder"
    local Module = Instance.new("ModuleScript")
    Module.Name = "TestModule.spec"
    Module.Source = "return function()"..
        "describe(\"Test\",function()"..
        "    it(\"should work\", function()"..
        "        expect(script:GetFullName()).to.equal(\"TestFolder.TestModule.spec\")"..
        "    end)"..
        "end)"..
        "end"
    Module.Parent = Folder
    
    --Create the component under testing.
    local CuT = ModuleUnitTest.new(Module)
    
    --Assert the test is ran correctly.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(#CuT.SubTests,1,"Total subtests is not correct.")
    UnitTest:AssertEquals(CuT.SubTests[1].Name,"Test","Subtest name is incorrect.")
    UnitTest:AssertEquals(CuT.SubTests[1].State,NexusUnitTestingProject.TestState.Passed,"Subtest ran.")
    UnitTest:AssertEquals(CuT.SubTests[1].CombinedState,NexusUnitTestingProject.TestState.Passed,"Subtest ran.")
    UnitTest:AssertEquals(#CuT.SubTests[1].SubTests,1,"Total subtests is not correct.")
    UnitTest:AssertEquals(CuT.SubTests[1].SubTests[1].Name,"should work","Subtest name is incorrect.")
    UnitTest:AssertEquals(CuT.SubTests[1].SubTests[1].State,NexusUnitTestingProject.TestState.Passed,"Subtest ran.")
    UnitTest:AssertEquals(CuT.SubTests[1].SubTests[1].CombinedState,NexusUnitTestingProject.TestState.Passed,"Subtest ran.")
    UnitTest:AssertEquals(#CuT.SubTests[1].SubTests[1].SubTests,0,"Total subtests is not correct.")
end)



return true