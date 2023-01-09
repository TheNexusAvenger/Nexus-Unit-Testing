--[[
TheNexusAvenger

Tests the ErrorAssertor class.
--]]
--!strict

local ErrorAssertor = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusUnitTesting"):WaitForChild("UnitTest"):WaitForChild("AssertionHelper"):WaitForChild("ErrorAssertor"))

return function()
    local TestErrorAssertor = nil
    beforeEach(function()
        TestErrorAssertor = ErrorAssertor.new("Test error")
    end)

    describe("An error assertor", function()
        it("should work with Contains.", function()
            TestErrorAssertor:Contains("error"):Contains("Test error")
            expect(function()
                TestErrorAssertor:Contains("TEST")
            end).to.throw()
            expect(function()
                TestErrorAssertor:Contains("something else")
            end).to.throw()
        end)

        it("should work with NotContains.", function()
            TestErrorAssertor:NotContains("something else")
            expect(function()
                TestErrorAssertor:NotContains("error")
            end).to.throw()
            expect(function()
                TestErrorAssertor:NotContains("Test error")
            end).to.throw()
        end)

        it("should work with Equals.", function()
            TestErrorAssertor:Equals("Test error")
            expect(function()
                TestErrorAssertor:Equals("Test")
            end).to.throw()
            expect(function()
                TestErrorAssertor:Equals("something else")
            end).to.throw()
        end)

        it("should work with NotEquals.", function()
            TestErrorAssertor:NotEquals("something else")
            expect(function()
                TestErrorAssertor:NotEquals("Test error")
            end).to.throw()
        end)
    end)
end