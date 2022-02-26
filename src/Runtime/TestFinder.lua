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
            if Module:IsA("ModuleScript") and (Module.Name:match("%.spec$") or Module.Name:match("%.nexusspec$")) then
                table.insert(Tests,ModuleUnitTest.new(Module))
            end
        end)
    end

    --Return the tests.
    return Tests
end



return Runner