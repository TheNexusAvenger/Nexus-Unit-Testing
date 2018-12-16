--[[
TheNexusAvenger

Unit tests for the DependencyInjector module. Since it is used for the 
Nexus Unit Testing plugin, it is not set up for the plugin.
These unit tests make sure the base functionality works.
--]]

local Tests = script.Parent.Parent.Parent
local Source = Tests.Parent:WaitForChild("Sources")
local NexusUnitTesting = require(Source:WaitForChild("NexusUnitTesting"))
local DependencyInjector = require(Source:WaitForChild("NexusUnitTesting"):WaitForChild("Util"):WaitForChild("DependencyInjector"))



--[[
Runs unit tests for the Inject method.
--]]
NexusUnitTesting:RegisterUnitTest("Inject",function(UnitTest)
	local BaseTable = {Value1 = 1,Value2 = 2,Value3 = 3}
	local Injector = DependencyInjector.CreateOverridder()
	Injector:WhenIndexed("Value1"):ThenReturn(2)
	Injector:WhenIndexed("Value2"):ThenCall(function()
		return 4
	end)
	
	local InjectedTable = DependencyInjector.Inject(BaseTable,Injector)
	UnitTest:AssertEquals(2,InjectedTable.Value1,"Value1 was not injected.")
	UnitTest:AssertEquals(4,InjectedTable.Value2,"Value2 was not injected.")
	UnitTest:AssertEquals(3,InjectedTable.Value3,"Value3 was injected.")
end)

--[[
Runs unit tests for the InjectEnvironmentVariables method.
--]]
NexusUnitTesting:RegisterUnitTest("InjectEnvironmentVariables",function(UnitTest)
	local Printed,Warned = false,false
	local Injector = DependencyInjector.CreateOverridder()
	Injector:WhenCalled("print"):ThenCall(function()
		Printed = true
	end)
	Injector:WhenCalled("warn"):ThenCall(function()
		Warned = true
	end)
	
	local function TestFunction()
		print("Test")
		warn("Test")
	end
	
	DependencyInjector.InjectEnvironmentVariables(TestFunction,Injector)
	TestFunction()
	UnitTest:AssertTrue(Printed,"print was not called or injected")
	UnitTest:AssertTrue(Warned,"warn was not called or injected")
end)

--[[
Runs unit tests for the Require method.
--]]
NexusUnitTesting:RegisterUnitTest("Require",function(UnitTest)
	local Printed,Warned = false,false
	local Injector = DependencyInjector.CreateOverridder()
	Injector:WhenCalled("print"):ThenCall(function()
		Printed = true
	end)
	Injector:WhenCalled("warn"):ThenCall(function()
		Warned = true
	end)
	
	local TestModule = Instance.new("ModuleScript")
	TestModule.Source = "print(\"Test\") warn(\"Test\") return true"
	
	DependencyInjector.Require(TestModule,Injector)
	UnitTest:AssertTrue(Printed,"print was not called or injected")
	UnitTest:AssertTrue(Warned,"warn was not called or injected")
end)

--[[
Runs unit tests for the CreateOverridder method. Only tests that it
returns an object since it has its own tets.
--]]
NexusUnitTesting:RegisterUnitTest("CreateOverridder",function(UnitTest)
	UnitTest:AssertNotNil(DependencyInjector.CreateOverridder(),"No overridder returned.")
end)



--Return true so there is no error with loading the ModuleScript.
return true