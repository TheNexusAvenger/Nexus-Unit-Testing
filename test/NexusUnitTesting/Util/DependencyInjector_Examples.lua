--[[
TheNexusAvenger

Unit tests for the DependencyInjector module. Since it is used for the 
Nexus Unit Testing plugin, it is not set up for the plugin.
These unit tests are examples of other functionality.
--]]

local Tests = script.Parent.Parent.Parent
local Source = Tests.Parent:WaitForChild("Sources")
local NexusUnitTesting = require(Source:WaitForChild("NexusUnitTesting"))
local DependencyInjector = require(Source:WaitForChild("NexusUnitTesting"):WaitForChild("Util"):WaitForChild("DependencyInjector"))



--[[
Runs unit tests for the Inject method with the math library.
--]]
NexusUnitTesting:RegisterUnitTest("Inject_RepeatableMathRandom",function(UnitTest)
	local i = 1
	local Injector = DependencyInjector.CreateOverridder()
	Injector:WhenCalled("random",1,10):ThenCall(function()
		i = i + 1
		return i
	end)
	
	local InjectedMath = DependencyInjector.Inject(math,Injector)
	UnitTest:AssertNotEquals(2,InjectedMath.random(),"math.random() not properly overriden.")
	for i = 2,10 do
		UnitTest:AssertEquals(i,InjectedMath.random(1,10),"math.random() not properly overriden.")
	end
	UnitTest:AssertNotEquals(11,InjectedMath.random(1,9),"math.random() not properly overriden.")
end)

--[[
Runs unit tests for the Inject method with Require to define a ModuleScript "Seam".
--]]
NexusUnitTesting:RegisterUnitTest("Require_Seam",function(UnitTest)
	local Injector = DependencyInjector.CreateOverridder()
	Injector:WhenCalled("require",game.Workspace):ThenReturn(function()
		return math.pi
	end)
	
	local FakeModule = Instance.new("ModuleScript")
	FakeModule.Source = "return 2 * require(game.Workspace)()"
	
	local ModuleResult = DependencyInjector.Require(FakeModule,Injector)
	UnitTest:AssertClose(2 * math.pi,ModuleResult,"Module not properly seamed.")
end)

--[[
Runs unit tests for the InjectEnvironmentVariables method to simulate a DataStore error.
--]]
NexusUnitTesting:RegisterUnitTest("InjectEnvironmentVariables_DataStoreSimulatedFailure",function(UnitTest)
	local ProperErrorWarned = false
	
	--Create the fake DataStore.
	local FakeDataStoreInjector = DependencyInjector.CreateOverridder()
	FakeDataStoreInjector:WhenCalled("GetAsync"):ThenCall(function()
		error("HTTP Service 503: Simulated error.")
	end)
	local FakeDataStore = DependencyInjector.Inject({},FakeDataStoreInjector)
	
	--Create the fake DataStoreService.
	local DataStoreServiceInjector = DependencyInjector.CreateOverridder()
	DataStoreServiceInjector:WhenCalled("GetGlobalDataStore"):ThenReturn(FakeDataStore)
	local FakeDataStoreService = DependencyInjector.Inject({},DataStoreServiceInjector)
	
	--Create the fake game.
	local GameInjector = DependencyInjector.CreateOverridder()
	GameInjector:WhenIndexed("GetService"):ThenReturn(function(_,Index)
		if Index == "DataStoreService" then
			return FakeDataStoreService
		end
	end)
	local FakeGame = DependencyInjector.Inject({},GameInjector)
	
	--Create the main injector.
	local Injector = DependencyInjector.CreateOverridder()
	Injector:WhenIndexed("game"):ThenReturn(FakeGame)
	Injector:WhenCalled("warn"):ThenCall(function(Warning)
		if string.match(Warning,"HTTP Service 503: Simulated error.") then
			ProperErrorWarned = true
		end
	end)
	
	
	--Create an inject the function.
	local function Test()
		local Worked,Return = pcall(function()
			return game:GetService("DataStoreService"):GetGlobalDataStore():GetAsync("Thing")
		end)
		
		if not Worked then
			warn("Failed because "..Return)
		end
	end
	DependencyInjector.InjectEnvironmentVariables(Test,Injector)
	
	--Run the assertions.
	Test()
	UnitTest:AssertTrue(ProperErrorWarned,"Error not warned.")
end)

--[[
Runs unit tests for the InjectEnvironmentVariables method to simulate a cloned Workspace.
--]]
NexusUnitTesting:RegisterUnitTest("InjectEnvironmentVariables_SimulatedWorkspace",function(UnitTest)
	--Create the fake Workspace and Baseplate
	local FakeWorkspace = Instance.new("Folder")
	FakeWorkspace.Name = "Workspace"
	
	local FakeBaseplate = game.Workspace.Baseplate:Clone()
	FakeBaseplate.Parent = FakeWorkspace
	
	--Create the fake game.
	local GameInjector = DependencyInjector.CreateOverridder()
	GameInjector:WhenIndexed("Workspace"):ThenReturn(FakeWorkspace)
	GameInjector:WhenIndexed("GetService"):ThenReturn(function(_,Index)
		if Index == "Workspace" then
			return FakeWorkspace
		end
	end)
	local FakeGame = DependencyInjector.Inject({},GameInjector)
	
	--Create the main injector.
	local Injector = DependencyInjector.CreateOverridder()
	Injector:WhenIndexed("game"):ThenReturn(FakeGame)
	
	--Create an inject the function.
	local function Test()
		local Workspace = game:GetService("Workspace")
		local Baseplate = Workspace:WaitForChild("Baseplate")
		Baseplate.BrickColor = BrickColor.new("Bright red")
		
		UnitTest:AssertEquals(Baseplate.BrickColor,BrickColor.new("Bright red"),"Color not changed")
		game.Workspace.Baseplate.BrickColor = BrickColor.new("Bright blue")
		UnitTest:AssertEquals(Baseplate.BrickColor,BrickColor.new("Bright blue"),"Color not changed")
	end
	DependencyInjector.InjectEnvironmentVariables(Test,Injector)
	
	--Run the assertions.
	Test()
	UnitTest:AssertNotEquals(game.Workspace.Baseplate.BrickColor,BrickColor.new("Bright blue"),"Actual baseplate's color changed.")
	UnitTest:AssertEquals(FakeBaseplate.BrickColor,BrickColor.new("Bright blue"),"Fake baseplate's color not changed.")
end)



--Return true so there is no error with loading the ModuleScript.
return true