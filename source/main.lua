print("Lost Your Marbles v"..playdate.metadata.version)

import "scene/time"
import "scene/Scene"
import "CoreLibs/keyboard"
import "game/Game"
import "config"
import "utility/diagnosticStats"
import "CoreLibs/timer"
import "effect/effects"

-- TODO: remove this import before final build
-- import "level/editor/EditorScene"

-- Set default drawing options
playdate.graphics.setBackgroundColor(playdate.graphics.kColorWhite)

-- Set up the game (globally accessible)
-- if config.LAUNCH_LEVEL_EDITOR then
--   Scene.setScene(EditorScene())
-- else
  game = Game()
-- end

local prevTime = playdate.getCurrentTimeMilliseconds()

-- Update the scene
function playdate.update()
  local currTime = playdate.getCurrentTimeMilliseconds()
  local dt
  if config.FRAME_RATE_INDEPENDENT then
    dt = ((currTime - prevTime) / 1000)
  else
    dt = 1 / 30
  end
  time:advance(dt)
  effects:update()
  diagnosticStats:update()
  if scene then
    if effects.freezeFrames <= 0 then
      scene:update()
    end
  	scene:draw()
  end
  if effects.freezeFrames <= 0 then
    playdate.timer.updateTimers()
  end
  prevTime = currTime
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
