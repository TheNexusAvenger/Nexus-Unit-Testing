--[[
TheNexusAvenger

Tests the yxpcall method.
--]]

local NexusUnitTesting = require("NexusUnitTesting")

local NexusUnitTestingProject = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusUnitTesting"))
local yxpcall = NexusUnitTestingProject:GetResource("UnitTest.yxpcall")



--[[
Tests no error being thrown.
--]]
NexusUnitTesting:RegisterUnitTest("NoErrorThrown",function(UnitTest)
	--Call yxpcall.
	local ErrorThrown = false
	local Worked,Return1,Return2 = yxpcall(function()
		return "Test1","Test2"
	end,function()
		ErrorThrown = true
	end)
	
	--Assert the results are correct.
	UnitTest:AssertFalse(ErrorThrown,"Error was thrown.")
	UnitTest:AssertTrue(Worked,"Worked result is incorrect.")
	UnitTest:AssertEquals(Return1,"Test1","First return is incorrect.")
	UnitTest:AssertEquals(Return2,"Test2","Second return is incorrect.")
end)

--[[
Tests calling with arguments.
--]]
NexusUnitTesting:RegisterUnitTest("NoErrorThrownArgumentsPassed",function(UnitTest)
	--Call yxpcall with arguments.
	local ErrorThrown = false
	local Worked,Return1,Return2 = yxpcall(function(Argument1,Argument2)
		return Argument1,Argument2
	end,function()
		ErrorThrown = true
	end,"Test1","Test2")
	
	--Assert the results are correct.
	UnitTest:AssertFalse(ErrorThrown,"Error was thrown.")
	UnitTest:AssertTrue(Worked,"Worked result is incorrect.")
	UnitTest:AssertEquals(Return1,"Test1","First return is incorrect.")
	UnitTest:AssertEquals(Return2,"Test2","Second return is incorrect.")
end)

--[[
Tests an error being thrown.
--]]
--[[
--Test is disabled for performance reasons until the new plugin is created
NexusUnitTesting:RegisterUnitTest("ErrorThrown",function(UnitTest)
	--Call yxpcall with arguments.
	local CalledError,CalledStackTrace
	local Worked = yxpcall(function()
		error("Test error")
	end,function(Error,StackTrace)
		CalledError,CalledStackTrace = Error,StackTrace
	end)
	
	--Assert the results are correct.
	UnitTest:AssertFalse(Worked,"Worked result is incorrect.")
	UnitTest:AssertNotNil(string.find(CalledError,"Test error"),"Error message doesn't contain the thrown error.")
	UnitTest:AssertNotNil(string.find(CalledStackTrace,"yxpcallTests"),"Error stack trace doesn't contain the script.")
end)
]]

--[[
Tests a stack overflow error being thrown.
--]]
--[[
--Test is disabled for performance reasons until the new plugin is created
NexusUnitTesting:RegisterUnitTest("StackOverflow",function(UnitTest)
	--Method that throws stack overflow.
	local function StackOverflow()
		StackOverflow()
	end
	
	--Call yxpcall with arguments.
	local CalledError,CalledStackTrace
	local Worked = yxpcall(function()
		StackOverflow()
	end,function(Error,StackTrace)
		CalledError,CalledStackTrace = Error,StackTrace
	end)
	
	--Assert the results are correct.
	UnitTest:AssertFalse(Worked,"Worked result is incorrect.")
	UnitTest:AssertNotNil(string.find(CalledError,"stack overflow"),"Error message doesn't contain stack overflow.")
	UnitTest:AssertNotNil(string.find(CalledStackTrace,"yxpcallTests"),"Error stack trace doesn't contain the script.")
	UnitTest:AssertNotNil(string.find(CalledStackTrace,"StackOverflow"),"Error stack trace doesn't contain the function name.")
	UnitTest:AssertTrue(#CalledStackTrace > 50000,"Stack trace isn't \"long\" ("..tostring(#CalledStackTrace).." < 50000 characters).")
end)
]]



return true