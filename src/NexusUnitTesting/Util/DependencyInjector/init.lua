--[[
TheNexusAvenger

Handles "dependency injection" (global variable overriding) for tables, functions,
and ModuleScripts. Note that ModuleScripts require a Studio Plugin or Command Line
context to be able to be run.
--]]

local DependencyInjector = {}

local OverriderClass = require(script:WaitForChild("OverriderClass"))



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------            "STATIC" METHODS            --------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--[[
Injects a table with a reference table. Returns the injected table.
--]]
function DependencyInjector.Inject(ReferenceTable,Injector)
	local NewTable = {}

	--Creates a wrapper for calling a function.
	local function WrapFunction(BaseFunction,Index)
		return function(...)
			--Get the override.
			local Parameters = {...}
			local OverrideCall = Injector:GetCallOverride(Index,Parameters)
			
			--If an override call exists, run the override call.
			if OverrideCall then
				return OverrideCall:GetReturn(...)
			end
			
			--Call the base function.
			return BaseFunction(...)
		end
	end
	
	--Create the environment.
    setmetatable(NewTable,{ 
        __index = function(self,Index)
			--Handle the index being overriden.
			local Overridereturn = Injector:GetIndexOverride(Index)
			if Overridereturn and Overridereturn:HasOverride() then
				local ReturnValue = Overridereturn:GetOverride()
				
				--Handle the index call being overriden.
				if type(ReturnValue) == "function" then
					return WrapFunction(ReturnValue,Index)
				end
				
				return ReturnValue
			end
			
			--Handle the index call being overriden.
			local ReturnValue = ReferenceTable[Index]
			if type(ReturnValue) == "function" or Injector:GetCallOverride(Index) then
				return WrapFunction(ReturnValue,Index)
			end
			
			--Return the base environment's index.
			return ReturnValue
		end
    })

	return NewTable
end

--[[
Injects a table or function's environment/global variables.
--]]
function DependencyInjector.InjectEnvironmentVariables(ObjectToInject,Injector)
	--Create the environment.
	local BaseEnvironment = getfenv()
	local InjectedEnvironment = DependencyInjector.Inject(BaseEnvironment,Injector)
	
	--Set the environment.
	setfenv(ObjectToInject,InjectedEnvironment)
end

--[[
Injects a ModuleScript with an injector. If no injector is
given, a default one is used that replaces require with this
method and changes the script reference. If an id is given,
an error will be thrown.
]]
function DependencyInjector.Require(ModuleScript,Injector)
	--If the ModuleScript is an id, display an error.
	if type(ModuleScript) == "number" then
		error("Unable to inject a module by id. Please use the InsertService and pass the inserted module.")
	end
	
	--Clone the module.
	local NewModuleScript = ModuleScript:Clone()
	
	--Create a default dependency injector for script.
	if not Injector then
		Injector = DependencyInjector.CreateOverrider()
	end
	local NewInjector = Injector:Clone()
	
	--Add script injection if not already done.
	if not NewInjector:GetIndexOverride("script") then
		NewInjector:WhenIndexed("script"):ThenReturn(ModuleScript)
	end
	
	--Add require injection if not already done.
	if not NewInjector:GetIndexOverride("require") and not NewInjector:GetCallOverride("require") then
		--Injector:WhenIndexed("require"):ThenReturn(DependencyInjector.Require)
		NewInjector:WhenIndexed("require"):ThenReturn(function(ModuleScript)
			return DependencyInjector.Require(ModuleScript,Injector)
		end)
	end
	
    --Forward everything but wait calls to the original env
	local function BuildFieldEnvironment(InjectedFunction)
		DependencyInjector.InjectEnvironmentVariables(InjectedFunction,NewInjector)
	end
	
	--Set up the field environments.
	if not _G.NexusDependencyInjection then
		_G.NexusDependencyInjection = {}
	end
	_G.NexusDependencyInjection[NewModuleScript] = BuildFieldEnvironment
	
	--Create the injection code.
	local ScriptInjectionStart = [[
	function InjectedModule()
	]]
	
	local ScriptInjectionEnd = [[
	end
	
	_G.NexusDependencyInjection[script](InjectedModule)
	
	return InjectedModule()
	]]
	
	--Add the injection code.
	ScriptInjectionStart = string.gsub(ScriptInjectionStart,"\n"," ")
	ScriptInjectionStart = string.gsub(ScriptInjectionStart,"\t","")
	ScriptInjectionEnd = string.gsub(ScriptInjectionEnd,"\n"," ")
	ScriptInjectionEnd = string.gsub(ScriptInjectionEnd,"\t","")
	NewModuleScript.Source = ScriptInjectionStart.." "..NewModuleScript.Source.."\n"..ScriptInjectionEnd
	
	--Require the module.
	return require(NewModuleScript)
end

--[[
Creates a dependency injector.
]]
function DependencyInjector.CreateOverrider()
	return OverriderClass.new()
end




return DependencyInjector