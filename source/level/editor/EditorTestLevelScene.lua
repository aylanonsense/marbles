import "render/camera"
import "scene/Scene"
import "level/levelIO"
import "physics/physics"
import "level/object/levelObjectByType"
import "level/object/Marble"

class("EditorTestLevelScene").extends(Scene)

function EditorTestLevelScene:init(levelInfo, nextScene, storyline)
	EditorTestLevelScene.super.init(self)
	self.nextScene = nextScene
	self.initialCameraSettings = {
		x = camera.position.x,
		y = camera.position.y,
		scale = camera.scale,
		rotation = camera.rotation
	}
	self.objects = {}
	self.worldBoundary = nil
	self.marble = nil
	self.score = 0

	-- Reset everything
	camera:reset()
	camera:recalculatePerspective()
	physics:reset()

	-- Add a physics callback
	physics:onCollide(function(collision)
		self:onCollide(collision)
	end)

	-- Load the level
	local levelData = loadPlayableLevelData(levelInfo)
	for _, objectData in ipairs(levelData.objects) do
		local obj = levelObjectByType[objectData.type].deserialize(objectData)
		if obj.type == LevelObject.Type.WorldBoundary then
			self.worldBoundary = obj
		else
			table.insert(self.objects, obj)
		end
	end
	self.marble = Marble(levelData.spawn.x, levelData.spawn.y)
	table.insert(self.objects, self.marble)
	self.storyline = storyline
end

function EditorTestLevelScene:update()
	-- Update the physics engine
	physics:update()

	-- Update all level objects
	if self.worldBoundary then
		self.worldBoundary:update()
	end
	for _, obj in ipairs(self.objects) do
		obj:update()
	end

	-- Remove despawned objects
	for i = #self.objects, 1, -1 do
		if self.objects[i].waitingToDespawn then
			table.remove(self.objects, i)
			self.objects[i]:onDespawn()
		end
	end

	-- Rotating the crank rotates the camera
	local crankChange = playdate.getCrankChange()
	camera.rotation = math.min(math.max(-45, camera.rotation + crankChange / 2), 45)

	-- Move the camera to be looking at the ball
	camera.position.x, camera.position.y = self.marble:getPosition()
	camera:recalculatePerspective()
end

function EditorTestLevelScene:draw()
	-- Clear the screen
	playdate.graphics.clear()

	-- If there's a world boundary, render a bit differently
	if self.worldBoundary then
		-- Fill the whole screen with checkerboard
		playdate.graphics.setPattern(patterns.Checkerboard)
		playdate.graphics.fillRect(-10, -10, camera.screenWidth + 20, camera.screenHeight + 20)

		-- Draw the WorldBoundary, which'll cut out a white area
		self.worldBoundary:draw()
	end

	-- Draw all level objects
	for _, obj in ipairs(self.objects) do
		obj:draw()
	end

	-- Draw the score
	local text = self.score .. ""
	local textWidth, textHeight = playdate.graphics.getTextSize(text)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.graphics.fillRect(camera.screenWidth - textWidth - 6, 2, textWidth + 4, textHeight + 2)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.drawText(text, camera.screenWidth - textWidth - 4, 2)
end

function EditorTestLevelScene:onCollide(collision)
	local levelObjA = collision.objectA:getParent()
	local levelObjB = collision.objectB:getParent()
	local shouldContinueA = levelObjA:preCollide(levelObjB, collision, true)
	local shouldContinueB = levelObjB:preCollide(levelObjA, collision, false)
	if shouldContinueA ~= false and shouldContinueB ~= false then
		collision:handle()
		levelObjA:onCollide(levelObjB, collision, true)
		levelObjB:onCollide(levelObjA, collision, false)
	end
end

function EditorTestLevelScene:BButtonDown()
	-- Progress to the next scene
	if self.nextScene then
		camera.position.x, camera.position.y = self.initialCameraSettings.x, self.initialCameraSettings.y
		camera.scale = self.initialCameraSettings.scale
		camera.rotation = self.initialCameraSettings.rotation
		camera:recalculatePerspective()
		Scene.setScene(self.nextScene)
	end
end
