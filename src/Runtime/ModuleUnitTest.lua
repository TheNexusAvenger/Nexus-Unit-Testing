--[[
TheNexusAvenger

Controls the unit tests of a ModuleScript.
--]]

local NexusUnitTesting = require(script.Parent.Parent:WaitForChild("NexusUnitTestingProject"))
local UnitTest = NexusUnitTesting:GetResource("UnitTest.UnitTest")

local ModuleUnitTest = UnitTest:Extend()
ModuleUnitTest:SetClassName("ModuleUnitTest")



--[[
Creates a module unit test object.
--]]
function ModuleUnitTest:__new(ModuleScript)
    self:InitializeSuper(ModuleScript:GetFullName())
    
    --Store the module.
    self.ModuleScript = ModuleScript
end

--[[
Runs the test.
If the setup fails, the test is not continued.
--]]
function ModuleUnitTest:Run()
    --Create the environment overrides.
    local EnvironmentOverrides = {}
    EnvironmentOverrides["plugin"] = plugin
    EnvironmentOverrides["require"] = function(Module)
        --Return an override for NexusUnitTesting or TestEZ
        if Module == "NexusUnitTesting" then
            return self
        elseif Module.Name == "NexusUnitTesting" then
            return self
        end
        
        --Return the base require.
        return self.Sandbox:RequireModule(Module,EnvironmentOverrides)
    end
    EnvironmentOverrides["print"] = function(...)
        self:OutputMessage(Enum.MessageType.MessageOutput,...)
    end
    EnvironmentOverrides["warn"] = function(...)
        self:OutputMessage(Enum.MessageType.MessageWarning,...)
    end
    
    --Require the module.
    local TestReturn = self.Sandbox:RequireModule(self.ModuleScript,EnvironmentOverrides)
    
    --Call the function if a function was returend (used by TestEZ)
    if type(TestReturn) == "function" then
        self:WrapEnvironment(TestReturn,{
            ["script"] = self.ModuleScript,
            ["require"] = EnvironmentOverrides["require"],
        })
        TestReturn()
    end
end



return ModuleUnitTest