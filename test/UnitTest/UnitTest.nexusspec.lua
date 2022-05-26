--[[
TheNexusAvenger

Tests the UnitTest class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")

local NexusUnitTestingProject = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusUnitTesting"):WaitForChild("NexusUnitTestingProject"))
local UnitTestClass = NexusUnitTestingProject:GetResource("UnitTest.UnitTest")



--[[
Tests the OutputMessage method.
--]]
NexusUnitTesting:RegisterUnitTest("OutputMessage",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    local OutputInformation = {}
    CuT.MessageOutputted:Connect(function(Message,Type)
        table.insert(OutputInformation,{Message,Type})
    end)
    
    --Output the messages and assert they are correct.
    CuT:OutputMessage(Enum.MessageType.MessageOutput,"Test message")
    CuT:OutputMessage(Enum.MessageType.MessageOutput,nil)
    CuT:OutputMessage(Enum.MessageType.MessageWarning,1,2,nil,4)
    CuT:OutputMessage(Enum.MessageType.MessageWarning,1,2,nil)
    wait()
    UnitTest:AssertEquals(OutputInformation[1][1],"Test message")
    UnitTest:AssertEquals(OutputInformation[1][2],Enum.MessageType.MessageOutput)
    UnitTest:AssertEquals(OutputInformation[2][1],"nil")
    UnitTest:AssertEquals(OutputInformation[2][2],Enum.MessageType.MessageOutput)
    UnitTest:AssertEquals(OutputInformation[3][1],"1 2 nil 4")
    UnitTest:AssertEquals(OutputInformation[3][2],Enum.MessageType.MessageWarning)
    UnitTest:AssertEquals(OutputInformation[4][1],"1 2 nil")
    UnitTest:AssertEquals(OutputInformation[4][2],Enum.MessageType.MessageWarning)
    UnitTest:AssertNil(OutputInformation[5],"Too many messages were outputted.")
    UnitTest:AssertEquals(CuT.Output[1][1],"Test message")
    UnitTest:AssertEquals(CuT.Output[1][2],Enum.MessageType.MessageOutput)
    UnitTest:AssertEquals(CuT.Output[2][1],"nil")
    UnitTest:AssertEquals(CuT.Output[2][2],Enum.MessageType.MessageOutput)
    UnitTest:AssertEquals(CuT.Output[3][1],"1 2 nil 4")
    UnitTest:AssertEquals(CuT.Output[3][2],Enum.MessageType.MessageWarning)
    UnitTest:AssertEquals(CuT.Output[4][1],"1 2 nil")
    UnitTest:AssertEquals(CuT.Output[4][2],Enum.MessageType.MessageWarning)
    UnitTest:AssertNil(CuT.Output[5],"Too many messages were outputted.")
end)

--[[
Tests the WrapEnvironment method.
--]]
NexusUnitTesting:RegisterUnitTest("WrapEnvironment",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    local OutputInformation = {}
    CuT.MessageOutputted:Connect(function(Message,Type)
        table.insert(OutputInformation,{Message,Type})
    end)
    
    --Create and wrap a custom method.
    local function TestMethod()
        print("Test call")
        warn("Test call 1","Test call 2",nil)
    end
    CuT:WrapEnvironment(TestMethod)
    
    --Assert the calls were correct.
    TestMethod()
    wait()
    UnitTest:AssertEquals(OutputInformation[1][1],"Test call")
    UnitTest:AssertEquals(OutputInformation[1][2],Enum.MessageType.MessageOutput)
    UnitTest:AssertEquals(OutputInformation[2][1],"Test call 1 Test call 2 nil")
    UnitTest:AssertEquals(OutputInformation[2][2],Enum.MessageType.MessageWarning)
    UnitTest:AssertNil(OutputInformation[3],"Too many messages were outputted.")
end)

--[[
Tests the RunTest method without errors.
--]]
NexusUnitTesting:RegisterUnitTest("RunTestNoErrors",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Set up the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    function CuT:Setup()
        SetupRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Run()
        TestRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Teardown()
        TeardownRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    --Run the test and assert the states are correct.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertTrue(TestRun,"Test not ran.")
    UnitTest:AssertTrue(TeardownRun,"Teardown not ran.")
end)

--[[
Tests the RunTest method with a setup error.
--]]
NexusUnitTesting:RegisterUnitTest("RunTestSetupError",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Set up the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    function CuT:Setup()
        SetupRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
        error("Fake setup error")
    end
    
    function CuT:Run()
        TestRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Teardown()
        TeardownRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    --Run the test and assert the states are correct.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Failed,"Test not failed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Failed,"Test not failed.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertFalse(TestRun,"Test ran.")
    UnitTest:AssertFalse(TeardownRun,"Teardown ran.")
end)

--[[
Tests the RunTest method with a test error.
--]]
NexusUnitTesting:RegisterUnitTest("RunTestSetupError",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Set up the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    function CuT:Setup()
        SetupRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Run()
        TestRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
        error("Fake test error")
    end
    
    function CuT:Teardown()
        TeardownRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.Failed)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.Failed)
    end
    
    --Run the test and assert the states are correct.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Failed,"Test not failed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Failed,"Test not failed.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertTrue(TestRun,"Test not ran.")
    UnitTest:AssertTrue(TeardownRun,"Teardown not ran.")
end)

