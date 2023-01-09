--[[
TheNexusAvenger

Helper function for determining if two userdata objects are equal.
--]]
--!strict

--[[
Returns if two user data are equal.
--]]
local function Equals(Object1: any, Object2: any, PreviousCheckedValues: {[string]: {[string]: boolean}}?): boolean
    local CheckedValues = PreviousCheckedValues or {} :: {[string]: {[string]: boolean}}
    
    --[[
    Performs a cyclic check and returns
    if the equals method should continue.
    --]]
    local function PerformCyclicCheck(Value1: any, Value2: any): boolean
        --Return true if either value aren't tables.
        if type(Value1) ~= "table" or type(Value2) ~= "table" then
            return true
        end
        
        --Return false if either value was already checked.
        if (CheckedValues[Value1] and CheckedValues[Value1][Value2]) or (CheckedValues[Value2] and CheckedValues[Value2][Value1]) then
            return false
        end
        
        --Store the values and return true (continue).
        if not CheckedValues[Value1] then
            CheckedValues[Value1] = {}
        end
        CheckedValues[Value1][Value2] = true
        if not CheckedValues[Value2] then
            CheckedValues[Value2] = {}
        end
        CheckedValues[Value2][Value1] = true
        return true
    end
    
    --If it is a table, check the keys and values being the same.
    if type(Object1) == "table" and type(Object2) == "table" and Object1 ~= Object2 then
        --Check the tables.
        for Key,Value in Object1 do
            if PerformCyclicCheck(Value, Object2[Key]) then
                if not Equals(Value, Object2[Key], CheckedValues) then
                    return false
                end
            end
        end
        
        for Key,Value in Object2 do
            if PerformCyclicCheck(Value,Object1[Key]) then
                if not Equals(Value, Object1[Key], CheckedValues) then
                    return false
                end
            end
        end
        
        --Return true (all equal).
        return true
    end
    
    --Return equality (base case)
    return Object1 == Object2
end



return Equals