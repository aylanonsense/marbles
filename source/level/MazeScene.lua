import "render/camera"
import "scene/Scene"
import "physics/physics"
import "level/object/levelObjectByType"
import "level/object/Marble"
import "utility/soundCache"

class("MazeScene").extends(Scene)

function MazeScene:init(levelData)
  MazeScene.super.init(self)

  self.levelData = levelData
  self.objects = {}
  self.worldBoundary = nil
  self.marble = nil
  self.isLoaded = false
  self.lastLoadedObjectIndex = 0

  -- Reset everything
  camera:reset()
  camera:recalculatePerspective()
  physics:reset()
  playdate.graphics.clear()

  -- Add a physics callback
  physics:onCollide(function(collision)
    self:onCollide(collision)
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
    else
      -- And finally sort the physics sectors
      physics:sortSectors()
      self.isLoaded = true
    end
  end
end

function MazeScene:update()
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
    camera.rotation = math.min(math.max(-45, camera.rotation + crankChange / 2), 45)

    -- Move the camera to be looking at the ball
    camera.x, camera.y = self.marble:getPosition()
    camera:recalculatePerspective()
  end
end

function MazeScene:draw()
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
      obj:draw()
    end
  end
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

function MazeScene:triggerExitTaken(exit)
  for _, obj in ipairs(self.objects) do
    if obj.type == LevelObject.Type.Exit then
      obj.isInvincible = true
    end
  end
  soundCache:stopAllSoundEffects()
  self:endScene(exit)
end
