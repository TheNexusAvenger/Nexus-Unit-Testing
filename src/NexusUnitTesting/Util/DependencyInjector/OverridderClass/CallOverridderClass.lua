--[[
TheNexusAvenger

Class representing an overridder for calling an index in a table or environment.
--]]

local CallOverridderClass = {}



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------               CONSTRUCTOR              --------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--[[
Creates a CallOverridder instance with a set of required parameters.
--]]
function CallOverridderClass.new(RequiredParameters)
	--Create the object.
	local CallOverridderObject = {
		RequiredParameters = RequiredParameters 
	}
	
	setmetatable(CallOverridderObject,{
		__index = CallOverridderClass
	})
	
	--Return the object.
	return CallOverridderObject
end



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------             OBJECT METHODS             --------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--[[
Returns if meets the parameter requirement.
--]]
function CallOverridderClass:CanBeCalled(GivenParameters)
	--Return false if any required parameters don't match.
	if self.RequiredParameters then
		for i,Parameter in pairs(self.RequiredParameters) do
			if Parameter ~= GivenParameters[i] then
				return false
			end
		end
	end
	
	--Return true (default)
	return true
end

--[[
Calls the override and returns the values it overrides with.
--]]
function CallOverridderClass:GetReturn(...)
	if self.CallMethod then
		return self.CallMethod(...)
	end
end

--[[
Sets the method to return a fixed value.
--]]
function CallOverridderClass:ThenReturn(Override)
	self.CallMethod = function()
		return Override
	end
end

--[[
Sets the method to call a function and return what it returns.
--]]
function CallOverridderClass:ThenCall(Callback)
	self.CallMethod = Callback
end

--[[
Makes the method do nothing.
--]]
function CallOverridderClass:DoNothing()
	self.CallMethod = nil
end



return CallOverridderClass