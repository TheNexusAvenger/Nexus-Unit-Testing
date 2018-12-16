The following is the documentation for the main module.
Examples can be found in:
<br>1. [`/test/NexusUnitTesting_Assertions.lua`](https://github.com/TheNexusAvenger/Nexus-Unit-Testing/blob/master/test/NexusUnitTesting_Assertions.lua)
<br>2. [`/test/NexusUnitTesting_EdgeCases.lua`](https://github.com/TheNexusAvenger/Nexus-Unit-Testing/blob/master/test/NexusUnitTesting_EdgeCases.lua)
<br>3. [`/test/NexusUnitTesting_Static.lua`](https://github.com/TheNexusAvenger/Nexus-Unit-Testing/blob/master/test/NexusUnitTesting_Static.lua)

## Properties
### `NexusUnitTesting.Util`
A table of the available utilities included as part of
Nexus Unit Testing. Right now this includes:
<br>1. [NexusUnitTesting.Util.DependencyInjector](../getting-started/util/nexus-depenendy-injector.md)

## Functions
### `NexusUnitTesting.new()`
Creates an instance of a NexusUnitTesting as an
individual unit test. A `Name` can also
be assigned to the object.

!!! note
    This is meant for internal use. It is recommended 
    to use `NexusUnitTesting::RegisterUnitTest` instead.
    Not using that function may result in compatibility
    problems when running unit tests.

!!! note
    Instantiating a unit test is not required to run
    assertions. Assertions are run statically, but will
    not have an associated name and will not implicitly
    call pass at the end of a unit test.

### `NexusUnitTesting:Pass()`
Ends the unit tests and considers the test a success.

!!! note
    This is implictly called with a unit test ran
    with `NexusUnitTesting::RegisterUnitTest`.

!!! warning
    This method will cause the current thread to yield.
    If unit tests are not run as separate processes, this
    will stop all unit tests (and anything else) being run.
    `NexusUnitTesting::RegisterUnitTest` is recommended to
    avoid this behavior.

### `NexusUnitTesting:Fail()`
Ends the unit tests and considers the test a failure.

!!! warning
    This method will cause the current thread to yield.
    If unit tests are not run as separate processes, this
    will stop all unit tests (and anything else) being run.
    `NexusUnitTesting::RegisterUnitTest` is recommended to
    avoid this behavior.

### `NexusUnitTesting:Assert(Function Assertion,String FailureMessage)`
Runs the given function. If the function returns true,
the assertion is considered true. If anything else is
returned, the assertion is considered false and will
fail the unit test. If the assertion fails, the message
will be an error message.

!!! tip
    All assertions will call this function to with a function.
    This means only this can be overridden rather than all
    of the assertions

### `NexusUnitTesting:AssertEquals(Object Expected,Object Actual,String FailureMessage)`
Asserts that two objects are equivalent. This is intended
for tables that may have the same entries but different
memory references.

!!! bug
    There is no check for cyclic tables. A recursive depth will be reached
    instead of returning the correct value.

### `NexusUnitTesting:AssertNotEquals(Object NotExpected,Object Actual,String FailureMessage)`
Asserts that two objects are not equivalent. This is intended
for tables that may have the same entries but different
memory references.

!!! bug
    There is no check for cyclic tables. A recursive depth will be reached
    instead of returning the correct value.

### `NexusUnitTesting:AssertSame(Object Expected,Object Actual,String FailureMessage)`
Asserts that performing `==` on the two objects is true.
For tables, this means the memory reference has to be
the same.

### `NexusUnitTesting:AssertNotSame(Object NotExpected,Object Actual,String FailureMessage)`
Asserts that performing `==` on the two objects is false.
For tables, this means the memory reference has to be
the same.

### `NexusUnitTesting:AssertClose(Object Expected,Object Actual,Float Epsilon,String FailureMessage)`
Asserts that two objects are within a given Epsilon
of each other. This is recommended for floats or
data types that include floats.

### `NexusUnitTesting:AssertNotClose(Object NotExpected,Object Actual,Float Epsilon,String FailureMessage)`
Asserts that two objects are not within a given Epsilon
of each other. This is recommended for floats or
data types that include floats.

### `NexusUnitTesting:AssertTrue(Boolean Actual,String FailureMessage)`
Asserts that a given bool is `true`.

### `NexusUnitTesting:AssertFalse(Boolean Actual,String FailureMessage)`
Asserts that a given bool is `false`.

### `NexusUnitTesting:AssertNil(Object Actual,String FailureMessage)`
Asserts that a given object is `nil`.

### `NexusUnitTesting:AssertNotNil(Object Actual,String FailureMessage)`
Asserts that a given object is not `nil`.

### `NexusUnitTesting:RegisterUnitTest(String Name,Function UnitTestFunction)`
Creates an instance of a unit test, sets the name of
the unit test, and runs the unit test function in
a co-routine. The given function has the unit test
as a parameter for running assertions.