import "render/camera"
import "scene/Scene"
import "level/levelIO"
import "physics/physics"
import "level/object/levelObjectByType"
import "level/object/Marble"
import "utility/soundCache"
import "utility/diagnosticStats"

class("EditorTestLevelScene").extends(Scene)

function EditorTestLevelScene:init(levelInfo, nextScene, storyline)
	EditorTestLevelScene.super.init(self)
	soundCache.stopAllSoundEffects()
	self.nextScene = nextScene
	self.initialCameraSettings = {
		x = camera.x,
		y = camera.y,
		scale = camera.scale,
		rotation = camera.rotation
	}
	self.objects = {}
	self.worldBoundary = nil
	self.marble = nil

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
  local wasInserted = false
  self.marble = Marble(levelData.spawn.x, levelData.spawn.y)
  for i = 1, #self.objects do
    if self.objects[i].layer > self.marble.layer then
      table.insert(self.objects, i, self.marble)
      wasInserted = true
      break
    end
  end
  if not wasInserted then
    table.insert(self.objects, self.marble)
  end
	self.storyline = storyline
	physics:sortSectors()
end

function EditorTestLevelScene:update()
	diagnosticStats:update()
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
			self.objects[i]:onDespawn()
			table.remove(self.objects, i)
		end
	end

	-- Rotating the crank rotates the camera
    local crankChange = playdate.getCrankChange()
    local crankRotation = playdate.getCrankPosition()
    crankRotation = (crankRotation + 180) % 360
    local minAngle = 3
    local maxAngle = 85
    local maxBufferAngle = 120
    local idealCameraRotation
    if crankRotation <= minAngle or crankRotation >= 360 - minAngle then
      idealCameraRotation = 0
    elseif crankRotation <= maxAngle then
      idealCameraRotation = 45 * (crankRotation - minAngle) / (maxAngle - minAngle)
    elseif crankRotation >= 360 - maxAngle then
      idealCameraRotation = -45 * (1 - (crankRotation - 360 + maxAngle) / (360 - minAngle - 360 + maxAngle))
    elseif crankRotation <= maxBufferAngle then
      idealCameraRotation = 45
    elseif crankRotation >= 360 - maxBufferAngle then
      idealCameraRotation = -45
    elseif camera.rotation > 25 then
      idealCameraRotation = 45
    elseif camera.rotation < -25 then
      idealCameraRotation = -45
    else
      idealCameraRotation = camera.rotation
    end
    local cameraRotationDiff = math.abs(camera.rotation - idealCameraRotation)
    if cameraRotationDiff < 0.5 and idealCameraRotation < 45 and idealCameraRotation > -45 then
      -- Don't do anything, to prevent flickering rotation
    elseif cameraRotationDiff < 1 then
      camera.rotation = idealCameraRotation
    else
      change = math.min(math.max(1, 0.75 * cameraRotationDiff), 15)
      if camera.rotation < idealCameraRotation then
        camera.rotation += change
      else
        camera.rotation -= change
      end
    end

	-- Move the camera to be looking at the ball
	camera.x, camera.y = self.marble:getPosition()
	camera:recalculatePerspective()
end

function EditorTestLevelScene:draw()
	-- Clear the screen
	playdate.graphics.clear()

	-- If there's a world boundary, render a bit differently
	if self.worldBoundary then
		if self.worldBoundary.fillPattern ~= 'Transparent' then
			-- Fill the whole screen
			playdate.graphics.setPattern(patterns[self.worldBoundary.fillPattern])
			playdate.graphics.fillRect(-10, -10, camera.screenWidth + 20, camera.screenHeight + 20)
		end

		-- Draw the WorldBoundary, which'll cut out a white area
		self.worldBoundary:draw()
	end

	-- Draw all level objects
	for _, obj in ipairs(self.objects) do
		obj:draw()
	end
	diagnosticStats:draw()
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
		camera.x, camera.y = self.initialCameraSettings.x, self.initialCameraSettings.y
		camera.scale = self.initialCameraSettings.scale
		camera.rotation = self.initialCameraSettings.rotation
		camera:recalculatePerspective()
		soundCache.stopAllSoundEffects()
		Scene.setScene(self.nextScene)
	end
end
