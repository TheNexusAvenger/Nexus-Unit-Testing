--[[
TheNexusAvenger

Controls the unit tests of a ModuleScript.
--]]

local NexusUnitTesting = require(script.Parent.Parent:WaitForChild("NexusUnitTestingProject"))
local UnitTest = NexusUnitTesting:GetResource("UnitTest.UnitTest")
local TestEZ = NexusUnitTesting:GetResource("TestEZ")

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
	EnvironmentOverrides["require"] = function(Module)
		--Return an override for NexusUnitTesting or TestEZ
		if Module == "NexusUnitTesting" then
			return self
		elseif Module == "TestEZ" then
			return TestEZ
		elseif Module.Name == "NexusUnitTesting" then
			return self
		elseif Module.Name == "TestEZ" then
			return TestEZ
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
	self.Sandbox:RequireModule(self.ModuleScript,EnvironmentOverrides)
end



return ModuleUnitTest