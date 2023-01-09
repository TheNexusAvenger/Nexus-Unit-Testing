--[[
TheNexusAvenger

Class representing a unit test.
--]]

local TestState = {
    NotRun = "NOTRUN",
    InProgress = "INPROGRESS",
    Passed = "PASSED",
    Failed = "FAILED",
    Skipped = "SKIPPED",
}

local NexusUnitTestingModule = script.Parent.Parent
local NexusInstance = require(NexusUnitTestingModule:WaitForChild("NexusInstance"):WaitForChild("NexusInstance"))
local NexusEvent = require(NexusUnitTestingModule:WaitForChild("NexusInstance"):WaitForChild("Event"):WaitForChild("NexusEvent"))
local ModuleSandbox = require(NexusUnitTestingModule:WaitForChild("UnitTest"):WaitForChild("ModuleSandbox"))
local Equals = require(NexusUnitTestingModule:WaitForChild("UnitTest"):WaitForChild("AssertionHelper"):WaitForChild("Equals"))
local IsClose = require(NexusUnitTestingModule:WaitForChild("UnitTest"):WaitForChild("AssertionHelper"):WaitForChild("IsClose"))
local ErrorAssertor = require(NexusUnitTestingModule:WaitForChild("UnitTest"):WaitForChild("AssertionHelper"):WaitForChild("ErrorAssertor"))
local TestEZ = require(NexusUnitTestingModule:WaitForChild("TestEZ"))

local UnitTest = NexusInstance:Extend()
UnitTest:SetClassName("UnitTest")
UnitTest.UnitTest = UnitTest
UnitTest.FunctionToUnitTest = {}
setmetatable(UnitTest.FunctionToUnitTest, {__mode="kv"})



local UNIT_TEST_STATE_PRIORITY = {
    [TestState.NotRun] = 1,
    [TestState.Passed] = 2,
    [TestState.Skipped] = 3,
    [TestState.Failed] = 4,
    [TestState.InProgress] = 5,
}



--[[
Creates a unit test object.
--]]
function UnitTest:__new(Name, RunDirectly)
    NexusInstance.__new(self)

    --Store the state.
    self.Name = Name
    self.State = TestState.NotRun
    self.CombinedState = TestState.NotRun
    self.SubTests = {}
    self.Output = {}
    self.Sandbox = ModuleSandbox.new()

    --Store the overrides.
    self.Overrides = {
        ["print"] = function(...)
            self:GetOutputTest():OutputMessage(Enum.MessageType.MessageOutput,...)
        end,
        ["warn"] = function(...)
            self:GetOutputTest():OutputMessage(Enum.MessageType.MessageWarning,...)
        end,
        ["BaseRequire"] = require,
        ["require"] = function(Module)
            return self.Sandbox:RequireModule(Module)
        end,
    }
    if not RunDirectly then
        self:AddTestEZOverrides()
    end

    --Create the events.
    self.TestAdded = NexusEvent.new()
    self.MessageOutputted = NexusEvent.new()
    self.SectionFinished = NexusEvent.new()

    --Connect the changed events.
    self:AddPropertyFinalizer("State",function()
        self:UpdateCombinedState()
    end)
end

--[[
Returns the test to output to.
--]]
function UnitTest:GetOutputTest()
    --Iterate through the functions and return the test if one exists.
    local CurrentIndex = 0
    while true do
        CurrentIndex = CurrentIndex + 1
        local Function = debug.info(coroutine.running(), CurrentIndex, "f")
        if Function == nil then break end
        local Test = self.FunctionToUnitTest[Function]
        if Test then return Test end
    end

    --Return itself (no other results valid).
    return self
end

