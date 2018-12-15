--[[
TheNexusAvenger

Unit tests for the IsClose module. Since it is used for the 
Nexus Unit Testing plugin, it is not set up for the plugin.
--]]

local Tests = script.Parent.Parent.Parent
local Source = Tests.Parent:WaitForChild("Sources")
local NexusUnitTesting = require(Source:WaitForChild("NexusUnitTesting"))
local IsClose = require(Source:WaitForChild("NexusUnitTesting"):WaitForChild("Helpers"):WaitForChild("IsClose"))

local DEFAULT_EPSIOLON = 0.001



--[[
Runs unit tests for the IsClose method with numbers.
--]]
NexusUnitTesting:RegisterUnitTest("IsClose_Numbers",function(UnitTest)
	UnitTest:AssertTrue(IsClose(math.pi,3.1415,DEFAULT_EPSIOLON),"Close numbers aren't close.")
	UnitTest:AssertTrue(IsClose(1,2,1),"Close numbers aren't close.")
	UnitTest:AssertFalse(IsClose(0,2,DEFAULT_EPSIOLON),"Non-close numbers are close.")
end)

--[[
Runs unit tests for the IsClose method with CFrames.
--]]
NexusUnitTesting:RegisterUnitTest("IsClose_CFrames",function(UnitTest)
	UnitTest:AssertTrue(IsClose(CFrame.Angles(0,math.pi,0),CFrame.new(0,0,0,-1,0,0,0,1,0,0,0,-1),DEFAULT_EPSIOLON),"Close CFrames aren't close.")
	UnitTest:AssertFalse(IsClose(CFrame.new(0,0,0),CFrame.Angles(0,math.pi,0),DEFAULT_EPSIOLON),"Non-close CFrames are close.")
end)

--[[
Runs unit tests for the IsClose method with Color3s.
--]]
NexusUnitTesting:RegisterUnitTest("IsClose_Color3s",function(UnitTest)
	UnitTest:AssertTrue(IsClose(Color3.new(0.333,0.333,0.333),Color3.new(1/3,1/3,1/3),DEFAULT_EPSIOLON),"Close Color3s aren't close.")
	UnitTest:AssertFalse(IsClose(Color3.new(1,0,0),Color3.new(0,1,0),DEFAULT_EPSIOLON),"Non-close Color3s are close.")
end)

--[[
Runs unit tests for the IsClose method with Rays.
--]]
NexusUnitTesting:RegisterUnitTest("IsClose_Rays",function(UnitTest)
	UnitTest:AssertTrue(IsClose(Ray.new(),Ray.new(),DEFAULT_EPSIOLON),"Close Rays aren't close.")
	UnitTest:AssertFalse(IsClose(Ray.new(Vector3.new(0,0,0),Vector3.new(1,1,1)),Ray.new(Vector3.new(1,1,1),Vector3.new(0,0,0)),DEFAULT_EPSIOLON),"Non-close Rays are close.")
end)

--[[
Runs unit tests for the IsClose method with Region3s.
--]]
NexusUnitTesting:RegisterUnitTest("IsClose_Region3s",function(UnitTest)
	UnitTest:AssertTrue(IsClose(Region3.new(),Region3.new(),DEFAULT_EPSIOLON),"Close Region3s aren't close.")
	UnitTest:AssertFalse(IsClose(Region3.new(Vector3.new(0,0,0),Vector3.new(1,1,1)),Region3.new(Vector3.new(1,1,1),Vector3.new(0,0,0)),DEFAULT_EPSIOLON),"Non-close Region3s are close.")
end)

--[[
Runs unit tests for the IsClose method with UDims.
--]]
NexusUnitTesting:RegisterUnitTest("IsClose_UDims",function(UnitTest)
	UnitTest:AssertTrue(IsClose(UDim.new(0.333,0),UDim.new(1/3,0),DEFAULT_EPSIOLON),"Close UDims aren't close.")
	UnitTest:AssertFalse(IsClose(UDim.new(0,1),UDim.new(1,0),DEFAULT_EPSIOLON),"Non-close UDims are close.")
end)

--[[
Runs unit tests for the IsClose method with UDim2s.
--]]
NexusUnitTesting:RegisterUnitTest("IsClose_UDim2s",function(UnitTest)
	UnitTest:AssertTrue(IsClose(UDim2.new(),UDim2.new(),DEFAULT_EPSIOLON),"Close UDim2s aren't close.")
	UnitTest:AssertFalse(IsClose(UDim2.new(1,0,1,0),UDim2.new(0,1,0,1),DEFAULT_EPSIOLON),"Non-close UDim2s are close.")
end)

--[[
Runs unit tests for the IsClose method with Vector2s.
--]]
NexusUnitTesting:RegisterUnitTest("IsClose_Vector2s",function(UnitTest)
	UnitTest:AssertTrue(IsClose(Vector2.new(),Vector2.new(),DEFAULT_EPSIOLON),"Close Vector2s aren't close.")
	UnitTest:AssertFalse(IsClose(Vector2.new(0,0),Vector2.new(1,1),DEFAULT_EPSIOLON),"Non-close Vector2s are close.")
end)

--[[
Runs unit tests for the IsClose method with Vector3s.
--]]
NexusUnitTesting:RegisterUnitTest("IsClose_Vector3s",function(UnitTest)
	UnitTest:AssertTrue(IsClose(Vector3.new(),Vector3.new(),DEFAULT_EPSIOLON),"Close Vector3s aren't close.")
	UnitTest:AssertFalse(IsClose(Vector3.new(0,0,0),Vector3.new(1,1,1),DEFAULT_EPSIOLON),"Non-close Vector3s are close.")
end)



--Return true so there is no error with loading the ModuleScript.
return true