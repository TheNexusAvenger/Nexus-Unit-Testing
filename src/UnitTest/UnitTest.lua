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
    Run: (self: UnitTest) -> (),
    OutputMessage: (self: UnitTest, Type: Enum.MessageType, ...any) -> (),
    RegisterUnitTest: (self: UnitTest, NewUnitTest: string | UnitTest, Function: (self: UnitTest) -> ()?) -> (),
    RunTest: (self: UnitTest) -> (),
    SetEnvironmentOverride: (self: UnitTest, Name: string, Value: any) -> (UnitTest),
    SetRun: (self: UnitTest, Method: (UnitTest) -> ()) -> (UnitTest),
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
    local OriginalNear = Expectation.near
    Expectation.near = bindSelf(Expectation, function(self, OtherValue: any, Limit: number?): any
        local OutputTest = UnitTest:GetOutputTest()
        if OutputTest.TestEZExtensionsEnabled then
            local ErrorMessage = IsClose.FormatTestEZMessage(self.value, OtherValue, (Limit or 1e-7) :: number, self.successCondition and "CLOSE" or "NOT_CLOSE")
            if ErrorMessage ~= nil then
                error(ErrorMessage)
            end
        else
            if typeof(self.value) ~= "number" or typeof(OtherValue) ~= "number" then
                OutputTest:OutputMessage(Enum.MessageType.MessageWarning, "TestEZ near with non-numbers is not supported in TestEZ. Add --$NexusUnitTestExtensions to the test script to enable Nexus Unit Testing to enable comparing non-numbers with near.")
            end
            return OriginalNear(self, OtherValue, Limit)
        end
        return self
    end)

    --Add the extension for deep equals with tables.
    Expectation.deepEqual = bindSelf(Expectation, function(self, OtherValue: any): any
        local OutputTest = UnitTest:GetOutputTest()
        if OutputTest.TestEZExtensionsEnabled then
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

    --Add the extension for contains with strings and tables.
    Expectation.contain = bindSelf(Expectation, function(self, OtherValue: any): any
        local OutputTest = UnitTest:GetOutputTest()
        if OutputTest.TestEZExtensionsEnabled then
            if typeof(self.value) == "string" then
                --Throw an error if the value is a string and doesn't contain the string.
                local Index, _ = string.find(self.value, tostring(OtherValue))
                if self.successCondition and not Index then
                    error(string.format("String %q does not contain %q when expected.", tostring(self.value), tostring(OtherValue)))
                elseif not self.successCondition and Index then
                    error(string.format("String %q contains %q but not expected.", tostring(self.value), tostring(OtherValue)))
                end
            elseif typeof(self.value) == "table" then
                --Throw an error if the value is a table and doesn't contain the value.
                local Contains = false
                for _, TableValue in self.value :: {any} do
                    if TableValue ~= OtherValue then continue end
                    Contains = true
                    break
                end
                if self.successCondition and not Contains then
                    error(string.format("Table %q does not contain %q (%s) when expected.", tostring(self.value), tostring(OtherValue), typeof(OtherValue)))
                elseif not self.successCondition and Contains then
                    error(string.format("Table %q contains %q (%s) but not expected.", tostring(self.value), tostring(OtherValue), typeof(OtherValue)))
                end
            end
        else
            error("TestEZ does not have contain. Add --$NexusUnitTestExtensions to the test script to enable Nexus Unit Testing to enable table and string contains.")
        end
        return self
    end)

    --Replace __index for negations.
    local CurrentUnitTest = self
    local Metatable = getmetatable(Expectation)
    if not Metatable.__NexusUnitTestingWrapped then
        local ExistingIndex = Metatable.__index
        Metatable.__NexusUnitTestingWrapped = true
        Metatable.__index = function(self, key: string): any
            local OriginalIndex = ExistingIndex(self, key)
            if key == "never" then
                CurrentUnitTest:AddTestEZExtensions(OriginalIndex)
            end
            return OriginalIndex
        end
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
Runs the test.
--]]
function UnitTest:Run(): ()
    
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
    NewUnitTestObject.TestEZExtensionsEnabled = self.TestEZExtensionsEnabled
    self.TestAdded:Fire(NewUnitTestObject)
    NewUnitTestObject:AddPropertyFinalizer("State", function()
        self:UpdateCombinedState()
    end)
    NewUnitTestObject:AddPropertyFinalizer("CombinedState", function()
        self:UpdateCombinedState()
    end)
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
    self:WrapEnvironment(self.Run)
    
    --Run the test.
    xpcall(function()
        self:BaseRunTest()
        if self.State == "INPROGRESS" then
            self.State = "PASSED"
        end
    end, function(ErrorMessage)
        self:OutputMessage(Enum.MessageType.MessageError, ErrorMessage)
        for _,Line in debug.traceback(nil, 2):split("\n") do
            if Line ~= "" then
                self:OutputMessage(Enum.MessageType.MessageInfo, Line)
            end
        end
        self.State = "FAILED"
    end)
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
Sets the Run method.
Can be chained with other methods (Object:Method1(...):Method2(...)...)
--]]
function UnitTest:SetRun(Method: (UnitTest) -> ()): UnitTest
    self.Run = Method
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



return (UnitTest :: any) :: UnitTest