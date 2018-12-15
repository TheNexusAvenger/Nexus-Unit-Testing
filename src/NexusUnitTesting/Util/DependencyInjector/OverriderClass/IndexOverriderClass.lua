--[[
TheNexusAvenger

Class representing an overrider for indexing a table or environment.
--]]

local IndexOverriderClass = {}



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------               CONSTRUCTOR              --------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--[[
Creates an IndexOverrider instance.
--]]
function IndexOverriderClass.new()
	--Create the object.
	local IndexOverriderObject = {}
	
	setmetatable(IndexOverriderObject,{
		__index = IndexOverriderClass
	})
	
	--Return the object.
	return IndexOverriderObject
end



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------             OBJECT METHODS             --------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--[[
Returns if there is an override.
--]]
function IndexOverriderClass:HasOverride()
	return self.OverrideFunction ~= nil
end

--[[
Returns the override value.
--]]
function IndexOverriderClass:GetOverride()
	return self.OverrideFunction()
end

--[[
Sets the method to return a fixed value.
--]]
function IndexOverriderClass:ThenReturn(Override)
	self.OverrideFunction = function()
		return Override
	end
end

--[[
Sets the method to call a function and return what it returns.
--]]
function IndexOverriderClass:ThenCall(Callback)
	self.OverrideFunction = Callback
end



return IndexOverriderClass