--[[
Corecii and TheNexusAvenger

Work-around to allow xpcall to be yieldable. Modified
for use in Nexus Unit Testing.

Original: https://www.roblox.com/library/1070503396/tpcall-pcall-with-traceback
--]]

local LogService = game:GetService("LogService")
local HttpService = game:GetService("HttpService")

local CurrentErrorMessage
local CurrentErrorStackTrace
local ErrorThrownEvent = require(script.Parent.Parent:WaitForChild("NexusInstance"):WaitForChild("Event"):WaitForChild("LuaEvent")).new()
local RunnerBase = script:WaitForChild("Runner")
local MessageError,MessageInfo = Enum.MessageType.MessageError,Enum.MessageType.MessageInfo
local InactiveRunners = {}


--Set up the logging to get full stack traces.
--ScriptContext.Error caps the output, mainly for stack overflow.
LogService.MessageOut:Connect(function(Message,Type)
	if Type == MessageError then
		--Set the error message.
		CurrentErrorMessage = Message
	elseif Type == MessageInfo and CurrentErrorMessage ~= nil then
		--Add the output line.
		if CurrentErrorStackTrace == nil then
			CurrentErrorStackTrace = Message
		else
			CurrentErrorStackTrace = CurrentErrorStackTrace.."\n"..Message
		end
		
		--If "Stack End" is reached, signal the error.
		if Message == "Stack End" then
			ErrorThrownEvent:Fire(CurrentErrorMessage,CurrentErrorStackTrace)
			CurrentErrorMessage = nil
			CurrentErrorStackTrace = nil
		end
	end
end)



--[[
Returns a runner for the given scripts.
If no runner is open, creates a new one.
--]]
local function GetRunner()
	--Return an existing runner if one exists.
	if #InactiveRunners >= 1 then
		local Runner = InactiveRunners[#InactiveRunners]
		table.remove(InactiveRunners,#InactiveRunners)
		return Runner
	end
	
	--Create a new runner.
	local NewRunner = RunnerBase:Clone()
	NewRunner.Name = HttpService:GenerateGUID()
	return NewRunner
end



--[[
Custom implementation of a yieldable xpcall for Roblox.
--]]
local function yxpcall(Function,ErrorHandler,...)
	--Create the runner.
	local NewRunner = GetRunner()
	local UniqueId = NewRunner.Name
	
	--Set up the runner.
	local Runner = require(NewRunner)
	local BindableIn = Instance.new("BindableEvent")
	local BindableOut = Instance.new("BindableEvent")
	local InArgumentss = {...}
	local Success = true
	local OutArgumentss
	BindableIn.Event:Connect(function()
		--Get the output from running the script.
		OutArgumentss = {Runner(Function,unpack(InArgumentss))}
		
		--Signal the function is done (successful).
		BindableOut:Fire()
	end)
	
	--Set up error handling.
	local ErrorConnection
	ErrorConnection = ErrorThrownEvent:Connect(function(ErrorMessage,Traceback)
		--If the unique id is in the traceback, set it as failing.
		if Traceback:find(UniqueId,1,true) then
			--Set the 
			Success = false
			OutArgumentss = {
				ErrorMessage,
				Traceback
			}
			
			--Signal the function is done (errored).
			BindableOut:fire()
		end
	end)
	
	--Start the input.
	BindableIn:Fire()
	
	--[[
	Disconnects the events.
	--]]
	local function DisconnectEvents()
		--Disconnect the events.
		ErrorConnection:Disconnect()
		BindableIn:Destroy()
		BindableOut:Destroy()
		
		--Re-add the runner.
		table.insert(InactiveRunners,NewRunner)
	end
	
	--[[
	Runs the error handler if there was an error.
	--]]
	local function RunErrorHandler()
		if not Success then
			ErrorHandler(unpack(OutArgumentss))
		end
	end
	
	--If it finishes before a wait can be setup, return the output.
	if OutArgumentss then
		DisconnectEvents()
		RunErrorHandler()
		return Success,unpack(OutArgumentss)
	end
	
	--Wait for the function to complete.
	BindableOut.Event:wait()
	
	--Return the output.
	DisconnectEvents()
	RunErrorHandler()
	return Success,unpack(OutArgumentss)
end



return yxpcall