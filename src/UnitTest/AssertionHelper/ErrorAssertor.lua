--[[
TheNexusAvenger

Class for asserting errors are correct.
--]]
--!strict

local ErrorAssertor = {}
ErrorAssertor.__index = ErrorAssertor

export type ErrorAssertor = {
    new: (Error: string) -> (ErrorAssertor),

    Error: string,
    Contains: (self: ErrorAssertor, MessageSection: string) -> (ErrorAssertor),
    NotContains: (self: ErrorAssertor, MessageSection: string) -> (ErrorAssertor),
    Equals: (self: ErrorAssertor, MessageSection: string) -> (ErrorAssertor),
    NotEquals: (self: ErrorAssertor, MessageSection: string) -> (ErrorAssertor),
}



--[[
Creates an error assertor object.
--]]
function ErrorAssertor.new(Error: string)
    return (setmetatable({
        Error = Error
    }, ErrorAssertor) :: any) :: ErrorAssertor
end

--[[
Asserts the error contains a string.
--]]
function ErrorAssertor:Contains(MessageSection: string): ErrorAssertor
    MessageSection = tostring(MessageSection)
    
    --Throw an error if the assertion is invalid.
    if not string.find(self.Error, MessageSection) then
        error("Error message is not correct.\n\tError message: "..tostring(self.Error).."\n\tNot contained: "..MessageSection)
    end
    
    --Return itself to allow chaining.
    return self
end

--[[
Asserts the error does not contain a string.
--]]
function ErrorAssertor:NotContains(MessageSection: string): ErrorAssertor
    MessageSection = tostring(MessageSection)
    
    --Throw an error if the assertion is invalid.
    if string.find(self.Error, MessageSection) then
        error("Error message is not correct.\n\tError message: "..tostring(self.Error).."\n\tContained: "..MessageSection)
    end
    
    --Return itself to allow chaining.
    return self
end

--[[
Asserts the error equals a string.
--]]
function ErrorAssertor:Equals(MessageSection: string): ErrorAssertor
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
function ErrorAssertor:NotEquals(MessageSection: string): ErrorAssertor
    --Throw an error if the assertion is invalid.
    if self.Error == MessageSection then
        error("Error message is not correct.\n\tActual message: "..tostring(self.Error).."\n\tNot expected message: "..MessageSection)
    end
    
    --Return itself to allow chaining.
    return self
end



return (ErrorAssertor :: any) :: ErrorAssertor