--[[
Tests the RunTest method with a teardown error.
--]]
NexusUnitTesting:RegisterUnitTest("RunTestSetupError",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Set up the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    function CuT:Setup()
        SetupRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Run()
        TestRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Teardown()
        TeardownRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
        error("Fake test error")
    end
    
    --Run the test and assert the states are correct.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Failed,"Test not failed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Failed,"Test not failed.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertTrue(TestRun,"Test not ran.")
    UnitTest:AssertTrue(TeardownRun,"Teardown not ran.")
end)


--[[
Tests the RunTest method without errors.
--]]
NexusUnitTesting:RegisterUnitTest("RunTestNoErrors",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Set up the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    function CuT:Setup()
        SetupRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Run()
        TestRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Teardown()
        TeardownRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    --Run the test and assert the states are correct.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertTrue(TestRun,"Test not ran.")
    UnitTest:AssertTrue(TeardownRun,"Teardown not ran.")
end)

--[[
Tests the RunTest method with a passing TestEZ test.
--]]
NexusUnitTesting:RegisterUnitTest("RunTestTestEZPass",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Set up the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    local StateTestCompleted,CombinedStateTestCompleted = false,false
    function CuT:Setup()
        SetupRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    CuT.IS_TESTEZ = true
    
    CuT.MessageOutputted:Connect(function(Message,Type)
        print(Message)
    end)
    
    function CuT:Run()
        TestRun = true
        
        --Get the TestEZ methods from the environment to prevent Script Analysis from showing problems.
        local describe = getfenv().describe
        local it = getfenv().it
        
        --Describe the test.
        describe("Test",function()
            it("state should be in progress", function()
                local expect = getfenv().expect
                expect(self.State).to.equal(NexusUnitTestingProject.TestState.InProgress)
                StateTestCompleted = true
            end)
            
            it("combined state should be in progress", function()
                local expect = getfenv().expect
                expect(self.CombinedState).to.equal(NexusUnitTestingProject.TestState.InProgress)
                CombinedStateTestCompleted = true
            end)
        end)
    end
    
    function CuT:Teardown()
        TeardownRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    --Run the test and assert the states are correct.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertTrue(TestRun,"Test not ran.")
    UnitTest:AssertTrue(TeardownRun,"Teardown not ran.")
    UnitTest:AssertTrue(StateTestCompleted,"Test case not ran.")
    UnitTest:AssertTrue(CombinedStateTestCompleted,"Test case not ran.")
end)

