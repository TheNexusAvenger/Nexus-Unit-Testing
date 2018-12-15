--[[
TheNexusAvenger

Unit tests for the NexusUnitTesting module. Since it is used for the 
Nexus Unit Testing plugin, it is not set up for the plugin.
This script tests the assertions.
--]]

local Tests = script.Parent
local Source = Tests.Parent:WaitForChild("Sources")
local NexusUnitTesting = require(Source:WaitForChild("NexusUnitTesting"))



--[[
Runs unit tests for the NexusUnitTesting.AssertEquals method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertEquals",function(UnitTest)
	UnitTest:AssertEquals(true,true,"Bools aren't equal.")
	UnitTest:AssertEquals(0,0,"Integers aren't equal.")
	UnitTest:AssertEquals({1,2,3},{1,2,3},"Same tables aren't equal.")
	UnitTest:AssertEquals({1,Test="",2,3},{1,2,3,Test=""},"Same tables aren't equal.")
end)

--[[
Runs unit tests for the NexusUnitTesting.AssertTrue method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertNotEquals",function(UnitTest)
	UnitTest:AssertNotEquals(0.333,1/3,"Doubles are equal.")
	UnitTest:AssertNotEquals(false,true,"Bools are equal.")
	UnitTest:AssertNotEquals({1,Test="",2,3},{1,2,Test=""},"Tables are equal.")
end)

--[[
Runs unit tests for the NexusUnitTesting.AssertSame method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertSame",function(UnitTest)
	local Table = {}
	
	UnitTest:AssertSame(true,true,"Bools aren't the same.")
	UnitTest:AssertSame(0,0,"Integers aren't the same.")
	UnitTest:AssertSame(Table,Table,"Same tables aren't the same.")
end)

--[[
Runs unit tests for the NexusUnitTesting.AssertTrue method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertNotSame",function(UnitTest)
	UnitTest:AssertNotSame(true,false,"Bools are the same.")
	UnitTest:AssertNotSame(0,1,"Integers are the same.")
	UnitTest:AssertNotSame({},{},"Same tables are the same.")
end)

--[[
Runs unit tests for the NexusUnitTesting.AssertClose method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertClose",function(UnitTest)
	UnitTest:AssertClose(0.333,1/3,"Doubles aren't close.")
	UnitTest:AssertClose(CFrame.new(1,2,3),CFrame.new(1,2,3),"CFrames aren't close.")
	UnitTest:AssertClose(Color3.new(0.333,0.666,0.999),Color3.new(1/3,2/3,3/3),"Color3s aren't close.")
	UnitTest:AssertClose(Ray.new(),Ray.new(),"Rays aren't close.")
	UnitTest:AssertClose(Region3.new(),Region3.new(),"Region3s aren't close.")
	UnitTest:AssertClose(UDim.new(),UDim.new(),"UDims aren't close.")
	UnitTest:AssertClose(UDim2.new(),UDim2.new(),"UDim2s aren't close.")
	UnitTest:AssertClose(Vector2.new(),Vector2.new(),"Vector2s aren't close.")
	UnitTest:AssertClose(Vector3.new(),Vector3.new(),"Vector3s aren't close.")
end)

--[[
Runs unit tests for the NexusUnitTesting.AssertNotClose method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertNotClose",function(UnitTest)
	UnitTest:AssertNotClose(0.333,2/3,"Doubles are close.")
	UnitTest:AssertNotClose(CFrame.new(1,2,3),CFrame.new(1,3,3),"CFrames are close.")
	UnitTest:AssertNotClose(Color3.new(0.333,0.666,0.999),Color3.new(2/3,2/3,3/3),"Color3s are close.")
end)

--[[
Runs unit tests for the NexusUnitTesting.AssertFalse method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertFalse",function(UnitTest)
	UnitTest:AssertFalse(false)
end)

--[[
Runs unit tests for the NexusUnitTesting.AssertTrue method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertTrue",function(UnitTest)
	UnitTest:AssertTrue(true)
end)

--[[
Runs unit tests for the NexusUnitTesting.AssertTrue method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertNotNil",function(UnitTest)
	UnitTest:AssertNotNil(true)
end)

--[[
Runs unit tests for the NexusUnitTesting.AssertTrue method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertNil",function(UnitTest)
	UnitTest:AssertNil(nil)
end)

--[[
Runs unit tests for the NexusUnitTesting.AssertErrors method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertErrors",function(UnitTest)
	UnitTest:AssertErrors(function()
		error("Test error")
	end)
end)



--Return true so there is no error with loading the ModuleScript.
return true