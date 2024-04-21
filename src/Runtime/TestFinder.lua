--[[
TheNexusAvenger

Static methods for running unit tests.
--]]
--!strict

local ModuleUnitTest = require(script.Parent.Parent:WaitForChild("Runtime"):WaitForChild("ModuleUnitTest"))

local TestFinder = {}



--[[
Returns a list of tests for all of the
ModuleScripts in the game or the given
container instance.
--]]
function TestFinder.GetTests(Container: Instance?)
    Container = Container or game

    --Get all the tests in the game.
    local Tests = {}
    for _, Module in (Container :: Instance):GetDescendants() do
        pcall(function()
            if Module:IsA("ModuleScript") and Module.Name:match("%.spec$") then
                table.insert(Tests, ModuleUnitTest.new(Module))
            end
        end)
    end

    --Return the tests.
    return Tests
end



return TestFinder