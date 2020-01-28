import "process/Process"

class("ManagingProcess").extends("Process")

function ManagingProcess:init(...)
	ManagingProcess.super.init(self, ...)
	self.activeChildProcesses = {}
end

function ManagingProcess:handleChildProcessOutput(...) end

function ManagingProcess:handleChildProcessTerminated() end

function ManagingProcess:handleProcessSpawned(process, spawningProcess, ...)
	if self.parentProcess then
		self.parentProcess:handleProcessSpawned(process, spawningProcess, ...)
	end
end

function ManagingProcess:update(...)
	self:handleCallback("update", ...)
end

function ManagingProcess:draw(...)
	self:handleCallback("draw", ...)
end

function ManagingProcess:pause(...)
	self:handleCallback("pause", ...)
end

function ManagingProcess:unpause(...)
	self:handleCallback("unpause", ...)
end

function ManagingProcess:handleCallback(callbackName, ...)
	for _, process in ipairs(self.activeChildProcesses) do
		process[callbackName](process, ...)
	end
end
