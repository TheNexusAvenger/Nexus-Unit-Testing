--[[
TheNexusAvenger

Class representing a unit test.
--]]
--!strict

local UNIT_TEST_STATE_PRIORITY = {
    NOTRUN = 1,
    PASSED = 2,
    SKIPPED = 3,
    FAILED = 4,
    INPROGRESS = 5,
} :: {[TestState]: number}

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
setmetatable(UnitTest.FunctionToUnitTest, {__mode = "kv"})

export type TestState = "NOTRUN" | "INPROGRESS" | "PASSED" | "FAILED" | "SKIPPED"
export type OutputEntry = {Type: Enum.MessageType, Message: string}
export type UnitTest = {
    new: (Name: string, RunDirectly: boolean?) -> UnitTest,
    Extend: (self: UnitTest) -> UnitTest,

    Name: string,
    State: TestState,
    CombinedState: TestState,
    SubTests: {UnitTest},
    Output: {OutputEntry},
    Sandbox: ModuleSandbox.ModuleSandbox,
    Overrides: {[string]: any},
    TestAdded: NexusEvent.NexusEvent<UnitTest>,
    MessageOutputted: NexusEvent.NexusEvent<Enum.MessageType, string>,
    TestEZExtensionsEnabled: boolean,
    Setup: (self: UnitTest) -> (),
    Run: (self: UnitTest) -> (),
    Teardown: (self: UnitTest) -> (),
    OutputMessage: (self: UnitTest, Type: Enum.MessageType, ...any) -> (),
    RegisterUnitTest: (self: UnitTest, NewUnitTest: string | UnitTest, Function: (self: UnitTest) -> ()?) -> (),
    RunTest: (self: UnitTest) -> (),
    RunSubtests: (self: UnitTest) -> (),
    SetEnvironmentOverride: (self: UnitTest, Name: string, Value: any) -> (UnitTest),
    SetSetup: (self: UnitTest, Method: (UnitTest) -> ()) -> (UnitTest),
    SetRun: (self: UnitTest, Method: (UnitTest) -> ()) -> (UnitTest),
    SetTeardown: (self: UnitTest, Method: (UnitTest) -> ()) -> (UnitTest),
    Pass: (self: UnitTest, Reason: string?) -> (),
    Fail: (self: UnitTest, Reason: string?) -> (),
    Skip: (self: UnitTest, Reason: string?) -> (),
    Assert: (self: UnitTest, Function: () -> (boolean), Message: string?) -> (),
    AssertEquals: <T>(self: UnitTest, ExpectedObject: T, ActualObject: T, Message: string?) -> (),
    AssertNotEquals: <T>(self: UnitTest, ExpectedObject: T, ActualObject: T, Message: string?) -> (),
    AssertSame: <T>(self: UnitTest, ExpectedObject: T, ActualObject: T, Message: string?) -> (),
    AssertNotSame: <T>(self: UnitTest, ExpectedObject: T, ActualObject: T, Message: string?) -> (),
    AssertClose: <T>(self: UnitTest, ExpectedObject: T, ActualObject: T, Epsilon: number? | string?, Message: string?) -> (),
    AssertNotClose: <T>(self: UnitTest, ExpectedObject: T, ActualObject: T, Epsilon: number? | string?, Message: string?) -> (),
    AssertFalse: (self: UnitTest, ActualObject: boolean, Message: string?) -> (),
    AssertTrue: (self: UnitTest, ActualObject: boolean, Message: string?) -> (),
    AssertNil: (self: UnitTest, ActualObject: any, Message: string?) -> (),
    AssertNotNil: (self: UnitTest, ActualObject: any, Message: string?) -> (),
    AssertErrors: (self: UnitTest, Function: () -> (), Message: string) -> (ErrorAssertor.ErrorAssertor),
} & NexusInstance.NexusInstance



