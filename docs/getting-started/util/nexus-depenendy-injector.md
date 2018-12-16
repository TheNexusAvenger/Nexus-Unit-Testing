# Nexus Dependency Injector
Nexus Dependency Injector provides the ability to override
global variables for functions, tables, and ModuleScripts.
The unit tests use Nexus Unit Testing, but it can be used
with any unit testing framework. Examples of what it can be
used for, included in the tests in 
[`/test/NexusUnitTesting/Util/DependencyInjector_Examples.lua`](https://github.com/TheNexusAvenger/Nexus-Unit-Testing/blob/master/test/NexusUnitTesting/Util/DependencyInjector_Examples.lua)
include:
<br>1. Overriding random number generators to be predictable.
<br>2. Creating "seams" for requiring ModuleScripts.
<br>3. Simulating DataStoreService and HttpService failures.
<br>4. Creating fake Workspaces and Players.

## DependencyInjector Functions
### `DependencyInjector.Inject(Table TableToInject,Injector InjectorObject)`
Injects the global variables of a given table with an 
injector object.

### `DependencyInjector.InjectEnvironmentVariables(Object ObjectToInject,Injector InjectorObject)`
Injects the global variables of a given function or
table with an injector object.

### `DependencyInjector.Require(ModuleScript Script,Injector InjectorObject)`
Requires a clone of a ModuleScript with injected global
variables. This is done by modifying the source to
encapsulate the module in a function and overriding the 
function's global variables. The ModuleScript is cloned
so the injection doesn't persist and gets around the caching
problem. Unless overridden, `require()` is overridden with
`DependencyInjector::Require` and `script` is replaced with
the original script's reference.

!!! note
    ModuleScript dependency injection requires cloning and
    modification of the source. It has to be run in a plugin
    or command line context.

### `DependencyInjector.CreateOverridder()`
Creates and returns an overridder class. This is used
for the various injection methods.

## Overridder Functions
### `Overridder.new()`
Creates an instance of an Overridder class. This is called
with `DependencyInjector.CreateOverridder()`.

### `Overridder:GetIndexOverride(Object Index)`
Returns the IndexOverridder for a given index. Nil gets
returned if there is no override.

### `Overridder:GetCallOverride(Object Index,Table Parameters)`
Returns the CallOverridder for a given index. Nil gets
returned if there is no Overridder or the Overridders
can't return for the given parameters.

### `Overridder:WhenIndexed(Object Index)`
Creates and returns an IndexOverridder object for a
given index.

### `Overridder:WhenCalled(Index,...)`
Creates and returns a CallOverridder object for a
given index. Any additional parameters are treated
as parameters that must match to be considered an
override. An example is overriding `math.random`
if the bounds are 2 and 5.

## IndexOverridder Functions
### `IndexOverridder.new()`
Creates an IndexOverridder object.

### `IndexOverridder:HasOverride()`
Returns if there an override set for the IndexOverridder.

### `IndexOverridder:GetOverride()`
Returns the current override.

### `IndexOverridder:ThenReturn(Object Override)`
Sets the override to return a fixed object when
IndexOverridder::GetOverride is called.

### `IndexOverridder:ThenCall(Function ReturnFunction)`
Sets the override to a function. When `IndexOverridder::GetOverride`
is called, the given function will be run and the
override will be what the function returns.

## CallOverride Functions
### `CallOverridder.new(Table RequiredParameters)`
Creates a CallOverridder object. Takes in a set of required
parameters for the override to be called.

### `CallOverridder:CanBeCalled(Table GivenParameters)`
Returns if the override is valid for the
given set of overrides. It is assumed an
extra parameters beyond the initial RequiredParameters
will be considered valid.

### `CallOverridder:GetReturn(...)`
Returns the override with the given set
of parameters.

### `CallOverridder:ThenReturn(Object Override)`
Sets the CallOverridder to return a specific
Object when called.

### `CallOverridder:ThenCall(Function Callback)`
Sets the CallOverridder to call a given callback
and return what the Callback returns. The Callback's
parameters will include all of the parameters that
the function was called with.

### `CallOverridder:DoNothing()`
Sets the CallOverridder to do nothing when called.