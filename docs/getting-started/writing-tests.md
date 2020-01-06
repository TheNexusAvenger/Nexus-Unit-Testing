# Writing Tests
Nexus Unit Testing and TestEZ tests are intended to
be written in `ModuleScripts`.

## Nexus Unit Testing
Nexus Unit Testing is designed to not rely
on returned methods, so tests can be written anywhere
in the `ModuleScript` as long as it runs. Detection
relies on `NexusUnitTesting` being `require`d at
some point in the script. Due to how tests are
set up, this is required either way.

```lua
--Require Nexus Unit Testing. Any of thje following will be detected as long
--the module is NexusUnitTesting (not something like NexusUnitTesting2).
local NexusUnitTesting = require(game.Path.To.NexusUnitTesting)
local NexusUnitTesting = require("NexusUnitTesting")
local NexusUnitTesting = require('NexusUnitTesting')

--Register a function as a unit test.
--This is deprecated, but works to not break V.1.X.X tests. Setup and teardown isn't supported.
NexusUnitTesting:RegisterUnitTest("TestName1",function(UnitTest)
    UnitTest:AssertEquals(1 + 1,2,"Addition doesn't work.")
end)

--Register a unit test class created the long way.
local UnitTest = NexusUnitTesting.UnitTest.new("TestName2")
function UnitTest:Setup()
    print(self.Name.." set up.")
end
function UnitTest:Run()
    self:AssertEquals(1 + 1,2,"Addition doesn't work.")
end
NexusUnitTesting:RegisterUnitTest(UnitTest)

--Register a unit test class created with setters.
NexusUnitTesting:RegisterUnitTest(UnitTest.new("TestName3"):SetSetup(function(self)
    print(self.Name.." set up.")
end):SetRun(function(self)
    self:AssertEquals(1 + 1,2,"Addition doesn't work.")
end))

--Return something to prevent Roblox throwing an error from nothing being returned.
--If a function is returned, it will be ran (mainly for TestEZ).
return true
```

## TestEZ
TestEZ's detection is different since it relies on
the name of the script ending with `.spec`. This allows for
unit tests to have the same parent as the module being tested
(ex: `UnitTest` and `UnitTest.spec`). The structure for TestEZ
involves having the tests be contained in a returned function
to allow for the environment being modified without having
to modify the source.

```lua
return function()
    --Describe a test.
    describe("TestName",function()
        --Desribe how it should behave.
        it("should perform addition",function()
            expect(1 + 1).to.equal(2)
        end)

        it("should perform subtraction",function()
            expect(1 - 1).to.equal(0)
        end)
    end)
end
```