import "CoreLibs/object"
import "utility/CallbackHandler"

class("Process").extends("CallbackHandler")

function Process:init()
	Process.super.init(self)
end

function Process:start(...) end

function Process:update() end
function Process:draw() end
function Process:pause() end
function Process:unpause() end

function Process:output(...)
	if self.parentProcess then
		self.parentProcess:handleChildProcessOutput(self, ...)
	end
end

function Process:terminate()
	if self.parentProcess then
		self.parentProcess:handleChildProcessTerminated(self)
	end
end

function Process:spawnProcess(process, ...)
	if self.parentProcess then
		self.parentProcess:handleProcessSpawned(process, self, ...)
	end
end