--[[
Creates a unit test object.
--]]
function UnitTest:__new(Name: string, RunDirectly: boolean?): ()
    NexusInstance.__new(self)

    --Store the state.
    self.Name = Name
    self.State = "NOTRUN"
    self.CombinedState = "NOTRUN"
    self.SubTests = {}
    self.Output = {}
    self.Sandbox = ModuleSandbox.new()
    self.TestEZExtensionsEnabled = false

    --Store the overrides.
    self.Overrides = {
        ["print"] = function(...)
            self:GetOutputTest():OutputMessage(Enum.MessageType.MessageOutput, ...)
        end,
        ["warn"] = function(...)
            self:GetOutputTest():OutputMessage(Enum.MessageType.MessageWarning, ...)
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
    self:AddPropertyFinalizer("State", function()
        self:UpdateCombinedState()
    end)
end

--[[
Returns the test to output to.
--]]
function UnitTest:GetOutputTest(): UnitTest
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
Adds the TestEZ extensions to TestEZ.
--]]
function UnitTest:AddTestEZExtensions(Expectation: any): ()
    --[[
	Returns a version of the given method that can be called with either . or :
    Taken from TestEZ.
    --]]
    local function bindSelf(self, method)
        return function(firstArg, ...)
            if firstArg == self then
                return method(self, ...)
            else
                return method(self, firstArg, ...)
            end
        end
    end

    --Add the extension for near to have non-numbers.
    local CurrentUnitTest = self
    local OriginalNear = Expectation.near
    Expectation.near = bindSelf(Expectation, function(self, OtherValue: any, Limit: number?): any
        if CurrentUnitTest.TestEZExtensionsEnabled then
            local ErrorMessage = IsClose.FormatTestEZMessage(self.value, OtherValue, (Limit or 1e-7) :: number, self.successCondition and "CLOSE" or "NOT_CLOSE")
            if ErrorMessage ~= nil then
                error(ErrorMessage)
            end
        else
            if typeof(self.value) ~= "number" or typeof(OtherValue) ~= "number" then
                CurrentUnitTest:GetOutputTest():OutputMessage(Enum.MessageType.MessageWarning, "TestEZ near with non-numbers is not supported in TestEZ. Add --$NexusUnitTestExtensions to the test script to enable Nexus Unit Testing to enable comparing non-numbers with near.")
            end
            return OriginalNear(self, OtherValue, Limit)
        end
        return self
    end)

    --Add the extension for deep equals with tables.
    Expectation.deepEqual = bindSelf(Expectation, function(self, OtherValue: any): any
        if CurrentUnitTest.TestEZExtensionsEnabled then
            local DeepEquals = Equals(self.value, OtherValue)
            if self.successCondition and not DeepEquals then
                error(string.format("Expected value %q (%s) to deep equal %q (%s).", tostring(OtherValue), type(OtherValue), tostring(self.value), type(self.value)))
            elseif not self.successCondition and DeepEquals then
                error(string.format("Expected value %q (%s) to not deep equal %q (%s).", tostring(OtherValue), type(OtherValue), tostring(self.value), type(self.value)))
            end
        else
            error("TestEZ does not have deepEqual. Add --$NexusUnitTestExtensions to the test script to enable Nexus Unit Testing to enable deep equals for tables.")
        end
        return self
    end)


    --Replace __index for negations.
    local ExistingIndex = getmetatable(Expectation).__index
    getmetatable(Expectation).__index = function(self, key: string): any
        local OriginalIndex = ExistingIndex(self, key)
        if key == "never" then
            CurrentUnitTest:AddTestEZExtensions(OriginalIndex)
        end
        return OriginalIndex
    end
end

