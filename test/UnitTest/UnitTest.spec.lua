--[[
TheNexusAvenger

Tests the UnitTest class.
--]]
--!strict

local UnitTest = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusUnitTesting"):WaitForChild("UnitTest"):WaitForChild("UnitTest"))

return function()
    local TestUnitTest = nil
    beforeEach(function()
        TestUnitTest = UnitTest.new("TestName")
    end)

    describe("A unit test", function()
        it("should output messages.", function()
            local OutputInformation = {}
            TestUnitTest.MessageOutputted:Connect(function(Message, Type)
                table.insert(OutputInformation, {Message = Message, Type = Type})
            end)

            TestUnitTest:OutputMessage(Enum.MessageType.MessageOutput, "Test message")
            TestUnitTest:OutputMessage(Enum.MessageType.MessageOutput, nil)
            TestUnitTest:OutputMessage(Enum.MessageType.MessageWarning, 1, 2, nil, 4)
            TestUnitTest:OutputMessage(Enum.MessageType.MessageWarning, 1, 2, nil)
            task.wait()
            expect(#OutputInformation).to.equal(4)
            expect(OutputInformation[1].Message).to.equal("Test message")
            expect(OutputInformation[1].Type).to.equal(Enum.MessageType.MessageOutput)
            expect(OutputInformation[2].Message).to.equal("nil")
            expect(OutputInformation[2].Type).to.equal(Enum.MessageType.MessageOutput)
            expect(OutputInformation[3].Message).to.equal("1 2 nil 4")
            expect(OutputInformation[3].Type).to.equal(Enum.MessageType.MessageWarning)
            expect(OutputInformation[4].Message).to.equal("1 2 nil")
            expect(OutputInformation[4].Type).to.equal(Enum.MessageType.MessageWarning)
            expect(#TestUnitTest.Output).to.equal(4)

            local Output = (TestUnitTest.Output :: {any})
            expect(Output[1].Message).to.equal("Test message")
            expect(Output[1].Type).to.equal(Enum.MessageType.MessageOutput)
            expect(Output[2].Message).to.equal("nil")
            expect(Output[2].Type).to.equal(Enum.MessageType.MessageOutput)
            expect(Output[3].Message).to.equal("1 2 nil 4")
            expect(Output[3].Type).to.equal(Enum.MessageType.MessageWarning)
            expect(Output[4].Message).to.equal("1 2 nil")
            expect(Output[4].Type).to.equal(Enum.MessageType.MessageWarning)
        end)

        it("should wrap environments.", function()
            local OutputInformation = {}
            TestUnitTest.MessageOutputted:Connect(function(Message, Type)
                table.insert(OutputInformation, {Message = Message, Type = Type})
            end)

            --Create and wrap a custom method.
            local function TestMethod()
                print("Test call")
                warn("Test call 1", "Test call 2", nil)
            end
            TestUnitTest:WrapEnvironment(TestMethod)
            
            --Assert the calls were correct.
            TestMethod()
            task.wait()
            expect(#OutputInformation).to.equal(2)
            expect(OutputInformation[1].Message).to.equal("Test call")
            expect(OutputInformation[1].Type).to.equal(Enum.MessageType.MessageOutput)
            expect(OutputInformation[2].Message).to.equal("Test call 1 Test call 2 nil")
            expect(OutputInformation[2].Type).to.equal(Enum.MessageType.MessageWarning)
        end)

        it("should run tests with no errors.", function()
            --Set up the methods.
            local TestRun = false
            function TestUnitTest:Run()
                TestRun = true
                expect(TestUnitTest.State).to.equal("INPROGRESS")
                expect(TestUnitTest.CombinedState).to.equal("INPROGRESS")
            end
            
            --Run the test and assert the states are correct.
            expect(TestUnitTest.State).to.equal("NOTRUN")
            expect(TestUnitTest.CombinedState).to.equal("NOTRUN")
            TestUnitTest:RunTest()
            expect(TestUnitTest.State).to.equal("PASSED")
            expect(TestUnitTest.CombinedState).to.equal("PASSED")
            expect(TestRun).to.equal(true)
        end)

        it("should show an error when a test fails.", function()
            --Set up the methods.
            local TestRun = false
            function TestUnitTest:Run()
                TestRun = true
                expect(TestUnitTest.State).to.equal("INPROGRESS")
                expect(TestUnitTest.CombinedState).to.equal("INPROGRESS")
                error("Fake test error")
            end
    
            --Run the test and assert the states are correct.
            expect(TestUnitTest.State).to.equal("NOTRUN")
            expect(TestUnitTest.CombinedState).to.equal("NOTRUN")
            TestUnitTest:RunTest()
            expect(TestUnitTest.State).to.equal("FAILED")
            expect(TestUnitTest.CombinedState).to.equal("FAILED")
            expect(TestRun).to.equal(true)
        end)

        it("should register subtests with test classes.", function()
            TestUnitTest:RegisterUnitTest(UnitTest.new("TestName2"))
            expect((TestUnitTest.SubTests :: any)[1].Name).to.equal("TestName2")
        end)

        it("should update the combined state correctly.", function()
            --Create additional tests.
            local UnitTest2 = UnitTest.new("TestName")
            local UnitTest3 = UnitTest.new("TestName")
            TestUnitTest:RegisterUnitTest(UnitTest2)
            TestUnitTest:RegisterUnitTest(UnitTest3)
            
            --Set the state and assert it was updated.
            TestUnitTest.State = "PASSED" :: any
            expect(TestUnitTest.CombinedState).to.equal("PASSED")
            
            --Update a subtest and assert the combined state is correct.
            UnitTest2.State = "INPROGRESS" :: any
            TestUnitTest:UpdateCombinedState()
            expect(TestUnitTest.CombinedState).to.equal("INPROGRESS")
            
            --Update a subtest and assert the combined state is correct.
            UnitTest3.State = "PASSED" :: any
            TestUnitTest:UpdateCombinedState()
            expect(TestUnitTest.CombinedState).to.equal("INPROGRESS")
            
            --Update a subtest and assert the combined state is correct.
            UnitTest2.State = "FAILED" :: any
            TestUnitTest:UpdateCombinedState()
            expect(TestUnitTest.CombinedState).to.equal("FAILED")
        end)

        it("should run subtests with no failures.", function()
            --Create additional tests.
            local UnitTest2 = UnitTest.new("TestName")
            local UnitTest3 = UnitTest.new("TestName")
            TestUnitTest:RegisterUnitTest(UnitTest2)
            TestUnitTest:RegisterUnitTest(UnitTest3)

            --Run the subtests and assert the state is correct.
            TestUnitTest.State = ("PASSED" :: any)
            UnitTest2:RunTest()
            UnitTest3:RunTest()
            expect(TestUnitTest.CombinedState).to.equal("PASSED")
            expect(TestUnitTest.CombinedState).to.equal("PASSED")
            expect(UnitTest2.State).to.equal("PASSED")
            expect(UnitTest2.CombinedState).to.equal("PASSED")
            expect(UnitTest3.State).to.equal("PASSED")
            expect(UnitTest3.CombinedState).to.equal("PASSED")
        end)

        it("should run subtests with failures.", function()
            --Create additional tests.
            local UnitTest2 = UnitTest.new("TestName"):SetRun(function()
                expect(TestUnitTest.CombinedState).to.equal("INPROGRESS")
                error("Test failure")
            end)
            local UnitTest3 = UnitTest.new("TestName"):SetRun(function()
                expect(TestUnitTest.CombinedState).to.equal("INPROGRESS")
            end)
            TestUnitTest:RegisterUnitTest(UnitTest2)
            TestUnitTest:RegisterUnitTest(UnitTest3)
        
            --Run the subtests and assert the state is correct.
            TestUnitTest.State = ("PASSED" :: any)
            expect(TestUnitTest.CombinedState).to.equal("PASSED")
            UnitTest2:RunTest()
            UnitTest3:RunTest()
            expect(TestUnitTest.CombinedState).to.equal("FAILED")
            expect(UnitTest2.State).to.equal("FAILED")
            expect(UnitTest2.CombinedState).to.equal("FAILED")
            expect(UnitTest3.State).to.equal("PASSED")
            expect(UnitTest3.CombinedState).to.equal("PASSED")
        end)

        it("should output messages to the correct test based on the stack.", function()
            --Create the test.
            local OutputInformation = {}
            TestUnitTest:SetRun(function(self)
                local function Test()
                    print("Test")
                    warn("Test")
                end

                local SubTest = UnitTest.new("TestName2")
                SubTest.MessageOutputted:Connect(function(Message, Type)
                    table.insert(OutputInformation, {Message = Message, Type = Type})
                end)
                SubTest:SetRun(function(UnitTest)
                    Test()
                end)
                SubTest:RunTest()
            end)

            --Run the test and assert the output is correct.
            TestUnitTest:RunTest()
            task.wait()
            expect(#OutputInformation).to.equal(2)
            expect(OutputInformation[1].Message).to.equal("Test")
            expect(OutputInformation[1].Type).to.equal(Enum.MessageType.MessageOutput)
            expect(OutputInformation[2].Message).to.equal("Test")
            expect(OutputInformation[2].Type).to.equal(Enum.MessageType.MessageWarning)
        end)

        it("should require modules.", function()
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
            
            --Create the test.
            TestUnitTest:SetRun(function()
                expect(require(Module1) :: any).to.equal("TestFolder.Module1")
            end)
            
            --Run the test and assert it runs.
            expect(TestUnitTest.State).to.equal("NOTRUN")
            expect(TestUnitTest.CombinedState).to.equal("NOTRUN")
            TestUnitTest:RunTest()
            expect(TestUnitTest.State).to.equal("PASSED")
            expect(TestUnitTest.CombinedState).to.equal("PASSED")
        end)
    end)

    describe("A unit test with TestEZ", function()
        it("should run TestEZ tests.", function()
            --Set up the methods.
            local TestRun = false
            local StateTestCompleted, CombinedStateTestCompleted = false, false

            function TestUnitTest:Run()
                TestRun = true
                
                --Get the TestEZ methods from the environment to prevent Script Analysis from showing problems.
                local describe = getfenv().describe
                local it = getfenv().it
                
                --Describe the test.
                describe("Test",function()
                    it("state should be in progress", function()
                        local expect = getfenv().expect
                        expect(TestUnitTest.State).to.equal("INPROGRESS")
                        StateTestCompleted = true
                    end)
                    
                    it("combined state should be in progress", function()
                        local expect = getfenv().expect
                        expect(TestUnitTest.CombinedState).to.equal("INPROGRESS")
                        CombinedStateTestCompleted = true
                    end)
                end)
            end
            
            --Run the test and assert the states are correct.
            expect(TestUnitTest.State).to.equal("NOTRUN")
            expect(TestUnitTest.CombinedState).to.equal("NOTRUN")
            TestUnitTest:RunTest()
            expect(TestUnitTest.State).to.equal("PASSED")
            expect(TestUnitTest.CombinedState).to.equal("PASSED")
            expect(TestRun).to.equal(true)
            expect(StateTestCompleted).to.equal(true)
            expect(CombinedStateTestCompleted).to.equal(true)
        end)

        it("should show failed TestEZ subtests.", function()
            --Set up the methods.
            local TestRun = false
            local StateTestCompleted, CombinedStateTestCompleted = false, false
            function TestUnitTest:Run()
                TestRun = true
                
                --Get the TestEZ methods from the environment to prevent Script Analysis from showing problems.
                local describe = getfenv().describe
                local it = getfenv().it
                
                --Describe the test.
                describe("Test",function()
                    it("state should be in progress", function()
                        local expect = getfenv().expect
                        expect(TestUnitTest.State).to.equal("INPROGRESS")
                        StateTestCompleted = true
                    end)
                    
                    it("combined state should be in progress", function()
                        local expect = getfenv().expect
                        expect(TestUnitTest.CombinedState).to.equal("FAILED")
                        CombinedStateTestCompleted = true
                    end)
                end)
            end
            
            --Run the test and assert the states are correct.
            expect(TestUnitTest.State).to.equal("NOTRUN")
            expect(TestUnitTest.CombinedState).to.equal("NOTRUN")
            TestUnitTest:RunTest()
            expect(TestUnitTest.State).to.equal("PASSED")
            expect(TestUnitTest.CombinedState).to.equal("FAILED")
            expect(TestRun).to.equal(true)
            expect(StateTestCompleted).to.equal(true)
            expect(CombinedStateTestCompleted).to.equal(false)
        end)

        it("should show failed TestEZ setups.", function()
            --Set up the methods.
            local TestRun = false
            function TestUnitTest:Run()
                TestRun = true
                
                --Get the TestEZ methods from the environment to prevent Script Analysis from showing problems.
                local describe = getfenv().describe
                
                --Describe the test.
                describe("Test", function()
                    error("Fake error")
                end)
            end
            
            --Run the test and assert the states are correct.
            expect(TestUnitTest.State).to.equal("NOTRUN")
            expect(TestUnitTest.CombinedState).to.equal("NOTRUN")
            TestUnitTest:RunTest()
            expect(TestUnitTest.State).to.equal("PASSED")
            expect(TestUnitTest.CombinedState).to.equal("FAILED")
            expect(TestRun).to.equal(true)
        end)

        it("should show skipped TestEZ setups.", function()
            --Set up the methods.
            local TestRun = false
            local StateTestCompleted, CombinedStateTestCompleted = false,false
            function TestUnitTest:Run()
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
                        expect(TestUnitTest.State).to.equal("INPROGRESS")
                        StateTestCompleted = true
                    end)
                    
                    it("combined state should be in progress", function()
                        local expect = getfenv().expect
                        expect(TestUnitTest.CombinedState).to.equal("INPROGRESS")
                        CombinedStateTestCompleted = true
                    end)
                end)
            end
            
            --Run the test and assert the states are correct.
            expect(TestUnitTest.State).to.equal("NOTRUN")
            expect(TestUnitTest.CombinedState).to.equal("NOTRUN")
            TestUnitTest:RunTest()
            expect(TestUnitTest.State).to.equal("PASSED")
            expect(TestUnitTest.CombinedState).to.equal("SKIPPED")
            expect(TestRun).to.equal(true)
            expect(StateTestCompleted).to.equal(false)
            expect(CombinedStateTestCompleted).to.equal(false)
        end)

        it("should show skipped TestEZ tests.", function()
            --Set up the methods.
            local TestRun = false
            local StateTestCompleted,CombinedStateTestCompleted = false, false
            function TestUnitTest:Run()
                TestRun = true
                
                --Get the TestEZ methods from the environment to prevent Script Analysis from showing problems.
                local describe = getfenv().describe
                local it = getfenv().it
                local xit = getfenv().xit
                
                --Describe the test.
                describe("Test",function()
                    xit("state should be in progress", function()
                        local expect = getfenv().expect
                        expect(TestUnitTest.State).to.equal("INPROGRESS")
                        StateTestCompleted = true
                    end)
                    
                    it("combined state should be in progress", function()
                        local expect = getfenv().expect
                        expect(TestUnitTest.CombinedState).to.equal("INPROGRESS")
                        CombinedStateTestCompleted = true
                    end)
                end)
            end

            --Run the test and assert the states are correct.
            expect(TestUnitTest.State).to.equal("NOTRUN")
            expect(TestUnitTest.CombinedState).to.equal("NOTRUN")
            TestUnitTest:RunTest()
            expect(TestUnitTest.State).to.equal("PASSED")
            expect(TestUnitTest.CombinedState).to.equal("SKIPPED")
            expect(TestRun).to.equal(true)
            expect(StateTestCompleted).to.equal(false)
            expect(CombinedStateTestCompleted).to.equal(true)
        end)
    end)
end