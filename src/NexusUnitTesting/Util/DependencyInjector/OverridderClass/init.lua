--[[
TheNexusAvenger

Class representing an overridder.
This is used to store overrides for the Nexus Dependency Injector.
--]]

local OverridderClass = {}

local IndexOverridderClass = require(script:WaitForChild("IndexOverridderClass"))
local CallOverridderClass = require(script:WaitForChild("CallOverridderClass"))



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------               CONSTRUCTOR              --------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--[[
Creates an overridder instance.
--]]
function OverridderClass.new()
	--Create the object.
	local OverridderObject = {
		IndexOverrides = {},
		CallOverrides = {},
	}
	
	setmetatable(OverridderObject,{
		__index = OverridderClass
	})
	
	--Return the object.
	return OverridderObject
end



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------             OBJECT METHODS             --------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--[[
Returns the override for determining the override of an index.
--]]
function OverridderClass:GetIndexOverride(Index)
	return self.IndexOverrides[Index]
end

--[[
Returns the override for determining the override of calling an index.
--]]
function OverridderClass:GetCallOverride(Index,Parameters)
	if not Parameters then Parameters = {} end
	local CallOverrides = self.CallOverrides[Index]
	
	--Get the call override.
	if CallOverrides then
		for _,Override in pairs(CallOverrides) do
			if Override:CanBeCalled(Parameters) then
				return Override
			end
		end
	end
end

--[[
Overides what is returned when a global variable is indexed.
]]
function OverridderClass:WhenIndexed(Index)
	local IndexOverridder = IndexOverridderClass.new()
	self.IndexOverrides[Index] = IndexOverridder
	
	return IndexOverridder
end

--[[
Overides what is returned when a global variable is called.
]]
function OverridderClass:WhenCalled(Index,...)
	local CallOverridder = CallOverridderClass.new({...})
	if not self.CallOverrides[Index] then self.CallOverrides[Index] = {} end
	table.insert(self.CallOverrides[Index],CallOverridder)
	
	return CallOverridder
end



return OverridderClass