--[[
TheNexusAvenger

Class representing a unit test.
--]]

local NexusUnitTesting = require(script.Parent.Parent:WaitForChild("NexusUnitTestingProject"))
local NexusInstance = NexusUnitTesting:GetResource("NexusInstance.NexusInstance")
local NexusEventCreator = NexusUnitTesting:GetResource("NexusInstance.Event.NexusEventCreator")
local yxpcall = NexusUnitTesting:GetResource("UnitTest.yxpcall")
local ModuleSandbox = NexusUnitTesting:GetResource("UnitTest.ModuleSandbox")
local Equals = NexusUnitTesting:GetResource("UnitTest.AssertionHelper.Equals")
local IsClose = NexusUnitTesting:GetResource("UnitTest.AssertionHelper.IsClose")
local ErrorAssertor = NexusUnitTesting:GetResource("UnitTest.AssertionHelper.ErrorAssertor")
local TestPlanner = NexusUnitTesting:GetResource("TestEZ.TestPlanner")
local TestPlanBuilder = NexusUnitTesting:GetResource("TestEZ.TestPlanBuilder")
local TestEnum = NexusUnitTesting:GetResource("TestEZ.TestEnum")
local TestRunner = NexusUnitTesting:GetResource("TestEZ.TestRunner")

local UnitTest = NexusInstance:Extend()
UnitTest:SetClassName("UnitTest")
UnitTest.UnitTest = UnitTest



local UNIT_TEST_STATE_PRIORITY = {
	[NexusUnitTesting.TestState.NotRun] = 1,
	[NexusUnitTesting.TestState.Passed] = 2,
	[NexusUnitTesting.TestState.Skipped] = 3,
	[NexusUnitTesting.TestState.Failed] = 4,
	[NexusUnitTesting.TestState.InProgress] = 5,
}



--[[
Creates a unit test object.
--]]
function UnitTest:__new(Name)
	self:InitializeSuper()
	
	--Store the state.
	self.Name = Name
	self.State = NexusUnitTesting.TestState.NotRun
	self.CombinedState = NexusUnitTesting.TestState.NotRun
	self.SubTests = {}
	self.Output = {}
	self.Sandbox = ModuleSandbox.new()
	
	--Store the overrides.
	self.Overrides = {
		["print"] = function(...)
			NexusUnitTesting.BasePrint(...)
			self:OutputMessage(Enum.MessageType.MessageOutput,...)
		end,
		["warn"] = function(...)
			NexusUnitTesting.BaseWarn(...)
			self:OutputMessage(Enum.MessageType.MessageWarning,...)
		end,
		["BaseRequire"] = require,
		["require"] = function(Module)
			return self.Sandbox:RequireModule(Module)
		end,
	}
	self:AddTestEZOverrides()
	
	--Create the events.
	self.TestAdded = NexusEventCreator:CreateEvent()
	self.MessageOutputted = NexusEventCreator:CreateEvent()
	self.SectionFinished = NexusEventCreator:CreateEvent()
	
	--Connect the changed events.
	self:GetPropertyChangedSignal("State"):Connect(function()
		self:UpdateCombinedState()
	end)
end

--[[
Adds overrides for TestEZ.
--]]
function UnitTest:AddTestEZOverrides()
	--Create the base environment.
	local PlanBuilder = TestPlanBuilder.new()
	self.PlanBuilder = PlanBuilder
	local Environment = TestPlanner.createEnvironment(PlanBuilder)
	
	--Add the methods.
	for Name,Value in pairs(Environment) do
		self:SetEnvironmentOverride(Name,Value)
	end
end

--[[
Sets up the test.
--]]
function UnitTest:Setup()
	
end

--[[
Runs the test.
If the setup fails, the test is not continued.
--]]
function UnitTest:Run()
	
end

--[[
Tears down the test.
Invoked regardless of the test passing or failing.
--]]
function UnitTest:Teardown()
	
end

--[[
Outputs a message for the server.
--]]
function UnitTest:OutputMessage(Type,...)
	if self.CurSubTest then
		return self.CurSubTest:OutputMessage(Type, ...)
	end
	local Message = ""
	
	--Get the elements and count. Handle cases of parameters ending in nil.

	local Elements = table.pack(...)
	local ElementsCount = select("#",...)
	
	--Determine the message.
	if ElementsCount == 0 then
		Message = "nil"
	elseif ElementsCount == 1 then
		Message = tostring(Elements[1])
	else
		--Concat the elements.
		for i = 1,ElementsCount do
			local Element = Elements[i]
			
			--Add a space for non-first elements.
			if i ~= 1 then
				Message = Message.." "
			end
			
			--Add the element.
			if Element == nil then
				Message = Message.."nil"
			else
				Message = Message..tostring(Element)
			end
		end
	end
	
	--Invoke the event.
	table.insert(self.Output,{Message,Type})
	self.MessageOutputted:Fire(Message,Type)
