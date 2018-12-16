--[[
TheNexusAvenger

Unit tests for the OverridderClass module. Since it is used for the 
Nexus Unit Testing plugin, it is not set up for the plugin.
--]]

local Tests = script.Parent.Parent.Parent.Parent
local Source = Tests.Parent:WaitForChild("Sources")
local NexusUnitTesting = require(Source:WaitForChild("NexusUnitTesting"))
local OverridderClass = require(Source:WaitForChild("NexusUnitTesting"):WaitForChild("Util"):WaitForChild("DependencyInjector"):WaitForChild("OverridderClass"))



--[[
Runs unit tests for the WhenIndexed and GetIndexOverride methods.
--]]
NexusUnitTesting:RegisterUnitTest("WhenIndexed",function(UnitTest)
	local Overridder = OverridderClass.new()
	
	--Create the index overrides.
	Overridder:WhenIndexed("Test1"):ThenReturn(true)
	Overridder:WhenIndexed("Test2"):ThenReturn(false)
	
	--Run the assertions.
	UnitTest:AssertNotNil(Overridder:GetIndexOverride("Test1"),"Overridder didn't return anything.")
	UnitTest:AssertTrue(Overridder:GetIndexOverride("Test1"):GetOverride(),"Overridder didn't return the correct overridder.")
	UnitTest:AssertNotNil(Overridder:GetIndexOverride("Test2"),"Overridder didn't return anything.")
	UnitTest:AssertFalse(Overridder:GetIndexOverride("Test2"):GetOverride(),"Overridder didn't return the correct overridder.")
	UnitTest:AssertNil(Overridder:GetIndexOverride("Test3"),"Overridder returned a function.")
end)

--[[
Runs unit tests for the WhenCalled and GetCallOverride methods.
--]]
NexusUnitTesting:RegisterUnitTest("WhenCalled",function(UnitTest)
	local Overridder = OverridderClass.new()
	
	--Create the index overrides.
	Overridder:WhenCalled("Test","Test1"):ThenReturn(true)
	Overridder:WhenCalled("Test","Test2"):ThenReturn(false)
	Overridder:WhenCalled("Test"):ThenReturn("FALLBACK")
	
	--Run the assertions.
	UnitTest:AssertNotNil(Overridder:GetCallOverride("Test",{"Test1"}),"Overridder didn't return anything.")
	UnitTest:AssertTrue(Overridder:GetCallOverride("Test",{"Test1"}):GetReturn("Test1"),"Overridder didn't return the correct overridder.")
	UnitTest:AssertNotNil(Overridder:GetCallOverride("Test",{"Test2"}),"Overridder didn't return anything.")
	UnitTest:AssertFalse(Overridder:GetCallOverride("Test",{"Test2"}):GetReturn("Test3"),"Overridder didn't return the correct overridder.")
	UnitTest:AssertNotNil(Overridder:GetCallOverride("Test",{"Test3"}),"Overridder didn't return anything.")
	UnitTest:AssertEquals(Overridder:GetCallOverride("Test",{"Test3"}):GetReturn("Test3"),"FALLBACK","Overridder didn't return the correct overridder.")
	UnitTest:AssertNil(Overridder:GetCallOverride("Test_",{"Test3"}),"Overridder returned a function.")
end)



--Return true so there is no error with loading the ModuleScript.
return true