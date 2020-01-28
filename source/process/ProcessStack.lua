import "process/ManagingProcess"

class("ProcessStack").extends("ManagingProcess")

function ProcessStack:init(process)
	ProcessStack.super.init(self)
	self.stack = {}
	if process then
		self:pushProcess(process)
	end
end

function ProcessStack:pushProcess(process, ...)
	if #self.stack > 0 then
		self:getCurrentProcess():pause()
	end
	process.parentProcess = self
	table.insert(self.stack, process)
	self.activeChildProcesses[1] = self:getCurrentProcess()
	self:getCurrentProcess():start(...)
end

function ProcessStack:popProcess()
	table.remove(self.stack)
	if #self.stack > 0 then
		self.activeChildProcesses[1] = self:getCurrentProcess()
		self:getCurrentProcess():unpause()
	else
		self:terminate()
	end
end

function ProcessStack:start(...)
	if #self.stack > 0 then
		self:getCurrentProcess():start(...)
	else
		self:terminate()
	end
end

function ProcessStack:handleChildProcessOutput(...) end

function ProcessStack:handleChildProcessTerminated()
	self:popProcess()
end

function ProcessStack:handleProcessSpawned(process, spawningProcess, ...)
	self:pushProcess(process, ...)
end

function ProcessStack:getCurrentProcess()
	if #self.stack > 0 then
		return self.stack[#self.stack]
	end
end
