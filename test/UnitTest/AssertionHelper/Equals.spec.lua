--[[
TheNexusAvenger

Tests the Equals helper function.
--]]
--!strict

local Equals = require(game:GetService("ReplicatedStorage"):WaitForChild("NexusUnitTesting"):WaitForChild("UnitTest"):WaitForChild("AssertionHelper"):WaitForChild("Equals"))

return(function()
    describe("The equal helper method", function()
        it("should work with non-tables.", function()
            expect(Equals(Vector3.new(0, 0, 0), Vector3.new(0, 0, 0))).to.equal(true)
            expect(Equals(Vector3.new(1, 1, 1), Vector3.new(1, 1, 1))).to.equal(true)
            expect(Equals(Vector3.new(0, 0, 0), Vector3.new(0, 1, 0))).to.equal(false)
        end)

        it("should work with lists.", function()
            local List1 = {1, 1, 2, 3, 5, 8, 13}
            local List2 = {1, 1, 2, 3, 5, 8, 13}
            local List3 = {1, 1, 2, 3, 5, 8}

            expect(List1 == List2).to.equal(false)
            expect(Equals(List1, List2)).to.equal(true)
            expect(Equals(List1, List3)).to.equal(false)
            expect(Equals(List3, List1)).to.equal(false)
        end)

        it("should work with mixed tables.", function()
            local Table1 = {1, 1, 2, 3, Value1 = 5, 8, Value2 = 13}
            local Table2 = {1, 1, 2, 3, Value1 = 5, 8, Value2 = 13}
            local Table3 = {1, 1, Value1 = 2, 3, 5, 8, Value2 = 13}

            expect(Equals(Table1, Table2)).to.equal(true)
            expect(Equals(Table1, Table3)).to.equal(false)
        end)

        it("should work with deep tables.", function()
            local Table1 = {1, 1, {2, 3, Value3 = 5, {1, 2}} :: {[any]: any}, Value1 = 5, 8, Value2 = 13} :: {[any]: any}
            local Table2 = {1, 1, {2, 3, Value3 = 5, {1, 2}} :: {[any]: any}, Value1 = 5, 8, Value2 = 13} :: {[any]: any}
            local Table3 = {1, 1, {2, 3, Value3 = 5, {1}} :: {[any]: any}, Value1 = 5, 8, Value2 = 13} :: {[any]: any}
        
            expect(Equals(Table1, Table2)).to.equal(true)
            expect(Equals(Table1, Table3)).to.equal(false)
        end)

        it("should work with cyclic tables.", function()
            --Test with cyclic tables.
            local Table1 = {1, 1, {2, 3, Value3 = 5, {1, 2}} :: {[any]: any}, Value1=5, 8, Value2 = 13} :: {[any]: any}
            Table1.Value4 = Table1
            local Table2 = {1, 1, {2, 3, Value3 = 5, {1, 2}} :: {[any]: any}, Value1=5, 8, Value2 = 13} :: {[any]: any}
            Table2.Value4 = Table2
            local Table3 = {1, 1, {2, 3, Value3 = 5, {1}} :: {[any]: any}, Value1 = 5, 8, Value2 = 13} :: {[any]: any}
            Table3.Value4 = Table3

            expect(Equals(Table1, Table2)).to.equal(true)
            expect(Equals(Table1, Table3)).to.equal(false)

            --Test with different cyclic tables that "expand" to be identical.
            --From: https://github.com/TheNexusAvenger/Nexus-Unit-Testing/pull/5
            local Table4 = {0, {1, nil} :: {[any]: any}} :: {[any]: any}
            Table4[2][2] = Table4
            local Table5 = {0, {1, nil} :: {[any]: any}} :: {[any]: any}
            Table5[2][2] = Table5
            local Table6 = {0, {1, nil} :: {[any]: any}} :: {[any]: any}
            Table6[2][2] = Table6[2]

            expect(Equals(Table4, Table5)).to.equal(true)
            expect(Equals(Table4, Table6)).to.equal(false)

            --Test with identical tables that expand differently.
            --From: https://github.com/TheNexusAvenger/Nexus-Unit-Testing/pull/5
            local Table7 = {0, {0}} :: {[any]: any}
            local Table8 = {{0, {0}}  :: {[any]: any}} :: {[any]: any}
            local Table9 = {Table7} :: {[any]: any}
            local Table10 = {{0, Table7}  :: {[any]: any}} :: {[any]: any}

            expect(Equals(Table8, Table9)).to.equal(true)
            expect(Equals(Table8, Table10)).to.equal(false)
            expect(Equals(Table9, Table10)).to.equal(false)
        end)

        it("should work with cycle table with multiple entries.", function()
            --From: https://github.com/TheNexusAvenger/Nexus-Unit-Testing/pull/5
            local Table0 = {0}
            local Table1 = {{0}, {0}}
            local Table2 = {Table0, Table0}
            local Table3 = {{0}, {1}}

            expect(Equals(Table1, Table2)).to.equal(true)
            expect(Equals(Table1, Table3)).to.equal(false)
            expect(Equals(Table2, Table3)).to.equal(false)
        end)
    end)
end)