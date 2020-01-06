# UnitTest.UnitTest
(extends `NexusInstance`)

## `static UnitTest UnitTest.UnitTest`
Cyclic reference to `UnitTest`. When `require("NexusUnitTesting")`
is called, a `UnitTest` object is retruned. `NexusUnitTesting.UnitTest.new(...)`
can be called to create a new unit test object to pass into
`NexusUnitTesting:RegisterUnitTest(...)`.

## `static UnitTest UnitTest.new(string UnitTestName)`
Creates a `UnitTest` object with the given name.

## `string UniTest.Name`
Name of the unit test.

## `NexusUnitTesting.TestState (string) UnitTest.State`
The state of the unit test. Can be:
- `NexusUnitTesting.TestState.NotRun ("NOTRUN")` - The test has not been ran.
- `NexusUnitTesting.TestState.InProgress ("INPROGRESS")` - The test is running.
- `NexusUnitTesting.TestState.Skipped ("SKIPPED")` - The test was skipped.
- `NexusUnitTesting.TestState.Passed ("PASSED")` - The test passed.
- `NexusUnitTesting.TestState.Failed ("FAILED")` - The test failed (error or assertion failed).

## `NexusUnitTesting.TestState (string) UnitTest.CombinedState`
The state of the unit test and subtests. Can be:
- `NexusUnitTesting.TestState.NotRun ("NOTRUN")` - The test and subtests has not been ran.
- `NexusUnitTesting.TestState.InProgress ("INPROGRESS")` - The tests or one subtest is running.
- `NexusUnitTesting.TestState.Skipped ("SKIPPED")` - The test has skipped or at least one test has skipped with no subtest failing or still running.
- `NexusUnitTesting.TestState.Passed ("PASSED")` - The test passed and all subtests are passed or not ran.
- `NexusUnitTesting.TestState.Failed ("FAILED")` - The test failed or at least one test has failed with no subtest still running.

## `List<UnitTest> UnitTest.SubTests`
List of tests that the test contains.

## `List<<string,Enum.MessageType>> UnitTest.Output`
List of the messages outputted while setting up, running, and tearing
down the test. The list contains a table with the first item (index `1`)
being the message and the second item (index `2`) the type. The errors
included the stack trace are stored in the table.

## `NexusEvent<UnitTest> UnitTest.TestAdded`
Event invoked whena test is added. When fired, the added `UnitTest`
is passed.

## `NexusEvent<string,Enum.MessageType> UnitTest.MessageOutputted`
Event invoked when a message is outputted. When fired, the message
of the output is passed as well as the type.

## `void UnitTest:Setup()`
Sets up the test. Intended to be replaced before running
if additional setup is not needed.

## `void UnitTest:Run()`
Runs the test. If the setup fails, the test is not continued.
Intended to be replaced before running to run the test.

## `void UnitTest:Teardown()`
Tears down the test. Runs regardless of the test passing
or failing. Intended to be replaced before running to 
clear the resources used by the test.

## `void UnitTest:OutputMessage(Enum.MessageType,...)`
Registers a message being outputted. Intended to be used
internally since print and warn are replaced in the environment.

## `void UnitTest:RunTest()`
Runs the test and updates the state. Should not be replaced
since it is used to run `UnitTest:Setup()`, `UnitTest:Run()`,
and `UnitTest:Teardown()`.

## `void UnitTest:RunSubtests()`
Runs all of the subtests and updates the combined state.

## `void UnitTest:UnitTest:SetEnvironmentOverride(string Name,object Value)
Sets an environment override for the methods
in the test.
Can be chained with other methods (`Object:Method1(...):Method2(...)...`)

## `void UnitTest:SetSetup(function Method)`
Sets the Setup method.
Can be chained with other methods (`Object:Method1(...):Method2(...)...`)

## `void UnitTest:SetRun(function Method)`
Sets the Run method.
Can be chained with other methods (`Object:Method1(...):Method2(...)...`)

## `void UnitTest:SetTeardown(function Method)`
Sets the Teardown method.
Can be chained with other methods (`Object:Method1(...):Method2(...)...`)

## `void UnitTest:UpdateCombinedState()`
Updates the `UnitTest.CombinedState` property based
on the test and subtests. Not intended to be
called externally.

## `void UnitTest:StopAssertionIfCompleted()`
Stops the calling thread if the test has completed.
This is to prevent threaded tests from calling assertions
after the test's state has been determined.

## `void UnitTest:Pass(string? Reason)`
Marks a unit test as passed. A reason for passing can also
be specified.

!!! info
    This yields the thread after running. If this is called in
    `UnitTest:Run()`, this will not affect `UnitTest:Teardown()`.

!!! warning
    This calls `UnitTest:StopAssertionIfCompleted()` before
    running. If the test has already completed, this will
    cause the test to function to yield, which may be unintended.

## `void UnitTest:Fail(string? Reason)`
Marks a unit test as failed. A reason for passing can also
be specified.

