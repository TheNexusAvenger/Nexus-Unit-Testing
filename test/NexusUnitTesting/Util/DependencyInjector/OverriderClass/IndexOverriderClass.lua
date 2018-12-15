--[[
TheNexusAvenger

Unit tests for the IndexOverriderClass module. Since it is used for the 
Nexus Unit Testing plugin, it is not set up for the plugin.
--]]

local Tests = script.Parent.Parent.Parent.Parent.Parent
local Source = Tests.Parent:WaitForChild("Sources")
local NexusUnitTesting = require(Source:WaitForChild("NexusUnitTesting"))
local IndexOverriderClass = require(Source:WaitForChild("NexusUnitTesting"):WaitForChild("Util"):WaitForChild("DependencyInjector"):WaitForChild("OverriderClass"):WaitForChild("IndexOverriderClass"))



--[[
Runs unit tests for the HasOverride method.
--]]
NexusUnitTesting:RegisterUnitTest("HasOverride",function(UnitTest)
	local IndexOverrider = IndexOverriderClass.new()
	
	UnitTest:AssertFalse(IndexOverrider:HasOverride(),"Override exists.")
	IndexOverrider:ThenReturn(true)
	UnitTest:AssertTrue(IndexOverrider:HasOverride(),"Override doesn't exist.")
end)

--[[
Runs unit tests for the GetOverride method.
--]]
NexusUnitTesting:RegisterUnitTest("GetOverride",function(UnitTest)
	local IndexOverrider = IndexOverriderClass.new()
	IndexOverrider:ThenReturn(true)
	
	UnitTest:AssertTrue(IndexOverrider:GetOverride(),"Override is incorrect.")
end)

--[[
Runs unit tests for the ThenReturn method.
--]]
NexusUnitTesting:RegisterUnitTest("ThenReturn",function(UnitTest)
	local IndexOverrider = IndexOverriderClass.new()
	IndexOverrider:ThenReturn(true)
	
	UnitTest:AssertTrue(IndexOverrider:GetOverride(),"Override is incorrect.")
	IndexOverrider:ThenReturn(false)
	UnitTest:AssertFalse(IndexOverrider:GetOverride(),"Override is incorrect.")
end)

--[[
Runs unit tests for the ThenCall method.
--]]
NexusUnitTesting:RegisterUnitTest("ThenCall",function(UnitTest)
	local IndexOverrider = IndexOverriderClass.new()
	IndexOverrider:ThenCall(function()
		return true
	end)
	
	UnitTest:AssertTrue(IndexOverrider:GetOverride(),"Override is incorrect.")
	IndexOverrider:ThenCall(function()
		return false
	end)
	UnitTest:AssertFalse(IndexOverrider:GetOverride(),"Override is incorrect.")
end)



--Return true so there is no error with loading the ModuleScript.
return true