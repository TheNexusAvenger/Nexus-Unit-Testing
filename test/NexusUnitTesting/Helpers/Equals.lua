--[[
TheNexusAvenger

Unit tests for the Equals module. Since it is used for the 
Nexus Unit Testing plugin, it is not set up for the plugin.
--]]

local Tests = script.Parent.Parent.Parent
local Source = Tests.Parent:WaitForChild("Sources")
local NexusUnitTesting = require(Source:WaitForChild("NexusUnitTesting"))
local Equals = require(Source:WaitForChild("NexusUnitTesting"):WaitForChild("Helpers"):WaitForChild("Equals"))



--[[
Runs unit tests for the Equals method with Roblox objects.
--]]
NexusUnitTesting:RegisterUnitTest("Equals_BaseCase",function(UnitTest)
	UnitTest:AssertTrue(Equals(Vector3.new(0,0,0),Vector3.new(0,0,0)),"Same Vector3s aren't equal.")
	UnitTest:AssertTrue(Equals(Vector3.new(1,1,1),Vector3.new(1,1,1)),"Same Color3s aren't equal.")
	UnitTest:AssertFalse(Equals(Vector3.new(0,0,0),Vector3.new(0,1,0)),"Different Vector3s are equal.")
end)

--[[
Runs unit tests for the Equals method with lists.
--]]
NexusUnitTesting:RegisterUnitTest("Equals_Lists",function(UnitTest)
	local List1 = {1,1,2,3,5,8,13}
	local List2 = {1,1,2,3,5,8,13}
	local List3 = {1,1,2,3,5,8}
	
	UnitTest:AssertFalse(List1 == List2,"Lists have the same memory reference.")
	UnitTest:AssertTrue(Equals(List1,List2),"Lists with same values are different")
	UnitTest:AssertFalse(Equals(List1,List3),"Lists with missing values are equal")
end)

--[[
Runs unit tests for the Equals method with mised tables.
--]]
NexusUnitTesting:RegisterUnitTest("Equals_MixedTables",function(UnitTest)
	local Table1 = {1,1,2,3,Value1=5,8,Value2=13}
	local Table2 = {1,1,2,3,Value1=5,8,Value2=13}
	local Table3 = {1,1,Value1=2,3,5,8,Value2=13}
	
	UnitTest:AssertTrue(Equals(Table1,Table2),"Tables with same values are different")
	UnitTest:AssertFalse(Equals(Table1,Table3),"Tables with missing values are equal")
end)

--[[
Runs unit tests for the Equals method with tables inside tables.
--]]
NexusUnitTesting:RegisterUnitTest("Equals_DeepTables",function(UnitTest)
	local Table1 = {1,1,{2,3,Value3=5,{1,2}},Value1=5,8,Value2=13}
	local Table2 = {1,1,{2,3,Value3=5,{1,2}},Value1=5,8,Value2=13}
	local Table3 = {1,1,{2,3,Value3=5,{1}},Value1=5,8,Value2=13}
	
	UnitTest:AssertTrue(Equals(Table1,Table2),"Tables with same values are different")
	UnitTest:AssertFalse(Equals(Table1,Table3),"Tables with missing values are equal")
end)



--Return true so there is no error with loading the ModuleScript.
return true