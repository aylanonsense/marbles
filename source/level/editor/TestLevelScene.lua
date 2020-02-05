import "render/camera"
import "scene/Scene"
import "level/levelIO"
import "physics/physics"
import "physics/PhysBall"
import "physics/PhysPoint"
import "physics/PhysLine"

class("TestLevelScene").extends(Scene)

function TestLevelScene:init(levelInfo, nextScene)
	TestLevelScene.super.init(self)
	self.nextScene = nextScene
	self.initialCameraSettings = {
		x = camera.position.x,
		y = camera.position.y,
		scale = camera.scale,
		rotation = camera.rotation
	}

	-- Reset everything
	camera:reset()
	camera:recalculatePerspective()
	physics:reset()

	-- Load the level
	local levelData = loadPlayableLevelData(levelInfo)
	self.ball = PhysBall(levelData.spawn.x, levelData.spawn.y, 15):add()
	for _, geom in ipairs(levelData.geometry) do
		if geom.type == "Polygon" then
			for _, obj in ipairs(geom.physics) do
				if obj.type == "Line" then
					PhysLine(obj.x1, obj.y1, obj.x2, obj.y2):add()
				elseif obj.type == "Point" then
					PhysPoint(obj.x, obj.y):add()
				end
			end
		end
	end
end

function TestLevelScene:update()
	-- Clear the screen
	playdate.graphics.clear()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)

	-- Set the balls' gravity to be relative to the current perspective
	for i = 1, #physics.balls do
		physics.balls[i].acceleration.x, physics.balls[i].acceleration.y = -5000 * camera.up.x, -5000 * camera.up.y
	end

	-- Update the physics engine and do all collisions
	physics:update()

	-- Rotating the crank rotates the camera
	camera.rotation = playdate.getCrankPosition()

	-- Move the camera to be looking at the ball
	camera.position.x, camera.position.y = self.ball.position.x, self.ball.position.y
	camera:recalculatePerspective()
end

function TestLevelScene:draw()
	-- Clear the screen
	playdate.graphics.clear()
	playdate.graphics.setColor(playdate.graphics.kColorBlack)

	-- Draw all physics objects
	physics:draw()
end

function TestLevelScene:BButtonDown()
	-- Progress to the next scene
	if self.nextScene then
		camera.position.x, camera.position.y = self.initialCameraSettings.x, self.initialCameraSettings.y
		camera.scale = self.initialCameraSettings.scale
		camera.rotation = self.initialCameraSettings.rotation
		camera:recalculatePerspective()
		Scene.setScene(self.nextScene)
	end
end
