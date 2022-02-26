--[[
TheNexusAvenger

Tests the ModuleSandbox class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")

local NexusUnitTestingProject = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusUnitTesting"):WaitForChild("NexusUnitTestingProject"))
local ModuleSandbox = NexusUnitTestingProject:GetResource("UnitTest.ModuleSandbox")



--[[
Tests the GetModule method.
--]]
NexusUnitTesting:RegisterUnitTest("GetModule",function(UnitTest)
    --Create the component under testing.
    local CuT1 = ModuleSandbox.new()
    local CuT2 = ModuleSandbox.new(CuT1)
    
    --Set the values.
    CuT1.ModulesLoaded["Value1"] = true
    CuT1.ModulesLoaded["Value2"] = true
    CuT2.ModulesLoaded["Value2"] = true
    CuT1.ModulesLoaded["Value3"] = false
    CuT2.ModulesLoaded["Value4"] = false
    CuT1.CachedModules["Value1"] = "Result1"
    CuT1.CachedModules["Value2"] = "Result2"
    CuT2.CachedModules["Value2"] = "Result3"
    spawn(function()
        wait(0.1)
        CuT1.ModulesLoaded["Value3"] = true
        CuT1.CachedModules["Value3"] = "Result4"
        CuT1.ModuleLoaded:Fire()
        wait(0.1)
        CuT2.ModulesLoaded["Value4"] = true
        CuT2.CachedModules["Value4"] = "Result5"
        CuT2.ModuleLoaded:Fire()
    end)
    
    --[[
    Asserts that a module is returned correctly.
    --]]
    local function AssertModuleResult(Sandbox,Name,Returned,Value)
        local ActualReturned,ActualValue = Sandbox:GetModule(Name)
        UnitTest:AssertEquals(ActualReturned,Returned)
        UnitTest:AssertEquals(ActualValue,Value)
    end
    
    --Output the messages and assert they are correct.
    AssertModuleResult(CuT1,"Value1",true,"Result1")
    AssertModuleResult(CuT1,"Value2",true,"Result2")
    AssertModuleResult(CuT1,"Value3",true,"Result4")
    AssertModuleResult(CuT1,"Value4",false,nil)
    AssertModuleResult(CuT1,"Value5",false,nil)
    AssertModuleResult(CuT2,"Value1",true,"Result1")
    AssertModuleResult(CuT2,"Value2",true,"Result3")
    AssertModuleResult(CuT2,"Value3",true,"Result4")
    AssertModuleResult(CuT2,"Value4",true,"Result5")
    AssertModuleResult(CuT2,"Value5",false,nil)
end)

--[[
Tests the RequireModule method.
--]]
NexusUnitTesting:RegisterUnitTest("RequireModule",function(UnitTest)
    --Create the component under testing.
    local CuT1 = ModuleSandbox.new()
    local CuT2 = ModuleSandbox.new(CuT1)
    
    --Create the modules.
    local Folder = Instance.new("Folder")
    Folder.Name = "TestFolder"
    local Module1 = Instance.new("ModuleScript")
    Module1.Name = "Module1"
    Module1.Source = "return script:GetFullName()"
    Module1.Parent = Folder
    local Module2 = Instance.new("ModuleScript")
    Module2.Name = "Module2"
    Module2.Source = "return function() return require(script.Parent.Module1) end"
    Module2.Parent = Folder
    local Module3 = Instance.new("ModuleScript")
    Module3.Name = "Module3"
    Module3.Source = "return function() return require(script.Parent.Module2) end"
    Module3.Parent = Folder
    
    --Require the modules and assert they are correct.
    UnitTest:AssertEquals(CuT1:RequireModule(Module1),"TestFolder.Module1")
    UnitTest:AssertEquals(CuT1:RequireModule(Module2)(),"TestFolder.Module1")
    UnitTest:AssertEquals(CuT1.ModulesLoaded[Module1],true,"Module not found.")
    UnitTest:AssertEquals(CuT1.ModulesLoaded[Module2],true,"Module not found.")
    UnitTest:AssertEquals(CuT1.ModulesLoaded[Module3],nil,"Module found.")
    UnitTest:AssertEquals(CuT2:RequireModule(Module1),"TestFolder.Module1")
    UnitTest:AssertEquals(CuT2:RequireModule(Module2)(),"TestFolder.Module1")
    UnitTest:AssertEquals(CuT2:RequireModule(Module3)()(),"TestFolder.Module1")
    UnitTest:AssertEquals(CuT2.ModulesLoaded[Module1],nil,"Module not found.")
    UnitTest:AssertEquals(CuT2.ModulesLoaded[Module2],nil,"Module not found.")
    UnitTest:AssertEquals(CuT2.ModulesLoaded[Module3],true,"Module found.")
end)


--[[
Tests the RequireModule method with environment overrides.
--]]
NexusUnitTesting:RegisterUnitTest("RequireModuleEnvironmentOverrides",function(UnitTest)
    --Create the component under testing.
    local CuT1 = ModuleSandbox.new()
    local CuT2 = ModuleSandbox.new(CuT1)
    
    --Create the modules.
    local Folder = Instance.new("Folder")
    Folder.Name = "TestFolder"
    local Module1 = Instance.new("ModuleScript")
    Module1.Name = "Module1"
    Module1.Source = "return UnknownGlobal..\",\"..tostring(script)"
    Module1.Parent = Folder
    local Module2 = Instance.new("ModuleScript")
    Module2.Name = "Module2"
    Module2.Source = "return function() return require(script.Module1) end"
    Module2.Parent = Folder
    local Module3 = Instance.new("ModuleScript")
    Module3.Name = "Module3"
    Module3.Source = "return function() return require(script.Module2) end"
    Module3.Parent = Folder
    
    --Require the modules and assert they are correct.
    local Overrides = {
        ["UnknownGlobal"] = "Test",
        ["script"] = Folder,
    }
    UnitTest:AssertEquals(CuT1:RequireModule(Module1,Overrides),"Test,TestFolder")
    UnitTest:AssertEquals(CuT1:RequireModule(Module2,Overrides)(),"Test,TestFolder")
    UnitTest:AssertEquals(CuT1.ModulesLoaded[Module1],true,"Module not found.")
    UnitTest:AssertEquals(CuT1.ModulesLoaded[Module2],true,"Module not found.")
    UnitTest:AssertEquals(CuT1.ModulesLoaded[Module3],nil,"Module found.")
    UnitTest:AssertEquals(CuT2:RequireModule(Module1,Overrides),"Test,TestFolder")
    UnitTest:AssertEquals(CuT2:RequireModule(Module2,Overrides)(),"Test,TestFolder")
    UnitTest:AssertEquals(CuT2:RequireModule(Module3,Overrides)()(),"Test,TestFolder")
    UnitTest:AssertEquals(CuT2.ModulesLoaded[Module1],nil,"Module not found.")
    UnitTest:AssertEquals(CuT2.ModulesLoaded[Module2],nil,"Module not found.")
    UnitTest:AssertEquals(CuT2.ModulesLoaded[Module3],true,"Module found.")
end)



return true