--[[
Wraps a TestEZ environment.
--]]
function UnitTest:WrapTestEZNodeEnvironment(CurrentNode)
    if not CurrentNode.NexusUnitTest then
        CurrentNode.NexusUnitTest = self
    end

    --[[
    Adds a child node.
    --]]
    local function AddChild(Phrase, Callback, NodeType, NodeModifier)
        --Create the parent test.
        local ParentTest = CurrentNode.NexusUnitTest
        local NewTest = UnitTest.new(Phrase, true)
        NewTest.IsInternal = true
        NewTest.Run = Callback
        if NodeModifier == TestEZ.TestEnum.NodeModifier.Skip or CurrentNode.modifier == TestEZ.TestEnum.NodeModifier.Skip then
            NewTest.State = TestState.Skipped
        end
        ParentTest:RegisterUnitTest(NewTest)

        --Create the node.
        local Node = CurrentNode:addChild(Phrase, NodeType, NodeModifier)
        Node.NexusUnitTest = NewTest
        Node.callback = function()
            --Run the test.
            NewTest:RunTest()

            --Update the state.
            if Node.modifier == TestEZ.TestEnum.NodeModifier.Skip or ParentTest.State == TestState.Skipped then
                NewTest.State = TestState.Skipped
            end
        end
        for Key, Value in pairs(Node.environment) do
            NewTest:SetEnvironmentOverride(Key, Value)
        end

        --Expand the node.
        if NodeType == TestEZ.TestEnum.NodeType.Describe then
            Node:expand()
        end
        return Node
    end

    --Replace the describe and it environment.
    local Environment = CurrentNode.environment
    function Environment.describeFOCUS(phrase, callback)
        AddChild(phrase, callback, TestEZ.TestEnum.NodeType.Describe, TestEZ.TestEnum.NodeModifier.Focus)
    end
    function Environment.describeSKIP(phrase, callback)
        AddChild(phrase, callback, TestEZ.TestEnum.NodeType.Describe, TestEZ.TestEnum.NodeModifier.Skip)
    end
    function Environment.describe(phrase, callback)
        AddChild(phrase, callback, TestEZ.TestEnum.NodeType.Describe, TestEZ.TestEnum.NodeModifier.None)
    end
    function Environment.itFOCUS(phrase, callback)
        AddChild(phrase, callback, TestEZ.TestEnum.NodeType.It, TestEZ.TestEnum.NodeModifier.Focus)
    end
    function Environment.itSKIP(phrase, callback)
        AddChild(phrase, callback, TestEZ.TestEnum.NodeType.It, TestEZ.TestEnum.NodeModifier.Skip)
    end
    function Environment.itFIXME(phrase, callback)
        local Node = AddChild(phrase, callback, TestEZ.TestEnum.NodeType.It, TestEZ.TestEnum.NodeModifier.Skip)
        Node.NexusUnitTest:OutputMessage(Enum.MessageType.MessageWarning, "FIXME: broken test "..Node:getFullName())
    end
    function Environment.it(phrase, callback)
        AddChild(phrase, callback, TestEZ.TestEnum.NodeType.It, TestEZ.TestEnum.NodeModifier.None)
    end
    function Environment.FIXME(optionalMessage)
        CurrentNode.NexusUnitTest:OutputMessage(Enum.MessageType.MessageWarning, "FIXME: broken test "..CurrentNode:getFullName().." "..(optionalMessage or ""))
        CurrentNode.modifier = TestEZ.TestEnum.NodeModifier.Skip
    end
    Environment.fit = Environment.itFOCUS
    Environment.xit = Environment.itSKIP
    Environment.fdescribe = Environment.describeFOCUS
    Environment.xdescribe = Environment.describeSKIP
end

--[[
Wraps a TestNode in TestEZ.
--]]
function UnitTest:WrapTestEZTestNode(Node)
    local OriginalAddChild = Node.addChild
    Node.addChild = function(...)
        local ChildNode = OriginalAddChild(...)
        self:WrapTestEZNodeEnvironment(ChildNode)
        self:WrapTestEZTestNode(ChildNode)
        return ChildNode
    end
end

