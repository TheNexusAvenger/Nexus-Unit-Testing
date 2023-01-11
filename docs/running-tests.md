# Running Tests
Tests can be run with several different methods.
All of the methods require being run in the command
line or as a plugin since reading and modifying the
`Source` property is required for detecting and running
Nexus Unit Testing tests. This may change in the future,
considering TestEZ's design doesn't have this requirement.

## Command Line
Using the `RunTests` method is not recommended since
it hides the output of the tests. Using the plugin
is recommended.
    
In the command line version can be run using the `RunTests`
method in the main `NexusUnitTesting` class.
```lua
require(game.ReplicatedStorage.NexusUnitTesting).RunTests()
```

To run only the tests in a specific container, a Roblox
instance can be specified.
```lua
require(game.ReplicatedStorage.NexusUnitTesting).RunTest(game.ReplicatedStorage.NexusUnitTestingTests)
```

## Roblox Studio Plugin
Nexus Unit Testing Plugin can be found from the
[Roblox Plugin Marketplace](https://www.roblox.com/library/11039022908/Nexus-Unit-Testing-Plugin),
[itch.io](https://thenexusavenger.itch.io/nexus-unit-testing-plugin),
as well as [GitHub](https://github.com/TheNexusAvenger/Nexus-Unit-Testing-Plugin).
It provides a graphical user interface for running
tests and viewing the output of individual tests.
