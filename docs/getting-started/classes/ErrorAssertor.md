# UnitTest.ErrorAssertor
(extends `NexusInstance`)

Class returned from `UnitTest:AssertErrors(...)` to run
assertions on error messages. All methods can be chained.

```lua
self:AssertErrors(function()
    error("Test error")
end):Contains("error"):Contains("Test"):NotContains("something else"):NotEquals("something else")
```

## `static ErrorAssertor ErrorAssertor.new(string ErrorMessage)`
Creates an ErrorAssertor object from a given error message.

## `void ErrorAssertor:Contains(string Message)`
Asserts that the error message contains a given string, including
the casing. Throws an error if the assertion is invalid.

## `void ErrorAssertor:NotContains(string Message)`
Asserts that the error message doesn't contains a given string, including
the casing. Throws an error if the assertion is invalid.

## `void ErrorAssertor:Equals(string Message)`
Asserts that the error message equals a given string, including
the casing. Throws an error if the assertion is invalid.

!!! warning
    Error messages typically include the script and line
    number, which can change. Using `ErrorAssertor:Contains`
    will be more reliable.

## `void ErrorAssertor:NotEquals(string Message)`
Asserts that the error message doesn't equal a given string, including
the casing. Throws an error if the assertion is invalid.

!!! warning
    Error messages typically include the script and line
    number, which can change. Using `ErrorAssertor:NotContains`
    will be more reliable.