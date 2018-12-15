--[[
TheNexusAvenger

Helper function for determining if two userdata objects are equal.
--]]



--[[
Returns if two user data are equal.
--]]
local function Equals(Object1,Object2)
	--If it is a table, check the keys and values being the same.
	if type(Object1) == "table" and type(Object2) == "table" then
		--Check the tables.
		for Key,Value in pairs(Object1) do
			if not Equals(Value,Object2[Key]) then
				return false
			end
		end
		
		for Key,Value in pairs(Object2) do
			if not Equals(Value,Object1[Key]) then
				return false
			end
		end
		
		--Return true (all equal).
		return true
	end
	
	--Return equality (base case)
	return Object1 == Object2
end



return Equals