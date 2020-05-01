import "level/object/LevelObject"
import "physics/PhysPoint"
import "physics/PhysLine"
import "render/camera"
import "render/imageCache"
import "scene/time"
import "utility/diagnosticStats"

class("CrumblingPlatform").extends("LevelObject")

local CRUMBLE_TIME = 1.0

function CrumblingPlatform:init(x, y)
  CrumblingPlatform.super.init(self, LevelObject.Type.CrumblingPlatform)
  self.image = imageCache.loadImageTable("images/crumbling-platform.png")
  self:addPhysicsObject(PhysPoint(x - 20, y - 20))
  self:addPhysicsObject(PhysPoint(x - 20, y + 20))
  self:addPhysicsObject(PhysPoint(x + 20, y - 20))
  self:addPhysicsObject(PhysPoint(x + 20, y + 20))
  self:addPhysicsObject(PhysLine(x + 20, y - 20, x + 20, y + 20))
  self:addPhysicsObject(PhysLine(x + 20, y + 20, x - 20, y + 20))
  self:addPhysicsObject(PhysLine(x - 20, y + 20, x - 20, y - 20))
  self:addPhysicsObject(PhysLine(x - 20, y - 20, x + 20, y - 20))
  self.isCrubling = false
  self.crumbleTime = CRUMBLE_TIME
end

function CrumblingPlatform:update()
  if self.isCrumbling then
    self.crumbleTime -= time.dt
    if self.crumbleTime <= 0 then
      self:despawn()
    end
  end
end

function CrumblingPlatform:draw()
  local x, y = self:getPosition()
  x, y = camera.matrix:transformXY(x, y)
  local scale = camera.scale
  local frame
  if self.crumbleTime >= CRUMBLE_TIME then
    frame = 1
  else
    frame = math.min(4, 4 - math.floor(3 * self.crumbleTime / CRUMBLE_TIME))
  end
  self.image[frame]:drawRotated(x, y, -camera.rotation, scale)
  diagnosticStats.transformedImagesDrawn += 1
end

function CrumblingPlatform:preCollide(other, collision)
  self.isCrumbling = true
end

function CrumblingPlatform:serialize()
  return CrumblingPlatform.super.serialize(self)
end

function CrumblingPlatform.deserialize(data)
  local platform = CrumblingPlatform(data.x, data.y)
  if data.layer then
    platform.layer = data.layer
  end
  return platform
end
