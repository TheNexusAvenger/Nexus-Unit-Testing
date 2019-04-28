--[[
TheNexusAvenger

Unit tests for the OverriderClass module. Since it is used for the 
Nexus Unit Testing plugin, it is not set up for the plugin.
--]]

local Tests = script.Parent.Parent.Parent.Parent
local Source = Tests.Parent:WaitForChild("Sources")
local NexusUnitTesting = require(Source:WaitForChild("NexusUnitTesting"))
local OverriderClass = require(Source:WaitForChild("NexusUnitTesting"):WaitForChild("Util"):WaitForChild("DependencyInjector"):WaitForChild("OverriderClass"))



--[[
Runs unit tests for the WhenIndexed and GetIndexOverride methods.
--]]
NexusUnitTesting:RegisterUnitTest("WhenIndexed",function(UnitTest)
	local Overrider = OverriderClass.new()
	
	--Create the index overrides.
	Overrider:WhenIndexed("Test1"):ThenReturn(true)
	Overrider:WhenIndexed("Test2"):ThenReturn(false)
	
	--Run the assertions.
	UnitTest:AssertNotNil(Overrider:GetIndexOverride("Test1"),"Overrider didn't return anything.")
	UnitTest:AssertTrue(Overrider:GetIndexOverride("Test1"):GetOverride(),"Overrider didn't return the correct overrider.")
	UnitTest:AssertNotNil(Overrider:GetIndexOverride("Test2"),"Overrider didn't return anything.")
	UnitTest:AssertFalse(Overrider:GetIndexOverride("Test2"):GetOverride(),"Overrider didn't return the correct overrider.")
	UnitTest:AssertNil(Overrider:GetIndexOverride("Test3"),"Overrider returned a function.")
end)

--[[
Runs unit tests for the WhenCalled and GetCallOverride methods.
--]]
NexusUnitTesting:RegisterUnitTest("WhenCalled",function(UnitTest)
	local Overrider = OverriderClass.new()
	
	--Create the index overrides.
	Overrider:WhenCalled("Test","Test1"):ThenReturn(true)
	Overrider:WhenCalled("Test","Test2"):ThenReturn(false)
	Overrider:WhenCalled("Test"):ThenReturn("FALLBACK")
	
	--Run the assertions.
	UnitTest:AssertNotNil(Overrider:GetCallOverride("Test",{"Test1"}),"Overrider didn't return anything.")
	UnitTest:AssertTrue(Overrider:GetCallOverride("Test",{"Test1"}):GetReturn("Test1"),"Overrider didn't return the correct overrider.")
	UnitTest:AssertNotNil(Overrider:GetCallOverride("Test",{"Test2"}),"Overrider didn't return anything.")
	UnitTest:AssertFalse(Overrider:GetCallOverride("Test",{"Test2"}):GetReturn("Test3"),"Overrider didn't return the correct overrider.")
	UnitTest:AssertNotNil(Overrider:GetCallOverride("Test",{"Test3"}),"Overrider didn't return anything.")
	UnitTest:AssertEquals(Overrider:GetCallOverride("Test",{"Test3"}):GetReturn("Test3"),"FALLBACK","Overrider didn't return the correct overrider.")
	UnitTest:AssertNil(Overrider:GetCallOverride("Test_",{"Test3"}),"Overrider returned a function.")
end)

--[[
Runs unit tests for the Clone.
--]]
NexusUnitTesting:RegisterUnitTest("Clone",function(UnitTest)
	local Overrider = OverriderClass.new()
	
	--Create the index overrides.
	Overrider:WhenIndexed("Test1"):ThenReturn(true)
	Overrider:WhenIndexed("Test2"):ThenReturn(false)
	Overrider:WhenCalled("Test","Test1"):ThenReturn(true)
	Overrider:WhenCalled("Test","Test2"):ThenReturn(false)
	
	--Clone the overrider.
	local ClonedOverrider = Overrider:Clone()
	ClonedOverrider:WhenIndexed("Test3"):ThenReturn(true)
	ClonedOverrider:WhenCalled("Test","Test3"):ThenReturn(true)
	
	--Run the assertions that the original isn't mutated.
	UnitTest:AssertNotNil(Overrider:GetIndexOverride("Test1"),"Overrider didn't return anything.")
	UnitTest:AssertTrue(Overrider:GetIndexOverride("Test1"):GetOverride(),"Overrider didn't return the correct overrider.")
	UnitTest:AssertNotNil(Overrider:GetIndexOverride("Test2"),"Overrider didn't return anything.")
	UnitTest:AssertFalse(Overrider:GetIndexOverride("Test2"):GetOverride(),"Overrider didn't return the correct overrider.")
	UnitTest:AssertNil(Overrider:GetIndexOverride("Test3"),"Overrider returned a function.")
		
	UnitTest:AssertNotNil(Overrider:GetCallOverride("Test",{"Test1"}),"Overrider didn't return anything.")
	UnitTest:AssertTrue(Overrider:GetCallOverride("Test",{"Test1"}):GetReturn("Test1"),"Overrider didn't return the correct overrider.")
	UnitTest:AssertNotNil(Overrider:GetCallOverride("Test",{"Test2"}),"Overrider didn't return anything.")
	UnitTest:AssertFalse(Overrider:GetCallOverride("Test",{"Test2"}):GetReturn("Test3"),"Overrider didn't return the correct overrider.")
	UnitTest:AssertNil(Overrider:GetCallOverride("Test",{"Test3"}),"Overrider returneda an overrider.")
		
	--Run the assertions that the cloned version has the new overrides.
	UnitTest:AssertNotNil(ClonedOverrider:GetIndexOverride("Test1"),"Overrider didn't return anything.")
	UnitTest:AssertTrue(ClonedOverrider:GetIndexOverride("Test1"):GetOverride(),"Overrider didn't return the correct overrider.")
	UnitTest:AssertNotNil(ClonedOverrider:GetIndexOverride("Test2"),"Overrider didn't return anything.")
	UnitTest:AssertFalse(ClonedOverrider:GetIndexOverride("Test2"):GetOverride(),"Overrider didn't return the correct overrider.")
	UnitTest:AssertNotNil(ClonedOverrider:GetIndexOverride("Test3"),"Overrider didn't return anything.")
	UnitTest:AssertTrue(ClonedOverrider:GetIndexOverride("Test3"):GetOverride(),"Overrider didn't return the correct overrider.")
		
	UnitTest:AssertNotNil(ClonedOverrider:GetCallOverride("Test",{"Test1"}),"Overrider didn't return anything.")
	UnitTest:AssertTrue(ClonedOverrider:GetCallOverride("Test",{"Test1"}):GetReturn("Test1"),"Overrider didn't return the correct overrider.")
	UnitTest:AssertNotNil(ClonedOverrider:GetCallOverride("Test",{"Test2"}),"Overrider didn't return anything.")
	UnitTest:AssertFalse(ClonedOverrider:GetCallOverride("Test",{"Test2"}):GetReturn("Test3"),"Overrider didn't return the correct overrider.")
	UnitTest:AssertNotNil(ClonedOverrider:GetCallOverride("Test",{"Test3"}),"Overrider didn't return anything.")
	UnitTest:AssertTrue(ClonedOverrider:GetCallOverride("Test",{"Test3"}):GetReturn("Test3"),"Overrider didn't return the correct overrider.")
end)



--Return true so there is no error with loading the ModuleScript.
return true