--[[
Wraps a TestEZ environment.
--]]
function UnitTest:WrapTestEZNodeEnvironment(CurrentNode: any): ()
    if not CurrentNode.NexusUnitTest then
        CurrentNode.NexusUnitTest = self
    end

    --[[
    Adds a child node.
    --]]
    local function AddChild(Phrase: string, Callback: () -> (), NodeType: any, NodeModifier: any)
        --Create the parent test.
        local ParentTest = CurrentNode.NexusUnitTest
        local NewTest = (UnitTest :: any).new(Phrase, true)
        NewTest.IsInternal = true
        NewTest.TestEZExtensionsEnabled = self.TestEZExtensionsEnabled
        NewTest.Run = Callback
        if NodeModifier == TestEZ.TestEnum.NodeModifier.Skip or CurrentNode.modifier == TestEZ.TestEnum.NodeModifier.Skip then
            NewTest.State = "SKIPPED"
        end
        ParentTest:RegisterUnitTest(NewTest)

        --Create the node.
        local Node = CurrentNode:addChild(Phrase, NodeType, NodeModifier)
        Node.NexusUnitTest = NewTest
        Node.callback = function()
            --Run the test.
            NewTest:RunTest()

            --Update the state.
            if Node.modifier == TestEZ.TestEnum.NodeModifier.Skip or ParentTest.State == "SKIPPED" then
                NewTest.State = "SKIPPED"
            end
        end
        for Key, Value in Node.environment do
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

    --Replace Expectation creation for extensions.
    getmetatable(Environment.expect).__call = function(_, ...)
        local Expectation = TestEZ.Expectation.new(...)
        self:AddTestEZExtensions(Expectation)
        return Expectation
    end
end

--[[
Wraps a TestNode in TestEZ.
--]]
function UnitTest:WrapTestEZTestNode(Node: any): ()
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
function UnitTest:AddTestEZOverrides(): ()
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
    for Name, Value in TestNode.environment do
        self:SetEnvironmentOverride(Name, Value)
    end
end

--[[
Sets up the test.
--]]
function UnitTest:Setup(): ()
    
end

--[[
Runs the test.
If the setup fails, the test is not continued.
--]]
function UnitTest:Run(): ()
    
end

--[[
Tears down the test.
Invoked regardless of the test passing or failing.
--]]
function UnitTest:Teardown(): ()
    
end

--[[
Outputs a message for the server.
--]]
function UnitTest:OutputMessage(Type: Enum.MessageType, ...: any): ()
    local Message = ""
    
    --Get the elements and count. Handle cases of parameters ending in nil.

    local Elements = table.pack(...)
    local ElementsCount = select("#", ...)
    
    --Determine the message.
    if ElementsCount == 0 then
        Message = "nil"
    elseif ElementsCount == 1 then
        Message = tostring(Elements[1])
    else
        --Concat the elements.
        for i = 1, ElementsCount do
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
    table.insert(self.Output, {Message = Message, Type = Type})
    self.MessageOutputted:Fire(Message, Type)
end

