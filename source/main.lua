import "render/camera"
import "physics/physics"
import "physics/Ball"
import "physics/Line"
import "physics/Arc"
import "physics/Point"
import "physics/Circle"

playdate.graphics.setBackgroundColor(playdate.graphics.kColorWhite)

-- Create a level out of physics objects
Arc(-10, 100, 40, 270, 90):add()
Line(30, 100, 100, 80):add()
Line(100, 80, 140, 90):add()
Line(140, 90, 120, -20):add()
Line(120, -20, 160, -30):add()
Line(160, -30, 130, -90):add()
Line(130, -90, 60, -100):add()
Line(60, -100, -30, -90):add()
Line(-30, -90, -40, -50):add()
Line(-40, -50, -60, -50):add()
Arc(-110, -50, 50, 270, 90):add().facing = Arc.Inwards
Line(-160, -50, -140, -10):add()
Line(-140, -10, -150, 60):add()
Line(-150, 60, -90, 40):add()
Line(-90, 40, -140, 80):add()
Line(-140, 80, -110, 100):add()
Line(-110, 100, -50, 100):add()
Circle(40, 0, 20):add()
Point(100, 80):add()
Point(120, -20):add()
Point(-40, -50):add()
Point(-60, -50):add()
Point(-140, -10):add()
Point(-90, 40):add()

-- Create a ball
local ball = Ball(0, 0, 15):add()
ball.restitution = 0.8

function playdate.update()
	-- Clear the screen
	playdate.graphics.clear()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)

	-- Set the ball's gravity to be relative to the current perspective
	for i = 1, #physics.balls do
		physics.balls[i].acceleration.x, physics.balls[i].acceleration.y = -5000 * camera.up.x, -5000 * camera.up.y
	end

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
