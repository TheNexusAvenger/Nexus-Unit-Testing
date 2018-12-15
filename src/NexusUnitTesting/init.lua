--[[
TheNexusAvenger

Base class for handling unit tests.
All assertions can be run as the static class.
--]]

local NexusUnitTesting = {}

local Helpers = script:WaitForChild("Helpers")
local Equals = require(Helpers:WaitForChild("Equals"))
local IsClose = require(Helpers:WaitForChild("IsClose"))
local Util = script:WaitForChild("Util")
local DependencyInjector = require(Util:WaitForChild("DependencyInjector"))

NexusUnitTesting.Util = {
	DependencyInjector = DependencyInjector
}



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------               CONSTRUCTOR              --------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--[[
Creates an instance of the unit tester.
--]]
function NexusUnitTesting.new()
	local NexusUnitTestingObject = {}
	
	--Clone the methods and properties.
	--A deep copy is not used.
	for Key,Value in pairs(NexusUnitTesting) do
		NexusUnitTestingObject[Key] = Value
	end
	
	--Return the object.
	return NexusUnitTestingObject
end



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------               ASSERTIONS               --------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--[[
Displays a message that the unit test passed. Implicitly called after 
completing the function passed into NexusUnitTesting::RegisterUnitTest.
]]
function NexusUnitTesting:Pass()
	--Display the message.
	if self.Name then
		print(self.Name..": Passed")
	else
		print("Unit test passed")
	end
	
	--End the co-routine.
	coroutine.yield()
end

--[[
Runs an assertion. Displays a message as an error if it fails.
--]]
function NexusUnitTesting:Assert(Function,Message)
	--Add the name of the unit test to the message.
	if self.Name then
		Message = self.Name..": "..Message
	end
	
	--Run the unit test to see if the result is expected.
	local ResultExpected = Function()
	
	--If the test failed, throw an error.
	if not ResultExpected then
		error(Message)
	end
end

--[[
Asserts that two objects are equal. Special cases are handles for
objects like arrays that may have the same elements. Not intended
to be used on Roblox Instances.
--]]
function NexusUnitTesting:AssertEquals(ExpectedObject,ActualObject,Message)
	--Set up the message.
	if not Message then
		Message = "Two objects aren't equal."
	end
	local Comparison = "\n\tExpected: "..tostring(ExpectedObject).."\n\tActual: "..tostring(ActualObject)
	Message = Message..Comparison
	
	--Set up the function.
	local function Assert()
		--Return false if the types are different.
		if typeof(ExpectedObject) ~= typeof(ActualObject) then
			return false
		end
		
		--Return the result.
		return Equals(ExpectedObject,ActualObject)
	end
	
	--Run the assertion.
	self:Assert(Assert,Message)	
end
	
--[[
Asserts that two objects aren't equal. Special cases are handles for
objects like arrays that may have the same elements.
--]]
function NexusUnitTesting:AssertNotEquals(ExpectedObject,ActualObject,Message)
	--Set up the message.
	if not Message then
		Message = "Two objects are equal."
	end
	local Comparison = "\n\tExpected: "..tostring(ExpectedObject).."\n\tActual: "..tostring(ActualObject)
	Message = Message..Comparison
	
	--Set up the function.
	local function Assert()
		--Return true if the types are different.
		if typeof(ExpectedObject) ~= typeof(ActualObject) then
			return true
		end
		
		--Return the result.
		return not Equals(ExpectedObject,ActualObject)
	end
	
	--Run the assertion.
	self:Assert(Assert,Message)	
end

--[[
Asserts that two objects are the same. This is mainly used for testing
if a new array or instance isn't created.
--]]
function NexusUnitTesting:AssertSame(ExpectedObject,ActualObject,Message)
	--Set up the message.
	if not Message then
		Message = "Two objects aren't the same."
	end
	Message = Message.."\n\tExpected: "..tostring(ExpectedObject).."\n\tActual: "..tostring(ActualObject)
	
	--Set up the function.
	local function Assert()
		return ExpectedObject == ActualObject
	end
	
	--Run the assertion.
	self:Assert(Assert,Message)
end
	
--[[
Asserts that two objects aren't the same. This is mainly used for testing
if a new array or instance isn't created.
--]]
function NexusUnitTesting:AssertNotSame(ExpectedObject,ActualObject,Message)
	--Set up the message.
	if not Message then
		Message = "Two objects are the same."
	end
	Message = Message.."\n\tNot expected: "..tostring(ExpectedObject).."\n\tActual: "..tostring(ActualObject)
	
	--Set up the function.
	local function Assert()
		return ExpectedObject ~= ActualObject
	end
	
	--Run the assertion.
	self:Assert(Assert,Message)
end