--[[
Wraps the environments of a given method for test
framework specific things logging.
--]]
function UnitTest:WrapEnvironment(Method: any, Overrides: {[string]: any}): ()
    --Add the overrides.
    self.FunctionToUnitTest[Method] = self
    Overrides = Overrides or {}
    for Key, Value in self.Overrides do
        Overrides[Key] = Value
    end
    
    --Set the environment.
    local BaseEnvironment = getfenv()
    setfenv(Method, setmetatable({} :: any, {
        __index = function(_, Index: string): ()
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
function UnitTest:RegisterUnitTest(NewUnitTest: string | UnitTest, Function: (self: UnitTest) -> ()?): ()
    --Create a unit test if the unit test is a string and the function exists (backwards compatibility).
    local NewUnitTestObject = nil
    if typeof(NewUnitTest) == "string" then
        NewUnitTestObject = (UnitTest :: any).new(NewUnitTest) :: UnitTest
        NewUnitTestObject:SetRun(Function)
    else
        NewUnitTestObject = NewUnitTest
    end

    --Add the unit test.
    table.insert(self.SubTests, NewUnitTestObject)
    NewUnitTestObject.Sandbox.BaseSandbox = self.Sandbox
    self.TestAdded:Fire(NewUnitTestObject)
end

--[[
Runs the run method and any TestEZ tests.
--]]
function UnitTest:BaseRunTest()
    if self.TestNode then
        self.TestNode:expand()
        TestEZ.TestRunner.runPlan(self.TestPlan)
        if self.TestNode.loadError then
            self.State = "FAILED"
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
function UnitTest:RunTest(): ()
    self.State = "INPROGRESS"
    
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
            self:OutputMessage(Enum.MessageType.MessageError, ErrorMessage)
            for _,Line in debug.traceback(nil, 2):split("\n") do
                if Line ~= "" then
                    self:OutputMessage(Enum.MessageType.MessageInfo, Line)
                end
            end
            self.State = "FAILED"
        end)
        
        self.SectionFinished:Fire()
    end)
    WaitForSectionToFinish()
    if self.State ~= "INPROGRESS" then
        SectionFinishedConnection:Disconnect()
        return
    end
    
    --Run the test.
    local TestWorked = true
    task.spawn(function()
        TestWorked = xpcall(function()
            self:BaseRunTest()
        end,function(ErrorMessage)
            self:OutputMessage(Enum.MessageType.MessageError, ErrorMessage)
            for _,Line in debug.traceback(nil,2):split("\n") do
                if Line ~= "" then
                    self:OutputMessage(Enum.MessageType.MessageInfo, Line)
                end
            end
            self.State = "FAILED"
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
            self:OutputMessage(Enum.MessageType.MessageError, ErrorMessage)
            for _,Line in debug.traceback(nil,2):split("\n") do
                if Line ~= "" then
                    self:OutputMessage(Enum.MessageType.MessageInfo, Line)
                end
            end
            self.State = "FAILED"
        end)
    
        self.SectionFinished:Fire()
    end)
    WaitForSectionToFinish()
    
    --Mark the test as successful.
    if self.State == "INPROGRESS" and TestWorked and TeardownWorked then
        self.State = "PASSED"
    end
    
    --Disconnect the event.
    SectionFinishedConnection:Disconnect()
end

--[[
Runs all of the subtests.
--]]
function UnitTest:RunSubtests(): ()
    if #self.SubTests > 0 then
        self.CombinedState = "INPROGRESS"
        
        --Run the subtests to get the tests.
        for _, Test in self.SubTests do
            if Test.State == "NOTRUN" and not Test.IsInternal then
                Test:RunTest()
            end
        end
        
        --Run the subtests' subtests.
        for _, Test in self.SubTests do
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
function UnitTest:SetEnvironmentOverride(Name: string, Value: any): UnitTest
    self.Overrides[Name] = Value
    return self
end

--[[
Sets the Setup method.
Can be chained with other methods (Object:Method1(...):Method2(...)...)
--]]
function UnitTest:SetSetup(Method: (UnitTest) -> ()): UnitTest
    self.Setup = Method
    return self
end

--[[
Sets the Run method.
Can be chained with other methods (Object:Method1(...):Method2(...)...)
--]]
function UnitTest:SetRun(Method: (UnitTest) -> ()): UnitTest
    self.Run = Method
    return self
end

--[[
Sets the Teardown method.
Can be chained with other methods (Object:Method1(...):Method2(...)...)
--]]
function UnitTest:SetTeardown(Method: (UnitTest) -> ()): UnitTest
    self.Teardown = Method
    return self
end

--[[
Updates the CombinedState.
--]]
function UnitTest:UpdateCombinedState(): ()
    --Get the current state.
    local CombinedState = self.State
    
    --Set the state based on the tests.
    for _, Test in self.SubTests do
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
    if self.State == "PASSED" or self.State == "FAILED" or self.State == "SKIPPED" then
        coroutine.yield()
    end
end

--[[
Marks a unit test as passed.
--]]
function UnitTest:Pass(Reason: string?): ()
    self:StopAssertionIfCompleted()
    self.State = "PASSED"
    
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
function UnitTest:Fail(Reason: string?): ()
    self:StopAssertionIfCompleted()
    self.State = "FAILED"
    
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
function UnitTest:Skip(Reason: string?): ()
    self:StopAssertionIfCompleted()
    self.State = "SKIPPED"
    
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
function UnitTest:Assert(Function: () -> (boolean), Message: string?): ()
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
function UnitTest:AssertEquals<T>(ExpectedObject: T, ActualObject: T, Message: string?): ()
    --Set up the message.
    Message = Message or "Two objects aren't equal."
    local Comparison = "\n\tObject 1: "..tostring(ExpectedObject).."\n\tObject 2: "..tostring(ActualObject)
    Message = (Message :: string)..Comparison
    
    --Set up the function.
    local function Assert()
        --Return false if the types are different.
        if typeof(ExpectedObject) ~= typeof(ActualObject) then
            return false
        end
        
        --Return the result.
        return Equals(ExpectedObject, ActualObject)
    end
    
    --Run the assertion.
    self:Assert(Assert, Message)    
end
    
--[[
Asserts that two objects aren't equal. Special cases are handles for
objects like arrays that may have the same elements.
--]]
function UnitTest:AssertNotEquals<T>(ExpectedObject: T, ActualObject: T, Message: string?): ()
    --Set up the message.
    Message = Message or "Two objects are equal."
    local Comparison = "\n\tObject 1: "..tostring(ExpectedObject).."\n\tObject 2: "..tostring(ActualObject)
    Message = (Message :: string)..Comparison
    
    --Set up the function.
    local function Assert()
        --Return true if the types are different.
        if typeof(ExpectedObject) ~= typeof(ActualObject) then
            return true
        end
        
        --Return the result.
        return not Equals(ExpectedObject, ActualObject)
    end
    
    --Run the assertion.
    self:Assert(Assert, Message)    
end

--[[
Asserts that two objects are the same. This is mainly used for testing
if a new array or instance isn't created.
--]]
function UnitTest:AssertSame<T>(ExpectedObject: T, ActualObject: T, Message: string?): ()
    --Set up the message.
    Message = Message or "Two objects aren't the same."
    Message = (Message :: string).."\n\tObject 1: "..tostring(ExpectedObject).."\n\tObject 2: "..tostring(ActualObject)
    
    --Set up the function.
    local function Assert()
        return ExpectedObject == ActualObject
    end
    
    --Run the assertion.
    self:Assert(Assert, Message)
end
    
--[[
Asserts that two objects aren't the same. This is mainly used for testing
if a new array or instance isn't created.
--]]
function UnitTest:AssertNotSame<T>(ExpectedObject: T, ActualObject: T, Message: string?): ()
    --Set up the message.
    if not Message then
        Message = "Two objects are the same."
    end
    Message = Message or "Two objects are the same."
    Message = (Message :: string).."\n\tObject 1: "..tostring(ExpectedObject).."\n\tObject 2: "..tostring(ActualObject)
    
    --Set up the function.
    local function Assert()
        return ExpectedObject ~= ActualObject
    end
    
    --Run the assertion.
    self:Assert(Assert, Message)
end

--[[
Asserts that two objects are within a given Epsilon of each other. If
the message is used in place of the Epsilon, 0.001 will be used.
--]]
function UnitTest:AssertClose<T>(ExpectedObject: T, ActualObject: T, Epsilon: number? | string?, Message: string?): ()
    --Set the message as the epsilon if needed.
    if type(Epsilon) == "string" and Message == nil then
        Message = Epsilon
        Epsilon = 0.001
    end
    
    --Set up the message.
    Message = Message or "Two objects aren't close."
    local Comparison = "\n\tObject 1: "..tostring(ExpectedObject).."\n\tObject 2: "..tostring(ActualObject)
    Message = (Message :: string)..Comparison
    
    --Set up the function.
    local function Assert()
        --Fail the test if the types are different.
        if typeof(ExpectedObject) ~= typeof(ActualObject) then
            self:Fail("Two objects aren't the same type."..Comparison)
        end
        
        --Determine if they are close.
        local Result, _ = IsClose.IsClose(ExpectedObject, ActualObject, Epsilon :: number)
        if Result == "UNSUPPORTED_TYPE" or Result == "DIFFERENT_TYPES" then
            self:Fail("Two objects can't be compared for closeness."..Comparison)
        end
        
        return Result == "CLOSE"
    end
    
    --Run the assertion.
    self:Assert(Assert ,Message)
end
    
--[[
Asserts that two objects aren't within a given Epsilon of each other. If
the message is used in place of the Epsilon, 0.001 will be used.
--]]
function UnitTest:AssertNotClose<T>(ExpectedObject: T, ActualObject: T, Epsilon: number? | string?, Message: string?): ()
    --Set the message as the epsilon if needed.
    if type(Epsilon) == "string" and Message == nil then
        Message = Epsilon
        Epsilon = 0.001
    end
    
    --Set up the message.
    Message = Message or "Two objects aren't close."
    local Comparison = "\n\tObject 1: "..tostring(ExpectedObject).."\n\tObject 2: "..tostring(ActualObject)
    Message = (Message :: string)..Comparison
    
    --Set up the function.
    local function Assert()
        --Fail the test if the types are different.
        if typeof(ExpectedObject) ~= typeof(ActualObject) then
            self:Fail("Two objects aren't the same type."..Comparison)
        end
        
        --Determine if they are close.
        local Result, _ = IsClose.IsClose(ExpectedObject, ActualObject, Epsilon :: number)
        if Result == "UNSUPPORTED_TYPE" or Result == "DIFFERENT_TYPES" then
            self:Fail("Two objects can't be compared for closeness."..Comparison)
        end
        
        return Result == "NOT_CLOSE"
    end
    
    --Run the assertion.
    self:Assert(Assert, Message)    
end
    
--[[
Asserts that an object is false.
--]]
function UnitTest:AssertFalse(ActualObject: boolean, Message: string?): ()
    --Set up the message.
    Message = Message or "Object isn't false."
    Message = (Message :: string).."\n\tActual: "..tostring(ActualObject)
    
    --Set up the function.
    local function Assert()
        return ActualObject == false
    end
    
    --Run the assertion.
    self:Assert(Assert, Message)    
end
    
--[[
Asserts that an object is true.
--]]
function UnitTest:AssertTrue(ActualObject: boolean, Message: string?): ()
    --Set up the message.
    Message = Message or "Object isn't true."
    Message = (Message :: string).."\n\tActual: "..tostring(ActualObject)
    
    --Set up the function.
    local function Assert()
        return ActualObject == true
    end
    
    --Run the assertion.
    self:Assert(Assert, Message)    
end

--[[
Asserts that an object is nil.
--]]
function UnitTest:AssertNil(ActualObject: any, Message: string?): ()
    --Set up the message.
    Message = Message or "Object isn't nil."
    Message = (Message :: string).."\n\tActual: "..tostring(ActualObject)
    
    --Set up the function.
    local function Assert()
        return ActualObject == nil
    end
    
    --Run the assertion.
    self:Assert(Assert, Message)
end
    
--[[
Asserts that an object is not nil.
--]]
function UnitTest:AssertNotNil(ActualObject: any, Message: string?): ()
    --Set up the message.
    Message = Message or "Object is nil."
    Message = (Message :: string).."\n\tActual: "..tostring(ActualObject)
    
    --Set up the function.
    local function Assert()
        return ActualObject ~= nil
    end
    
    --Run the assertion.
    self:Assert(Assert, Message)
end

--[[
Asserts that an error is thrown.
--]]
function UnitTest:AssertErrors(Function: () -> (), Message: string): ErrorAssertor.ErrorAssertor
    --Set up the message.
    if not Message then
        Message = "No error was created."
    end
    
    --Set up the function.
    local Assertor
    local function Assert()
        local Worked, Return = pcall(function()
            Function()
        end)
        if not Worked then
            Assertor = ErrorAssertor.new(Return)
        end
        
        return not Worked
    end
    
    --Run the assertion and return the assertor.
    self:Assert(Assert, Message)
    return Assertor
end



return (UnitTest :: any) :: UnitTest