import "level/object/LevelObject"
import "physics/PhysPoint"
import "physics/PhysLine"
import "render/camera"
import "render/imageCache"
import "scene/time"
import "utility/diagnosticStats"

class("TriangleBumper").extends("LevelObject")

function TriangleBumper:init(x, y, flippedHorizontal, flippedVertical)
  TriangleBumper.super.init(self, LevelObject.Type.TriangleBumper)
  self.flippedHorizontal = flippedHorizontal or false
  self.flippedVertical = flippedVertical or false
  self.image = imageCache.loadImage("images/level/objects/triangle-bumper.png")
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
  self.image:drawRotated(x, y, rotation, scale, scale)
  diagnosticStats.transformedImagesDrawn += 1
end

function TriangleBumper:addPhysicsObject(physObj)
  physObj.restitution = 1.0
  return TriangleBumper.super.addPhysicsObject(self, physObj)
end

function TriangleBumper:preCollide(other, collision)
  other:scaleVelocity(0.3)
  collision.impulse = 0.2 * collision.impulse + 300
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
