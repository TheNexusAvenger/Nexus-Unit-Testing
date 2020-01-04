--[[
Corecii

Runs a function with a random script name.
(Comments by TheNexusAvenger)
--]]

return setmetatable({}, {
	__call = function(_,func,...)
		return func(...)
	end
})