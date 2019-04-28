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
	local Injector = DependencyInjector.CreateOverrider()
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
	local Injector = DependencyInjector.CreateOverrider()
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
	local Injector = DependencyInjector.CreateOverrider()
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
Runs unit tests for the require method in scripts.
--]]
NexusUnitTesting:RegisterUnitTest("RequireMixedScriptReferences",function(UnitTest)
	local Printed,Warned = false,false
	local Injector = DependencyInjector.CreateOverrider()
	Injector:WhenCalled("print"):ThenCall(function()
		Printed = true
	end)
	Injector:WhenCalled("warn"):ThenCall(function()
		Warned = true
	end)
	
	local TestModule1 = Instance.new("ModuleScript")
	TestModule1.Source = "return require(script:WaitForChild(\"TestModule2\"))"
	
	local TestModule2 = Instance.new("ModuleScript")
	TestModule2.Name = "TestModule2"
	TestModule2.Source = "return require(script:WaitForChild(\"TestModule3\"))"
	TestModule2.Parent = TestModule1
	
	local TestModule3 = Instance.new("ModuleScript")
	TestModule3.Name = "TestModule3"
	TestModule3.Source = "print(\"Test\") warn(\"Test\") return true"
	TestModule3.Parent = TestModule2
	
	UnitTest:AssertTrue(DependencyInjector.Require(TestModule1,Injector),"Wrong value returned")
	UnitTest:AssertTrue(Printed,"print was not called or injected")
	UnitTest:AssertTrue(Warned,"warn was not called or injected")
end)

--[[
Runs unit tests for the CreateOverrider method. Only tests that it
returns an object since it has its own tets.
--]]
NexusUnitTesting:RegisterUnitTest("CreateOverrider",function(UnitTest)
	UnitTest:AssertNotNil(DependencyInjector.CreateOverrider(),"No Overrider returned.")
end)



--Return true so there is no error with loading the ModuleScript.
return true