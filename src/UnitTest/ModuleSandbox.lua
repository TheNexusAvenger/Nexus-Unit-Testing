--[[
TheNexusAvenger

Sandboxes requiring ModuleScripts to prevent caching.
--]]

local NexusInstance = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("NexusInstance"))
local NexusEvent = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("Event"):WaitForChild("NexusEvent"))

local ModuleSandbox = NexusInstance:Extend()
ModuleSandbox:SetClassName("ModuleSandbox")



--[[
Creates a module sandbox object.
--]]
function ModuleSandbox:__new(BaseSandbox)
    NexusInstance.__new(self)
    
    --Store the state.
    self.BaseSandbox = BaseSandbox
    self.ModulesLoaded = {}
    self.CachedModules = {}
    
    --Create the events.
    self.ModuleLoaded = NexusEvent.new()
end

--[[
Gets a module. Returns if a module existed
and what it returned.
--]]
function ModuleSandbox:GetModule(Module)
    --Wait for a module to load.
    if self.ModulesLoaded[Module] == false then
        while self.ModulesLoaded[Module] == false do
            self.ModuleLoaded:Wait()
        end
    end
    
    --Return the loaded module.
    if self.ModulesLoaded[Module] then
        return true,self.CachedModules[Module]
    end
    
    --Return the base's return.
    if self.BaseSandbox then
        return self.BaseSandbox:GetModule(Module)
    end
    
    --Return false (not loaded).
    return false,nil
end

--[[
Requires a module.
--]]
function ModuleSandbox:RequireModule(Module,EnvironmentOverrides)
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
        __index = function(_,Index)
            --Return the base override.
            local Override = EnvironmentOverrides[Index]
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
    ClonedModule.Source = "local function Load() "..ClonedModule.Source.."\nend\n\nsetfenv(Load,_G[script])\n_G[script] = nil\nreturn Load()"

    --Reset the Archivable value.
    Module.Archivable = IsArchivable
    ClonedModule.Archivable = IsArchivable

    --Require the module.
    local BaseRequire = getfenv()["BaseRequire"]
    if BaseRequire then
        self.CachedModules[Module] = BaseRequire(ClonedModule)
    else
        self.CachedModules[Module] = require(ClonedModule)
    end
    
    --Set it as loaded.
    self.ModulesLoaded[Module] = true
    self.ModuleLoaded:Fire()
    
    --Return the loaded module.
    return self.CachedModules[Module]
end



return ModuleSandbox