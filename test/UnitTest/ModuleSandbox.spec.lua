--[[
TheNexusAvenger

Tests the ModuleSandbox class.
--]]
--!strict

local ModuleSandbox = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusUnitTesting"):WaitForChild("UnitTest"):WaitForChild("ModuleSandbox"))

return function()
    local TestModuleSandbox, TestSubModuleSandbox = nil, nil
    beforeEach(function()
        TestModuleSandbox = ModuleSandbox.new() :: any
        TestSubModuleSandbox = ModuleSandbox.new(TestModuleSandbox) :: any
    end)

    describe("A module sandbox", function()
        it("should get modules with caching.", function()
            --Set the values.
            TestModuleSandbox.ModulesLoaded["Value1"] = true
            TestModuleSandbox.ModulesLoaded["Value2"] = true
            TestSubModuleSandbox.ModulesLoaded["Value2"] = true
            TestModuleSandbox.ModulesLoaded["Value3"] = false
            TestSubModuleSandbox.ModulesLoaded["Value4"] = false
            TestModuleSandbox.CachedModules["Value1"] = "Result1"
            TestModuleSandbox.CachedModules["Value2"] = "Result2"
            TestSubModuleSandbox.CachedModules["Value2"] = "Result3"
            task.spawn(function()
                task.wait(0.1)
                TestModuleSandbox.ModulesLoaded["Value3"] = true
                TestModuleSandbox.CachedModules["Value3"] = "Result4"
                TestModuleSandbox.ModuleLoaded:Fire()
                task.wait(0.1)
                TestSubModuleSandbox.ModulesLoaded["Value4"] = true
                TestSubModuleSandbox.CachedModules["Value4"] = "Result5"
                TestSubModuleSandbox.ModuleLoaded:Fire()
            end)
            
            --[[
            Asserts that a module is returned correctly.
            --]]
            local function AssertModuleResult(Sandbox: ModuleSandbox.ModuleSandbox, Name: any, Returned: any, Value: any)
                local ActualReturned,ActualValue = Sandbox:GetModule(Name)
                expect(ActualReturned).to.equal(Returned)
                expect(ActualValue).to.equal(Value)
            end
            
            --Output the messages and assert they are correct.
            AssertModuleResult(TestModuleSandbox, "Value1", true, "Result1")
            AssertModuleResult(TestModuleSandbox, "Value2", true, "Result2")
            AssertModuleResult(TestModuleSandbox, "Value3", true, "Result4")
            AssertModuleResult(TestModuleSandbox, "Value4", false, nil)
            AssertModuleResult(TestModuleSandbox, "Value5", false, nil)
            AssertModuleResult(TestSubModuleSandbox, "Value1", true, "Result1")
            AssertModuleResult(TestSubModuleSandbox, "Value2", true, "Result3")
            AssertModuleResult(TestSubModuleSandbox, "Value3", true, "Result4")
            AssertModuleResult(TestSubModuleSandbox, "Value4", true, "Result5")
            AssertModuleResult(TestSubModuleSandbox, "Value5", false, nil)
        end)

        it("should require modules.", function()
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
            expect(TestModuleSandbox:RequireModule(Module1)).to.equal("TestFolder.Module1")
            expect(TestModuleSandbox:RequireModule(Module2)()).to.equal("TestFolder.Module1")
            expect(TestModuleSandbox.ModulesLoaded[Module1]).to.equal(true)
            expect(TestModuleSandbox.ModulesLoaded[Module2]).to.equal(true)
            expect(TestModuleSandbox.ModulesLoaded[Module3]).to.equal(nil)
            expect(TestSubModuleSandbox:RequireModule(Module1)).to.equal("TestFolder.Module1")
            expect(TestSubModuleSandbox:RequireModule(Module2)()).to.equal("TestFolder.Module1")
            expect(TestSubModuleSandbox:RequireModule(Module3)()()).to.equal("TestFolder.Module1")
            expect(TestSubModuleSandbox.ModulesLoaded[Module1]).to.equal(nil)
            expect(TestSubModuleSandbox.ModulesLoaded[Module2]).to.equal(nil)
            expect(TestSubModuleSandbox.ModulesLoaded[Module3]).to.equal(true)
        end)

        it("should use environment overrides.", function()
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
            expect(TestModuleSandbox:RequireModule(Module1, Overrides)).to.equal("Test,TestFolder")
            expect(TestModuleSandbox:RequireModule(Module2, Overrides)()).to.equal("Test,TestFolder")
            expect(TestModuleSandbox.ModulesLoaded[Module1]).to.equal(true)
            expect(TestModuleSandbox.ModulesLoaded[Module2]).to.equal(true)
            expect(TestModuleSandbox.ModulesLoaded[Module3]).to.equal(nil)
            expect(TestSubModuleSandbox:RequireModule(Module1, Overrides)).to.equal("Test,TestFolder")
            expect(TestSubModuleSandbox:RequireModule(Module2, Overrides)()).to.equal("Test,TestFolder")
            expect(TestSubModuleSandbox:RequireModule(Module3, Overrides)()()).to.equal("Test,TestFolder")
            expect(TestSubModuleSandbox.ModulesLoaded[Module1]).to.equal(nil)
            expect(TestSubModuleSandbox.ModulesLoaded[Module2]).to.equal(nil)
            expect(TestSubModuleSandbox.ModulesLoaded[Module3]).to.equal(true)
        end)
    end)
end