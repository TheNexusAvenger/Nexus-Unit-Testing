--[[
TheNexusAvenger

Class representing an overridder for indexing a table or environment.
--]]

local IndexOverridderClass = {}



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------               CONSTRUCTOR              --------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--[[
Creates an IndexOverridder instance.
--]]
function IndexOverridderClass.new()
	--Create the object.
	local IndexOverridderObject = {}
	
	setmetatable(IndexOverridderObject,{
		__index = IndexOverridderClass
	})
	
	--Return the object.
	return IndexOverridderObject
end



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------             OBJECT METHODS             --------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--[[
Returns if there is an override.
--]]
function IndexOverridderClass:HasOverride()
	return self.OverrideFunction ~= nil
end

--[[
Returns the override value.
--]]
function IndexOverridderClass:GetOverride()
	return self.OverrideFunction()
end

--[[
Sets the method to return a fixed value.
--]]
function IndexOverridderClass:ThenReturn(Override)
	self.OverrideFunction = function()
		return Override
	end
end

--[[
Sets the method to call a function and return what it returns.
--]]
function IndexOverridderClass:ThenCall(Callback)
	self.OverrideFunction = Callback
end



return IndexOverridderClass