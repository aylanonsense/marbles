import "level/object/LevelObject"
import "physics/PhysCircle"
import "render/camera"
import "render/imageCache"
import "utility/soundCache"
import "scene/time"
import "utility/diagnosticStats"
import "config"
import "effect/effects"

class("CircleBumper").extends("LevelObject")

local pitches = { 0.95, 0.9, 0.82, 0.85, 0.93, 0.89, 0.81, 1.00, 0.94, 0.80 }
local pitchIndex = 1

function CircleBumper:init(x, y)
  CircleBumper.super.init(self, LevelObject.Type.CircleBumper)
  self.highlightFrames = 0
  self.image = imageCache.loadImageTable("images/level/objects/circular-bumper.png")
  self.bumpSound = soundCache.createSoundEffectPlayer("sound/sfx/bumper")
  self.bumpSound:setVolume(config.SOUND_VOLUME)
  self:addPhysicsObject(PhysCircle(x, y, 25))
end

function CircleBumper:update()
  self.highlightFrames = math.max(0, self.highlightFrames - 1)
end

function CircleBumper:draw()
  local x, y = self:getPosition()
  x, y = camera.matrix:transformXY(x, y)
  local scale = camera.scale
  local rotation = -camera.rotation
  self.image[(self.highlightFrames > 0) and 2 or 1]:drawRotated(x, y, rotation, scale, scale)
  diagnosticStats.transformedImagesDrawn += 1
end

function CircleBumper:addPhysicsObject(physObj)
  physObj.restitution = 1.0
  return CircleBumper.super.addPhysicsObject(self, physObj)
end

function CircleBumper:preCollide(other, collision)
  other:scaleVelocity(0.3)
  collision.impulse = 0.2 * collision.impulse + 275
  self.highlightFrames = 15
  effects:shake(3, collision.normalX, collision.normalY)
  collision.tag = "bumper"
  pitchIndex = (pitchIndex % #pitches) + 1
  self.bumpSound:setRate(pitches[pitchIndex])
  self.bumpSound:play(1)
end

function CircleBumper:serialize()
  return CircleBumper.super.serialize(self)
end

function CircleBumper.deserialize(data)
  local bumper = CircleBumper(data.x, data.y)
  if data.layer then
    bumper.layer = data.layer
  end
  return bumper
end
