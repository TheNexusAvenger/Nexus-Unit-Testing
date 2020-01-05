--[[
TheNexusAvenger

Static methods for running unit tests.
--]]

local NexusUnitTesting = require(script.Parent.Parent:WaitForChild("NexusUnitTestingProject"))
local NexusInstance = NexusUnitTesting:GetResource("NexusInstance.NexusInstance")
local ModuleUnitTest = NexusUnitTesting:GetResource("Runtime.ModuleUnitTest")

local Runner = NexusInstance:Extend()
Runner:SetClassName("Runner")



--[[
Returns if the given source is a unit test.
--]]
function Runner.ScriptContainsTests(ScriptSource)
	--Get the require statements.
	local RemainingScript = ScriptSource
	while RemainingScript ~= "" do
		--Find the next require and breeak the loop if it doesn't exist.
		local NextRequire = string.find(RemainingScript,"require%(")
		if not NextRequire then
			break
		end
		
		--Read the script until the end is reached.
		RemainingScript = string.sub(RemainingScript,NextRequire + 8)
		local CurrentParentheses = 1
		local CurrentQuote
		local CurrentRequire = "require("
		while RemainingScript ~= "" do
			local NextCharacter = string.sub(RemainingScript,1,1)
			CurrentRequire = CurrentRequire..NextCharacter
			RemainingScript = string.sub(RemainingScript,2)
			
			--Handle the next character.
			if not CurrentQuote then
				if NextCharacter == "(" then
					CurrentParentheses = CurrentParentheses + 1
				elseif NextCharacter == ")" then
					CurrentParentheses = CurrentParentheses - 1
				elseif NextCharacter == "'" or NextCharacter == "\"" then
					CurrentQuote = NextCharacter
				end
			elseif NextCharacter == CurrentQuote then
				CurrentQuote = nil
			end
			
			--Break the loop if the end was reached.
			if CurrentParentheses == 0 then
				break
			end
		end
		
		--Return true if the requrie contains NexusUnitTesting.
		if string.find(CurrentRequire,"[^%w]NexusUnitTesting[^%w]") then
			return true
		end
	end
	
	--Return false (not a unit test).
	return false
end

--[[
Returns a list of tests for all of the
ModuleScripts in the game or the given
container instance.
--]]
function Runner.GetTests(Container)
	Container = Container or game
	
	--Get all the tests in the game.
	local Tests = {}
	for _,Module in pairs(Container:GetDescendants()) do
		pcall(function()
			if Module:IsA("ModuleScript") and (Module.Name:match("%.spec$") or Runner.ScriptContainsTests(Module.Source)) then
				table.insert(Tests,ModuleUnitTest.new(Module))
			end
		end)
	end
	
	--Return the tests.
	return Tests
end



return Runner