end

--[[
Wraps the environments of a given method for test
framework specific things logging.
--]]
function UnitTest:WrapEnvironment(Method,Overrides)
	--Add the overrides.
	Overrides = Overrides or {}
	for Key,Value in pairs(self.Overrides) do
		Overrides[Key] = Value
	end
	
	--Set the environment.
	local BaseEnvironment = getfenv()
	setfenv(Method,setmetatable({},{
		__index = function(_,Index)
			--Return an override.
			local Override = Overrides[Index]
			if Override then
				return Override
			end
			
			--Return the base value.
			return BaseEnvironment[Index]
		end
	}))
end

--[[
Registers a child unit test.
--]]
function UnitTest:RegisterUnitTest(NewUnitTest,Function)
	--Create a unit test if the unit test is a string and the function exists (backwards compatibility).
	if typeof(NewUnitTest) == "string" then
		NewUnitTest = UnitTest.new(NewUnitTest)
		NewUnitTest:SetRun(Function)
	end
	
	--Add the unit test.
	table.insert(self.SubTests,NewUnitTest)
	NewUnitTest.Sandbox.BaseSandbox = self.Sandbox
	self.TestAdded:Fire(NewUnitTest)
end

--[[
Runs the run method and any TestEZ tests.
--]]
function UnitTest:BaseRunTest()
	--Run the test.
	self:Run()
	
	--Run the TestEZ tests if any were defined.
	local TestEZPlan = self.PlanBuilder:finalize()
	if #TestEZPlan.children >= 1 then
		local TestEZResults = TestRunner.runPlan(TestEZPlan)
		
		--[[
		Visits a child node.
		--]]
		local function VisitChildNode(Node,ParentTest)
			local Status = Node.status
			local PlanNode = Node.planNode
			local Skipped = PlanNode.modifier == "Skip"
			
			--Create the new test.
			local NewTest = UnitTest.new(PlanNode.phrase)
			ParentTest:RegisterUnitTest(NewTest)
			if Skipped or ParentTest.State == NexusUnitTesting.TestState.Skipped then
				NewTest.State = NexusUnitTesting.TestState.Skipped
			elseif Status == "Success" then
				NewTest.State = NexusUnitTesting.TestState.Passed
			elseif Status == "Failure" then
				NewTest.State = NexusUnitTesting.TestState.Failed
			end
			
			--Visit the child nodes.
			for _,ChildNode in pairs(Node.children) do
				VisitChildNode(ChildNode,NewTest)
			end
			
			--Update the combined state.
			NewTest:UpdateCombinedState()
			
			--Output the error(s).
			for _,Error in pairs(Node.errors) do
				self:OutputMessage(Enum.MessageType.MessageError,string.split(Error,"\n",1)[1])
				self:OutputMessage(Enum.MessageType.MessageInfo,Error)
			end
		end
		
		--Visit the children.
		for _,ChildNode in pairs(TestEZResults.children) do
			VisitChildNode(ChildNode,self)
		end
	end
end

