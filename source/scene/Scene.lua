import "CoreLibs/object"
import "utility/CallbackHandler"

class("Scene").extends("CallbackHandler")

scene = nil

function Scene.setScene(s, onEndScene)
	scene = s
  scene.onEndSceneCallback = onEndScene
end

function Scene:update() end
function Scene:draw() end
function Scene:endScene(...)
  if self.onEndSceneCallback then
    self.onEndSceneCallback(...)
  end
end