--[[
Tests the RunTest method with a failing TestEZ test.
--]]
NexusUnitTesting:RegisterUnitTest("RunTestTestEZFailedTest",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Set up the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    local StateTestCompleted,CombinedStateTestCompleted = false,false
    function CuT:Setup()
        SetupRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Run()
        TestRun = true
        
        --Get the TestEZ methods from the environment to prevent Script Analysis from showing problems.
        local describe = getfenv().describe
        local it = getfenv().it
        
        --Describe the test.
        describe("Test",function()
            it("state should be in progress", function()
                local expect = getfenv().expect
                expect(self.State).to.equal(NexusUnitTestingProject.TestState.InProgress)
                StateTestCompleted = true
            end)
            
            it("combined state should be in progress", function()
                local expect = getfenv().expect
                expect(self.CombinedState).to.equal(NexusUnitTestingProject.TestState.Failed)
                CombinedStateTestCompleted = true
            end)
        end)
    end
    
    function CuT:Teardown()
        TeardownRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    --Run the test and assert the states are correct.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Failed,"Test not passed.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertTrue(TestRun,"Test not ran.")
    UnitTest:AssertTrue(TeardownRun,"Teardown not ran.")
    UnitTest:AssertTrue(StateTestCompleted,"Test case not ran.")
    UnitTest:AssertFalse(CombinedStateTestCompleted,"Test case ran.")
end)

--[[
Tests the RunTest method with a failing TestEZ setup.
--]]
NexusUnitTesting:RegisterUnitTest("RunTestTestEZFailedSetup",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Set up the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    function CuT:Setup()
        SetupRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Run()
        TestRun = true
        
        --Get the TestEZ methods from the environment to prevent Script Analysis from showing problems.
        local describe = getfenv().describe
        local it = getfenv().it
        
        --Describe the test.
        describe("Test",function()
            error("Fake error")
        end)
    end
    
    function CuT:Teardown()
        TeardownRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    --Run the test and assert the states are correct.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Failed,"Test not passed.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertTrue(TestRun,"Test not ran.")
    UnitTest:AssertTrue(TeardownRun,"Teardown not ran.")
end)

--[[
Tests the RunTest method with a skipping TestEZ setup.
--]]
NexusUnitTesting:RegisterUnitTest("RunTestTestEZSkippedSetup",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Set up the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    local StateTestCompleted,CombinedStateTestCompleted = false,false
    function CuT:Setup()
        SetupRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Run()
        TestRun = true
        
        --Get the TestEZ methods from the environment to prevent Script Analysis from showing problems.
        local describe = getfenv().describe
        local SKIP = getfenv().SKIP
        local it = getfenv().it
        
        --Describe the test.
        describe("Test",function()
            SKIP()
            
            it("state should be in progress", function()
                local expect = getfenv().expect
                expect(self.State).to.equal(NexusUnitTestingProject.TestState.InProgress)
                StateTestCompleted = true
            end)
            
            it("combined state should be in progress", function()
                local expect = getfenv().expect
                expect(self.CombinedState).to.equal(NexusUnitTestingProject.TestState.InProgress)
                CombinedStateTestCompleted = true
            end)
        end)
    end
    
    function CuT:Teardown()
        TeardownRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    --Run the test and assert the states are correct.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Skipped,"Test not passed.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertTrue(TestRun,"Test not ran.")
    UnitTest:AssertTrue(TeardownRun,"Teardown not ran.")
    UnitTest:AssertFalse(StateTestCompleted,"Test case not ran.")
    UnitTest:AssertFalse(CombinedStateTestCompleted,"Test case ran.")
end)

