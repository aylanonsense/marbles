import "level/editor/LevelEditorScene"

playdate.graphics.setBackgroundColor(playdate.graphics.kColorWhite)

local scene = LevelEditorScene()

function playdate.update()
	scene:update(1 / 20)
	scene:draw()
end

-- Pass callbacks through to the scene (TODO switch over to pushing input handlers)
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
