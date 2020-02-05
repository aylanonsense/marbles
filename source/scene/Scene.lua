import "CoreLibs/object"
import "utility/CallbackHandler"

class("Scene").extends("CallbackHandler")

scene = nil

function Scene.setScene(s)
	if scene then
		scene:onStop()
	end
	scene = s
	scene:onStart()
end

function Scene:update() end
function Scene:draw() end
function Scene:onStart() end
function Scene:onStop() end
