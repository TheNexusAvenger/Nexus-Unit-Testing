--[[
TheNexusAvenger

Sandboxes requiring ModuleScripts to prevent caching.
--]]
--!strict

local ScriptEditorService = game:GetService("ScriptEditorService")

local NexusEvent = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("Event"):WaitForChild("NexusEvent"))

local ModuleSandbox = {}
ModuleSandbox.__index = ModuleSandbox

export type ModuleSandbox = {
    new: (BaseSandbox: ModuleSandbox?) -> (ModuleSandbox),

    BaseSandbox: ModuleSandbox?,
    ModuleLoaded: NexusEvent.NexusEvent<>,
    GetModule: (self: ModuleSandbox, Module: ModuleScript) -> (boolean, ModuleScript?),
    RequireModule: (self: ModuleSandbox, Module: ModuleScript, EnvironmentOverrides: {[string]: any}?) -> (any),
}



--[[
Creates a module sandbox object.
--]]
function ModuleSandbox.new(BaseSandbox: ModuleSandbox?): ModuleSandbox
    return (setmetatable({
        BaseSandbox = BaseSandbox,
        ModulesLoaded = {},
        CachedModules = {},
        ModuleLoaded = NexusEvent.new(),
    }, ModuleSandbox) :: any) :: ModuleSandbox
end

--[[
Gets a module. Returns if a module existed
and what it returned.
--]]
function ModuleSandbox:GetModule(Module: ModuleScript): (boolean, ModuleScript?)
    --Wait for a module to load.
    if self.ModulesLoaded[Module] == false then
        while self.ModulesLoaded[Module] == false do
            self.ModuleLoaded:Wait()
        end
    end
    
    --Return the loaded module.
    if self.ModulesLoaded[Module] then
        return true, self.CachedModules[Module]
    end
    
    --Return the base's return.
    if self.BaseSandbox then
        return self.BaseSandbox:GetModule(Module)
    end
    
    --Return false (not loaded).
    return false, nil
end

--[[
Requires a module.
--]]
function ModuleSandbox:RequireModule(Module: ModuleScript, EnvironmentOverrides: {[string]: any}?): any
    EnvironmentOverrides = EnvironmentOverrides or {}
    
    --Return an existing value.
    local WasLoaded,ExistingReturn = self:GetModule(Module)
    if WasLoaded then
        return ExistingReturn
    end
    
    --Throw an error if it isn't a ModuleScript.
    if typeof(Module) ~= "Instance" or not Module:IsA("ModuleScript") then
        error(tostring(Module).." is not a ModuleScript.")
    end
    
    --Load the ModuleScript.
    self.ModulesLoaded[Module] = false
    local BaseEnvironment = getfenv()
    local Environment = setmetatable({},{
        __index = function(_, Index: string): any
            --Return the base override.
            local Override = (EnvironmentOverrides :: {[string]: any})[Index]
            if Override then
                return Override
            end
            
            --Return the override internal.
            if Index == "script" then
                return Module
            elseif Index == "require" then
                return function(Module)
                    return self:RequireModule(Module,EnvironmentOverrides)
                end
            else
                return BaseEnvironment[Index]
            end
        end
    })
    
    --Modify the source.
    local IsArchivable = Module.Archivable
    Module.Archivable = true
    local ClonedModule = Module:Clone()
    _G[ClonedModule] = Environment
    ClonedModule.Source = "local function Load() "..ScriptEditorService:GetEditorSource(ClonedModule).."\nend\n\nsetfenv(Load,_G[script])\n_G[script] = nil\nreturn Load()"

    --Reset the Archivable value.
    Module.Archivable = IsArchivable
    ClonedModule.Archivable = IsArchivable

    --Require the module.
    local BaseRequire = getfenv()["BaseRequire"]
    if BaseRequire then
        self.CachedModules[Module] = BaseRequire(ClonedModule)
    else
        self.CachedModules[Module] = require(ClonedModule) :: any
    end
    
    --Set it as loaded.
    self.ModulesLoaded[Module] = true
    self.ModuleLoaded:Fire()
    
    --Return the loaded module.
    return self.CachedModules[Module]
end



return ModuleSandbox