import "CoreLibs/object"
import "utility/CallbackHandler"

class("Scene").extends("CallbackHandler")

scene = nil

function Scene.setScene(s, onEndScene)
	scene = s
  scene.onEndSceneCallback = onEndScene
  scene.hasEndedScene = false
end

function Scene:update() end
function Scene:draw() end
function Scene:endScene(...)
  if not self.hasEndedScene and self.onEndSceneCallback then
    self.hasEndedScene = true
    self.onEndSceneCallback(...)
  end
end
