import "level/object/LevelObject"
import "physics/PhysPoint"
import "physics/PhysLine"
import "render/camera"
import "render/imageCache"
import "utility/soundCache"
import "scene/time"
import "utility/diagnosticStats"
import "config"
import "effect/effects"

class("CrumblingPlatform").extends("LevelObject")

local CRUMBLE_TIME = 2.0

function CrumblingPlatform:init(x, y)
  CrumblingPlatform.super.init(self, LevelObject.Type.CrumblingPlatform)
  self.x, self.y = x, y
  self.image = imageCache.loadImageTable("images/level/objects/crumbling-platform.png")
  self.crumbleSound = soundCache.createSoundEffectPlayer("sound/sfx/crumbling-platform")
  self.crumbleSound:setVolume(0.4 * config.SOUND_VOLUME)
  self.crumbleSound:setRate(0.6)
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
    if #self.physObjects > 0 and self.crumbleTime < 0.3 * CRUMBLE_TIME then
      self:clearPhysObjects()
    end
    if self.crumbleTime <= 0 then
      self:despawn()
    end
  end
end

function CrumblingPlatform:draw()
  local x, y = camera.matrix:transformXY(self.x, self.y)
  local scale = camera.scale
  local frame
  if self.crumbleTime >= CRUMBLE_TIME then
    frame = 1
  else
    frame = math.min(11, 11 - math.floor(10 * self.crumbleTime / CRUMBLE_TIME))
  end
  self.image[frame]:drawRotated(x, y, -camera.rotation, scale)
  diagnosticStats.transformedImagesDrawn += 1
end

function CrumblingPlatform:preCollide(other, collision)
  if not self.isCrumbling then
    self.isCrumbling = true
    self.crumbleSound:play(1)
    effects:shake(3, collision.normalX, collision.normalY)
    collision.tag = "platform-crumble"
  end
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
