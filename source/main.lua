import "physics/Circle"

-- Set initial state
playdate.graphics.setBackgroundColor(playdate.graphics.kColorWhite)

-- Create a circle
local circle = Circle(10, 10, 10)
circle.velocity.x = 10
circle.acceleration.y = 10000

function playdate.update()
	playdate.graphics.clear()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	circle:update(1 / 20)
	circle:draw()
end
