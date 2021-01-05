--[[
TheNexusAvenger

Base module for NexusUnitTesting.
--]]

local NexusUnitTesting = require(script:WaitForChild("NexusUnitTestingProject"))
local TestFinder = NexusUnitTesting:GetResource("Runtime.TestFinder")



--[[
Runs the tests for a given container,
or game if it isn't provided.
Not intended to be used by custom views for
unit tests since it doesn't provide visibility to the tests.
--]]
function NexusUnitTesting.RunTests(Container)
	--Get the tests.
	local Tests = TestFinder.GetTests(Container)
	local PassedTests,FailedTests,SkippedTests = {},{},{}
	
	--[[
	Runs the tests.
	--]]
	local function RunTest(Test,BaseName)
		--Connect the output.
		local MessageOutputtedEvent = Test.MessageOutputted:Connect(function(Message,Type)
			if Type == Enum.MessageType.MessageOutput then
				print("[MESSAGE]: "..tostring(Message))
			elseif Type == Enum.MessageType.MessageWarning then
				warn("[WARNING]: "..tostring(Message))
			elseif Type == Enum.MessageType.MessageError then
				warn("[ERROR]: "..tostring(Message))
			elseif Type == Enum.MessageType.MessageInfo then
				warn("[INFO]: "..tostring(Message))
			end
		end)

		--Run the test.
		local TestName = BaseName..Test.Name
		print("Running "..TestName)
		Test:RunTest()
		print("\t"..TestName.." "..Test.State)
		
		--Log the test state.
		if Test.State == NexusUnitTesting.TestState.Passed then
			table.insert(PassedTests,TestName)
		elseif Test.State == NexusUnitTesting.TestState.Failed then
			table.insert(FailedTests,TestName)
		elseif Test.State == NexusUnitTesting.TestState.Skipped then
			table.insert(SkippedTests,TestName)
		end

		--Disconnect the output.
		MessageOutputtedEvent:Disconnect()

		--Run the subtests.
		for _,SubTest in pairs(Test.SubTests) do
			RunTest(SubTest,TestName.." > ")
		end
	end
	
	--Run the tests.
	for _,Test in pairs(Tests) do
		RunTest(Test,"")
	end
	
	--Print the skipped and failed tests.
	print("")
	if #SkippedTests ~= 0 then
		print("Skipped tests:")
		for _,TestName in pairs(SkippedTests) do
			print("\t"..TestName)
		end
	end
	if #FailedTests ~= 0 then
		print("Failed tests:")
		for _,TestName in pairs(FailedTests) do
			print("\t"..TestName)
		end
	end
	
	--Print the totals.
	print(tostring(#PassedTests).." passed, "..tostring(#FailedTests).." failed, "..tostring(#SkippedTests).." skipped")
end



return NexusUnitTesting