--[[
Runs the complete text. Should not be overriden
to run tests since it is intended to be used by the
view to run tests.
--]]
function UnitTest:RunTest()
	self.State = NexusUnitTesting.TestState.InProgress
	
	--Wrap the methods.
	self:WrapEnvironment(self.Setup)
	self:WrapEnvironment(self.Run)
	self:WrapEnvironment(self.Teardown)
	
	--Setup event listening.
	local SectionFinished = false
	local SectionFinishedConnection = self.SectionFinished:Connect(function()
		SectionFinished = true
	end)
	
	--[[
	Waits for a section to finish.
	--]]
	local function WaitForSectionToFinish()
		while not SectionFinished do wait() end
		SectionFinished = false
	end
	
	--Run the setup.
	coroutine.wrap(function()
		yxpcall(function() self:Setup() end,function(ErrorMessage,StackTrace)
			self:OutputMessage(Enum.MessageType.MessageError,ErrorMessage)
			self:OutputMessage(Enum.MessageType.MessageInfo,StackTrace)
			self.State = NexusUnitTesting.TestState.Failed
		end)
		
		self.SectionFinished:Fire()
	end)()
	WaitForSectionToFinish()
	if self.State ~= NexusUnitTesting.TestState.InProgress then SectionFinishedConnection:Disconnect() return end
	
	--Run the test.
	local TestWorked = true
	coroutine.wrap(function()
		TestWorked = yxpcall(function() self:BaseRunTest() end,function(ErrorMessage,StackTrace)
			self:OutputMessage(Enum.MessageType.MessageError,ErrorMessage)
			self:OutputMessage(Enum.MessageType.MessageInfo,StackTrace)
			self.State = NexusUnitTesting.TestState.Failed
		end)
		
		self.SectionFinished:Fire()
	end)()
	WaitForSectionToFinish()
	
	--Teardown the test.
	local TeardownWorked = true
	coroutine.wrap(function()
		TeardownWorked = yxpcall(function() self:Teardown() end,function(ErrorMessage,StackTrace)
			self:OutputMessage(Enum.MessageType.MessageError,ErrorMessage)
			self:OutputMessage(Enum.MessageType.MessageInfo,StackTrace)
			self.State = NexusUnitTesting.TestState.Failed
		end)
	
		self.SectionFinished:Fire()
	end)()
	WaitForSectionToFinish()
	
	--Mark the test as successful.
	if self.State == NexusUnitTesting.TestState.InProgress and TestWorked and TeardownWorked then
		self.State = NexusUnitTesting.TestState.Passed
	end
	
	--Disconnect the event.
	SectionFinishedConnection:Disconnect()
end

--[[
Runs all of the subtests.
--]]
function UnitTest:RunSubtests()
	if #self.SubTests > 0 then
		self.CombinedState = NexusUnitTesting.TestState.InProgress
		
		--Run the subtests to get the tests.
		for _,Test in pairs(self.SubTests) do
			if Test.State == NexusUnitTesting.TestState.NotRun then
				self.CurSubTest = Test
				Test:RunTest()
				self:UpdateCombinedState()
			end
		end

		--Run the subtests' subtests.
		for _,Test in pairs(self.SubTests) do
			self.CurSubTest = Test
			Test:RunSubtests()
		end
		self.CurSubTest = nil
		
		--Update the state.
		self:UpdateCombinedState()
	end
end

--[[
Sets an environment override for the methods
in the test.
Can be chained with other methods (Object:Method1(...):Method2(...)...)
--]]
function UnitTest:SetEnvironmentOverride(Name,Value)
	self.Overrides[Name] = Value
	return self
end

--[[
Sets the Setup method.
Can be chained with other methods (Object:Method1(...):Method2(...)...)
--]]
function UnitTest:SetSetup(Method)
	self.Setup = Method
	return self
end

--[[
Sets the Run method.
Can be chained with other methods (Object:Method1(...):Method2(...)...)
--]]
function UnitTest:SetRun(Method)
	self.Run = Method
	return self
end

--[[
Sets the Teardown method.
Can be chained with other methods (Object:Method1(...):Method2(...)...)
--]]
function UnitTest:SetTeardown(Method)
	self.Teardown = Method
	return self
end

--[[
Updates the CombinedState.
--]]
function UnitTest:UpdateCombinedState()
	--Get the current state.
	local CombinedState = self.State
	
	--Set the state based on the tests.
	for _,Test in pairs(self.SubTests) do
		local TestState = Test.CombinedState
		if UNIT_TEST_STATE_PRIORITY[TestState] > UNIT_TEST_STATE_PRIORITY[CombinedState] then
			CombinedState = TestState
		end
	end
	
	--Set the state.
	self.CombinedState = CombinedState
end

--[[
Stops the asserting thread if the
test is completed.
--]]
function UnitTest:StopAssertionIfCompleted()
	if self.State == NexusUnitTesting.TestState.Passed or self.State == NexusUnitTesting.TestState.Failed or self.State == NexusUnitTesting.TestState.Skipped then
		coroutine.yield()
	end
end

--[[
Marks a unit test as passed.
--]]
function UnitTest:Pass(Reason)
	self:StopAssertionIfCompleted()
	self.State = NexusUnitTesting.TestState.Passed
	
	--Print the reason for passing.
	if Reason ~= nil then
		print("Test passed: "..Reason)
	end
	
	--Stop the thread.
	self.SectionFinished:Fire()
	coroutine.yield()
