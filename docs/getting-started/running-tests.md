# Running Tests
Tests can be run with several different methods.
All of the methods require being run in the command
line or as a plugin since reading and modifying the
`Source` property is required for detecting and running
Nexus Unit Testing tests. This may change in the future,
considering TestEZ's design doesn't have this requirement.

## Command Line
!!! warning
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
require(game.ReplicatedStorage.NexusUnitTesting).RunTes(game.ReplicatedStorage.NexusUnitTestingTests)
```

### Lemur
Lemur has not been tested with Nexus Unit Testing. TestEZ
is used with Lemur projects and should be used instead.

## Roblox Studio Plugin
The plugin has not been released yet. Information will
updated when the plugin is public.