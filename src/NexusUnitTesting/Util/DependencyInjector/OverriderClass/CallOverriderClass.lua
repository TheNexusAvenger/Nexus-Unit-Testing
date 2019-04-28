--[[
TheNexusAvenger

Class representing an overrider for calling an index in a table or environment.
--]]

local CallOverriderClass = {}



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------               CONSTRUCTOR              --------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--[[
Creates a CallOverrider instance with a set of required parameters.
--]]
function CallOverriderClass.new(RequiredParameters)
	--Create the object.
	local CallOverriderObject = {
		RequiredParameters = RequiredParameters 
	}
	
	setmetatable(CallOverriderObject,{
		__index = CallOverriderClass
	})
	
	--Return the object.
	return CallOverriderObject
end



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------             OBJECT METHODS             --------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--[[
Returns if meets the parameter requirement.
--]]
function CallOverriderClass:CanBeCalled(GivenParameters)
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
function CallOverriderClass:GetReturn(...)
	if self.CallMethod then
		return self.CallMethod(...)
	end
end

--[[
Sets the method to return a fixed value.
--]]
function CallOverriderClass:ThenReturn(Override)
	self.CallMethod = function()
		return Override
	end
end

--[[
Sets the method to call a function and return what it returns.
--]]
function CallOverriderClass:ThenCall(Callback)
	self.CallMethod = Callback
end

--[[
Makes the method do nothing.
--]]
function CallOverriderClass:DoNothing()
	self.CallMethod = nil
end



return CallOverriderClass