end

--[[
Marks a unit test as failed.
--]]
function UnitTest:Fail(Reason)
	self:StopAssertionIfCompleted()
	self.State = NexusUnitTesting.TestState.Failed
	
	--Add a reason if none exists.
	if Reason == nil then
		Reason = "Test failed"
	end
	
	--Throw an error.
	error(Reason)
end

--[[
Marks a unit test as skipped.
--]]
function UnitTest:Skip(Reason)
	self:StopAssertionIfCompleted()
	self.State = NexusUnitTesting.TestState.Skipped
	
	--Print the reason for skipping.
	if Reason ~= nil then
		print("Test skipped: "..Reason)
	end
	
	--Stop the thread.
	self.SectionFinished:Fire()
	coroutine.yield()
end

--[[
Runs an assertion. Displays a message as an error if it fails.
--]]
function UnitTest:Assert(Function,Message)
	self:StopAssertionIfCompleted()
	
	--Run the unit test to see if the result is expected.
	local ResultExpected = Function()
	
	--If the test failed, fail the unit test.
	if not ResultExpected then
		self:Fail(Message)
	end
end

--[[
Asserts that two objects are equal. Special cases are handles for
objects like arrays that may have the same elements. Not intended
to be used on Roblox Instances.
--]]
function UnitTest:AssertEquals(ExpectedObject,ActualObject,Message)
	--Set up the message.
	if not Message then
		Message = "Two objects aren't equal."
	end
	local Comparison = "\n\tObject 1: "..tostring(ExpectedObject).."\n\tObject 2: "..tostring(ActualObject)
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
function UnitTest:AssertNotEquals(ExpectedObject,ActualObject,Message)
	--Set up the message.
	if not Message then
		Message = "Two objects are equal."
	end
	local Comparison = "\n\tObject 1: "..tostring(ExpectedObject).."\n\tObject 2: "..tostring(ActualObject)
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
function UnitTest:AssertSame(ExpectedObject,ActualObject,Message)
	--Set up the message.
	if not Message then
		Message = "Two objects aren't the same."
	end
	Message = Message.."\n\tObject 1: "..tostring(ExpectedObject).."\n\tObject 2: "..tostring(ActualObject)
	
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
function UnitTest:AssertNotSame(ExpectedObject,ActualObject,Message)
	--Set up the message.
	if not Message then
		Message = "Two objects are the same."
	end
	Message = Message.."\n\tObject 1: "..tostring(ExpectedObject).."\n\tObject 2: "..tostring(ActualObject)
	
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
function UnitTest:AssertClose(ExpectedObject,ActualObject,Epsilon,Message)
	--Set the message as the epsilon if needed.
	if type(Epsilon) == "string" and Message == nil then
		Message = Epsilon
		Epsilon = 0.001
	end
	
	--Set up the message.
	if not Message then
		Message = "Two objects aren't close."
	end
	local Comparison = "\n\tObject 1: "..tostring(ExpectedObject).."\n\tObject 2: "..tostring(ActualObject)
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
function UnitTest:AssertNotClose(ExpectedObject,ActualObject,Epsilon,Message)
	--Set the message as the epsilon if needed.
	if type(Epsilon) == "string" and Message == nil then
		Message = Epsilon
		Epsilon = 0.001
	end
	
	--Set up the message.
	if not Message then
		Message = "Two objects aren't close."
	end
	local Comparison = "\n\tObject 1: "..tostring(ExpectedObject).."\n\tObject 2: "..tostring(ActualObject)
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
function UnitTest:AssertFalse(ActualObject,Message)
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
function UnitTest:AssertTrue(ActualObject,Message)
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
function UnitTest:AssertNil(ActualObject,Message)
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
function UnitTest:AssertNotNil(ActualObject,Message)
	--Set up the message.
	if not Message then
		Message = "Object isn't nil."
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
function UnitTest:AssertErrors(Function,Message)
	--Set up the message.
	if not Message then
		Message = "No error was created."
	end
	
	--Set up the function.
	local Assertor
	local function Assert()
		local Worked,Return = pcall(Function)
		if not Worked then
			Assertor = ErrorAssertor.new(Return)
		end
		
		return not Worked
	end
	
	--Run the assertion and return the assertor.
	self:Assert(Assert,Message)
	return Assertor
end



return UnitTest