--[[
Tests the RunTest method with a skipping TestEZ test.
--]]
NexusUnitTesting:RegisterUnitTest("RunTestTestEZSkippedTest",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Set up the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    local StateTestCompleted,CombinedStateTestCompleted = false,false
    function CuT:Setup()
        SetupRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Run()
        TestRun = true
        
        --Get the TestEZ methods from the environment to prevent Script Analysis from showing problems.
        local describe = getfenv().describe
        local it = getfenv().it
        local xit = getfenv().xit
        
        --Describe the test.
        describe("Test",function()
            xit("state should be in progress", function()
                local expect = getfenv().expect
                expect(self.State).to.equal(NexusUnitTestingProject.TestState.InProgress)
                StateTestCompleted = true
            end)
            
            it("combined state should be in progress", function()
                local expect = getfenv().expect
                expect(self.CombinedState).to.equal(NexusUnitTestingProject.TestState.InProgress)
                CombinedStateTestCompleted = true
            end)
        end)
    end
    
    function CuT:Teardown()
        TeardownRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    --Run the test and assert the states are correct.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Skipped,"Test not passed.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertTrue(TestRun,"Test not ran.")
    UnitTest:AssertTrue(TeardownRun,"Teardown not ran.")
    UnitTest:AssertFalse(StateTestCompleted,"Test case not ran.")
    UnitTest:AssertTrue(CombinedStateTestCompleted,"Test case ran.")
end)

--[[
Tests the chain setters.
--]]
NexusUnitTesting:RegisterUnitTest("ChainedSetters",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Create the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    local function Setup(CuT)
        SetupRun = true
        UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(getfenv().TestOverride,4)
    end
    
    local function Run(CuT)
        TestRun = true
        UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(getfenv().TestOverride,4)
    end
    
    local function Teardown(CuT)
        TeardownRun = true
        UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(getfenv().TestOverride,4)
    end
    
    --Set the test and assert it runs correctly.
    CuT:SetSetup(Setup):SetRun(Run):SetTeardown(Teardown):SetEnvironmentOverride("TestOverride",4)
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertTrue(TestRun,"Test not ran.")
    UnitTest:AssertTrue(TeardownRun,"Teardown not ran.")
end)

--[[
Tests the RegisterUnitTest method with a string and method input.
--]]
NexusUnitTesting:RegisterUnitTest("RegisterUnitTestUnitTestInput",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Register the unit test and assert the test is correct.
    CuT:RegisterUnitTest("TestName2",function() end)
    UnitTest:AssertEquals(CuT.SubTests[1].Name,"TestName2")
end)

--[[
Tests the RegisterUnitTest method with a UnitTest input.
--]]
NexusUnitTesting:RegisterUnitTest("RegisterUnitTestStringInput",function(UnitTest)
    --Create the component under testing.
    local CuT1 = UnitTestClass.new("TestName")
    local CuT2 = UnitTestClass.new("TestName2")
    
    --Register the unit test and assert the test is correct.
    CuT1:RegisterUnitTest(CuT2)
    UnitTest:AssertEquals(CuT1.SubTests[1].Name,"TestName2")
end)

