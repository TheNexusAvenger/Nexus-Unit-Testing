--[[
TheNexusAvenger

Helper function for determining if two userdata objects are equal.
--]]

--[[
Returns if two user data are equal.
--]]
local function Equals(Object1,Object2,CheckedValues)
	--Create the checked values table if it doesn't exist.
	if not CheckedValues then
		CheckedValues = { {}, {} }
	end

	--[[
	Performs a cyclic check and returns
	if the equals method should continue.
	--]]
	local function PerformCyclicCheck(Value1,Value2)
		--Return true if either value aren't tables.
		if type(Value1) ~= "table" or type(Value2) ~= "table" then
			return true
		end

		--Return false if either value was already checked.
		if CheckedValues[1][Value1] or CheckedValues[2][Value2] then
			return false
		end

		--Store the values and return true (continue).
		CheckedValues[1][Value1] = true
		CheckedValues[2][Value2] = true
		return true
	end

	--If it is a table, check the keys and values being the same.
	if type(Object1) == "table" and type(Object2) == "table" then
		-- Check the tables.
		if Object1 ~= Object2 then
			for Key, Value in pairs(Object1) do
				if PerformCyclicCheck(Value, Object2[Key]) then
					if not Equals(Value, Object2[Key], CheckedValues) then
						return false
					end
				end
			end

			for Key, Value in pairs(Object2) do
				if PerformCyclicCheck(Value, Object1[Key]) then
					if not Equals(Value, Object1[Key], CheckedValues) then
						return false
					end
				end
			end
		end

		-- Clear the checked flag for the values
		CheckedValues[1][Object1] = nil
		CheckedValues[2][Object2] = nil

		-- Return true (all equal).
		return true
	end

	--Return equality (base case)
	return Object1 == Object2
end

return Equals