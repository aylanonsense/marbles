import "physics/physics"
import "physics/Ball"
import "physics/Circle"
import "physics/Line"
import "physics/Arc"
import "utility/math"

playdate.graphics.setBackgroundColor(playdate.graphics.kColorWhite)

-- Define some methods to add physics objects to the game
function addNewBall(x, y, radius)
	local ball = Ball(x or randomInt(20, 380), y or 20, radius or randomInt(5, 20))
	ball.restitution = 1.0
	ball.acceleration.y = 10000
	ball.mass = (ball.radius / 10) ^ 2
	ball:add()
	return ball
end
function addNewCircle(x, y, radius)
	local circle = Circle(x or randomInt(0, 400), y or randomInt(90, 240), radius or randomInt(10, 30))
	circle:add()
	return circle
end
function addNewLine(x1, y1, x2, y2)
	local line = Line(x1 or randomInt(0, 400), y1 or randomInt(90, 240), x2 or randomInt(0, 400), y2 or randomInt(90, 240))
	line:add()
	return line
end
function addNewArc(x, y, radius, startAngle, endAngle)
	local arc = Arc(x or randomInt(0, 400), y or randomInt(90, 240), radius or randomInt(40, 80), startAngle or randomInt(0, 360), endAngle  or randomInt(0, 360))
	arc.facing = Arc.Inwards
	arc:add()
	return arc
end

-- Add a bunch of physics objects
addNewBall(30, 30, 10)
addNewCircle(27, 140, 10)
addNewCircle(60, 100, 10)
addNewLine(110, 160, 190, 80)
addNewArc(70, 180, 45, 140, 270)
addNewCircle(250, 185, 50)
addNewArc(310, 70, 60, 350, 220)

function playdate.update()
	-- Clear the screen
	playdate.graphics.clear()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)

	-- Update the physics engine
	physics:update(1 / 20)

	-- Draw all the physics objects
	physics:draw()

	-- Draw some debug info
  playdate.drawFPS(10, 10)
end

-- Whenever A or B are pressed, add a new ball to the game
function playdate.AButtonDown()
	addNewBall()
end
function playdate.BButtonDown()
	addNewBall()
end
