--[[
TheNexusAvenger

Unit tests for the IndexOverridderClass module. Since it is used for the 
Nexus Unit Testing plugin, it is not set up for the plugin.
--]]

local Tests = script.Parent.Parent.Parent.Parent.Parent
local Source = Tests.Parent:WaitForChild("Sources")
local NexusUnitTesting = require(Source:WaitForChild("NexusUnitTesting"))
local IndexOverridderClass = require(Source:WaitForChild("NexusUnitTesting"):WaitForChild("Util"):WaitForChild("DependencyInjector"):WaitForChild("OverridderClass"):WaitForChild("IndexOverridderClass"))



--[[
Runs unit tests for the HasOverride method.
--]]
NexusUnitTesting:RegisterUnitTest("HasOverride",function(UnitTest)
	local IndexOverridder = IndexOverridderClass.new()
	
	UnitTest:AssertFalse(IndexOverridder:HasOverride(),"Override exists.")
	IndexOverridder:ThenReturn(true)
	UnitTest:AssertTrue(IndexOverridder:HasOverride(),"Override doesn't exist.")
end)

--[[
Runs unit tests for the GetOverride method.
--]]
NexusUnitTesting:RegisterUnitTest("GetOverride",function(UnitTest)
	local IndexOverridder = IndexOverridderClass.new()
	IndexOverridder:ThenReturn(true)
	
	UnitTest:AssertTrue(IndexOverridder:GetOverride(),"Override is incorrect.")
end)

--[[
Runs unit tests for the ThenReturn method.
--]]
NexusUnitTesting:RegisterUnitTest("ThenReturn",function(UnitTest)
	local IndexOverridder = IndexOverridderClass.new()
	IndexOverridder:ThenReturn(true)
	
	UnitTest:AssertTrue(IndexOverridder:GetOverride(),"Override is incorrect.")
	IndexOverridder:ThenReturn(false)
	UnitTest:AssertFalse(IndexOverridder:GetOverride(),"Override is incorrect.")
end)

--[[
Runs unit tests for the ThenCall method.
--]]
NexusUnitTesting:RegisterUnitTest("ThenCall",function(UnitTest)
	local IndexOverridder = IndexOverridderClass.new()
	IndexOverridder:ThenCall(function()
		return true
	end)
	
	UnitTest:AssertTrue(IndexOverridder:GetOverride(),"Override is incorrect.")
	IndexOverridder:ThenCall(function()
		return false
	end)
	UnitTest:AssertFalse(IndexOverridder:GetOverride(),"Override is incorrect.")
end)



--Return true so there is no error with loading the ModuleScript.
return true