import "render/camera"
import "physics/physics"
import "physics/Ball"
import "physics/Line"
import "physics/Arc"
import "physics/Point"
import "physics/Circle"

playdate.graphics.setBackgroundColor(playdate.graphics.kColorWhite)

local timer = 0

-- Create a level out of physics objects
local movingPlatform = {}
Arc(-10, 100, 40, 270, 90):add()
Line(30, 100, 100, 80):add()
Line(100, 80, 140, 90):add()
Line(140, 90, 120, -70):add()
Line(120, -70, 160, -80):add()
Line(160, -80, 130, -140):add()
Line(130, -140, 60, -150):add()
Line(60, -150, -30, -140):add()
Line(-30, -140, -40, -100):add()
Line(-40, -100, -60, -100):add()
Arc(-110, -100, 50, 270, 90):add().facing = Arc.Inwards
Line(-160, -100, -140, -60):add()
Line(-140, -60, -150, 60):add()
Line(-150, 60, -90, 40):add()
Line(-90, 40, -140, 80):add()
Line(-140, 80, -110, 100):add()
Line(-110, 100, -50, 100):add()
table.insert(movingPlatform, Line(-40, -60, 40, -60):add())
table.insert(movingPlatform, Line(40, -60, 60, -40):add())
table.insert(movingPlatform, Line(60, -40, -40, -40):add())
table.insert(movingPlatform, Line(-40, -40, -40, -60):add())
local blinkingCircle = Circle(80, 40, 20):add()
Point(100, 80):add()
Point(120, -70):add()
Point(-40, -100):add()
Point(-60, -100):add()
Point(-140, -60):add()
Point(-90, 40):add()
table.insert(movingPlatform, Point(-40, -60):add())
table.insert(movingPlatform, Point(40, -60):add())
table.insert(movingPlatform, Point(60, -40):add())
table.insert(movingPlatform, Point(-40, -40):add())

-- Create a ball
local ball = Ball(0, 0, 15):add()
ball.restitution = 0.8

function playdate.update()
	timer += 1 / 20

	-- Clear the screen
	playdate.graphics.clear()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)

	-- Set the ball's gravity to be relative to the current perspective
	for i = 1, #physics.balls do
		physics.balls[i].acceleration.x, physics.balls[i].acceleration.y = -5000 * camera.up.x, -5000 * camera.up.y
	end

	-- Make the parts of the moving platform oscillate back and forth
	for i = 1, #movingPlatform do
		movingPlatform[i].velocity.x = 40 * math.cos(timer)
	end

	-- Make the blinking circle pop in and out of existence
	blinkingCircle.isEnabled = timer % 4 < 2

	-- Update the physics engine and do all collisions
	physics:update(1 / 20)

	-- Rotating the crank rotates the camera
	camera.rotation = playdate.getCrankPosition()

	-- Move the camera to be looking at the ball
	camera.position.x, camera.position.y = ball.position.x, ball.position.y
	camera:recalculatePerspective()

	-- Draw all the physics objects
	physics:draw()

	-- Draw some debug info
  playdate.drawFPS(10, 10)
end

-- Press A or B to add more balls to the scene
function addAnotherBall()
	local anotherBall = Ball(0, 0, 10):add()
	anotherBall.mass = 0.5
	anotherBall.restitution = 0.8
end
function playdate.AButtonDown()
	addAnotherBall()
end
function playdate.BButtonDown()
	addAnotherBall()
end
