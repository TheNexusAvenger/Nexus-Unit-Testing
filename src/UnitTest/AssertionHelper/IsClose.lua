--[[
TheNexusAvenger

Helper function for determining if two userdata objects are close.
--]]
--!strict

local PROPERTY_TO_LIST = {
    Vector2 = function(Value: Vector2)
        return {Value.X, Value.Y}, {"X", "Y"}
    end,
    Vector3 = function(Value: Vector3)
        return {Value.X, Value.Y, Value.Z}, {"X", "Y", "Z"}
    end,
    CFrame = function(Value: CFrame)
        return {Value:GetComponents()}, {"X", "Y", "Z", "R00", "R01", "R02", "R10", "R11", "R12", "R20", "R21", "R22"}
    end,
    Ray = function(Value: Ray)
        return {Value.Origin.X, Value.Origin.Y, Value.Origin.Z, Value.Direction.X, Value.Direction.Y, Value.Direction.Z}, {"X0", "Y0", "Z0", "X1", "Y1", "Z1"}
    end,
    Region3 = function(Value: Region3)
        local Min, Max = Value.CFrame * -(Value.Size / 2), Value.CFrame * (Value.Size / 2)
        return {Min.X, Min.Y, Min.Z, Max.X, Max.Y, Max.Z}, {"MinX", "MinY", "MinZ", "MaxX", "MaxY", "MaxZ"}
    end,
    UDim = function(Value: UDim)
        return {Value.Scale, Value.Offset}, {"Scale", "Offset"}
    end,
    UDim2 = function(Value: UDim2)
        return {Value.X.Scale, Value.X.Offset, Value.Y.Scale, Value.Y.Offset}, {"XScale", "XOffset", "YScale", "YOffset"}
    end,
    Color3 = function(Value: Color3)
        return {Value.R, Value.G, Value.B}, {"R", "G", "B"}
    end,
    ColorSequence = function(Value: ColorSequence)
        local Values, Keys = {}, {}
        for i, Keypoint in Value.Keypoints do
            table.insert(Values, Keypoint.Time)
            table.insert(Values, Keypoint.Value.R)
            table.insert(Values, Keypoint.Value.G)
            table.insert(Values, Keypoint.Value.B)
            table.insert(Keys, "Time"..tostring(i - 1))
            table.insert(Keys, "R"..tostring(i - 1))
            table.insert(Keys, "G"..tostring(i - 1))
            table.insert(Keys, "B"..tostring(i - 1))
        end
        return Values, Keys
    end,
    ColorSequenceKeypoint = function(Value: ColorSequenceKeypoint)
        return {Value.Time, Value.Value.R, Value.Value.G, Value.Value.B}, {"Time", "R", "G", "B"} 
    end,
    NumberRange = function(Value: NumberRange)
        return {Value.Min, Value.Max}, {"Min", "Max"}
    end,
    NumberSequence = function(Value: NumberSequence)
        local Values, Keys = {}, {}
        for i, Keypoint in Value.Keypoints do
            table.insert(Values, Keypoint.Time)
            table.insert(Values, Keypoint.Value)
            table.insert(Values, Keypoint.Envelope)
            table.insert(Keys, "Time"..tostring(i - 1))
            table.insert(Keys, "Value"..tostring(i - 1))
            table.insert(Keys, "Envelope"..tostring(i - 1))
        end
        return Values, Keys
    end,
    NumberSequenceKeypoint = function(Value: NumberSequenceKeypoint)
        return {Value.Time, Value.Value, Value.Envelope}, {"Time", "Value", "Envelope"}
    end,
    Rect = function(Value: Rect)
        return {Value.Min.X, Value.Min.Y, Value.Max.X, Value.Max.Y}, {"MinX", "MinY", "MaxX", "MaxY"}
    end,
    PhysicalProperties = function(Value: PhysicalProperties)
        return {Value.Density, Value.Friction, Value.Elasticity, Value.FrictionWeight, Value.ElasticityWeight}, {"Density", "Friction", "Elasticity", "FrictionWeight", "ElasticityWeight"}
    end
} :: {[string]: (Value: any) -> ({number}, {string})}

local IsCloseModule = {}



--[[
Returns a string result for the match and an optional
list of keys that don't match based on if the values
are close.
--]]
function IsCloseModule.IsClose<T>(Object1: T, Object2: T, Epsilon: number): (string, {string}?)
    Epsilon = math.abs(Epsilon)
    
    --Return if the types aren't equal.
    if typeof(Object1) ~= typeof(Object2) then
        return "DIFFERENT_TYPES"
    end
    
    --Return a special-case for numbers.
    if typeof(Object1) == "number" and typeof(Object2) == "number" then
        return math.abs((Object1 :: number) - (Object2 :: number)) <= Epsilon and "CLOSE" or "NOT_CLOSE"
    end

    --Return if the type is not stored.
    if not PROPERTY_TO_LIST[typeof(Object1)] then
        return "UNSUPPORTED_TYPE"
    end

    --Convert the types to lists of values.
    local Object1Values, Object1Keys = PROPERTY_TO_LIST[typeof(Object1)](Object1)
    local Object2Values, Object2Keys = PROPERTY_TO_LIST[typeof(Object2)](Object2)

    --Determine the keys that are different.
    local NotCloseKeys = {}
    for i = 1, math.max(#Object1Values, #Object2Values) do
        if not Object1Values[i] then
            table.insert(NotCloseKeys, Object2Keys[i])
        elseif not Object2Values[i] then
            table.insert(NotCloseKeys, Object1Keys[i])
        elseif math.abs(Object1Values[i] - Object2Values[i]) > Epsilon then
            table.insert(NotCloseKeys, Object1Keys[i])
        end
    end

    --Return the result.
    return #NotCloseKeys == 0 and "CLOSE" or "NOT_CLOSE", NotCloseKeys
end

--[[
Returns a string result for the match and an optional
list of keys that don't match based on if the values
are not close.
--]]
function IsCloseModule.IsNotClose<T>(Object1: T, Object2: T, Epsilon: number): (string, {string}?)
    --Invert the keys that are not close.
    local Result, NotCloseKeys = IsCloseModule.IsClose(Object1, Object2, Epsilon)
    local CloseKeys = nil
    if NotCloseKeys ~= nil then
        CloseKeys = {}
        local NotCloseKeysMap = {}
        for _, Key in NotCloseKeys do
            NotCloseKeysMap[Key] = true
        end
        local _, ObjectKeys = PROPERTY_TO_LIST[typeof(Object1)](Object1)
        for _, Key in ObjectKeys do
            if NotCloseKeysMap[Key] then continue end
            table.insert(CloseKeys, Key)
        end
    end

    --Invert the result and return the keys.
    return Result, CloseKeys
end



return IsCloseModule