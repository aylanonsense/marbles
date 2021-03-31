import "render/camera"
import "scene/Scene"
import "scene/sceneTransition"
import "physics/physics"
import "level/object/levelObjectByType"
import "level/object/Marble"
import "utility/soundCache"
import "utility/diagnosticStats"
import "config"
import "CoreLibs/ui"
import "scene/time"
import "effect/effects"
import "fonts/fonts"
import "level/object/Booster"

class("MazeScene").extends(Scene)

local hasPlayedAMazeBefore = false

function MazeScene:init(levelData, prompt, musicPlayer)
  MazeScene.super.init(self)

  self.levelData = levelData
  self.objects = {}
  self.blankLoadFrames = 64
  self.worldBoundary = nil
  self.marble = nil
  self.isLoaded = false
  self.lastLoadedObjectIndex = 0
  self.musicPlayer = musicPlayer
  self.slowtimeFramesLeft = 0
  self.isCameraLocked = false
  self.framesUntilTransitionOut = 0
  self.finalExitData = nil
  self.prompt = prompt
  if self.prompt then
    playdate.graphics.setFont(fonts.MarbleBasic)
    self.promptWidth, self.promptHeight = playdate.graphics.getTextSize(self.prompt)
  end
  self.hideCrankIndicatorFrames = hasPlayedAMazeBefore and 200 or 110

  hasPlayedAMazeBefore = true

  -- Reset everything
  camera:reset()
  camera:recalculatePerspective()
  physics:reset()
  playdate.graphics.clear()

  -- Add a physics callback
  physics:onCollide(function(collision)
    self:onCollide(collision)
  end)
  sceneTransition:hold()

  -- Reset the crank animation
  playdate.ui.crankIndicator:start()

  playdate.getSystemMenu():addMenuItem("title screen", function()
    self:endScene(nil, nil, nil, true)
  end)
end

function MazeScene:partialLoad()
  if not self.isLoaded then
    self.lastLoadedObjectIndex += 1
    if self.lastLoadedObjectIndex <= #self.levelData.objects then
      -- Load each object individually
      local objectData = self.levelData.objects[self.lastLoadedObjectIndex]
      local obj = levelObjectByType[objectData.type].deserialize(objectData)
      if obj.type == LevelObject.Type.WorldBoundary then
        self.worldBoundary = obj
      else
        table.insert(self.objects, obj)
      end
    elseif not self.marble then
      -- Create the marble
      local wasInserted = false
      self.marble = Marble(self.levelData.spawn.x, self.levelData.spawn.y)
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
    elseif self.blankLoadFrames > 0 then
      self.blankLoadFrames -= 1
    else
      -- And finally sort the physics sectors
      physics:sortSectors()
      self.isLoaded = true
      sceneTransition:transitionIn()
      if self.musicPlayer then
        self.musicPlayer:play(0)
      end
    end
  end
end

function MazeScene:update()
  Booster.updateSoundCombo()
  self.hideCrankIndicatorFrames = math.max(0, self.hideCrankIndicatorFrames - 1)
  if self.slowtimeFramesLeft > 0 then
    self.slowtimeFramesLeft -= 1
    if self.slowtimeFramesLeft <= 0 then
      time:transitionTimeScale(1.00)
    end
  end
  if not self.isLoaded then
    for i = 1, 2 do
      self:partialLoad()
    end
  end
  if self.isLoaded then
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
    if not self.isCameraLocked then
      camera.x, camera.y = self.marble:getPosition()
    end
  end
  if self.framesUntilTransitionOut > 0 then
    self.framesUntilTransitionOut -= 1
    if self.framesUntilTransitionOut <= 0 then
      sceneTransition:transitionOut(function()
        soundCache.stopAllSoundEffects()
        self:endScene(self.finalExitData)
      end)
    end
  end
  sceneTransition:update()
end

function MazeScene:draw()
  if not config.BACKWARDS_COMPATIBILITY_MODE then
    playdate.graphics.setDrawOffset(0, 20)
  end
  camera.x += effects.screenShakeX
  camera.y += effects.screenShakeY
  camera:recalculatePerspective()
  if self.isLoaded then
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
      if obj:isOnScreen() then
        obj:draw()
      end
    end
  end
  -- Draw the crank hint indicator
  if not config.BACKWARDS_COMPATIBILITY_MODE then
    playdate.graphics.setDrawOffset(0, 0)
  end
  if playdate.isCrankDocked() and self.hideCrankIndicatorFrames <= 0 and not self.finalExitData then
    playdate.ui.crankIndicator:update()
  end
  if self.prompt then
    playdate.graphics.setColor(playdate.graphics.kColorWhite)
    playdate.graphics.fillRect(0, 0, 400, self.promptHeight + 7)
    playdate.graphics.drawText(self.prompt, 200 - self.promptWidth / 2, 5)
  end
  sceneTransition:draw()
  if config.DEBUG_MODE_ENABLED then
    diagnosticStats:draw()
  end
  camera.x -= effects.screenShakeX
  camera.y -= effects.screenShakeY
end

function MazeScene:onCollide(collision)
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

function MazeScene:triggerExitHit(exitData, exit, collision)
  if exit.health >= 2 then
    time:setTimescale(0.03)
    self.slowtimeFramesLeft = 45
    effects:freeze(5)
    effects:shake(2, collision.normalX, collision.normalY)
  elseif exit.health >= 1 then
    time:setTimescale(0.25)
    self.slowtimeFramesLeft = 3
    effects:freeze(3)
    effects:shake(2, collision.normalX, collision.normalY)
  else
    time:setTimescale(0.15)
    self.slowtimeFramesLeft = 25
    self.isCameraLocked = true
    effects:freeze(5)
    effects:shake(4, collision.normalX, collision.normalY)
  end
end

function MazeScene:triggerExitTaken(exitData, exit, collision)
  for _, obj in ipairs(self.objects) do
    if obj.type == LevelObject.Type.Exit then
      obj.isInvincible = true
    end
  end
  self.finalExitData = exitData
  self.framesUntilTransitionOut = 105
end
