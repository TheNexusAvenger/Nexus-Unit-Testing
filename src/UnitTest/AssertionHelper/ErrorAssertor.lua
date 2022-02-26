--[[
TheNexusAvenger

Class for asserting errors are correct.
--]]

local NexusUnitTesting = require(script.Parent.Parent.Parent:WaitForChild("NexusUnitTestingProject"))
local NexusInstance = NexusUnitTesting:GetResource("NexusInstance.NexusInstance")


local ErrorAssertor = NexusInstance:Extend()
ErrorAssertor:SetClassName("ErrorAssertor")



--[[
Creates an error assertor object.
--]]
function ErrorAssertor:__new(Error)
    self:InitializeSuper()
    
    --Store the error.
    self.Error = Error
end

--[[
Asserts the error contains a string.
--]]
function ErrorAssertor:Contains(MessageSection)
    MessageSection = tostring(MessageSection)
    
    --Throw an error if the assertion is invalid.
    if not string.find(self.Error,MessageSection) then
        error("Error message is not correct.\n\tError message: "..tostring(self.Error).."\n\tNot contained: "..MessageSection)
    end
    
    --Return itself to allow chaining.
    return self
end

--[[
Asserts the error does not contain a string.
--]]
function ErrorAssertor:NotContains(MessageSection)
    MessageSection = tostring(MessageSection)
    
    --Throw an error if the assertion is invalid.
    if string.find(self.Error,MessageSection) then
        error("Error message is not correct.\n\tError message: "..tostring(self.Error).."\n\tContained: "..MessageSection)
    end
    
    --Return itself to allow chaining.
    return self
end

--[[
Asserts the error equals a string.
--]]
function ErrorAssertor:Equals(MessageSection)
    --Throw an error if the assertion is invalid.
    if self.Error ~= MessageSection then
        error("Error message is not correct.\n\tActual message: "..tostring(self.Error).."\n\tExpected message: "..MessageSection)
    end
    
    --Return itself to allow chaining.
    return self
end

--[[
Asserts the error does not equal a string.
--]]
function ErrorAssertor:NotEquals(MessageSection)
    --Throw an error if the assertion is invalid.
    if self.Error == MessageSection then
        error("Error message is not correct.\n\tActual message: "..tostring(self.Error).."\n\tNot expected message: "..MessageSection)
    end
    
    --Return itself to allow chaining.
    return self
end



return ErrorAssertor