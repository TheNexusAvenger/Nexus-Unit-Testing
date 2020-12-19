--[[
TheNexusAvenger

Tests the Equals helper function.
--]]

local NexusUnitTesting = require("NexusUnitTesting")

local NexusUnitTestingProject = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusUnitTesting"):WaitForChild("NexusUnitTestingProject"))
local Equals = NexusUnitTestingProject:GetResource("UnitTest.AssertionHelper.Equals")



--[[
Tests the Equals function with Roblox objects.
--]]
NexusUnitTesting:RegisterUnitTest("EqualsBaseCase",function(UnitTest)
	UnitTest:AssertTrue(Equals(Vector3.new(0,0,0),Vector3.new(0,0,0)),"Same Vector3s aren't equal.")
	UnitTest:AssertTrue(Equals(Vector3.new(1,1,1),Vector3.new(1,1,1)),"Same Color3s aren't equal.")
	UnitTest:AssertFalse(Equals(Vector3.new(0,0,0),Vector3.new(0,1,0)),"Different Vector3s are equal.")
end)

--[[
Tests the Equals function with lists.
--]]
NexusUnitTesting:RegisterUnitTest("EqualsLists",function(UnitTest)
	local List1 = {1,1,2,3,5,8,13}
	local List2 = {1,1,2,3,5,8,13}
	local List3 = {1,1,2,3,5,8}
	
	UnitTest:AssertFalse(List1 == List2,"Lists have the same memory reference.")
	UnitTest:AssertTrue(Equals(List1,List2),"Lists with same values are different")
	UnitTest:AssertFalse(Equals(List1,List3),"Lists with missing values are equal")
end)

--[[
Tests the Equals function with mised tables.
--]]
NexusUnitTesting:RegisterUnitTest("EqualsMixedTables",function(UnitTest)
	local Table1 = {1,1,2,3,Value1=5,8,Value2=13}
	local Table2 = {1,1,2,3,Value1=5,8,Value2=13}
	local Table3 = {1,1,Value1=2,3,5,8,Value2=13}
	
	UnitTest:AssertTrue(Equals(Table1,Table2),"Tables with same values are different")
	UnitTest:AssertFalse(Equals(Table1,Table3),"Tables with missing values are equal")
end)

--[[
Tests the Equals function with tables inside tables.
--]]
NexusUnitTesting:RegisterUnitTest("EqualsDeepTables",function(UnitTest)
	local Table1 = {1,1,{2,3,Value3=5,{1,2}},Value1=5,8,Value2=13}
	local Table2 = {1,1,{2,3,Value3=5,{1,2}},Value1=5,8,Value2=13}
	local Table3 = {1,1,{2,3,Value3=5,{1}},Value1=5,8,Value2=13}
	
	UnitTest:AssertTrue(Equals(Table1,Table2),"Tables with same values are different")
	UnitTest:AssertFalse(Equals(Table1,Table3),"Tables with missing values are equal")
end)

--[[
Tests the Equals function with cyclic tables.
--]]
NexusUnitTesting:RegisterUnitTest("EqualsCyclicTables",function(UnitTest)
	local Table1 = {1,1,{2,3,Value3=5,{1,2}},Value1=5,8,Value2=13}
	Table1.Value4 = Table1
	local Table2 = {1,1,{2,3,Value3=5,{1,2}},Value1=5,8,Value2=13}
	Table2.Value4 = Table2
	local Table3 = {1,1,{2,3,Value3=5,{1}},Value1=5,8,Value2=13}
	Table3.Value4 = Table3
	
	UnitTest:AssertTrue(Equals(Table1,Table2),"Tables with same values are different")
	UnitTest:AssertFalse(Equals(Table1,Table3),"Tables with missing values are equal")
end)

--[[
Tests the Equals function with already checked values.
--]]
NexusUnitTesting:RegisterUnitTest("EqualsCheckedTables",function(UnitTest)
	local Table0 = { 0 }
	local Table1 = { { 0 }, { 0 } }
	local Table2 = { Table0, Table0 }
	local Table3 = { { 0 }, { 1 } }

	UnitTest:AssertTrue(Equals(Table1,Table2),"Tables with same values are different")
	UnitTest:AssertFalse(Equals(Table1,Table3),"Tables with different values are equal")
	UnitTest:AssertFalse(Equals(Table2,Table3),"Tables with different values are equal")
end)

return true