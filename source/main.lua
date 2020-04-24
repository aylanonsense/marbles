import "scene/time"
import "scene/Scene"
import "CoreLibs/keyboard"
import "game/Game"
import "level/editor/EditorScene"

local LAUNCH_LEVEL_EDITOR = true

-- Set default drawing options
playdate.graphics.setBackgroundColor(playdate.graphics.kColorWhite)

-- Set up the gane (globally accessible)
if LAUNCH_LEVEL_EDITOR then
  Scene.setScene(EditorScene())
else
  game = Game()
end

-- Update the scene
function playdate.update()
	time:advance(1 / 20)
  if scene then
  	scene:update()
  	scene:draw()
  end
  playdate.drawFPS(380, 10)
end

-- Pass callbacks through to the scene
function playdate.AButtonDown(...) scene:AButtonDown(...) end
function playdate.AButtonHeld(...) scene:AButtonHeld(...) end
function playdate.AButtonUp(...) scene:AButtonUp(...) end
function playdate.BButtonDown(...) scene:BButtonDown(...) end
function playdate.BButtonHeld(...) scene:BButtonHeld(...) end
function playdate.BButtonUp(...) scene:BButtonUp(...) end
function playdate.downButtonDown(...) scene:downButtonDown(...) end
function playdate.downButtonHeld(...) scene:downButtonHeld(...) end
function playdate.downButtonUp(...) scene:downButtonUp(...) end
function playdate.leftButtonDown(...) scene:leftButtonDown(...) end
function playdate.leftButtonHeld(...) scene:leftButtonHeld(...) end
function playdate.leftButtonUp(...) scene:leftButtonUp(...) end
function playdate.rightButtonDown(...) scene:rightButtonDown(...) end
function playdate.rightButtonHeld(...) scene:rightButtonHeld(...) end
function playdate.rightButtonUp(...) scene:rightButtonUp(...) end
function playdate.upButtonDown(...) scene:upButtonDown(...) end
function playdate.upButtonHeld(...) scene:upButtonHeld(...) end
function playdate.upButtonUp(...) scene:upButtonUp(...) end
function playdate.cranked(...) scene:cranked(...) end
function playdate.keyPressed(...) scene:keyPressed(...) end
function playdate.keyReleased(...) scene:keyReleased(...) end
function playdate.debugDraw(...) scene:debugDraw(...) end
function playdate.keyboard.keyboardDidShowCallback(...) scene:keyboardDidShowCallback(...) end
function playdate.keyboard.keyboardDidHideCallback(...) scene:keyboardDidHideCallback(...) end
function playdate.keyboard.keyboardWillHideCallback(...) scene:keyboardWillHideCallback(...) end
function playdate.keyboard.keyboardAnimatingCallback(...) scene:keyboardAnimatingCallback(...) end
function playdate.keyboard.textChangedCallback(...) scene:keyboardTextChangedCallback(...) end
