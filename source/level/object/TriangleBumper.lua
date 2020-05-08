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

class("TriangleBumper").extends("LevelObject")

local pitches = { 0.88, 1.00, 0.89, 0.80, 0.97, 0.84, 0.84, 0.99, 0.89, 0.97 }
local pitchIndex = 1

function TriangleBumper:init(x, y, flippedHorizontal, flippedVertical)
  TriangleBumper.super.init(self, LevelObject.Type.TriangleBumper)
  self.flippedHorizontal = flippedHorizontal or false
  self.flippedVertical = flippedVertical or false
  self.highlightFrames = 0
  self.image = imageCache.loadImageTable("images/level/objects/triangular-bumper.png")
  self.bumpSound = soundCache.createSoundEffectPlayer("sound/sfx/bumper")
  self.bumpSound:setVolume(config.SOUND_VOLUME)
  local x1, y1, x2, y2, x3, y3
  if self.flippedHorizontal and self.flippedVertical then
    x1, y1 = x + 30, y - 30
    x2, y2 = x - 30, y + 30
    x3, y3 = x - 30, y - 30
  elseif self.flippedHorizontal then
    x1, y1 = x - 30, y - 30
    x2, y2 = x + 30, y + 30
    x3, y3 = x - 30, y + 30
  elseif self.flippedVertical then
    x1, y1 = x + 30, y + 30
    x2, y2 = x - 30, y - 30
    x3, y3 = x + 30, y - 30
  else
    x1, y1 = x - 30, y + 30
    x2, y2 = x + 30, y - 30
    x3, y3 = x + 30, y + 30
  end
  self:addPhysicsObject(PhysPoint(x1, y1))
  self:addPhysicsObject(PhysPoint(x2, y2))
  self:addPhysicsObject(PhysPoint(x3, y3))
  self:addPhysicsObject(PhysLine(x1, y1, x2, y2))
  self:addPhysicsObject(PhysLine(x2, y2, x3, y3)).lowPriority = true
  self:addPhysicsObject(PhysLine(x3, y3, x1, y1)).lowPriority = true
end

function TriangleBumper:update()
  self.highlightFrames = math.max(0, self.highlightFrames - 1)
end

function TriangleBumper:draw()
  local x, y = self:getPosition()
  x, y = camera.matrix:transformXY(x, y)
  local scale = camera.scale
  local rotation = -camera.rotation
  if self.flippedHorizontal and self.flippedVertical then
    rotation += 180
  elseif self.flippedHorizontal then
    rotation += 90
  elseif self.flippedVertical then
    rotation -= 90
  end
  self.image[(self.highlightFrames > 0) and 2 or 1]:drawRotated(x, y, rotation, scale, scale)
  diagnosticStats.transformedImagesDrawn += 1
end

function TriangleBumper:addPhysicsObject(physObj)
  physObj.restitution = 1.0
  return TriangleBumper.super.addPhysicsObject(self, physObj)
end

function TriangleBumper:preCollide(other, collision)
  other:scaleVelocity(0.3)
  collision.impulse = 0.2 * collision.impulse + 300
  self.highlightFrames = 15
  effects:shake(3, collision.normalX, collision.normalY)
  collision.tag = "bumper"
  pitchIndex = (pitchIndex % #pitches) + 1
  self.bumpSound:setRate(pitches[pitchIndex])
  self.bumpSound:play(1)
end

function TriangleBumper:getEditableFields()
  return {
    {
      label = "Flip Horizontal",
      field = "flippedHorizontal",
      change = function(dir)
        self.flippedHorizontal = not self.flippedHorizontal
      end
    },
    {
      label = "Flip Vertical",
      field = "flippedVertical",
      change = function(dir)
        self.flippedVertical = not self.flippedVertical
      end
    }
  }
end

function TriangleBumper:serialize()
  local data = TriangleBumper.super.serialize(self)
  data.flippedHorizontal = self.flippedHorizontal
  data.flippedVertical = self.flippedVertical
  return data
end

function TriangleBumper.deserialize(data)
  local bumper = TriangleBumper(data.x, data.y, data.flippedHorizontal, data.flippedVertical)
  if data.layer then
    bumper.layer = data.layer
  end
  return bumper
end
