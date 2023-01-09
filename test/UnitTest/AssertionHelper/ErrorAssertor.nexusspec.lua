--[[
TheNexusAvenger

Tests the ErrorAssertor class.
--]]

local NexusUnitTesting = require("NexusUnitTesting")

local ErrorAssertor = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusUnitTesting"):WaitForChild("UnitTest"):WaitForChild("AssertionHelper"):WaitForChild("ErrorAssertor"))



--[[
Tests the Contains method.
--]]
NexusUnitTesting:RegisterUnitTest("Contains",function(UnitTest)
    --Create the component under testing.
    local CuT = ErrorAssertor.new("Test error")
    
    --Assert the error contains correctly.
    CuT:Contains("Test"):Contains("error"):Contains("Test error")
    UnitTest:AssertErrors(function()
        CuT:Contains("TEST")
    end)
    UnitTest:AssertErrors(function()
        CuT:Contains("something else")
    end)
end)

--[[
Tests the NotContains method.
--]]
NexusUnitTesting:RegisterUnitTest("NotContains",function(UnitTest)
    --Create the component under testing.
    local CuT = ErrorAssertor.new("Test error")
    
    --Assert the error contains correctly.
    CuT:NotContains("TEST"):NotContains("something else")
    UnitTest:AssertErrors(function()
        CuT:NotContains("Test")
    end)
    UnitTest:AssertErrors(function()
        CuT:NotContains("error")
    end)
    UnitTest:AssertErrors(function()
        CuT:NotContains("Test error")
    end)
end)

--[[
Tests the Equals method.
--]]
NexusUnitTesting:RegisterUnitTest("Equals",function(UnitTest)
    --Create the component under testing.
    local CuT = ErrorAssertor.new("Test error")
    
    --Assert the error contains correctly.
    CuT:Equals("Test error")
    UnitTest:AssertErrors(function()
        CuT:Equals("Test")
    end)
    UnitTest:AssertErrors(function()
        CuT:Equals("something else")
    end)
end)


--[[
Tests the NotEquals method.
--]]
NexusUnitTesting:RegisterUnitTest("NotEquals",function(UnitTest)
    --Create the component under testing.
    local CuT = ErrorAssertor.new("Test error")
    
    --Assert the error contains correctly.
    CuT:NotEquals("Test"):NotEquals("something else")
    UnitTest:AssertErrors(function()
        CuT:NotEquals("Test error")
    end)
end)



return true