--[[
Asserts that two objects are within a given Epsilon of each other. If
the message is used in place of the Epsilon, 0.001 will be used.
--]]
function NexusUnitTesting:AssertClose(ExpectedObject,ActualObject,Epsilon,Message)
	--Set the message as the epsilon if needed.
	if type(Epsilon) == "string" and Message == nil then
		Message = Epsilon
		Epsilon = 0.001
	end
	
	--Set up the message.
	if not Message then
		Message = "Two objects aren't close."
	end
	local Comparison = "\n\tExpected: "..tostring(ExpectedObject).."\n\tActual: "..tostring(ActualObject)
	Message = Message..Comparison
	
	--Set up the function.
	local function Assert()
		--Fail the test if the types are different.
		if typeof(ExpectedObject) ~= typeof(ActualObject) then
			self:Fail("Two objects aren't the same type."..Comparison)
		end
		
		--Determine if they are close.
		local Result = IsClose(ExpectedObject,ActualObject,Epsilon)
		if Result == nil then
			self:Fail("Two objects can't be compared for closeness."..Comparison)
		end
		
		return Result
	end
	
	--Run the assertion.
	self:Assert(Assert,Message)	
end
	
--[[
Asserts that two objects aren't within a given Epsilon of each other. If
the message is used in place of the Epsilon, 0.001 will be used.
--]]
function NexusUnitTesting:AssertNotClose(ExpectedObject,ActualObject,Epsilon,Message)
	--Set the message as the epsilon if needed.
	if type(Epsilon) == "string" and Message == nil then
		Message = Epsilon
		Epsilon = 0.001
	end
	
	--Set up the message.
	if not Message then
		Message = "Two objects aren't close."
	end
	local Comparison = "\n\tExpected: "..tostring(ExpectedObject).."\n\tActual: "..tostring(ActualObject)
	Message = Message..Comparison
	
	--Set up the function.
	local function Assert()
		--Fail the test if the types are different.
		if typeof(ExpectedObject) ~= typeof(ActualObject) then
			self:Fail("Two objects aren't the same type."..Comparison)
		end
		
		--Determine if they are close.
		local Result = IsClose(ExpectedObject,ActualObject,Epsilon)
		if Result == nil then
			self:Fail("Two objects can't be compared for closeness."..Comparison)
		end
		
		return not Result
	end
	
	--Run the assertion.
	self:Assert(Assert,Message)	
end
	
--[[
Asserts that an object is false.
--]]
function NexusUnitTesting:AssertFalse(ActualObject,Message)
	--Set up the message.
	if not Message then
		Message = "Object isn't false."
	end
	Message = Message.."\n\tActual: "..tostring(ActualObject)
	
	--Set up the function.
	local function Assert()
		return ActualObject == false
	end
	
	--Run the assertion.
	self:Assert(Assert,Message)	
end
	
--[[
Asserts that an object is true.
--]]
function NexusUnitTesting:AssertTrue(ActualObject,Message)
	--Set up the message.
	if not Message then
		Message = "Object isn't true."
	end
	Message = Message.."\n\tActual: "..tostring(ActualObject)
	
	--Set up the function.
	local function Assert()
		return ActualObject == true
	end
	
	--Run the assertion.
	self:Assert(Assert,Message)	
end

--[[
Asserts that an object is nil.
--]]
function NexusUnitTesting:AssertNil(ActualObject,Message)
	--Set up the message.
	if not Message then
		Message = "Object isn't nil."
	end
	Message = Message.."\n\tActual: "..tostring(ActualObject)
	
	--Set up the function.
	local function Assert()
		return ActualObject == nil
	end
	
	--Run the assertion.
	self:Assert(Assert,Message)	
end
	
--[[
Asserts that an object is not nil.
--]]
function NexusUnitTesting:AssertNotNil(ActualObject,Message)
	--Set up the message.
	if not Message then
		Message = "Object isn nil."
	end
	Message = Message.."\n\tActual: "..tostring(ActualObject)
	
	--Set up the function.
	local function Assert()
		return ActualObject ~= nil
	end
	
	--Run the assertion.
	self:Assert(Assert,Message)	
end

--[[
Asserts that an error is thrown.
--]]
function NexusUnitTesting:AssertErrors(Function,Message)
	--Set up the message.
	if not Message then
		Message = "No error was created."
	end
	
	--Set up the function.
	local function Assert()
		local Worked = pcall(Function)
		return not Worked
	end
	
	--Run the assertion.
	self:Assert(Assert,Message)	
end

--[[
Fails a unit test.
--]]
function NexusUnitTesting:Fail(Message)
	--Set up the message.
	if not Message then
		Message = "Unit test failed."
	end
	
	--Set up the function.
	local function Assert()
		return false
	end
	
	--Run the assertion.
	self:Assert(Assert,Message)
end



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------            "STATIC" METHODS            --------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--[[
Registers a unit test with a given name.
--]]
function NexusUnitTesting:RegisterUnitTest(Name,RunFunction)
	--Create the unit test class.
	local UnitTestObject = NexusUnitTesting.new()
	UnitTestObject.Name = Name
	
	--Run the unit test as a co-routine.
	spawn(function()
		RunFunction(UnitTestObject)
		
		--If the test didn't error, display a pass.
		UnitTestObject:Pass()
	end)
end



return NexusUnitTesting