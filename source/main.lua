import "scene/DemoScene"

playdate.graphics.setBackgroundColor(playdate.graphics.kColorWhite)

local scene = DemoScene()

function playdate.update()
	scene:update(1 / 20)
	scene:draw()
end

function playdate.AButtonDown()
	scene:AButtonDown()
end

function playdate.BButtonDown()
	scene:BButtonDown()
end
