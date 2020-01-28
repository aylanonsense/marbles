import "process/ManagingProcess"

class("ProcessPipe").extends("ManagingProcess")

function ProcessPipe:init(pipe)
	ProcessPipe.super.init(self)
	self.pipe = pipe
	self.currentProcessIndex = 1
	for _, process in ipairs(self.pipe) do
		process.parentProcess = self
	end
	self.activeChildProcesses[1] = self:getCurrentProcess()
end

function ProcessPipe:start(...)
	if #self.pipe > 0 then
		self:getCurrentProcess():start(...)
	else
		self:terminate()
	end
end

function ProcessPipe:getCurrentProcess()
	return self.pipe[self.currentProcessIndex]
end

function ProcessPipe:handleChildProcessOutput(...)
	self:getCurrentProcess():pause()
	if self.currentProcessIndex < #self.pipe then
		self.currentProcessIndex += 1
		self.activeChildProcesses[1] = self:getCurrentProcess()
		self:getCurrentProcess():start(...)
	else
		self:output(...)
	end
end

function ProcessPipe:handleChildProcessTerminated()
	if self.currentProcessIndex > 1 then
		self.currentProcessIndex -= 1
		self.activeChildProcesses[1] = self:getCurrentProcess()
		self:getCurrentProcess():unpause()
	else
		self:terminate()
	end
end
