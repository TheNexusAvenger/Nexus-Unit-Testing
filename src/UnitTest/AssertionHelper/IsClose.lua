--[[
TheNexusAvenger

Helper function for determining if two userdata objects are close.
--]]



--[[
Returns the following:
	true - two objects are close
	false - two objects aren't close
	nil - two objects aren't able to be close
--]]
local function IsClose(Object1,Object2,Epsilon)
	Epsilon = math.abs(Epsilon)
	
	--Return if the types aren't equal.
	if typeof(Object1) ~= typeof(Object2) then
		return
	end
	
	--Handle the objects being numbers.
	if type(Object1) == "number" then
		return math.abs(Object2 - Object1) <= Epsilon
	end
	
	--Handle the objects being CFrames.
	if typeof(Object1) == "CFrame" then
		return IsClose(Object1.Position,Object2.Position,Epsilon) and IsClose(Object1.LookVector,Object2.LookVector,Epsilon)
			and IsClose(Object1.RightVector,Object2.RightVector,Epsilon) and IsClose(Object1.UpVector,Object2.UpVector,Epsilon)
	end
	
	--Handle the objects being numbers.
	if typeof(Object1) == "Color3" then
		return IsClose(Object1.r,Object2.r,Epsilon) and IsClose(Object1.g,Object2.g,Epsilon) 
			and IsClose(Object1.b,Object2.b,Epsilon)
	end
	
	--Handle the objects being Rays.
	if typeof(Object1) == "Ray" then
		return IsClose(Object1.Origin,Object2.Origin,Epsilon) and IsClose(Object1.Direction,Object2.Direction,Epsilon)
	end
	
	--Handle the objects being Region3s.
	if typeof(Object1) == "Region3" then
		return IsClose(Object1.CFrame,Object2.CFrame,Epsilon) and IsClose(Object1.Size,Object2.Size,Epsilon)
	end
	
	--Handle the objects being UDims.
	if typeof(Object1) == "UDim" then
		return IsClose(Object1.Scale,Object2.Scale,Epsilon) and IsClose(Object1.Offset,Object2.Offset,Epsilon)
	end
	
	--Handle the objects being UDim2s.
	if typeof(Object1) == "UDim2" then
		return IsClose(Object1.X,Object2.X,Epsilon) and IsClose(Object1.Y,Object2.Y,Epsilon)
	end
	
	--Handle the objects being Vector2s.
	if typeof(Object1) == "Vector2" then
		return IsClose(Object1.X,Object2.X,Epsilon) and IsClose(Object1.Y,Object2.Y,Epsilon)
	end
	
	--Handle the objects being Vector3s.
	if typeof(Object1) == "Vector3" then
		return IsClose(Object1.X,Object2.X,Epsilon) and IsClose(Object1.Y,Object2.Y,Epsilon) 
			and IsClose(Object1.Z,Object2.Z,Epsilon)
	end
end



return IsClose