--[[
Tests the UpdateCombinedState method.
--]]
NexusUnitTesting:RegisterUnitTest("UpdateCombinedState",function(UnitTest)
    --Create the component under testing.
    local CuT1 = UnitTestClass.new("TestName")
    local CuT2 = UnitTestClass.new("TestName")
    local CuT3 = UnitTestClass.new("TestName")
    CuT1:RegisterUnitTest(CuT2)
    CuT1:RegisterUnitTest(CuT3)
    
    --Set the state and assert it was updated.
    CuT1.State = NexusUnitTestingProject.TestState.Passed
    UnitTest:AssertEquals(CuT1.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test state not changed.")
    
    --Update a subtest and assert the combined state is correct.
    CuT2.State = NexusUnitTestingProject.TestState.InProgress
    CuT1:UpdateCombinedState()
    UnitTest:AssertEquals(CuT1.CombinedState,NexusUnitTestingProject.TestState.InProgress,"Test state not changed.")
    
    --Update a subtest and assert the combined state is correct.
    CuT3.State = NexusUnitTestingProject.TestState.Passed
    CuT1:UpdateCombinedState()
    UnitTest:AssertEquals(CuT1.CombinedState,NexusUnitTestingProject.TestState.InProgress,"Test state not changed.")
    
    --Update a subtest and assert the combined state is correct.
    CuT2.State = NexusUnitTestingProject.TestState.Failed
    CuT1:UpdateCombinedState()
    UnitTest:AssertEquals(CuT1.CombinedState,NexusUnitTestingProject.TestState.Failed,"Test state not changed.")
end)

--[[
Tests the RunSubtests method without a failure.
--]]
NexusUnitTesting:RegisterUnitTest("RunSubtestsNoFailure",function(UnitTest)
    --Create the component under testing.
    local CuT1 = UnitTestClass.new("TestName1")
    local CuT2 = UnitTestClass.new("TestName2"):SetSetup(function() UnitTest:AssertEquals(CuT1.CombinedState,NexusUnitTestingProject.TestState.InProgress) end)
    local CuT3 = UnitTestClass.new("TestName3"):SetSetup(function() UnitTest:AssertEquals(CuT1.CombinedState,NexusUnitTestingProject.TestState.InProgress) end)
    CuT1:RegisterUnitTest(CuT2)
    CuT2:RegisterUnitTest(CuT3)
    
    --Run the subtests and assert the state is correct.
    CuT1.State = NexusUnitTestingProject.TestState.Passed
    UnitTest:AssertEquals(CuT1.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test state not correct.")
    CuT1:RunSubtests()
    UnitTest:AssertEquals(CuT1.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test state not correct.")
    UnitTest:AssertEquals(CuT2.State,NexusUnitTestingProject.TestState.Passed,"Test state not correct.")
    UnitTest:AssertEquals(CuT2.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test state not correct.")
    UnitTest:AssertEquals(CuT3.State,NexusUnitTestingProject.TestState.Passed,"Test state not correct.")
    UnitTest:AssertEquals(CuT3.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test state not correct.")
end)

--[[
Tests the RunSubtests method with a failure.
--]]
NexusUnitTesting:RegisterUnitTest("RunSubtestsWithFailure",function(UnitTest)
    --Create the component under testing.
    local CuT1 = UnitTestClass.new("TestName1")
    local CuT2 = UnitTestClass.new("TestName2"):SetSetup(function() UnitTest:AssertEquals(CuT1.CombinedState,NexusUnitTestingProject.TestState.InProgress) error("Test failure") end)
    local CuT3 = UnitTestClass.new("TestName3"):SetSetup(function() UnitTest:AssertEquals(CuT1.CombinedState,NexusUnitTestingProject.TestState.InProgress) end)
    CuT1:RegisterUnitTest(CuT2)
    CuT2:RegisterUnitTest(CuT3)
    
    --Run the subtests and assert the state is correct.
    CuT1.State = NexusUnitTestingProject.TestState.Passed
    UnitTest:AssertEquals(CuT1.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test state not correct.")
    CuT1:RunSubtests()
    UnitTest:AssertEquals(CuT1.CombinedState,NexusUnitTestingProject.TestState.Failed,"Test state not correct.")
    UnitTest:AssertEquals(CuT2.State,NexusUnitTestingProject.TestState.Failed,"Test state not correct.")
    UnitTest:AssertEquals(CuT2.CombinedState,NexusUnitTestingProject.TestState.Failed,"Test state not correct.")
    UnitTest:AssertEquals(CuT3.State,NexusUnitTestingProject.TestState.Passed,"Test state not correct.")
    UnitTest:AssertEquals(CuT3.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test state not correct.")
end)


--[[
Tests the output with a function with the parent environment.
--]]
NexusUnitTesting:RegisterUnitTest("OutputMessageUsingStack", function(UnitTest)
    --Create the test.
    local OutputInformation = {}
    local CuT = UnitTestClass.new("TestName"):SetRun(function(UnitTest)
        local function Test()
            print("Test")
            warn("Test")
        end

        local SubTest = UnitTestClass.new("TestName2")
        SubTest.MessageOutputted:Connect(function(Message, Type)
            table.insert(OutputInformation, {Message, Type})
        end)
        UnitTest:RegisterUnitTest(SubTest:SetRun(function(UnitTest)
            Test()
        end))
    end)

    --Run the test and assert the output is correct.
    CuT:RunTest()
    CuT:RunSubtests()
    UnitTest:AssertEquals(OutputInformation[1][1], "Test")
    UnitTest:AssertEquals(OutputInformation[1][2], Enum.MessageType.MessageOutput)
    UnitTest:AssertEquals(OutputInformation[2][1], "Test")
    UnitTest:AssertEquals(OutputInformation[2][2], Enum.MessageType.MessageWarning)
    UnitTest:AssertNil(OutputInformation[3], "Too many messages were outputted.")
end)
--[[
Tests the require method in tests.
--]]
NexusUnitTesting:RegisterUnitTest("require",function(UnitTest)
    --Create the modules.
    local Folder = Instance.new("Folder")
    Folder.Name = "TestFolder"
    local Module1 = Instance.new("ModuleScript")
    Module1.Name = "Module1"
    Module1.Source = "return script:GetFullName()"
    Module1.Parent = Folder
    local Module2 = Instance.new("ModuleScript")
    Module2.Name = "Module2"
    Module2.Source = "return function() return require(script.Parent.Module1) end"
    Module2.Parent = Folder
    
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    CuT:SetSetup(function()
        UnitTest:AssertEquals(require(Module1),"TestFolder.Module1")
    end)
    
    --Run the test and assert it runs.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
end)

--[[
Tests the Pass method in Setup.
--]]
NexusUnitTesting:RegisterUnitTest("PassInSetup",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Set up the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    function CuT:Setup()
        SetupRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
        self:Pass()
        error("Test continued")
    end
    
    function CuT:Run()
        TestRun = true
    end
    
    function CuT:Teardown()
        TeardownRun = true
    end
    
    --Run the test and assert the states are correct.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertFalse(TestRun,"Test ran.")
    UnitTest:AssertFalse(TeardownRun,"Teardown ran.")
end)

--[[
Tests the Pass method in Run.
--]]
NexusUnitTesting:RegisterUnitTest("PassInRun",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Set up the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    function CuT:Setup()
        SetupRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Run()
        TestRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
        self:Pass()
        error("Test continued")
    end
    
    function CuT:Teardown()
        TeardownRun = true
    end
    
    --Run the test and assert the states are correct.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertTrue(TestRun,"Test not ran.")
    UnitTest:AssertTrue(TeardownRun,"Teardown not ran.")
end)

--[[
Tests the Pass method in Run.
--]]
NexusUnitTesting:RegisterUnitTest("PassInTeardown",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Set up the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    function CuT:Setup()
        SetupRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Run()
        TestRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Teardown()
        TeardownRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
        self:Pass()
        error("Test continued")
    end
    
    --Run the test and assert the states are correct.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertTrue(TestRun,"Test not ran.")
    UnitTest:AssertTrue(TeardownRun,"Teardown not ran.")
end)

--[[
Tests the Fail method in Setup.
--]]
NexusUnitTesting:RegisterUnitTest("FailInSetup",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Set up the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    function CuT:Setup()
        SetupRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
        self:Fail("Fake test failure")
    end
    
    function CuT:Run()
        TestRun = true
    end
    
    function CuT:Teardown()
        TeardownRun = true
    end
    
    --Run the test and assert the states are correct.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Failed,"Test not failed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Failed,"Test not failed.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertFalse(TestRun,"Test ran.")
    UnitTest:AssertFalse(TeardownRun,"Teardown ran.")
end)

--[[
Tests the Fail method in Run.
--]]
NexusUnitTesting:RegisterUnitTest("FailInRun",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Set up the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    function CuT:Setup()
        SetupRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Run()
        TestRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
        self:Fail("Fake test failure")
    end
    
    function CuT:Teardown()
        TeardownRun = true
    end
    
    --Run the test and assert the states are correct.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Failed,"Test not failed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Failed,"Test not failed.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertTrue(TestRun,"Test not ran.")
    UnitTest:AssertTrue(TeardownRun,"Teardown not ran.")
end)

--[[
Tests the Fail method in Run.
--]]
NexusUnitTesting:RegisterUnitTest("FailInTeardown",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Set up the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    function CuT:Setup()
        SetupRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Run()
        TestRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Teardown()
        TeardownRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
        self:Fail("Fake test failure")
    end
    
    --Run the test and assert the states are correct.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Failed,"Test not failed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Failed,"Test not failed.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertTrue(TestRun,"Test not ran.")
    UnitTest:AssertTrue(TeardownRun,"Teardown not ran.")
end)

--[[
Tests the Skip method in Setup.
--]]
NexusUnitTesting:RegisterUnitTest("SkipInSetup",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Set up the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    function CuT:Setup()
        SetupRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
        self:Skip()
        error("Test continued")
    end
    
    function CuT:Run()
        TestRun = true
    end
    
    function CuT:Teardown()
        TeardownRun = true
    end
    
    --Run the test and assert the states are correct.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Skipped,"Test not skipped.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Skipped,"Test not skipped.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertFalse(TestRun,"Test ran.")
    UnitTest:AssertFalse(TeardownRun,"Teardown ran.")
end)

--[[
Tests the Skip method in Run.
--]]
NexusUnitTesting:RegisterUnitTest("SkipInRun",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Set up the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    function CuT:Setup()
        SetupRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Run()
        TestRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
        self:Skip()
        error("Test continued")
    end
    
    function CuT:Teardown()
        TeardownRun = true
    end
    
    --Run the test and assert the states are correct.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Skipped,"Test not skipped.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Skipped,"Test not skipped.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertTrue(TestRun,"Test not ran.")
    UnitTest:AssertTrue(TeardownRun,"Teardown not ran.")
end)

--[[
Tests the Skip method in Run.
--]]
NexusUnitTesting:RegisterUnitTest("SkipInTeardown",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Set up the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    function CuT:Setup()
        SetupRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Run()
        TestRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Teardown()
        TeardownRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
        self:Skip()
        error("Test continued")
    end
    
    --Run the test and assert the states are correct.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Skipped,"Test not skipped.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Skipped,"Test not skipped.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertTrue(TestRun,"Test not ran.")
    UnitTest:AssertTrue(TeardownRun,"Teardown not ran.")
end)

--[[
Tests the Fail after calling Skip.
--]]
NexusUnitTesting:RegisterUnitTest("FailAfterSkip",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    
    --Set up the methods.
    local SetupRun,TestRun,TeardownRun = false,false,false
    function CuT:Setup()
        SetupRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
    end
    
    function CuT:Run()
        TestRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.InProgress)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.InProgress)
        
        task.spawn(function()
            self:Skip()
        end)
        
        wait()
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.Skipped)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.Skipped)
        self:Fail()
    end
    
    function CuT:Teardown()
        TeardownRun = true
        UnitTest:AssertEquals(self.State,NexusUnitTestingProject.TestState.Skipped)
        UnitTest:AssertEquals(self.CombinedState,NexusUnitTestingProject.TestState.Skipped)
    end
    
    --Run the test and assert the states are correct.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Skipped,"Test not skipped.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Skipped,"Test not skipped.")
    UnitTest:AssertTrue(SetupRun,"Setup not ran.")
    UnitTest:AssertTrue(TestRun,"Test not ran.")
    UnitTest:AssertTrue(TeardownRun,"Teardown not ran.")
end)

--[[
Tests the AssertEquals method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertEquals",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    CuT:SetSetup(function(UnitTest)
        UnitTest:AssertEquals(true,true,"Bools aren't equal.")
        UnitTest:AssertEquals(0,0,"Integers aren't equal.")
        UnitTest:AssertEquals({1,2,3},{1,2,3},"Same tables aren't equal.")
        UnitTest:AssertEquals({1,Test="",2,3},{1,2,3,Test=""},"Same tables aren't equal.")
    end)
    
    --Run the test and assert it passes.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
end)

--[[
Tests the AssertNotEquals method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertNotEquals",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    CuT:SetSetup(function(UnitTest)
        UnitTest:AssertNotEquals(0.333,1/3,"Doubles are equal.")
        UnitTest:AssertNotEquals(false,true,"Bools are equal.")
        UnitTest:AssertNotEquals({1,Test="",2,3},{1,2,Test=""},"Tables are equal.")
    end)
    
    --Run the test and assert it passes.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
end)

--[[
Tests the AssertSame method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertSame",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    CuT:SetSetup(function(UnitTest)
        local Table = {}
        
        UnitTest:AssertSame(true,true,"Bools aren't the same.")
        UnitTest:AssertSame(0,0,"Integers aren't the same.")
        UnitTest:AssertSame(Table,Table,"Same tables aren't the same.")
    end)
    
    --Run the test and assert it passes.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
end)

--[[
Tests the AssertNotSame method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertNotSame",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    CuT:SetSetup(function(UnitTest)
        UnitTest:AssertNotSame(true,false,"Bools are the same.")
        UnitTest:AssertNotSame(0,0.1,"Integers are the same.")
        UnitTest:AssertNotSame({},{},"Tables are the same.")
    end)
    
    --Run the test and assert it passes.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
end)

--[[
Tests the AssertClose method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertClose",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    CuT:SetSetup(function(UnitTest)
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
    
    --Run the test and assert it passes.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
end)

--[[
Tests the AssertNotClose method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertNotClose",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    CuT:SetSetup(function(UnitTest)
        UnitTest:AssertNotClose(0.333,2/3,"Doubles are close.")
        UnitTest:AssertNotClose(CFrame.new(1,2,3),CFrame.new(1,3,3),"CFrames are close.")
        UnitTest:AssertNotClose(Color3.new(0.333,0.666,0.999),Color3.new(2/3,2/3,3/3),"Color3s are close.")
    end)
    
    --Run the test and assert it passes.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
end)

--[[
Tests the AssertFalse method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertFalse",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    CuT:SetSetup(function(UnitTest)
        UnitTest:AssertFalse(false)
    end)
    
    --Run the test and assert it passes.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
end)

--[[
Tests the AssertTrue method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertTrue",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    CuT:SetSetup(function(UnitTest)
        UnitTest:AssertTrue(true)
    end)
    
    --Run the test and assert it passes.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
end)

--[[
Tests the AssertNil method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertNil",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    CuT:SetSetup(function(UnitTest)
        UnitTest:AssertNil(nil)
    end)
    
    --Run the test and assert it passes.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
end)

--[[
Tests the AssertNotNil method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertNotNil",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    CuT:SetSetup(function(UnitTest)
        UnitTest:AssertNotNil(true)
    end)
    
    --Run the test and assert it passes.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
end)

--[[
Tests the AssertErrors method.
--]]
NexusUnitTesting:RegisterUnitTest("AssertErrors",function(UnitTest)
    --Create the component under testing.
    local CuT = UnitTestClass.new("TestName")
    CuT:SetSetup(function(UnitTest)
        UnitTest:AssertErrors(function() error("Test error") end):Contains("Test"):Contains("error"):NotContains("something else"):NotEquals("something else")
    end)
    
    --Run the test and assert it passes.
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.NotRun,"Test initially not run.")
    CuT:RunTest()
    UnitTest:AssertEquals(CuT.State,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
    UnitTest:AssertEquals(CuT.CombinedState,NexusUnitTestingProject.TestState.Passed,"Test not passed.")
end)



return true