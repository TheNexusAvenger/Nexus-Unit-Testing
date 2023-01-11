# Writing Tests
Nexus Unit Testing supports a custom syntax for writing
tests and [TestEZ](https://github.com/Roblox/testez).
Nexus Unit Testing's syntax is no longer recommended
in favor of TestEZ and is no longer covered in the
docs.

[Legacy docs for Nexus Unit Testing's syntax can be found in version control.](https://github.com/TheNexusAvenger/Nexus-Unit-Testing/blob/5fcc02d5cfdc50530d513df551fd981107db36a8/docs/getting-started/writing-tests.md)

# Base TestEZ
See TestEZ's [writing tests](https://roblox.github.io/testez/getting-started/writing-tests/)
and [API reference](https://roblox.github.io/testez/api-reference/)
docs for writing tests using TestEZ.

# TestEZ Extensions
Nexus Unit Testing will run TestEZ tests with the
default API. To achieve feature parity with
Nexus Unit Testing's syntax, a couple extensions can
be enabled on top of TestEZ. **Extensions are provided
since TestEZ is no longer maintained and the extensions
will cause failing tests on other TestEZ versions.**
To enable them, add `--$NexusUnitTestExtensions` as a
comment to the script containing the text. When
added, the following will be added:

* `expect(...)...near(...)` - While `near` is part
  of TestEZ, it only works numbers. `near` with the
  TestEZ extensions allows it to work with numbers and
  most Roblox data types.
* `expect(...)...deepEqual(...)` - `deepEqual` is intended
  for tables and will compare the values of tables instead
  of only if `==` is `true` for the table.
* `expect(...)...contain(...)` - for strings, `contain`
  will check if a pattern or substring exists in the
  initial string. For tables, `contain` will check if
  the table contains a value.

```lua
--!strict
--$NexusUnitTestExtensions

return function()
    describe("A test with extensions", function()
        it("should allow for datatypes to be near.", function()
            expect(Vector3.zero).to.be.near(Vector3.new(0, 0, 0))
            expect(Vector3.one).to.never.be.near(Vector3.new(0, 0, 0))
        end)

        it("should allow for tables to be equal.", function()
            expect({Thing1 = "Value1", Thing2 = "Value2"}).to.deepEqual({Thing1 = "Value1", Thing2 = "Value2"})
            expect({1, 2, 3}).to.deepEqual({1, 2, 3})
            expect({1, 2, 3}).to.neever.deepEqual({1, 2, 4})
            expect({1, 2, 3}).to.neever.deepEqual({1, 2, 3, 4})
            expect({1, 2, 3}).to.neever.deepEqual({1, 2})
        end)

        it("should check if strings contain patterns.", function()
            expect("Test string").to.contain("Test")
            expect("Test string").to.contain("[Tt]est")
            expect("Test string").never.to.contain("test")
        end)

        it("should check if tables contain values.", function()
            expect({Thing1 = "Value1", Thing2 = "Value2"}).to.contain("Value1")
            expect({Thing1 = "Value1", Thing2 = "Value2"}).to.never.contain("Value3")
            expect({1, 2, 3}).to.contain(1)
            expect({1, 2, 3}).to.never.contain(4)
        end)
    end)
end
```