--[[
Adds overrides for TestEZ.
--]]
function UnitTest:AddTestEZOverrides()
    --Create the base environment.
    local TestPlan = TestEZ.TestPlan.new()
    self:WrapTestEZTestNode(TestPlan)
    local TestNode = TestPlan:addChild(self.Name, TestEZ.TestEnum.NodeType.Describe)
    TestNode.callback = function()
        self:Run()
    end
    self.TestNode = TestNode
    self.TestPlan = TestPlan

    --Store the environment.
    for Name, Value in pairs(TestNode.environment) do
        self:SetEnvironmentOverride(Name, Value)
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
    self.FunctionToUnitTest[Method] = self
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
    if self.TestNode then
        self.TestNode:expand()
        TestEZ.TestRunner.runPlan(self.TestPlan)
        if self.TestNode.loadError then
            self.State = TestState.Failed
            self:OutputMessage(Enum.MessageType.MessageError, self.TestNode.loadError)
        end
    else
        self:Run()
    end
end

--[[
Runs the complete text. Should not be overriden
to run tests since it is intended to be used by the
view to run tests.
--]]
function UnitTest:RunTest()
    self.State = TestState.InProgress
    
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
        while not SectionFinished do task.wait() end
        SectionFinished = false
    end
    
    --Run the setup.
    task.spawn(function()
        xpcall(function()
            self:Setup()
        end,function(ErrorMessage)
            self:OutputMessage(Enum.MessageType.MessageError,ErrorMessage)
            for _,Line in pairs(debug.traceback(nil,2):split("\n")) do
                if Line ~= "" then
                    self:OutputMessage(Enum.MessageType.MessageInfo,Line)
                end
            end
            self.State = TestState.Failed
        end)
        
        self.SectionFinished:Fire()
    end)
    WaitForSectionToFinish()
    if self.State ~= TestState.InProgress then SectionFinishedConnection:Disconnect() return end
    
    --Run the test.
    local TestWorked = true
    task.spawn(function()
        TestWorked = xpcall(function()
            self:BaseRunTest()
        end,function(ErrorMessage)
            self:OutputMessage(Enum.MessageType.MessageError,ErrorMessage)
            for _,Line in pairs(debug.traceback(nil,2):split("\n")) do
                if Line ~= "" then
                    self:OutputMessage(Enum.MessageType.MessageInfo,Line)
                end
            end
            self.State = TestState.Failed
        end)
        
        self.SectionFinished:Fire()
    end)
    WaitForSectionToFinish()
    
    --Teardown the test.
    local TeardownWorked = true
    task.spawn(function()
        TeardownWorked = xpcall(function()
            self:Teardown()
        end,function(ErrorMessage)
            self:OutputMessage(Enum.MessageType.MessageError,ErrorMessage)
            for _,Line in pairs(debug.traceback(nil,2):split("\n")) do
                if Line ~= "" then
                    self:OutputMessage(Enum.MessageType.MessageInfo,Line)
                end
            end
            self.State = TestState.Failed
        end)
    
        self.SectionFinished:Fire()
    end)
    WaitForSectionToFinish()
    
    --Mark the test as successful.
    if self.State == TestState.InProgress and TestWorked and TeardownWorked then
        self.State = TestState.Passed
    end
    
    --Disconnect the event.
    SectionFinishedConnection:Disconnect()
end

--[[
Runs all of the subtests.
--]]
function UnitTest:RunSubtests()
    if #self.SubTests > 0 then
        self.CombinedState = TestState.InProgress
        
        --Run the subtests to get the tests.
        for _,Test in pairs(self.SubTests) do
            if Test.State == TestState.NotRun and not Test.IsInternal then
                Test:RunTest()
            end
        end
        
        --Run the subtests' subtests.
        for _,Test in pairs(self.SubTests) do
            Test:RunSubtests()
        end
        
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
    if self.State == TestState.Passed or self.State == TestState.Failed or self.State == TestState.Skipped then
        coroutine.yield()
    end
end

--[[
Marks a unit test as passed.
--]]
function UnitTest:Pass(Reason)
    self:StopAssertionIfCompleted()
    self.State = TestState.Passed
    
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
    self.State = TestState.Failed
    
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
    self.State = TestState.Skipped
    
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