!!! warning
    This throws an error to stop the test. Anything ran in the method
    afterwards will not run. If this is called in
    `UnitTest:Run()`, this will not affect `UnitTest:Teardown()`.

!!! warning
    This calls `UnitTest:StopAssertionIfCompleted()` before
    running. If the test has already completed, this will
    cause the test to function to yield, which may be unintended.

## `void UnitTest:Skip(string? Reason)`
Marks a unit test as skipped. A reason for passing can also
be specified.

!!! info
    This yields the thread after running. If this is called in
    `UnitTest:Run()`, this will not affect `UnitTest:Teardown()`.

!!! warning
    This calls `UnitTest:StopAssertionIfCompleted()` before
    running. If the test has already completed, this will
    cause the test to function to yield, which may be unintended.

## `void UnitTest:Assert(function Function,string Message)`
Runs an assertion. The given function should return `true` if the
assertion is valid and `false` if the assertion is invalid. If the
assertion fails, an error is thrown with the given message.

!!! warning
    This calls `UnitTest:StopAssertionIfCompleted()` before
    running. If the test has already completed, this will
    cause the test to function to yield, which may be unintended.

## `void UnitTest:AssertEquals(object ExpectedObject,object ActualObject,string? Message)`
Asserts that two objects are equal. Special cases are handled for
objects like arrays that may have the same elements. Not intended
to be used on Roblox Instances.

!!! warning
    This calls `UnitTest:StopAssertionIfCompleted()` before
    running. If the test has already completed, this will
    cause the test to function to yield, which may be unintended.

## `void UnitTest:AssertNotEquals(object ExpectedObject,object ActualObject,string? Message)`
Asserts that two objects aren't equal. Special cases are handled for
objects like arrays that may have the same elements. Not intended
to be used on Roblox Instances.

!!! warning
    This calls `UnitTest:StopAssertionIfCompleted()` before
    running. If the test has already completed, this will
    cause the test to function to yield, which may be unintended.

## `void UnitTest:AssertSame(object ExpectedObject,object ActualObject,string Message)`
Asserts that two objects are the same. This is mainly used for testing
if a new array or instance isn't created.

!!! warning
    This calls `UnitTest:StopAssertionIfCompleted()` before
    running. If the test has already completed, this will
    cause the test to function to yield, which may be unintended.

## `void UnitTest:AssertNotSame(object ExpectedObject,object ActualObject,string? Message)`
Asserts that two objects aren't the same. This is mainly used for testing
if a new array or instance isn't created.

!!! warning
    This calls `UnitTest:StopAssertionIfCompleted()` before
    running. If the test has already completed, this will
    cause the test to function to yield, which may be unintended.

## `void UnitTest:AssertClose(object ExpectedObject,object ActualObject,float? Epsilon,string? Message)`
Asserts that two objects are within a given Epsilon of each other. If
the message is used in place of the Epsilon, 0.001 will be used.

!!! warning
    This calls `UnitTest:StopAssertionIfCompleted()` before
    running. If the test has already completed, this will
    cause the test to function to yield, which may be unintended.

## `void UnitTest:AssertNotClose(object ExpectedObject,object ActualObject,float? Epsilon,string? Message)`
Asserts that two objects aren't within a given Epsilon of each other. If
the message is used in place of the Epsilon, 0.001 will be used.

!!! warning
    This calls `UnitTest:StopAssertionIfCompleted()` before
    running. If the test has already completed, this will
    cause the test to function to yield, which may be unintended.

## `void UnitTest:AssertFalse(bool ActualObject,string? Message)`
Asserts that an object is false.

!!! warning
    This calls `UnitTest:StopAssertionIfCompleted()` before
    running. If the test has already completed, this will
    cause the test to function to yield, which may be unintended.

## `void UnitTest:AssertTrue(bool ActualObject,string? Message)`
Asserts that an object is true.

!!! warning
    This calls `UnitTest:StopAssertionIfCompleted()` before
    running. If the test has already completed, this will
    cause the test to function to yield, which may be unintended.

## `void UnitTest:AssertNil(object ActualObject,string? Message)`
Asserts that an object is nil.

!!! warning
    This calls `UnitTest:StopAssertionIfCompleted()` before
    running. If the test has already completed, this will
    cause the test to function to yield, which may be unintended.

## `void UnitTest:AssertNotNil(object ActualObject,string? Message)`
Asserts that an object is not nil.

!!! warning
    This calls `UnitTest:StopAssertionIfCompleted()` before
    running. If the test has already completed, this will
    cause the test to function to yield, which may be unintended.

## `ErrorAssertor UnitTest:AssertErrors(function Function,string? Message)`
Asserts that an error is thrown. Returns an `ErrorAssertor`
object that can be used to validate the error's message.

!!! warning
    This calls `UnitTest:StopAssertionIfCompleted()` before
    running. If the test has already completed, this will
    cause the test to function to yield, which may be unintended.