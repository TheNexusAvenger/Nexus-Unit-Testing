--[[
TheNexusAvenger

Unit tests for the CallOverridderClass module. Since it is used for the 
Nexus Unit Testing plugin, it is not set up for the plugin.
--]]

local Tests = script.Parent.Parent.Parent.Parent.Parent
local Source = Tests.Parent:WaitForChild("Sources")
local NexusUnitTesting = require(Source:WaitForChild("NexusUnitTesting"))
local CallOverridderClass = require(Source:WaitForChild("NexusUnitTesting"):WaitForChild("Util"):WaitForChild("DependencyInjector"):WaitForChild("OverridderClass"):WaitForChild("CallOverridderClass"))



--[[
Runs unit tests for the CanBeCalled method.
--]]
NexusUnitTesting:RegisterUnitTest("CanBeCalled",function(UnitTest)
	local CallOverridder = CallOverridderClass.new({"Test1","Test2"})
	
	UnitTest:AssertFalse(CallOverridder:CanBeCalled({}),"Uncallable parameters can be called.")
	UnitTest:AssertFalse(CallOverridder:CanBeCalled({"Test1"}),"Uncallable parameters can be called.")
	UnitTest:AssertTrue(CallOverridder:CanBeCalled({"Test1","Test2"}),"Callable parameters can't be called.")
	UnitTest:AssertTrue(CallOverridder:CanBeCalled({"Test1","Test2","Test3"}),"Callable parameters can't be called.")
	UnitTest:AssertFalse(CallOverridder:CanBeCalled({"Test1","Test","Test3"}),"Uncallable parameters can be called.")
end)


--[[
Runs unit tests for the ThenReturn method.
--]]
NexusUnitTesting:RegisterUnitTest("ThenReturn",function(UnitTest)
	local CallOverridder = CallOverridderClass.new({"Test1","Test2"})
	CallOverridder:ThenReturn(true)
	
	UnitTest:AssertTrue(CallOverridder:GetReturn("Test1","Test2"),"Incorrect value returned.")
end)

--[[
Runs unit tests for the ThenCall method.
--]]
NexusUnitTesting:RegisterUnitTest("ThenCall",function(UnitTest)
	local FunctionRan = true
	local CallOverridder = CallOverridderClass.new({"Test1","Test1"})
	CallOverridder:ThenCall(function(String1,String2)
		FunctionRan = true
		return String1 == String2
	end)
	
	UnitTest:AssertTrue(FunctionRan,"Method not called.")
	UnitTest:AssertTrue(CallOverridder:GetReturn("Test1","Test1"),"Incorrect value returned.")
end)

--[[
Runs unit tests for the DoNothing method.
--]]
NexusUnitTesting:RegisterUnitTest("DoNothing",function(UnitTest)
	local CallOverridder = CallOverridderClass.new({"Test1","Test1"})
	CallOverridder:DoNothing()
	
	UnitTest:AssertNil(CallOverridder:GetReturn("Test1","Test1"),"A value was returned.")
end)



--Return true so there is no error with loading the ModuleScript.
return true